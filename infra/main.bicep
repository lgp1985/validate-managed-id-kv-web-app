param location string
import * as types from './types.bicep'
param network types.networkParams
param resources types.resourceParams

targetScope = 'subscription'

resource networkResourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: network.resourceGroupName
  location: location
  tags: {}
}

module networkDeployment 'network.bicep' = {
  name: 'deployNetworkResources'
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
  name: 'deployResources'
  scope: resourceGroup
  params: {
    location: location
    resources: resources
  }
}
