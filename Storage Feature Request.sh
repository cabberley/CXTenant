#To register with Azure CLI, call the az feature register command. 
az feature register --namespace Microsoft.Storage --name FederatedClientIdentity 

# To check the status of your registration with Azure CLI, call the az feature command. 
az feature show --namespace Microsoft.Storage --name FederatedClientIdentity 

#After your registration is approved, you must re-register the Azure Storage resource provider. To re-register the resource provider with Azure CLI, call the az provider register command. 
az provider register --namespace 'Microsoft.Storage' 