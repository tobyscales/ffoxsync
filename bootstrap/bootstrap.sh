#!/bin/bash
# additional environment variables available: $AZURE_SUBSCRIPTION_ID, $AZURE_AADTENANT_ID and $AZURE_KEYVAULT
echo Location: $AZURE_LOCATION
echo Resource Group: $AZURE_RESOURCE_GROUP

az login --identity
az configure --defaults location=$AZURE_LOCATION
az configure --defaults group=$AZURE_RESOURCE_GROUP

az acr create --name $AZURE_RESOURCE_GROUP --sku Standard
az acr build --image my/syncserver:v1 --registry $AZURE_RESOURCE_GROUP --file Dockerfile .

spID=$(az container show -n bootstrapper --query identity.principalId --out tsv)
resourceID=$(az acr show --resource-group $AZURE_RESOURCE_GROUP --name $AZURE_RESOURCE_GROUP --query id --output tsv)
#az role assignment create --assignee $spID --scope $resourceID --role acrpull

#az acr build --registry $ACR_NAME --image ffoxsync:v1 .


echo Setting up storage accounts...
az storage share create -n $AZURE_STORAGE_SHARE --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s $AZURE_STORAGE_SHARE --permissions dlrw

echo adding Firefox user
addgroup -g 1001 app && adduser -u 1001 -S -D -G app -s /usr/sbin/nologin app
usermod -aG sudo app

echo Copying your configuration...
cp /code/syncserver.ini /syncserver/syncserver.ini -f

echo Building Firefox Sync Server...
cd /syncserver
make build
make test
make serve

## uncomment the below statement to troubleshoot your startup script interactively in ACI (on the Connect tab)
tail -f /dev/null