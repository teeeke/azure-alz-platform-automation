targetScope = 'resourceGroup'

@description('The prefix for resource names')
param prefix string

@description('The environment (prod, dev, test, qa)')
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

// Networking Module
module networking 'networking.bicep' = {
  name: 'networking-deployment'
  params: {
    prefix: prefix
    environment: environment
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    vnetAddressMask: vnetAddressMask
    dnsServers: dnsServers
    tags: tags
  }
}

output vnetId string = networking.outputs.vnetId
