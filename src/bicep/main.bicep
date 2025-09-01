targetScope = 'tenant'

// Tenant ID is used implicitly in management group deployments

// Core parameters
@description('Environment name. Used in resource naming and tags.')
@allowed(['prod', 'dev', 'test', 'qa'])
param environment string

@description('The prefix used for all resources and management groups')
param prefix string

@description('Primary location for all resources')
param location string = deployment().location

@description('Optional DNS Servers for the virtual network')
param dnsServers array = []

@description('Tags to be applied to all resources')
param tags object = {}

// Network parameters
@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('Virtual network address mask (16-24)')
@minValue(16)
@maxValue(24)
param vnetAddressMask int = 16

// Management Group parameters
@description('Custom names for management groups')
param mgCustomNames object = {}

@description('Log Analytics retention period in days')
@allowed([30, 60, 90, 120, 180, 365, 730])
param logRetentionDays int = 30

@description('Enabled monitoring solutions')
param enabledSolutions object = {
  securityInsights: true
  updateManagement: true
  changeTracking: true
}

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

// Management Group Module
module managementGroups 'modules/management-groups.bicep' = {
  name: 'mg-${prefix}-deployment'
  params: {
    prefix: prefix
    managementGroupNames: managementGroupNames
  }
}

// Create Management Group Structure
module mgStructure 'modules/management-groups.bicep' = {
  name: 'mg-structure-deployment'
  scope: tenant()
  params: {
    prefix: prefix
    managementGroupNames: managementGroupNames
  }
}

@description('The subscription ID where resources will be deployed')
param targetSubscriptionId string

// Variables for resource group
var platformRGName = '${prefix}-${environment}-platform-rg'

// Deploy subscription level resources
module subscriptionDeploy 'subscription.bicep' = {
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
}

// Policy Definitions Module
module policyDefinitions 'modules/policy-definitions.bicep' = {
  name: 'policy-${environment}-deployment'
  scope: managementGroup(managementGroupNames.platform)
  params: {
    location: location
    prefix: prefix
  }
  dependsOn: [
    managementGroups
  ]
}
