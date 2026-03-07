param location string
import * as types from './types.bicep'
param network types.networkParams
param resources types.resourceParams
param githubRun_id string = '0'

targetScope = 'subscription'

resource networkResourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: network.resourceGroupName
  location: location
  tags: {}
}

module networkDeployment 'network.bicep' = {
  name: 'deployNetworkResources-${githubRun_id}'
  scope: networkResourceGroup
  params: {
    location: location
    network: network
  }
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: resources.resourceGroupName
  location: location
  tags: {}
}

module deployment 'deployment.bicep' = {
  name: 'deployResources-${githubRun_id}'
  scope: resourceGroup
  params: {
    location: location
    resources: resources
    network: network
  }
  dependsOn: [
    networkDeployment
  ]
}
