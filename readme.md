# Building an Azure Cross-Tenant Customer Managed Key (CMK) PoC

## What is Azure Cross-Tenant CMK


## Resources Required to Create a Proof of Concept
You will require at least two subscriptions with each subscription associated with a separate Azure AD Tenants. i.e.
- Azure Subscription1 with Azure AD Tenant A
- Azure Subscription2 with Azure AD Tenant B

**Private Preview Additional Requirements**
1. Whitelisting of Service Provider Subscription with Cross-Tenant CMK Identity Team
2. Whitelisting of Service PRovider Subscription with Cross-Tenant CMK Storage Team

## Information Needed to Create a Proof of Concept
The process to configure Cross Tenant CMK in the Private Preview stage needs to be performed with a combination of Azure CLI and ARM Templates. As there is numerous deployment specific parameters utilized it may be easier to create a list ahead of time to ensure all components align across the environments.
Below is a table outlining each parameter and what it is used for, keep in mind there is a few parameters which are generated in phase 1 and 2 which need to be carried over to the next phase.

Parameter Name|Description|Phase|Example
------------------------------------|----------------------------------------------------------------------------------|---|-----------------------------------------------
subscriptionService|Display Name of the Service Provider Subscription|1|"My Azure Subscription"
federatedIdentityApplicationName|Service PRovider Application Name to Register|1|"XTCMKDemoApp1"
rgNameService|Resource Group to deploy User-Assigned Managed IDentity to|1|"XTCMKDemo"
locationService|This is the Region where the Service Provider will store the Managed IDentity|1|"eastus2"
uamiName|name of User-Assigned Managed IDentity|1|"xtcmkFIC1"
subscriptionCustomer|Customer Subscription where Key Vault will be stored|2|"Customer Azure Sub"
rgNameCustomer|Resource Group Name to create Key Vault in|2|"XTCMKKeys"
keyvaultNameCustomer|provide a name for keyvault|2/3|"xtcmkvault01"
locationKeyvaultCustomer|Azure Region that keyvault will be created in Currently Canary Regions|2|"eastus2"
xtCmkKeyNameCustomer|Name of the Key to be generated and used for CMK|2/3|"xtMasterCmkKey"
federatedIdentityApplicationId|This is generated in Phase 1 steps you will need to copy this value from the output of the scripts. It will be in GUID format|1/2/3|"00000000-0000-0000-0000-000000000000"
rgNameStorage|Resource Group to deploy Storage Account to in Service Provider Subscription|3|"XTCMKDemo"
locationStorage|Region for the Storage Account to be created in.|3|"eastus2" 
storageAccountName|Name of the Storage Account that will be created|3|"xtcmk2022demostorage2"
locationCosmosDb|Region for the CosmosDb Account to be created in **Note** CosmosDB location parameter is Display Name!.|3|"East US 2"
cosmosDbAccount|Name of the CosmosDB Account to create|3|"mycosmosDB01"

## Required Security Permissions
### Service Provider
#### Azure AD Tenant
The identity being used to create the Enterprise Application to establish the Federated Identity will require the AAD **"Application Developer"** Role within the Service Providers Tenant.
#### Subscription hosting Azure Resources
The Identity will need to have sufficient permissions at various points to do the following 
- for a Proof of Concept in a non-production Subscription granting contributor will enable all the steps to be performed.
- Alternatively the identity will need to be able to:
  - Create a Resource Group
  - Create a User-Assigned Managed Identity
  - Create the Azure Resources to be protected by the Customer's provided CMK
### Customers Environment
#### Azure AD Tenant
The identity being used to create the Enterprise Application to establish the Federated Identity will require the AAD **"Application Developer"** Role within the Service Providers Tenant.
#### Subscription hosting Azure Resources
The Identity will need to have sufficient permissions at various points to do the following 
- for a Proof of Concept in a non-production Subscription granting contributor will enable all the steps to be performed.
- Alternatively the identity will need to be able to:
  - Create a Resource Group for holding the Azure KeyVault
  - Create an Azure Key Vault configured to use RBAC
  - Create a Key and grant the Federated Identity the Role Assignment **"Key Vault Crypto Service Encryption User"** (which equates to wrap, unwrap, list)
