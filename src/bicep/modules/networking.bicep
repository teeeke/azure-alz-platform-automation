targetScope = 'subscription'

@description('The prefix for resource names')
param prefix string

@description('The environment (prod, dev, test)')
param environment string

@description('The Azure region for deployment')
param location string

@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('Virtual network address mask (16-24)')
param vnetAddressMask int

@description('Optional DNS servers for the virtual network')
param dnsServers array = []

@description('Tags to be applied to all resources')
param tags object

// Variables
var vnetName = '${prefix}-${environment}-hub-vnet'
var nsgName = '${prefix}-${environment}-hub-nsg'
var vnetConfig = {
  addressPrefix: '${vnetAddressPrefix}/${vnetAddressMask}'
  subnets: [
    {
      name: 'AzureFirewallSubnet'
      properties: {
        addressPrefix: '${vnetAddressPrefix}/${vnetAddressMask + 8}'
      }
    }
    {
      name: 'GatewaySubnet'
      properties: {
        addressPrefix: '${vnetAddressPrefix}/${vnetAddressMask + 8}'
      }
    }
    {
      name: 'AzureBastionSubnet'
      properties: {
        addressPrefix: '${vnetAddressPrefix}/${vnetAddressMask + 8}'
      }
    }
    {
      name: 'management'
      properties: {
        addressPrefix: '${vnetAddressPrefix}/${vnetAddressMask + 8}'
        networkSecurityGroup: {
          id: nsg.id
        }
      }
    }
  ]
}

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
      {
        name: 'AllowSSH'
        properties: {
          priority: 1001
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetConfig.addressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: !empty(dnsServers) ? dnsServers : null
    }
    subnets: vnetConfig.subnets
  }
}

// Outputs
output vnetId string = vnet.id
output vnetName string = vnet.name
output subnetIds object = {
  AzureFirewallSubnet: '${vnet.id}/subnets/AzureFirewallSubnet'
  GatewaySubnet: '${vnet.id}/subnets/GatewaySubnet'
  AzureBastionSubnet: '${vnet.id}/subnets/AzureBastionSubnet'
  management: '${vnet.id}/subnets/management'
}
