#!/usr/bin/fish
# Check Azure credentials

if not test -f ~/.azure/azureProfile.json
    echo "Azure credentials not found. Please run 'az login' first."
    exit 1
end

# Get Resource Group
echo "Select an Azure Resource Group:"