# Automated CSR Generation

This guide provides automated methods to generate Certificate Signing Requests (CSRs) using Kubernetes pods.

## Available Scripts

- `auto-csr-generator.ps1` - PowerShell script for Windows users
- `auto-csr-generator.sh` - Bash script for Linux/macOS users

Both scripts provide the same functionality and generate wildcard CSRs automatically.

## Quick Start

### For Windows Users (PowerShell)

```powershell
# Run with default parameters
.\auto-csr-generator.ps1

# Run with custom parameters
.\auto-csr-generator.ps1 -Namespace "prod" -Domain "example.com" -Country "US" -State "California" -City "San Francisco" -Organization "Example Corp" -OrganizationalUnit "IT"
```

### For Linux/macOS Users (Bash)

```bash
# Make script executable
chmod +x auto-csr-generator.sh

# Run with default parameters
./auto-csr-generator.sh

# Run with custom parameters
./auto-csr-generator.sh "prod" "csr-generator" "./csr-files" "example.com" "US" "California" "San Francisco" "Example Corp" "IT"
```

## What the Scripts Do

The automated scripts perform the following steps:

1. **Check Prerequisites**: Verify kubectl is installed and available
2. **Create Output Directory**: Create the specified output directory if it doesn't exist
3. **Clean Up Existing Resources**: Remove any existing CSR generator pods
4. **Deploy Pod**: Create a temporary pod with OpenSSL installed
5. **Wait for Pod Ready**: Ensure the pod is running and ready
6. **Generate CSR**: Execute CSR generation commands inside the pod
7. **Copy Files**: Copy generated files from the pod to your local machine
8. **Clean Up**: Remove the temporary pod and clean up resources

## Generated Files

The scripts generate the following files in your output directory:

- `private.key` - Private key (2048-bit RSA)
- `certificate-wildcard.csr` - Wildcard CSR for `*.yourdomain.com`

## Parameters

### PowerShell Script Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `Namespace` | `dev` | Kubernetes namespace |
| `PodName` | `csr-generator` | Name of the temporary pod |
| `OutputDir` | `./csr-files` | Local output directory |
| `Domain` | `revenue.ai` | Your domain name |
| `Country` | `NL` | Country code (2-letter) |
| `State` | `Gelderland` | State or province |
| `City` | `Arnhem` | City name |
| `Organization` | `Revenue.ai` | Organization name |
| `OrganizationalUnit` | `IT` | Organizational unit |

### Bash Script Parameters

The bash script accepts positional parameters in this order:

1. `NAMESPACE` (default: `dev`)
2. `POD_NAME` (default: `csr-generator`)
3. `OUTPUT_DIR` (default: `./csr-files`)
4. `DOMAIN` (default: `revenue.ai`)
5. `COUNTRY` (default: `NL`)
6. `STATE` (default: `Gelderland`)
7. `CITY` (default: `Arnhem`)
8. `ORGANIZATION` (default: `Revenue.ai`)
9. `ORGANIZATIONAL_UNIT` (default: `IT`)

## Examples

### Basic Usage

```bash
# PowerShell
.\auto-csr-generator.ps1

# Bash
./auto-csr-generator.sh
```

### Custom Domain and Organization

```bash
# PowerShell
.\auto-csr-generator.ps1 -Domain "mycompany.com" -Organization "My Company" -Country "US" -State "Texas" -City "Austin"

# Bash
./auto-csr-generator.sh "dev" "csr-generator" "./csr-files" "mycompany.com" "US" "Texas" "Austin" "My Company" "IT"
```

### Production Environment

```bash
# PowerShell
.\auto-csr-generator.ps1 -Namespace "prod" -Domain "production.com" -OutputDir "./prod-csr-files"

# Bash
./auto-csr-generator.sh "prod" "csr-generator" "./prod-csr-files" "production.com"
```

## Prerequisites

1. **kubectl**: Must be installed and configured
2. **Kubernetes Access**: Must have permissions to create pods in the target namespace
3. **Network Access**: Pod must be able to pull the Alpine Linux image

## Troubleshooting

### Common Issues

#### kubectl Not Found
```
Error: kubectl is not installed or not in PATH
```
**Solution**: Install kubectl and ensure it's in your PATH

#### Pod Fails to Start
```
Error: Pod failed to become ready within timeout
```
**Solution**: 
- Check namespace permissions: `kubectl auth can-i create pods -n dev`
- Check pod events: `kubectl describe pod csr-generator -n dev`
- Check pod logs: `kubectl logs csr-generator -n dev`

#### Script Copy Fails
```
Error: Failed to copy script to pod
```
**Solution**: 
- Verify pod is running: `kubectl get pods -n dev`
- Check pod status: `kubectl describe pod csr-generator -n dev`

#### Permission Denied
```
Error: Failed to make script executable in pod
```
**Solution**: This is usually a temporary issue. The script will retry automatically.

### Debug Information

The scripts provide detailed output including:
- Step-by-step progress
- Debug information about script copying and execution
- File verification steps
- Error messages with context

### Manual Verification

If you need to manually verify the process:

```bash
# Check if pod exists
kubectl get pods -n dev

# Check pod logs
kubectl logs csr-generator -n dev

# Execute into pod (if still running)
kubectl exec -it csr-generator -n dev -- /bin/sh

# List files in pod
kubectl exec csr-generator -n dev -- ls -la /csr/
```

## Security Considerations

1. **Private Key Security**: The private key is generated in the pod's temporary storage and copied to your local machine. Store it securely.
2. **Pod Cleanup**: The scripts automatically clean up the temporary pod after use.
3. **Key Size**: Uses 2048-bit RSA keys. Consider using 4096-bit for enhanced security in production.
4. **File Permissions**: Ensure the generated files have appropriate permissions on your local machine.

## Next Steps

After generating your CSR:

1. **Submit to CA**: Send the CSR file to your Certificate Authority
2. **Receive Certificate**: Get the signed certificate from your CA
3. **Install Certificate**: Install the certificate in your application
4. **Configure Application**: Update your application to use the certificate
5. **Test**: Verify the certificate works correctly

## Support

For issues or questions:

1. Check the script output for detailed error messages
2. Verify kubectl configuration: `kubectl config current-context`
3. Check namespace permissions: `kubectl auth can-i create pods -n dev`
4. Review pod logs if available: `kubectl logs csr-generator -n dev` 