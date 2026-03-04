param location string
param keyVaultName string
param appServicePlanName string
param webAppName string
param userAssignedIdentityName string

param secretName string
param KnwonValue string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: {}
  properties: {
    createMode: 'default'
    enableRbacAuthorization: true
    enableSoftDelete: false
    // networkAcls: {
    //   bypass: kvByPass
    //   defaultAction: kvDefaultAction
    //   ipRules: kvIpRules
    //   virtualNetworkRules: [ for (kvVirtualNewtworkSubnetId,i) in SubnetResourceIdsForServiceEndpoints :  (!empty(SubnetResourceIdsForServiceEndpoints)) ? {
    //     id: kvVirtualNewtworkSubnetId
    //     ignoreMissingVnetServiceEndpoint: kvIgnoreMissingVnetServiceEndpoint
    //   } : {} ]
    // }
    provisioningState: 'RegisteringDns'
    // publicNetworkAccess: (empty(SubnetResourceIdsForServiceEndpoints)) ? 'Disabled' : 'Enabled'

    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
  }
}

resource KeyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  resource secret 'secrets@2023-07-01' = {
    name: secretName
    properties: {
      value: KnwonValue
    }
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: appServicePlanName
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

resource UserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
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

resource webApp 'Microsoft.Web/sites@2024-11-01' = {
  name: webAppName
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
      // ipSecurityRestrictions: [
      //   for vnetSubnetResourceId in vnetSubnetResourceIds: {
      //     vnetSubnetResourceId: vnetSubnetResourceId
      //     action: 'Allow'
      //     tag: 'Default'
      //     priority: 1000
      //   }
      // ]
      healthCheckPath: '/'
    }
    // virtualNetworkSubnetId: virtualNetworkSubnetIdVinrouterApp2Kv
    httpsOnly: true
  }
}

resource roleKeyVaultUserAssignedIdentity 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, UserAssignedIdentity.id, 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') // Key Vault Secrets User
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
    ) // Key Vault Secrets User
    principalId: UserAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
