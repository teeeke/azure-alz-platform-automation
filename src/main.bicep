targetScope = 'tenant'

// Core parameters
@description('Environment name. Used in resource naming and tags.')
@allowed(['prod', 'dev', 'test', 'qa'])
param environment string

@description('The prefix used for all resources and management groups')
param prefix string

@description('Primary location for all resources')
param location string = deployment().location

@description('The subscription ID where resources will be deployed')
param targetSubscriptionId string

// Management Group parameters
@description('Custom names for management groups')
param mgCustomNames object = {}

// Monitoring parameters
@description('Log Analytics retention period in days')
@allowed([30, 60, 90, 120, 180, 365, 730])
param logRetentionDays int = 30

@description('Enabled monitoring solutions')
param enabledSolutions object = {
  securityInsights: true
  updateManagement: true
  changeTracking: true
}

// Network parameters
@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('Virtual network address mask (16-24)')
@minValue(16)
@maxValue(24)
param vnetAddressMask int = 16

@description('Optional DNS Servers for the virtual network')
param dnsServers array = []

// Resource tags
@description('Tags to be applied to all resources')
param tags object = {}

// Variables
var managementGroupNames = union({
  platform: '${prefix}-platform'
  identity: '${prefix}-identity'
  management: '${prefix}-mgmt'
  connectivity: '${prefix}-connectivity'
  landingZones: '${prefix}-landingzones'
  corp: '${prefix}-corp'
  online: '${prefix}-online'
  sandbox: '${prefix}-sandbox'
  decommissioned: '${prefix}-decom'
}, mgCustomNames)

// Variables for resource group and naming
var platformRGName = '${prefix}-${environment}-platform-rg'

// Create Management Group Structure
module managementGroups 'modules/management-groups.bicep' = {
  name: 'mg-structure-deployment'
  params: {
    prefix: prefix
    managementGroupNames: managementGroupNames
  }
}

// Deploy subscription level resources
module subscriptionDeploy 'modules/subscription.bicep' = {
  name: 'subscription-deployment'
  scope: subscription(targetSubscriptionId)
  params: {
    prefix: prefix
    environment: environment
    location: location
    platformRGName: platformRGName
    logRetentionDays: logRetentionDays
    enabledSolutions: enabledSolutions
    vnetAddressPrefix: vnetAddressPrefix
    vnetAddressMask: vnetAddressMask
    dnsServers: dnsServers
    tags: tags
  }
  dependsOn: [
    managementGroups
  ]
}

// Deploy Policy Definitions
module policyDefinitions 'modules/policy-definitions.bicep' = {
  name: 'policy-definitions-deployment'
  scope: managementGroup(managementGroupNames.platform)
  params: {
    location: location
    prefix: prefix
    tags: tags
  }
  dependsOn: [
    managementGroups
  ]
}
