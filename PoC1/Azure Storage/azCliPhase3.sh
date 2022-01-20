# Create a Azure Storage Account in Service Provider using Keyvault and Key provided by Client
# CAVEAT - Currently keyvault must be in same region as Storage Account

# List of Parameters to modify for each deployment
    subscriptionService="Chris VStudio Sub"      # Service Provider Subscription
    subscriptionIdCustomer= 
    appName="XTCMKDemoApp"      # Service PRovider Application Name to Register
    rgNameService="XTCMKDemo"      # Resource Group to deploy User-Assigned Managed IDentity to
    rgNameStorage="XTCMKDemo"      # Resource Group to deploy User-Assigned Managed IDentity to
    storageAccountName="xtcmk2022demo2"
    locationService="eastus2euap"      # This is the Azure canary.
    #locationService="eastus2"
    uamiName="xtcmkFIC"     #name of User-Assigned Managed IDentity
    keyvaultNameCustomer="https://cmk-keys-oak-poc-kv.vault.azure.net/"
    keyvaultKeyName="mastercmkkey"
    federatedIdentityApplicationId="da442cb8-893a-450a-9b2f-fc7c5d568422" #


# Step - 0 Login to Azure and set subscription to use for Service Provider side
    #az login # not needed if running from Portal Bash
    az account set --subscription "$subscriptionService"
    username=$(az account show --query user.name --out tsv)
    tenantId=$(az account show --query tenantId --out tsv)
    subscriptionId=$(az account show --query id --out tsv) 
    echo "Logged in as username = $username from Tenant = $tenantId using subscrtiption = $subscriptionService"

uri='https://management.azure.com/subscriptions/'$subscriptionId'/resourceGroups/'$rgNameStorage'/providers/Microsoft.Storage/storageAccounts/'$storageAccountName'?api-version=2021-05-01'

body='{  
  "identity": {"type": "SystemAssigned,UserAssigned ", 
  "userAssignedIdentities": {  
      "/subscriptions/'$subscriptionId'/resourceGroups/'$rgNameService'/providers/Microsoft.ManagedIdentity/userAssignedIdentities/'$uamiName'": {} 
    } 
  }, 
  "sku": { 
    "name": "Standard_LRS" 
  }, 
  "kind": "Storage", 
  "location": "'$locationService'", 
  "properties": { 
    "encryption": { 
      "services": { 
        "file": { 
          "keyType": "Account", 
          "enabled": true 
        }, 
        "blob": { 
          "keyType": "Account", 
          "enabled": true 
        } 
      }, 
      "keyvaultproperties": { 
        "keyvaulturi": "'$keyvaultNameCustomer'", 
        "keyname": "'$keyvaultKeyName'", 
        "keyversion": "" 
      }, 
      "keySource": "Microsoft.Keyvault", 
      "identity": { 
        "userAssignedIdentity": "/subscriptions/'$subscriptionId'/resourceGroups/'$rgNameService'/providers/Microsoft.ManagedIdentity/userAssignedIdentities/'$uamiName'",
 	  "federatedIdentityClientId": "'$federatedIdentityApplicationId'" 
      } 
    } 
  } 
} '

az rest --method put --uri $uri --body "$body"