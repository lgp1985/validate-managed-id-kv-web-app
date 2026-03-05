param location string
import * as types from './types.bicep'
param network types.networkParams

resource networkSecurityGroups_nsg_lg_temp1_name_resource 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: network.networkSecurityGroupName
  location: location
  properties: {
    securityRules: []
  }
}

resource routeTables_rt_vnet_temp1_name_resource 'Microsoft.Network/routeTables@2024-07-01' = {
  name: network.routeTablesName
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: []
  }
}

resource virtualNetworks_vnet_lg_temp1_name_AzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  // this is out-of-box
  parent: virtualNetworks_vnet_lg_temp1_name_resource
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefixes: [
      '10.0.1.0/26'
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource virtualNetworks_vnet_lg_temp1_name_default 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  // this is out-of-box
  parent: virtualNetworks_vnet_lg_temp1_name_resource
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

resource virtualNetworks_vnet_lg_temp1_name_resource 'Microsoft.Network/virtualNetworks@2024-07-01' = {
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

resource virtualNetworks_vnet_lg_temp1_name_snet_kv_web_temp1 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  parent: virtualNetworks_vnet_lg_temp1_name_resource
  name: 'snet-kv-web-temp1'
  properties: {
    addressPrefixes: [
      '10.0.1.64/27'
    ]
    networkSecurityGroup: {
      id: networkSecurityGroups_nsg_lg_temp1_name_resource.id
    }
    routeTable: {
      id: routeTables_rt_vnet_temp1_name_resource.id
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
}
