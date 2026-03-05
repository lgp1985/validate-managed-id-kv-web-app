@export()
@minLength(1)
@maxLength(90)
type rgName = string

@export()
type networkParams = {
  resourceGroupName: rgName
  routeTablesName: string
  virtualNetworkName: string
  networkSecurityGroupName: string
  subnetName: string
}

@export()
type resourceParams = {
  resourceGroupName: rgName
  appServicePlanName:string
  webAppName: string
  userAssignedIdentityName: string
  keyVaultName: string

  secretName: string
  KnwonValue: string
}
