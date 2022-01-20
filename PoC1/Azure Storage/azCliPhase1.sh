# Phase 1 Service PRovider Tenant and Subscription Setup and Configuration for Cross Tenant CMK
#
# These steps will 
#  - Create and configure a Federated Application
#  - Create a Resource Group and User Assigned Managed Identity
#  - Configure the Federated Identity with the User Assigned Managed Identity
#  - Generate the Federated Identity Application ID required in the next phases
#
# CAVEATS
#  - Currently keyvaults must be in same region as the Storage Account - Caveat should be removed by GA
#

# List of Parameters to modify for each deployment
    subscriptionService="Chris VStudio Sub"                     # Service Provider Subscription
    federatedIdentityApplicationName="XTCMKDemoApp2"            # Service PRovider Application Name to Register
    rgNameService="XTCMKDemo"                                   # Resource Group to deploy User-Assigned Managed IDentity to
    locationService="eastus2"                               # This is the Azure canary.
    uamiName="xtcmkFIC2"                                        #name of User-Assigned Managed IDentity

# Step - 0 Login to Azure and set subscription to use for Service Provider side
    #az login # not needed if running from Portal Bash
    az account set --subscription "$subscriptionService"
    username=$(az account show --query user.name --out tsv)
    tenantId=$(az account show --query tenantId --out tsv)
    subscriptionId=$(az account show --query id --out tsv) 
    echo "Logged in as username = $username from Tenant = $tenantId using subscrtiption = $subscriptionService"

# Step 1 - Create a new Multi-tenant AAD Application registration
    # Create Multi-Tenant App registration
    appObjectId=$(az ad app create --display-name $federatedIdentityApplicationName --available-to-other-tenants true --query objectId --out tsv)
    federatedIdentityApplicationId=$(az ad app show --id $appObjectId --query appId --out tsv)
    echo "Multi-tenant AAD Enterprise Application $federatedIdentityApplicationName has appId = $federatedIdentityApplicationId and ObjectId = $appObjectId"

# Step 2 - Create a resource group and a user-assigned managed identity
    az group create --location $locationService --resource-group $rgNameService --subscription $subscriptionId
    echo "Created a new resource group with name = $rgNameService, location = $locationService in subscriptionid = $subscriptionId"
    uamiObjectId=$(az identity create --name $uamiName --resource-group $rgNameService --location $locationService --subscription $subscriptionId --query principalId --out tsv)

#Step 3 - Configure user-assigned managed identity as a federated identity credential on the application
    uri='https://graph.microsoft.com/beta/applications/'$appObjectId'/federatedIdentityCredentials'
    body='{
        "name":"test01",
        "issuer":"https://login.microsoftonline.com/'$tenantId'/v2.0",
        "subject":"'$uamiObjectId'",
        "description":"This is a new test federated identity credential",
        "audiences":["api://AzureADTokenExchange"]
        }'
#Post using the Azure CLI REST the federated Identity Credential configuration
    az rest --method POST --uri $uri --body "$body"

echo "To configure the Customer Subscription and Tenant Side the federatedIdentityApplicationId created is required!"
echo "Copy this value below for use in configuring the customer side before creating dependant resources in this subscription for CMK"
echo "federatedIdentityApplicationId: '$federatedIdentityApplicationId'"
# Finished