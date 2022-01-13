# Phase 1 - Service Provider configures identities

# List of Parameters to modify for each deployment
    set subscriptionService = "Chris VStudio Sub"      # Service Provider Subscription
    set appName="XTCMKDemoApp1"      # Service PRovider Application Name to Register
    set rgNameService="XTCMKDemo1"      # Resource Group to deploy User-Assigned Managed IDentity to
    set locationService="eastus2euap"      # This is the Azure canary.
    set locationService="eastus2"
    set uamiName="xtcmkFIC1"     #name of User-Assigned Managed IDentity

# Step - 0 Login to Azure and set subscription to use for Service Provider side
    #az login # not needed if running from Portal Bash
    az account set --subscription "$subscriptionService"
    username=$(az account show --query user.name --out tsv)
    tenantId=$(az account show --query tenantId --out tsv)
    subscriptionId=$(az account show --query id --out tsv) 
    echo "Logged in as username = $username from Tenant = $tenantId using subscrtiption = $subscriptionService"

# Step 1 - Create a new Multi-tenant AAD Application registration


    # Create Multi-Tenant App registration
    appObjectId=$(az ad app create --display-name $appName --available-to-other-tenants true --query objectId --out tsv)
    appId=$(az ad app show --id $appObjectId --query appId --out tsv)
    echo "Multi-tenant AAD Application has appId = $appId and ObjectId = $appObjectId"

# Step 2 - Create a resource group and a user-assigned managed identity

    az group create --location $locationService --resource-group $rgNameService --subscription $subscriptionId
    echo "Created a new resource group with name = $rgNameService, location = $locationService in subscriptionid = $subscriptionId"
    uamiObjectId=$(az identity create --name $uamiName --resource-group $rgNameService --location $locationService --subscription $subscriptionId --query principalId --out tsv)

#Step 3 - Configure user-assigned managed identity as a federated identity credential on the application
    az rest --method POST --uri 'https://graph.microsoft.com/beta/applications/'$appObjectId'/federatedIdentityCredentials' --body '{"name":"test01","issuer":"https://login.microsoftonline.com/'$tenantId'/v2.0","subject":"'$uamiObjectId'","description":"This is a new test federated identity credential","audiences":["api://AzureADTokenExchange"]}'

echo " To configure the Customer Tenant Side the AppID created is required copy this vlaue AppID: '$appId'"
# Finished