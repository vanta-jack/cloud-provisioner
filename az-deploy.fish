#!/usr/bin/fish

# Check Azure credentials
if not test -f ~/.azure/azureProfile.json
    echo "Azure credentials not found. Please run 'az login' first."
    exit 1
end

# Get Resource Group
echo "Select an Azure Resource Group:"
# List existing resource groups, extracting just the name
set existing_rgs (az group list --query "[].name" -o tsv)
set all_rgs $existing_rgs "<Create New>"

set RG (gum choose $all_rgs)

if test "$RG" = "<Create New>"
    set RG (gum input --placeholder "Enter new Resource Group Name")
    set RG_REGION (gum choose "eastus" "westus" "centralus" "eastus2" "westeurope" "northeurope" "uksouth" "canadacentral" "australiaeast" --header "Select Region for new Resource Group:")
    echo "Creating Resource Group $RG in $RG_REGION..."
    az group create --name "$RG" --location "$RG_REGION"
end

set VM_NAME (gum input --placeholder "Enter VM Name (e.g. DevBox)")
set REGION (gum choose "eastus" "westus" "centralus" "eastus2" "westeurope" "northeurope" "uksouth" "canadacentral" "australiaeast" --header "Select Region for the VM:")

gum confirm "Create VM '$VM_NAME' in $REGION (Resource Group: $RG)?" || exit 1

echo "Provisioning VM $VM_NAME..."

# Create the ephemeral Spot VM and pass the YAML template
az vm create \
  --resource-group "$RG" \
  --name "$VM_NAME" \
  --location "$REGION" \
  --image Ubuntu2404 \
  --size Standard_D4ds_v5 \
  --priority Spot \
  --eviction-policy Delete \
  --ephemeral-os-disk true \
  --os-disk-placement TempDisk \
  --generate-ssh-keys \
  --custom-data ./start-init.yaml

echo "VM Provisioned. Waiting for public IP..."

# Grab the IP and immediately open the reverse SSH tunnel
set IP (az vm show -d -g "$RG" -n "$VM_NAME" --query publicIps -o tsv)
echo "VM IP is $IP. Opening reverse SSH tunnel..."

ssh -R 8022:localhost:8022 azureuser@$IP
