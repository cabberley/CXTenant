# Phase 2 - Customer Tenant authorizes Azure Key Vault
# List of Parameters to modify for each deployment
    subscriptionCustomer="Chris VStudio Sub"      # Customer Subscription where Key Vault will be stored
    appId="73331241-e1e5-49d1-b39f-86e3ea0bef39"  # Needs to be provided from output from Service Side Creation script
    rgNameCustomer="CMKKeys"        # Resource Group Name to create Key Vault in
    vaultName="cxcmkvault01"      # provide a name for keyvault
    locationKeyvault="Eastus"     # for example: location='centralus'
    mastercmkkey="mastercmkkey"   # name to give the CMK key that will be generated
    
    appName="XTCMKDemoApp1"      # Service PRovider Application Name to Register
    rgName="XTCMKDemo1"      # Resource Group to deploy User-Assigned Managed IDentity to
    location="eastus2euap"      # This is the Azure canary.
    location="eastus2"
    uamiName="xtcmkFIC1"     #name of User-Assigned Managed IDentity

# Step - 0 Login to Azure and set subscription to use for Customer side
    #az login # not needed if running from Portal Bash
    az account set --subscription $subscriptionCustomer
    username=$(az account show --query user.name --out tsv)
    tenantId=$(az account show --query tenantId --out tsv)
    subscriptionId=$(az account show --query id --out tsv) 
    echo "Logged in as username = $username from Tenant = $tenantId using subscription = $subscriptionCustomer"


# Step 1 Install the Azure AD Application using AppId in the customer tenant.
    # Install the application
    appObjectId=$(az ad sp create --id $appId --query objectId --out tsv)
    appObjectId=$(az ad sp show --id $appId --query objectId --out tsv)

# Step 2 Create a key vault and encryption keys
    #Role assignments to manageresourcesandkeyvaultsintheresourcegroup.
    az group create --location $location --name $rgNameCustomer
    currentUserObjectId=$(az ad signed-in-user show --query objectId --out tsv)
    
    # Create Azure RBAC Role assignment to manage resouces and key vaults in the resource group.
    az role assignment create --role 00482a5a-887f-4fb3-b363-3b7fe8e74483 --scope /subscriptions/$subscriptionId/resourceGroups/$rgNameCustomer --assignee-object-id $currentUserObjectId
    az role assignment create --role 8e3af657-a8ff-443c-a75c-2fe8c4bcb635 --scope /subscriptions/$subscriptionId/resourceGroups/$rgNameCustomer --assignee-object-id $currentUserObjectId

    # Create the Key Vault
    az keyvault create --location $locationKeyvault --name $vaultName --resource-group $rgNameCustomer --subscription $subscriptionId --enable-purge-protection true --enable-rbac-authorization true --query name --out tsv
    
    # Create an encryption key and store it in the Key Vault
    az keyvault key create --name $mastercmkkey --vault-name $vaultName

    #Grant Service Provider Application access to the key vault
    az role assignment create --role e147488a-f6f5-4113-8e2d-b22465e65bf6 --scope /subscriptions/$subscriptionId/resourceGroups/$rgNameCustomer/providers/Microsoft.KeyVault/vaults/$vaultName --assignee-object-id $appObjectId

    #finished
