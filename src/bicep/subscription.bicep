targetScope = 'subscription'

// Parameters
@description('Environment name. Used in resource naming and tags.')
@allowed(['prod', 'dev', 'test', 'qa'])
param environment string

@description('The prefix used for all resources')
param prefix string

@description('Azure region for deployment')
param location string

@description('Optional tags')
param tags object = {}

@description('Log retention days')
param logRetentionDays int

@description('Enabled monitoring solutions')
param enabledSolutions object

@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('Virtual network address mask (16-24)')
param vnetAddressMask int

@description('DNS servers for the virtual network')
param dnsServers array

@description('Name of the platform resource group')
param platformRGName string

// Create platform resource group
resource platformRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: platformRGName
  location: location
  tags: tags
}

// Deploy logging and monitoring resources
module logging 'modules/logging/logging.bicep' = {
  name: 'logging-deployment'
  scope: resourceGroup(platformRG.name)
  params: {
    prefix: prefix
    environment: environment
    location: location
    retentionDays: logRetentionDays
    enabledSolutions: enabledSolutions
    tags: tags
  }
}

// Deploy platform components
module platformDeploy 'modules/platform-deploy.bicep' = {
  name: 'platform-deployment'
  scope: resourceGroup(platformRG.name)
  params: {
    prefix: prefix
    environment: environment
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    vnetAddressMask: vnetAddressMask
    dnsServers: dnsServers
    tags: tags
  }
  dependsOn: [
    logging
  ]
}
