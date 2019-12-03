#!/bin/bash
# additional environment variables available: $AZURE_SUBSCRIPTION_ID, $AZURE_AADTENANT_ID and $AZURE_KEYVAULT
echo Location: $AZURE_LOCATION
echo Resource Group: $AZURE_RESOURCE_GROUP

az login --identity
az configure --defaults location=$AZURE_LOCATION
az configure --defaults group=$AZURE_RESOURCE_GROUP

#cp /$BOOTSTRAP_REPO/Dockerfile /$GITHUB_REPO/Dockerfile -f
cd /$BOOTSTRAP_REPO

#inner loop troubleshooting
curl -o Dockerfile https://sascript.blob.core.windows.net/public/Dockerfile
curl -o boot.sh https://sascript.blob.core.windows.net/public/boot.sh
curl -o nginx-ssl.json https://sascript.blob.core.windows.net/public/nginx-ssl.json

chmod +x boot.sh

./boot.sh
## uncomment the below statement to troubleshoot your startup script interactively in ACI (on the Connect tab)
tail -f /dev/null