# Azure Deployment for NixOS Shield

This directory contains the Azure deployment script for the NixOS Shield system configuration.

## Files

- `deploy-azure.sh` - Azure deployment script that uploads VHD and creates VM
- `default.nix` - NixOS system configuration for Shield
- `ssh/id_ed25519.pub` - SSH public key for the `opadmin` user

## Prerequisites

1. **Azure CLI** - Available in your Nix environment
2. **Azure Authentication** - Run `az login` before using the script
3. **VHD Image** - Build the Azure image first:
   ```bash
   nix build .#nixosConfigurations.shield.config.formats.azure
   ```

## Usage

### Basic Usage
```bash
./deploy-azure.sh
```

### With Custom Options
```bash
# Override VM name and location
./deploy-azure.sh -n my-shield-vm -l eastus

# Custom resource group and VM size
./deploy-azure.sh -g my-rg -z Standard_D2s_v3

# All options
./deploy-azure.sh \
  -s "your-subscription-id" \
  -g "custom-rg" \
  -a "customstorage" \
  -l "westus2" \
  -n "shield-vm" \
  -z "Standard_B4ms" \
  -v "/path/to/custom.vhd"
```

## Command Line Options

| Option | Long Form | Description | Default |
|--------|-----------|-------------|---------|
| `-s` | `--subscription` | Azure subscription ID | `cba69f50-0a97-4d1d-8272-17ec79b32a7e` |
| `-g` | `--resource-group` | Resource group name | `shield-nixos-rg` |
| `-a` | `--storage-account` | Storage account base name | `shieldnixosstorage` |
| `-l` | `--location` | Azure region | `westus` |
| `-n` | `--vm-name` | VM name | `nixos-shield-vm` |
| `-z` | `--vm-size` | VM size | `Standard_B2s` |
| `-v` | `--vhd-path` | Path to VHD file | `../../../result/nixos-image-azure-*.vhd` |
| `-h` | `--help` | Show help message | - |

## What the Script Does

1. **Sets Azure subscription** - Ensures you're working in the correct subscription
2. **Creates resource group** - Creates a new resource group for all resources
3. **Creates storage account** - Creates a storage account with timestamp for uniqueness
4. **Uploads VHD** - Uploads your NixOS VHD image as a page blob
5. **Creates managed disk** - Creates an Azure managed disk from the VHD
6. **Creates VM** - Creates a virtual machine using the managed disk
7. **Shows connection info** - Displays SSH connection details

## Connecting to Your VM

After deployment, connect via SSH:
```bash
ssh opadmin@$(az vm show -d -g shield-nixos-rg -n nixos-shield-vm --query publicIps -o tsv)
```

The VM is configured with:
- Username: `opadmin`
- SSH key authentication (no password)
- SSH key from `ssh/id_ed25519.pub`

## Cleanup

To delete all created resources:
```bash
az group delete --name shield-nixos-rg --yes --no-wait
```

## Notes

- Storage account names must be globally unique, so the script appends a timestamp
- VHD upload can take a significant amount of time depending on file size and connection
- The script assumes you're using Nix for package management (no tool installation checks)
- VM name changes automatically update related resource names (disk, VHD blob)