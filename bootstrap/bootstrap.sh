#!/bin/bash
# additional environment variables available: $AZURE_SUBSCRIPTION_ID, $AZURE_AADTENANT_ID and $AZURE_KEYVAULT
echo Location: $AZURE_LOCATION
echo Resource Group: $AZURE_RESOURCE_GROUP

az login --identity
az configure --defaults location=$AZURE_LOCATION
az configure --defaults group=$AZURE_RESOURCE_GROUP

az storage share create -n firefoxsync --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY

## uncomment the below statement to troubleshoot your startup script interactively in ACI (on the Connect tab)
tail -f /dev/null