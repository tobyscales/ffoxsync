#!/bin/bash
# additional environment variables available: $AZURE_SUBSCRIPTION_ID, $AZURE_AADTENANT_ID and $AZURE_KEYVAULT
echo Location: $AZURE_LOCATION
echo Resource Group: $AZURE_RESOURCE_GROUP

az login --identity
az configure --defaults location=$AZURE_LOCATION
az configure --defaults group=$AZURE_RESOURCE_GROUP

#cp /$BOOTSTRAP_REPO/Dockerfile /$GITHUB_REPO/Dockerfile -f
cd /$BOOTSTRAP_REPO

#VGoshev specific
#cd docker
#cp /$BOOTSTRAP_REPO/Dockerfile /$GITHUB_REPO/docker/Dockerfile -f

az acr create --name $AZURE_RESOURCE_GROUP --sku Standard --admin-enabled true

git clone https://github.com/Neilpang/acme.sh.git
cd acme.sh

az acr build --image nginx-ssl:v1 --registry $AZURE_RESOURCE_GROUP --file ../Dockerfile .

az logout
az login --identity

acruser=$AZURE_RESOURCE_GROUP
password=$(az acr credential show --name $AZURE_RESOURCE_GROUP --query passwords[0].value --out tsv)
imageServer=$(az acr show --name $AZURE_RESOURCE_GROUP --query loginServer --output tsv)

echo Setting up storage accounts...
#az storage share create -n $AZURE_STORAGE_SHARE --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY
#az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s $AZURE_STORAGE_SHARE --permissions dlrw

echo Setting up Nginx storage accounts...
az storage share create -n nginx-config --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s nginx-config --permissions dlrw

az storage share create -n nginx-html --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s nginx-html --permissions dlrw

az storage share create -n nginx-certs --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s nginx-certs --permissions dlrw

az storage file upload --source /$BOOTSTRAP_REPO/conf/nginx.conf --share-name nginx-config 
az storage file upload --source /$BOOTSTRAP_REPO/html/index.html --share-name nginx-html 

echo Deploying Nginx+SSL container...
az deployment create --template-file nginx-ssl.json --parameters StorageAccountName=$AZURE_STORAGE_ACCOUNT StorageAccountKey=$AZURE_STORAGE_KEY

## uncomment the below statement to troubleshoot your startup script interactively in ACI (on the Connect tab)
tail -f /dev/null