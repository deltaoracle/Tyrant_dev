# Fully Automated CSR Generator for Kubernetes
# This script creates a pod, generates CSR files, copies them locally, and cleans up

param(
    [string]$Namespace = "dev",
    [string]$PodName = "csr-generator",
    [string]$OutputDir = "./csr-files",
    [string]$Domain = "revenue.ai",
    [string]$Country = "NL",
    [string]$State = "Gelderland",
    [string]$City = "Arnhem",
    [string]$Organization = "Revenue.ai",
    [string]$OrganizationalUnit = "IT"
)

Write-Host "=== Automated CSR Generator ===" -ForegroundColor Green
Write-Host "Domain: $Domain" -ForegroundColor Cyan
Write-Host "Namespace: $Namespace" -ForegroundColor Cyan
Write-Host "Output Directory: $OutputDir" -ForegroundColor Cyan

# Function to check if kubectl is available
function Test-Kubectl {
    try {
        $null = kubectl version --client
        return $true
    }
    catch {
        Write-Host "Error: kubectl is not installed or not in PATH" -ForegroundColor Red
        return $false
    }
}

# Function to create temporary pod manifest
function New-TempPodManifest {
    $tempFile = [System.IO.Path]::GetTempFileName()
    $manifest = @"
apiVersion: v1
kind: Pod
metadata:
  name: $PodName
  namespace: $Namespace
spec:
  containers:
  - name: csr-generator
    image: alpine:latest
    command: ["/bin/sh"]
    args: ["-c", "apk add --no-cache openssl && tail -f /dev/null"]
    volumeMounts:
    - name: csr-volume
      mountPath: /csr
  volumes:
  - name: csr-volume
    emptyDir: {}
  restartPolicy: Never
"@
    Set-Content -Path $tempFile -Value $manifest
    return $tempFile
}

# Function to create CSR generation script
function New-CSRScript {
    $scriptFile = "generate-csr.sh"
    
    # Build the script content with proper variable substitution
    $scriptContent = @"
#!/bin/sh

# Create CSR directory
mkdir -p /csr

# Generate private key
echo "Generating private key..."
openssl genrsa -out /csr/private.key 2048

# Generate wildcard CSR
echo "Generating wildcard CSR..."
openssl req -new -key /csr/private.key -out /csr/certificate-wildcard.csr -subj "/C=$Country/ST=$State/L=$City/O=$Organization/OU=$OrganizationalUnit/CN=*.$Domain"

# List generated files
echo "Generated files:"
ls -la /csr/

# Show CSR content (first few lines)
echo "Wildcard CSR content:"
openssl req -in /csr/certificate-wildcard.csr -text -noout | head -20

echo "CSR generation complete!"
"@
    
    # Convert line endings to Unix format and write the file
    $scriptContent = $scriptContent -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($scriptFile, $scriptContent, [System.Text.Encoding]::UTF8)
    return $scriptFile
}

# Main execution
try {
    # Check kubectl availability
    if (-not (Test-Kubectl)) {
        exit 1
    }

    # Create output directory
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
        Write-Host "Created output directory: $OutputDir" -ForegroundColor Green
    }

    # Clean up any existing pod
    Write-Host "`n1. Cleaning up any existing pod..." -ForegroundColor Yellow
    kubectl delete pod $PodName -n $Namespace --ignore-not-found=true --timeout=30s

    # Create temporary pod manifest
    Write-Host "`n2. Creating pod manifest..." -ForegroundColor Yellow
    $podManifest = New-TempPodManifest

    # Apply pod manifest
    Write-Host "`n3. Applying pod manifest..." -ForegroundColor Yellow
    kubectl apply -f $podManifest

    # Wait for pod to be ready
    Write-Host "`n4. Waiting for pod to be ready..." -ForegroundColor Yellow
    kubectl wait --for=condition=Ready "pod/$PodName" -n $Namespace --timeout=300s

    if ($LASTEXITCODE -ne 0) {
        throw "Pod failed to become ready within timeout"
    }

    # Create CSR generation script
    Write-Host "`n5. Creating CSR generation script..." -ForegroundColor Yellow
    $csrScript = New-CSRScript

    # Execute CSR generation directly in the pod
    Write-Host "`n6. Executing CSR generation..." -ForegroundColor Yellow
    
    # Copy script to pod and execute
    Write-Host "  Copying script to pod..." -ForegroundColor Gray
    kubectl cp $csrScript "$Namespace/${PodName}:/tmp/csr-generator.sh"
    
    # Verify script was copied successfully
    Write-Host "  Verifying script copy..." -ForegroundColor Gray
    $scriptExists = kubectl exec $PodName -n $Namespace -- test -f /tmp/csr-generator.sh
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to copy script to pod. Script file not found in pod."
    }
    Write-Host "  ✓ Script successfully copied to pod" -ForegroundColor Green
    
    # Convert line endings to Unix format in the pod
    Write-Host "  Converting line endings to Unix format..." -ForegroundColor Gray
    kubectl exec $PodName -n $Namespace -- sed -i 's/\r$//' /tmp/csr-generator.sh
    
    # Make script executable
    Write-Host "  Making script executable..." -ForegroundColor Gray
    kubectl exec $PodName -n $Namespace -- chmod +x /tmp/csr-generator.sh
    
    # Verify script is executable
    $isExecutable = kubectl exec $PodName -n $Namespace -- test -x /tmp/csr-generator.sh
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to make script executable in pod."
    }
    Write-Host "  ✓ Script is now executable" -ForegroundColor Green
    
    # Execute the script
    Write-Host "  Executing CSR generation script..." -ForegroundColor Gray
    
    # Debug: Check script content and permissions
    Write-Host "  Debug: Checking script details..." -ForegroundColor Gray
    kubectl exec $PodName -n $Namespace -- ls -la /tmp/csr-generator.sh
    kubectl exec $PodName -n $Namespace -- head -5 /tmp/csr-generator.sh
    
    # Try to execute with explicit shell
    Write-Host "  Attempting to execute with explicit shell..." -ForegroundColor Gray
    kubectl exec $PodName -n $Namespace -- sh /tmp/csr-generator.sh

    # Copy files from pod to local machine
    Write-Host "`n7. Copying CSR files to local machine..." -ForegroundColor Yellow
    & kubectl cp "$Namespace/${PodName}:/csr/" $OutputDir

    # Verify files were copied
    Write-Host "`n8. Verifying copied files..." -ForegroundColor Yellow
    $files = Get-ChildItem -Path $OutputDir -Recurse
    foreach ($file in $files) {
        Write-Host "  - $($file.Name)" -ForegroundColor Gray
    }

    # Clean up pod
    Write-Host "`n9. Cleaning up pod..." -ForegroundColor Yellow
    kubectl delete pod $PodName -n $Namespace --timeout=30s

    # Clean up temporary files
    Remove-Item $podManifest -Force -ErrorAction SilentlyContinue
    # Note: CSR script is kept in current directory for reference

    Write-Host "`n=== CSR Generation Complete ===" -ForegroundColor Green
    Write-Host "Files generated in: $OutputDir" -ForegroundColor Cyan
    Write-Host "Files include:" -ForegroundColor Cyan
    Write-Host "  - private.key (private key)" -ForegroundColor Gray
    Write-Host "  - certificate-wildcard.csr (wildcard CSR)" -ForegroundColor Gray

}
catch {
    Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
    
    # Cleanup on error
    Write-Host "`nCleaning up on error..." -ForegroundColor Yellow
    kubectl delete pod $PodName -n $Namespace --ignore-not-found=true --timeout=30s
    
    # Clean up temporary files
    if ($podManifest -and (Test-Path $podManifest)) {
        Remove-Item $podManifest -Force -ErrorAction SilentlyContinue
    }
    # Note: CSR script is kept in current directory for reference
    
    exit 1
} 