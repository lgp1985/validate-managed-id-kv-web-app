param location string
import * as types from './types.bicep'
param network types.networkParams

param vnetConnected bool

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: network.networkSecurityGroupName
  location: location
  properties: {
    securityRules: []
  }
}

resource routeTable 'Microsoft.Network/routeTables@2025-05-01' = {
  name: network.routeTablesName
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: []
  }
}

resource virtualNetwork_AzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  // this is out-of-box
  parent: virtualNetwork
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefixes: [
      '10.0.1.0/26'
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetwork_default
  ]
}

resource virtualNetwork_default 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  // this is out-of-box
  parent: virtualNetwork
  name: 'default'
  properties: {
    addressPrefixes: [
      '10.0.0.0/24'
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: network.virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      // {
      //   name: 'default'
      //   id: virtualNetworks_vnet_lg_temp1_name_default.id
      //   properties: {
      //     addressPrefixes: [
      //       '10.0.0.0/24'
      //     ]
      //     delegations: []
      //     privateEndpointNetworkPolicies: 'Disabled'
      //     privateLinkServiceNetworkPolicies: 'Enabled'
      //   }
      //   type: 'Microsoft.Network/virtualNetworks/subnets'
      // }
      // {
      //   name: 'AzureFirewallSubnet'
      //   id: virtualNetworks_vnet_lg_temp1_name_AzureFirewallSubnet.id
      //   properties: {
      //     addressPrefixes: [
      //       '10.0.1.0/26'
      //     ]
      //     delegations: []
      //     privateEndpointNetworkPolicies: 'Disabled'
      //     privateLinkServiceNetworkPolicies: 'Enabled'
      //   }
      //   type: 'Microsoft.Network/virtualNetworks/subnets'
      // }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource virtualNetwork_snetKvWeb 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = if (vnetConnected) {
  // This should be idempotent, but if the subnet is already connected it'll fail with "code": "InUseSubnetCannotBeDeleted", "message": "Subnet snet-kv-web-temp1 is in use by /subscriptions/***/resourceGroups/rg-lg-vnet-temp1/providers/Microsoft.Network/virtualNetworks/vnet-lg-temp1/subnets/snet-kv-web-temp1/serviceAssociationLinks/AppServiceLink and cannot be deleted. In order to delete the subnet, delete all the resources within the subnet. See aka.ms/deletesubnet.",
  parent: virtualNetwork
  name: network.subnetName
  properties: {
    addressPrefixes: [
      '10.0.1.64/27'
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
    routeTable: {
      id: routeTable.id
    }
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
        locations: [
          '*'
        ]
      }
    ]
    delegations: [
      {
        name: 'Microsoft.Web/serverFarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetwork_AzureFirewallSubnet
  ]
}
