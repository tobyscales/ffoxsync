# ffoxsync
One-click secure deployment of a self-hosted Mozilla Sync Service on Azure Container Instances (for synchronizing Firefox bookmarks, passwords, etc.)

# Self-host your Firefox Data in One Step

This is a pretty simple script that merges my [ARM bootstrapper](https://github.com/tescales/azure-bootstrapper-arm) with my [one-click Nginx+LetsEncrypt deployment](https://github.com/tescales/azure-letsencrypt) to create a push button experience for securely self-hosting Firefox sync data on Azure, using Container Instances and Azure Files.

Simply click the buttons below to deploy, or if you prefer fork the repo and use your own GH username/repo name in azuredeploy.json.

# What it does/deployment steps:
1) Creates a deployment Container Instance using the latest [azure-cli](https://hub.docker.com/_/microsoft-azure-cli) Docker image. 
2) Creates an Azure Files storage share for keeping MySQL database, LetsEncrypt certificates and Nginx config.
3) Clones this repo into the deployment container and executes bootstrap.sh. This script sets correct permissions on the Azure Files storage account, then passes configuration values from the ARM template into the Nginx config.
4) Creates a separate Container Group consisting of an Nginx container, a Mozilla SyncServer container and a MySQL container.


`IMPORTANT NOTE: In order to validate the SSL certificate, you will need to create a cname record for your domain and point it at the ACI DNS name in the Azure portal.`

| Parameter Name    | What it does   | Default |
| --- | --- | --- |
| gitHubUser/gitHubRepo    | indicates where the bootstrap.sh and config files will be taken from |  defaults to this repo |
| subscriptionId/aadTenantId | used for provisioning appropriate access to the deployment container | defaults to current |
| roleName   | used to assign access to the deployment container  | defaults to Owner (for this Resource Group only) |
| newVaultName | creates a new KV and stores deployment secrets there | defaults to none |
| syncStorageAccount | name for new Azure Files storage account | defaults to Resource Group Name + "stor" |
| syncStorageShareName | name for Azure Files container where sync data lives | defaults to ffsync-data |
| syncDomainName | public DNS record for your Firefox Sync Server | required for SSL support |
| syncPort | publicly-exposed port for your Firefox Sync Server | defaults to 443 |
| ssl-email | email address to use for LetsEncrypt registration | defaults to certbot@eff.org |
| ssl-env | LetsEncrypt environment to use for registration | defaults to blank; set this to "staging" for testing |


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftescales%2Fffoxsync%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>

services: `azure-container-instances,azure-files,docker,nginx,letsencrypt,mozilla-sync-server`

# TODO:
* add conditional deployment option for LetsEncrypt support
* add support for pre-existing storage account
* add ACI DNS name as output
* add support for storing config data in keyvault
  