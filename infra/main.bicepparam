using './main.bicep'

param location = 'Central US'

param network = {
  resourceGroupName: 'rg-lg-vnet-temp1'
  routeTablesName: 'rt-vnet-temp1'
  virtualNetworkName: 'vnet-lg-temp1'
  networkSecurityGroupName: 'nsg-lg-temp1'
  subnetName: 'snet-kv-web-temp1'
}

param resources = {
  resourceGroupName: 'rg-lg-temp1'
  appServicePlanName: 'app-temp1'
  webAppName: 'web-temp1'
  userAssignedIdentityName: 'uai-temp1'
  keyVaultName: 'kv-lgp-temp1'
  secretName: 'secret-temp1'
  KnwonValue: 'known-value'
}
