#!/usr/bin/env bash
# vim: ts=2:sw=2:et

# Azure deployment script for NixOS VHD image
# Usage: ./deploy-azure.sh [OPTIONS] [ACTION]
# Actions: deploy (default), destroy
# Options:
#   -s, --subscription    Azure subscription ID
#   -g, --resource-group  Resource group name
#   -a, --storage-account Storage account name
#   -l, --location        Azure region
#   -n, --vm-name         VM name
#   -z, --vm-size         VM size
#   -v, --vhd-path        Path to VHD file
#   -o, --overwrite       Overwrite existing disk image
#   -h, --help            Show this help

set -euo pipefail

# Default configuration variables
SUBSCRIPTION="cba69f50-0a97-4d1d-8272-17ec79b32a7e"
RESOURCE_GROUP="shield-nixos-rg"
STORAGE_ACCOUNT="shieldnixosstorage"
LOCATION="westus"
CONTAINER_NAME="vhds"
VM_NAME="nixos-shield-vm"
VM_SIZE="Standard_B2s"
VHD_PATH="../../../result/nixos-image-azure-25.11.20250714.62e0f05-x86_64-linux.vhd"
OVERWRITE=false
ACTION="deploy"

# Generate timestamp for unique naming
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Functions

set_azure_subscription() {
    echo "🔑 Setting Azure subscription: $SUBSCRIPTION"
    az account set --subscription "$SUBSCRIPTION"
}

ensure_resource_group_exists() {
    echo "📦 Checking resource group: $RESOURCE_GROUP"
    if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
        echo "✅ Resource group exists"
    else
        echo "📦 Creating resource group: $RESOURCE_GROUP"
        az group create \
            --name "$RESOURCE_GROUP" \
            --location "$LOCATION"
    fi
}

ensure_storage_account_exists() {
    echo "💾 Checking storage account: $STORAGE_ACCOUNT"
    if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
        echo "✅ Storage account exists"
    else
        echo "💾 Creating storage account: $STORAGE_ACCOUNT"
        az storage account create \
            --resource-group "$RESOURCE_GROUP" \
            --name "$STORAGE_ACCOUNT" \
            --location "$LOCATION" \
            --sku Standard_LRS
    fi
}

get_storage_key() {
    echo "🔑 Getting storage account key"
    STORAGE_KEY=$(az storage account keys list \
        --resource-group "$RESOURCE_GROUP" \
        --account-name "$STORAGE_ACCOUNT" \
        --query '[0].value' -o tsv)
}

ensure_storage_container_exists() {
    echo "📁 Checking storage container: $CONTAINER_NAME"
    if az storage container show --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT" --account-key "$STORAGE_KEY" &>/dev/null; then
        echo "✅ Storage container exists"
    else
        echo "📁 Creating storage container: $CONTAINER_NAME"
        az storage container create \
            --name "$CONTAINER_NAME" \
            --account-name "$STORAGE_ACCOUNT" \
            --account-key "$STORAGE_KEY"
    fi
}

upload_vhd() {
    echo "⬆️  Uploading VHD file using azcopy (this may take a while)..."
    echo "VHD path: $VHD_PATH"
    echo "VHD name: $VHD_NAME"

    # Check if blob exists and handle overwrite
    if az storage blob exists --account-name "$STORAGE_ACCOUNT" --account-key "$STORAGE_KEY" --container-name "$CONTAINER_NAME" --name "$VHD_NAME" --query exists -o tsv | grep -q true; then
        if [[ "$OVERWRITE" == "true" ]]; then
            echo "🔄 Overwriting existing VHD blob"
        else
            echo "❌ VHD blob already exists. Use --overwrite to overwrite or choose a different name."
            exit 1
        fi
    fi

    # Build the destination URL
    BLOB_URL="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/${VHD_NAME}"
    
    # Use azcopy for faster upload with automatic retry and parallelization
    echo "🚀 Using azcopy for optimized upload..."
    azcopy copy "$VHD_PATH" "$BLOB_URL" \
        --blob-type PageBlob \
        --overwrite="$([[ "$OVERWRITE" == "true" ]] && echo "true" || echo "false")" \
        --log-level INFO

    echo "✅ VHD upload completed with azcopy"
}

create_managed_disk() {
    echo "💿 Creating managed disk: $DISK_NAME"
    VHD_URL="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/${VHD_NAME}"

    # Check if disk exists
    if az disk show --name "$DISK_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
        if [[ "$OVERWRITE" == "true" ]]; then
            echo "🔄 Deleting existing managed disk"
            az disk delete --name "$DISK_NAME" --resource-group "$RESOURCE_GROUP" --yes
        else
            echo "❌ Managed disk already exists. Use --overwrite to overwrite or choose a different name."
            exit 1
        fi
    fi

    az disk create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DISK_NAME" \
        --source "$VHD_URL"
}

create_vm() {
    echo "🖥️  Creating VM: $VM_NAME"

    # Check if VM exists
    if az vm show --name "$VM_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
        echo "❌ VM already exists: $VM_NAME"
        echo "Please destroy the existing VM first or choose a different name."
        exit 1
    fi

    az vm create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VM_NAME" \
        --attach-os-disk "$DISK_NAME" \
        --os-type linux \
        --size "$VM_SIZE"
}

show_vm_info() {
    echo "📋 Getting VM information..."
    VM_INFO=$(az vm show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VM_NAME" \
        --show-details \
        --output table)

    echo ""
    echo "🎉 Deployment completed successfully!"
    echo ""
    echo "VM Information:"
    echo "$VM_INFO"
    echo ""
    echo "To connect to your VM:"
    echo "ssh opadmin@\$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)"
}

deploy_vm() {
    echo "🚀 Starting Azure deployment for NixOS Shield VM..."

    set_azure_subscription
    ensure_resource_group_exists
    ensure_storage_account_exists
    get_storage_key
    ensure_storage_container_exists
    upload_vhd
    create_managed_disk
    create_vm
    show_vm_info
}

destroy_vm() {
    echo "💀 Starting destruction of Azure resources..."

    set_azure_subscription

    # Delete VM
    if az vm show --name "$VM_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
        echo "🗑️  Deleting VM: $VM_NAME"
        az vm delete --name "$VM_NAME" --resource-group "$RESOURCE_GROUP" --yes
    else
        echo "ℹ️  VM not found: $VM_NAME"
    fi

    # Delete managed disk
    if az disk show --name "$DISK_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
        echo "🗑️  Deleting managed disk: $DISK_NAME"
        az disk delete --name "$DISK_NAME" --resource-group "$RESOURCE_GROUP" --yes
    else
        echo "ℹ️  Managed disk not found: $DISK_NAME"
    fi

    # Get storage key for blob operations
    if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
        get_storage_key

        # Delete VHD blob
        if az storage blob exists --account-name "$STORAGE_ACCOUNT" --account-key "$STORAGE_KEY" --container-name "$CONTAINER_NAME" --name "$VHD_NAME" --query exists -o tsv | grep -q true; then
            echo "🗑️  Deleting VHD blob: $VHD_NAME"
            az storage blob delete --account-name "$STORAGE_ACCOUNT" --account-key "$STORAGE_KEY" --container-name "$CONTAINER_NAME" --name "$VHD_NAME"
        else
            echo "ℹ️  VHD blob not found: $VHD_NAME"
        fi

        # Delete storage container (only if empty)
        echo "🗑️  Attempting to delete storage container: $CONTAINER_NAME"
        az storage container delete --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT" --account-key "$STORAGE_KEY" || echo "⚠️  Container not empty or doesn't exist"

        # Delete storage account
        echo "🗑️  Deleting storage account: $STORAGE_ACCOUNT"
        az storage account delete --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --yes
    else
        echo "ℹ️  Storage account not found: $STORAGE_ACCOUNT"
    fi

    # Delete resource group
    echo "🗑️  Deleting resource group: $RESOURCE_GROUP"
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait

    echo "💀 Destruction completed!"
}

show_help() {
    echo "Usage: $0 [OPTIONS] [ACTION]"
    echo ""
    echo "Actions:"
    echo "  deploy    Deploy VM (default)"
    echo "  destroy   Destroy VM and resources"
    echo ""
    echo "Options:"
    echo "  -s, --subscription    Azure subscription ID (default: $SUBSCRIPTION)"
    echo "  -g, --resource-group  Resource group name (default: $RESOURCE_GROUP)"
    echo "  -a, --storage-account Storage account name (default: $STORAGE_ACCOUNT)"
    echo "  -l, --location        Azure region (default: $LOCATION)"
    echo "  -n, --vm-name         VM name (default: $VM_NAME)"
    echo "  -z, --vm-size         VM size (default: $VM_SIZE)"
    echo "  -v, --vhd-path        Path to VHD file (default: $VHD_PATH)"
    echo "  -o, --overwrite       Overwrite existing disk image"
    echo "  -h, --help            Show this help"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--subscription)
            SUBSCRIPTION="$2"
            shift 2
            ;;
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -a|--storage-account)
            STORAGE_ACCOUNT="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -n|--vm-name)
            VM_NAME="$2"
            shift 2
            ;;
        -z|--vm-size)
            VM_SIZE="$2"
            shift 2
            ;;
        -v|--vhd-path)
            VHD_PATH="$2"
            shift 2
            ;;
        -o|--overwrite)
            OVERWRITE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        deploy|destroy)
            ACTION="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Set derived names based on overwrite flag
if [[ "$OVERWRITE" == "true" ]]; then
    VHD_NAME="${VM_NAME}.vhd"
    DISK_NAME="${VM_NAME}-disk"
else
    VHD_NAME="${VM_NAME}-${TIMESTAMP}.vhd"
    DISK_NAME="${VM_NAME}-disk-${TIMESTAMP}"
fi

# Execute action
case $ACTION in
    deploy)
        deploy_vm
        ;;
    destroy)
        destroy_vm
        ;;
    *)
        echo "Unknown action: $ACTION"
        exit 1
        ;;
esac
