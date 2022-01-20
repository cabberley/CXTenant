# Create a basic CosmosDB Account in Service Provider using Cross Tenant CMK 
#
# REQUIRES
# - Keyvault name and Key name configured in Customer Subscription 
# - Phase 1 - created Federated Identity and App Registration in this Subscription and Tenant
# - Phase 2 - Customer Subscription and Tenant Registration of APP from Phase 1 and Creation of keyvault and key
#
# CAVEATS
#  - Currently keyvaults must be in same region as the Storage Account - Caveat should be removed by GA
#  - CosmosDB Create parameters requires Display Name of Region not name e.g. "East US 2" NOT "EASTUS2"
#

# List of Parameters to modify for each deployment
    subscriptionService="AG-CI-PROJECTOAK-AG1-JAMESPO"                        # Service Provider Subscription that will be hosting Resources subjected to Cross Tenant CMK
    federatedIdentityApplicationName="XTCMKDemoApp1"                          # Service Provider Application Name to Register
    rgNameService="XTCMKDemo"                                                 # Resource Group to deploy User-Assigned Managed IDentity to
    rgNameStorage="XTCMKDemo"                                                 # Resource Group to deploy Storage Account to
    locationService="eastus2euap"                                             # Region for Federated IDentity App -- eastuseuap is the Azure canary.
    locationStorage="eastus2euap"                                             # Region for the Storage Account to be created in -- eastuseuap  is the Azure canary. 
    locationCosmosDb="East US 2 EUAP"                                         # Region for the CosmosDb Account to be created in -- eastuseuap  is the Azure canary. 
    uamiName="xtcmkFIC1"                                                      # Name of User-Assigned Managed IDentity created in Phase 1
    storageAccountName="xtcmk2022demo2"                                       # Name of the Storage Account that will be created
    cosmosDbAccount="agcichabb01"

#This variable values need to be provided from phase 1 
    federatedIdentityApplicationId="da442cb8-893a-450a-9b2f-fc7c5d568422"     #This is created in Phase 1 steps will be in GUID format e.g. "da442cb8-893a-450a-9b2f-fc7c5d568422"

#These two variables values need to be provided from phase 2 
    keyvaultNameCustomer="xtcmkvault01"                                       # Name of the Customer Keyvault holding the CMK
    xtCmkKeyNameCustomer="xtMasterCmkKey"                                     # Name of the Key to be used for CMK

# Step - 0 Login to Azure and set subscription to use for Service Provider side
    #az login # not needed if running from Portal Bash
    az account set --subscription "$subscriptionService"
    username=$(az account show --query user.name --out tsv)
    tenantId=$(az account show --query tenantId --out tsv)
    subscriptionId=$(az account show --query id --out tsv) 
    echo "Logged in as username = $username from Tenant = $tenantId using subscrtiption = $subscriptionService"

# Step - 1 Create CosmosDB Account using Custmoer provided CMK
# Create uri based on the parameters for this deployment
    uri='https://management.azure.com/subscriptions/'$subscriptionId'/resourceGroups/'$rgNameStorage'/providers/Microsoft.DocumentDB/databaseAccounts/'$cosmosDbAccount'?api-version=2021-01-15'

# Create JSON body to create a CosmosDB account based on the parameters

    body='{ 
        "kind": "GlobalDocumentDB", 
        "location": "'$locationCosmosDb'", 
        "identity": { 
            "type": "UserAssigned", 
            "userAssignedIdentities": { 
                "/subscriptions/'$subscriptionId'/resourceGroups/'$rgNameService'/providers/Microsoft.ManagedIdentity/userAssignedIdentities/'$uamiName'": {} 
                }
            } 
        "properties": { 
            "locations": [ 
                { 
                    "locationName": '$locationCosmosDb', 
                    "failoverPriority": 0, 
                    "isZoneRedundant": false 
                }
            ], 
            "databaseAccountOfferType": "Standard", 
            "keyvaultKeyuri": "https://'$keyvaultNameCustomer'.vault.azure.net/keys/'$xtCmkKeyName'", 
            "defaultIdentity": "UserAssignedIdentity=/subscriptions/'$subscriptionId'/resourceGroups/'$rgNameService'/providers/Microsoft.ManagedIdentity/userAssignedIdentities/'$uamiName'&FederatedClientId='$federatedIdentityApplicationId'"
        } 
    }'


# use the Azure CLI REST command to execute the creation of CosmosDB configured with a Cross Tenant Customer Managed KEY
    az rest --method put --uri $uri --body "$body"

# Storage account should now be protected with a CMK from customers Tenant