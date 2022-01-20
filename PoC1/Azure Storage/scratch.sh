Call Storage account Update API to configure the storage account with FederatedClientId and managed identity (system-assigned or user-assigned) 
userAssignedIdentities – User-assigned managed identity in ISV’s tenant to be used for cross-tenant key vault access (if user-assigned identity is being used) 
userAssignedIdentity - User-assigned managed identity in ISV’s tenant to be used for cross-tenant key vault access (if user-assigned identity is being used) 
type – Can be “SystemAssigned” or “UserAssigned” or “SystemAssigned,UserAssigned” depending on whether system-assigned or user-assigned managed identity is being used 
federatedIdentityClientId – the application Id of the multi-tenant AAD application in ISV’s tenant 

Note – If a system-assigned managed identity is used then skip the first two parameters above and set type to “SystemAssigned” 
PUT / PATCH 
https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{accountName}?api-version=2021-05-01 
https://management.azure.com/subscriptions/187de015-bb09-4bb7-9376-337ff2023532/resourceGroups/XTCMKDemo/providers/Microsoft.Storage/storageAccounts/xtcmk2022demo2?api-version=2021-05-01

{ 
  "identity": { 
    "type": "SystemAssigned,UserAssigned", 
    "userAssignedIdentities": { 
      "/subscriptions/{subscription-id}/resourceGroups/res9101/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{managed-identity-name}": {} 
    } 
  }, 
  "sku": { 
    "name": "Standard_LRS" 
  }, 
  "kind": "Storage", 
  "location": "eastus2euap", 
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
        "keyvaulturi": "https://myvault8569.vault.azure.net", 
        "keyname": "wrappingKey", 
        "keyversion": "" 
      }, 
      "keySource": "Microsoft.Keyvault", 
      "identity": { 
        "userAssignedIdentity": "/subscriptions/{subscription-id}/resourceGroups/res9101/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{managed-identity-name}" 
 	  "federatedIdentityClientId": "10b5ca4d-482c-4ebd-8970-9464ad8b671e", 
      } 
    } 
  } 
} 


{ "identity": 
{"type": "SystemAssigned,UserAssigned ", "userAssignedIdentities": 
{ "/subscriptions/187de015-bb09-4bb7-9376-337ff2023532/resourceGroups/XTCMKDemo/providers/Microsoft.ManagedIdentity/userAssignedIdentities/xtcmkFIC": {} 
} }, 
"sku": { "name": "Standard_LRS" }, 
"kind": "Storage", "location": "eastus2", "properties": { "encryption": { "services": { "file": { "keyType": "Account", "enabled": true }, "blob": { "keyType": "Account", "enabled": true } }, 
"keyvaultproperties": 
{ "keyvaulturi": "https://cmk-keys-oak-poc-kv.vault.azure.net/", "keyname": "wrappingKey", "keyversion": "" }, "keySource": "Microsoft.Keyvault", "identity": { "userAssignedIdentity": "/subscriptions/187de015-bb09-4bb7-9376-337ff2023532/resourceGroups/XTCMKDemo/providers/Microsoft.ManagedIdentity/userAssignedIdentities/xtcmkFIC", "federatedIdentityClientId": "da442cb8-893a-450a-9b2f-fc7c5d568422" } } } }