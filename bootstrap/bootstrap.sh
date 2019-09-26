#!/bin/bash
# additional environment variables available: $AZURE_SUBSCRIPTION_ID, $AZURE_AADTENANT_ID and $AZURE_KEYVAULT
echo Location: $AZURE_LOCATION
echo Resource Group: $AZURE_RESOURCE_GROUP

az login --identity
az configure --defaults location=$AZURE_LOCATION
az configure --defaults group=$AZURE_RESOURCE_GROUP

cp /code/$GITHUB_REPO/Dockerfile /mozilla/syncserver/Dockerfile -f
cd /mozilla/syncserver

#az acr create --name $AZURE_RESOURCE_GROUP --sku Standard --admin-enabled true

az acr build --image syncserver:v1 --registry $AZURE_RESOURCE_GROUP --file Dockerfile .
az logout
az login --identity

acruser=$AZURE_RESOURCE_GROUP
password=$(az acr credential show --name $AZURE_RESOURCE_GROUP --query passwords[0].value --out tsv)
imageServer=$(az acr show --name $AZURE_RESOURCE_GROUP --query loginServer --output tsv)

echo Setting up storage accounts...
az storage share create -n $AZURE_STORAGE_SHARE --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s $AZURE_STORAGE_SHARE --permissions dlrw

echo Deploying Firefox syncserver container...
az container create --name $AZURE_RESOURCE_GROUP\
 --image $imageServer/syncserver:v1 --registry-username=$acruser --registry-password=$password\
 --azure-file-volume-mount-path "/home/$AZURE_STORAGE_SHARE" --azure-file-volume-account-key $AZURE_STORAGE_KEY\
 --azure-file-volume-account-name $AZURE_STORAGE_ACCOUNT --azure-file-volume-share-name $AZURE_STORAGE_SHARE\
 --command-line "tail -f /dev/null"\
 --ip-address Public --dns-name-label $AZURE_STORAGE_ACCOUNT  --ports 5000\
 --environment-variables SYNCSERVER_SQLURI="sqlite:///home/$AZURE_STORAGE_SHARE/syncserver.db" SYNCSERVER_PUBLIC_URL="$AZURE_RESOURCE_GROUP.$AZURE_LOCATION.azurecontainer.io" PORT="5000"
 

## uncomment the below statement to troubleshoot your startup script interactively in ACI (on the Connect tab)
tail -f /dev/null