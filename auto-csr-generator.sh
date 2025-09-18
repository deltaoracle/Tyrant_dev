#!/bin/bash

# Fully Automated CSR Generator for Kubernetes
# This script creates a pod, generates CSR files, copies them locally, and cleans up

# Default parameters
NAMESPACE=${1:-"dev"}
POD_NAME=${2:-"csr-generator"}
OUTPUT_DIR=${3:-"./csr-files"}
DOMAIN=${4:-"revenue.ai"}
COUNTRY=${5:-"NL"}
STATE=${6:-"Gelderland"}
CITY=${7:-"Arnhem"}
ORGANIZATION=${8:-"Revenue.ai"}
ORGANIZATIONAL_UNIT=${9:-"IT"}

echo "=== Automated CSR Generator ==="
echo "Domain: $DOMAIN"
echo "Namespace: $NAMESPACE"
echo "Output Directory: $OUTPUT_DIR"

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "Error: kubectl is not installed or not in PATH"
        return 1
    fi
    return 0
}

# Function to create temporary pod manifest
create_pod_manifest() {
    local temp_file=$(mktemp)
    cat > "$temp_file" << EOF
apiVersion: v1
kind: Pod
metadata:
  name: $POD_NAME
  namespace: $NAMESPACE
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
EOF
    echo "$temp_file"
}

# Function to create CSR generation script
create_csr_script() {
    local script_file="generate-csr.sh"
    
    # Build the script content with proper variable substitution
    cat > "$script_file" << EOF
#!/bin/sh

# Create CSR directory
mkdir -p /csr

# Generate private key
echo "Generating private key..."
openssl genrsa -out /csr/private.key 2048

# Generate wildcard CSR
echo "Generating wildcard CSR..."
openssl req -new -key /csr/private.key -out /csr/certificate-wildcard.csr -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=*.$DOMAIN"

# List generated files
echo "Generated files:"
ls -la /csr/

# Show CSR content (first few lines)
echo "Wildcard CSR content:"
openssl req -in /csr/certificate-wildcard.csr -text -noout | head -20

echo "CSR generation complete!"
EOF
    
    echo "$script_file"
}

# Main execution
main() {
    # Check kubectl availability
    if ! check_kubectl; then
        exit 1
    fi

    # Create output directory
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
        echo "Created output directory: $OUTPUT_DIR"
    fi

    # Clean up any existing pod
    echo ""
    echo "1. Cleaning up any existing pod..."
    kubectl delete pod "$POD_NAME" -n "$NAMESPACE" --ignore-not-found=true --timeout=30s

    # Create temporary pod manifest
    echo ""
    echo "2. Creating pod manifest..."
    POD_MANIFEST=$(create_pod_manifest)

    # Apply pod manifest
    echo ""
    echo "3. Applying pod manifest..."
    kubectl apply -f "$POD_MANIFEST"

    # Wait for pod to be ready
    echo ""
    echo "4. Waiting for pod to be ready..."
    if ! kubectl wait --for=condition=Ready "pod/$POD_NAME" -n "$NAMESPACE" --timeout=300s; then
        echo "Error: Pod failed to become ready within timeout"
        exit 1
    fi

    # Create CSR generation script
    echo ""
    echo "5. Creating CSR generation script..."
    CSR_SCRIPT=$(create_csr_script)

    # Execute CSR generation directly in the pod
    echo ""
    echo "6. Executing CSR generation..."
    
    # Copy script to pod and execute
    echo "  Copying script to pod..."
    kubectl cp "$CSR_SCRIPT" "$NAMESPACE/$POD_NAME:/tmp/csr-generator.sh"
    
    # Verify script was copied successfully
    echo "  Verifying script copy..."
    if ! kubectl exec "$POD_NAME" -n "$NAMESPACE" -- test -f /tmp/csr-generator.sh; then
        echo "Error: Failed to copy script to pod. Script file not found in pod."
        exit 1
    fi
    echo "  ✓ Script successfully copied to pod"
    
    # Convert line endings to Unix format in the pod
    echo "  Converting line endings to Unix format..."
    kubectl exec "$POD_NAME" -n "$NAMESPACE" -- sed -i 's/\r$//' /tmp/csr-generator.sh
    
    # Make script executable
    echo "  Making script executable..."
    kubectl exec "$POD_NAME" -n "$NAMESPACE" -- chmod +x /tmp/csr-generator.sh
    
    # Verify script is executable
    if ! kubectl exec "$POD_NAME" -n "$NAMESPACE" -- test -x /tmp/csr-generator.sh; then
        echo "Error: Failed to make script executable in pod."
        exit 1
    fi
    echo "  ✓ Script is now executable"
    
    # Execute the script
    echo "  Executing CSR generation script..."
    
    # Debug: Check script content and permissions
    echo "  Debug: Checking script details..."
    kubectl exec "$POD_NAME" -n "$NAMESPACE" -- ls -la /tmp/csr-generator.sh
    kubectl exec "$POD_NAME" -n "$NAMESPACE" -- head -5 /tmp/csr-generator.sh
    
    # Try to execute with explicit shell
    echo "  Attempting to execute with explicit shell..."
    kubectl exec "$POD_NAME" -n "$NAMESPACE" -- sh /tmp/csr-generator.sh

    # Copy files from pod to local machine
    echo ""
    echo "7. Copying CSR files to local machine..."
    kubectl cp "$NAMESPACE/$POD_NAME:/csr/" "$OUTPUT_DIR"

    # Verify files were copied
    echo ""
    echo "8. Verifying copied files..."
    if [ -d "$OUTPUT_DIR" ]; then
        for file in "$OUTPUT_DIR"/*; do
            if [ -f "$file" ]; then
                echo "  - $(basename "$file")"
            fi
        done
    fi

    # Clean up pod
    echo ""
    echo "9. Cleaning up pod..."
    kubectl delete pod "$POD_NAME" -n "$NAMESPACE" --timeout=30s

    # Clean up temporary files
    rm -f "$POD_MANIFEST"
    # Note: CSR script is kept in current directory for reference

    echo ""
    echo "=== CSR Generation Complete ==="
    echo "Files generated in: $OUTPUT_DIR"
    echo "Files include:"
    echo "  - private.key (private key)"
    echo "  - certificate-wildcard.csr (wildcard CSR)"
}

# Error handling and cleanup
cleanup() {
    echo ""
    echo "Cleaning up on error..."
    kubectl delete pod "$POD_NAME" -n "$NAMESPACE" --ignore-not-found=true --timeout=30s
    
    # Clean up temporary files
    if [ -n "$POD_MANIFEST" ] && [ -f "$POD_MANIFEST" ]; then
        rm -f "$POD_MANIFEST"
    fi
    # Note: CSR script is kept in current directory for reference
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Run main function
main "$@" 