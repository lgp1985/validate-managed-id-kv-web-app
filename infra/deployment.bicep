param location string
import * as types from './types.bicep'
param resources types.resourceParams
param network types.networkParams

resource networkResourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' existing = {
  name: network.resourceGroupName
  scope: subscription()
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  scope: networkResourceGroup
  name: network.virtualNetworkName
}

resource virtualNetwork_snetKvWeb 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  parent: virtualNetwork
  name: network.subnetName
}

resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' = {
  name: resources.keyVaultName
  location: location
  tags: {}
  properties: {
    createMode: 'default'
    enableRbacAuthorization: true
    enableSoftDelete: false
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: virtualNetwork_snetKvWeb.id
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
    }
    publicNetworkAccess: 'Enabled'
    provisioningState: 'RegisteringDns'

    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  name: resources.secretName
  parent: keyVault
  properties: {
    value: resources.KnwonValue
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: resources.appServicePlanName
  location: location
  kind: 'app,linux'
  properties: {
    reserved: true // Linux
  }
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource UserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: resources.userAssignedIdentityName
  location: location
  tags: {}
}

// resource federatedIdentitiesResource 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
//   name: fi.federatedidName
//   parent: UserAssignedIdentity
//   properties: {
//     audiences: fi.audiences
//     issuer: fi.issuerUrl
//     subject: fi.subjectId
//   }
// }

resource webApp 'Microsoft.Web/sites@2025-03-01' = {
  name: resources.webAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${UserAssignedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    keyVaultReferenceIdentity: UserAssignedIdentity.id
    siteConfig: {
      minTlsVersion: '1.3'
      netFrameworkVersion: 'v8.0'
      linuxFxVersion: 'DOTNETCORE|8.0'
      use32BitWorkerProcess: false
      ftpsState: 'FtpsOnly'
      http20Enabled: true
      healthCheckPath: '/'
    }
    virtualNetworkSubnetId: virtualNetwork_snetKvWeb.id
    httpsOnly: true
  }
}

resource roleKeyVaultUserAssignedIdentity 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, UserAssignedIdentity.id, '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '4633458b-17de-408a-b874-0445c86b69e6'
    ) // Key Vault Secrets User
    principalId: UserAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: resources.logAnalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: 30
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: resources.applicationInsightsName
  location: location
  kind: 'web'
  properties:{
    Application_Type: 'web'
    WorkspaceResourceId: logWorkspace.id
  }
}

resource webAppAppSettings 'Microsoft.Web/sites/config@2025-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: webApp
  properties: {
    secret__temp1: '@Microsoft.KeyVault(SecretUri=${secret.properties.secretUri})'
    APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
  }
  dependsOn: [
    roleKeyVaultUserAssignedIdentity
  ]
}
