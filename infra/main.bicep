param location string
param resourceGroupName string
param appServicePlanName string
param webAppName string
param userAssignedIdentityName string
param keyVaultName string
param secretName string
param KnwonValue string

targetScope = 'subscription'
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: resourceGroupName
  location: location
  tags: {}
}

module deployment 'deployment.bicep' = {
  name: 'deployResources'
  scope: resourceGroup
  params: {
    location: location
    appServicePlanName: appServicePlanName
    webAppName: webAppName
    userAssignedIdentityName: userAssignedIdentityName
    keyVaultName: keyVaultName
    secretName: secretName
    KnwonValue: KnwonValue
  }
}
