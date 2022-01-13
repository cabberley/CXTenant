# List of Parameters to modify for each deployment
    subscriptionService="Chris VStudio Sub"      # Service Provider Subscription
    subscriptionIdCustomer= 
    appName="XTCMKDemoApp1"      # Service PRovider Application Name to Register
    rgNameService="XTCMKDemo1"      # Resource Group to deploy User-Assigned Managed IDentity to
    rgNameStorage="XTCMKDemo1"      # Resource Group to deploy User-Assigned Managed IDentity to
     storageAccountName="xtcmk2022demo2"
    locationService="eastus2euap"      # This is the Azure canary.
    locationService="eastus2"
    uamiName="xtcmkFIC1"     #name of User-Assigned Managed IDentity
    keyvaultNameCustomer="https://cmk-keys-oak-poc-kv.vault.azure.net/"
    federatedIdentityApplicationId="da442cb8-893a-450a-9b2f-fc7c5d568422" #
    keyvaultCmk="mastercmkkey"
    managedIdentity="/subscriptions/187de015-bb09-4bb7-9376-337ff2023532/resourceGroups/XTCMKDemo/providers/Microsoft.ManagedIdentity/userAssignedIdentities/xtcmkFIC"

    comosDbdAccount="xtcmkcosmos01"
    rgNameCosmosDB="XTCosmos"
    keyVaultKeyUri=$keyvaultNameCustomer"keys/"$keyvaultCmk



# Step - 0 Login to Azure and set subscription to use for Service Provider side
    #az login # not needed if running from Portal Bash
    az account set --subscription "$subscriptionService"
    username=$(az account show --query user.name --out tsv)
    tenantId=$(az account show --query tenantId --out tsv)
    subscriptionId=$(az account show --query id --out tsv) 
    echo "Logged in as username = $username from Tenant = $tenantId using subscrtiption = $subscriptionService"


# Create CosmosDB Account and encrypt
    az cosmosdb create -n $comosDbdAccount -g $rgNameCosmosDB --key-uri $keyVaultKeyUri --assign-identity $managedIdentity --default-identity "UserAssignedIdentity="$managedIdentity