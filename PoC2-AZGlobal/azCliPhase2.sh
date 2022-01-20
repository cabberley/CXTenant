# Phase 2 Customer Subscription Setup and COnfiguration for Cross Tenant CMK
#
# These steps will install\register the Service Providers Federated Application
# Create a keyvault and Key to be used for CMK
# Configure RBAC on the keyvault and keys to allow the Federated Identity to use the keys
#
# REQUIRES
# - Phase 1 - created Federated Identity and App Registration in this Subscription and Tenant
#
# CAVEATS
#  - Currently keyvaults must be in same region as the Storage Account - Caveat should be removed by GA

#


# Phase 2 - Customer Tenant authorizes Azure Key Vault
# List of Parameters to modify for each deployment
    subscriptionCustomer="AG-CI-PROJECTOAK-AG2-JAMESPO"                         # Customer Subscription where Key Vault will be stored
    rgNameCustomer="XTCMKKeys"                                                  # Resource Group Name to create Key Vault in
    keyvaultNameCustomer="xtcmkvault01"                                         # provide a name for keyvault
    locationKeyvaultCustomer="eastus2euap"                                      # Azure Region that keyvault will be created in Currently Canary Regions
    xtCmkKeyNameCustomer="xtMasterCmkKey"                                       # Name of the Key to be generated and used for CMK                   

#This variable values need to be provided from phase 1 
    federatedIdentityApplicationId="<get from Phase 1 output>"                  # This is created in Phase 1 steps will be in GUID format e.g. "da442cb8-893a-450a-9b2f-fc7c5d568422"

# Step - 0 Login to Azure and set subscription to use for Customer side
    #az login # not needed if running from Portal Bash
    az account set --subscription "$subscriptionCustomer"
    username=$(az account show --query user.name --out tsv)
    tenantId=$(az account show --query tenantId --out tsv)
    subscriptionId=$(az account show --query id --out tsv) 
    echo "Logged in as username = $username from Tenant = $tenantId using subscription = $subscriptionCustomer"

# Step 1 Install the Azure AD Application using AppId in the customer tenant.
    # Install the application
    appObjectId=$(az ad sp create --id $federatedIdentityApplicationId --query objectId --out tsv)
    appObjectId=$(az ad sp show --id $federatedIdentityApplicationId --query objectId --out tsv)

# Step 2 Create a key vault and encryption keys
    #Role assignments to manageresourcesandkeyvaultsintheresourcegroup.
    az group create --location $locationKeyvaultCustomer --name $rgNameCustomer
    currentUserObjectId=$(az ad signed-in-user show --query objectId --out tsv)
    
    # Create Azure RBAC Role assignment to manage resouces and key vaults in the resource group.
    az role assignment create --role 00482a5a-887f-4fb3-b363-3b7fe8e74483 --scope /subscriptions/$subscriptionId/resourceGroups/$rgNameCustomer --assignee-object-id $currentUserObjectId
    az role assignment create --role 8e3af657-a8ff-443c-a75c-2fe8c4bcb635 --scope /subscriptions/$subscriptionId/resourceGroups/$rgNameCustomer --assignee-object-id $currentUserObjectId

    # Create the Key Vault
    az keyvault create --location $locationKeyvault --name $keyvaultNameCustomer --resource-group $rgNameCustomer --subscription $subscriptionId --enable-purge-protection true --enable-rbac-authorization true --query name --out tsv
    
    # Create an encryption key and store it in the Key Vault
    az keyvault key create --name $xtCmkKeyNameCustomer --vault-name $keyvaultNameCustomer

    #Grant Service Provider Application access to the key vault
    az role assignment create --role e147488a-f6f5-4113-8e2d-b22465e65bf6 --scope /subscriptions/$subscriptionId/resourceGroups/$rgNameCustomer/providers/Microsoft.KeyVault/vaults/$keyvaultNameCustomer --assignee-object-id $appObjectId

    echo "The Azure Keyvault and key should now be generated and cofngiured for use in Cross Tenant CMK"
    echo "Service Provider will need the following details to configure CMK using your key"
    echo "keyvaultNameCustomer=$keyvaultNameCustomer"
    echo "locationKeyvaultCustomer=$locationKeyvaultCustomer"
    echo "xtCmkKeyNameCustomer=$xtCmkKeyNameCustomer"
    #finished
