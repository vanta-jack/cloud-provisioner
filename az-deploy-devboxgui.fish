#!/usr/bin/fish

# Create the ephemeral Spot VM and pass the YAML template
az vm create \
  --resource-group devRG \
  --name devboxVM \
  --image Ubuntu2404 \
  --size Standard_D4ds_v5 \
  --priority Spot \
  --eviction-policy Delete \
  --ephemeral-os-disk true \
  --os-disk-placement TempDisk \
  --generate-ssh-keys \
  --custom-data ./cloud-init.yaml

# Grab the IP and immediately open the reverse SSH tunnel
set IP (az vm show -d -g devRG -n devboxVM --query publicIps -o tsv)
ssh -R 8022:localhost:8022 azureuser@$IP 