targetScope = 'tenant'

@description('Environment to deploy (dev/test/prod)')
param environment string

@description('Prefix used for all resources')
param prefix string

@description('Azure location for deployment')
param location string

@description('Log Analytics retention period in days')
param logRetentionDays int

@description('Resource tags')
param tags object

@description('Optional custom management group names')
param mgCustomNames object = {}

// ---------------------------
// MODULE: Management Groups
// ---------------------------
module managementGroups 'modules/management-groups.bicep' = {
  name: 'mg-deployment'
  params: {
    prefix: prefix
    mgCustomNames: mgCustomNames
  }
}

// ---------------------------
// MODULE: Policy Definitions
// ---------------------------
module policyDefinitions 'modules/policy-definitions.bicep' = {
  name: 'policy-definitions-deployment'
  scope: managementGroup(managementGroups.outputs.platformId)
  params: {
    prefix: prefix
    location: location
    tags: tags
  }
  dependsOn: [
    managementGroups
  ]
}

// ---------------------------
// MODULE: Log Analytics
// ---------------------------
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'log-analytics-deployment'
  scope: resourceGroup('${prefix}-${environment}-logging-rg')
  params: {
    workspaceName: '${prefix}-${environment}-logs'
    location: location
    retentionDays: logRetentionDays
    tags: tags
  }
  dependsOn: [
    managementGroups
  ]
}

// ---------------------------
// OUTPUTS
// ---------------------------
output platformMGId string = managementGroups.outputs.platformId
output logWorkspaceId string = logAnalytics.outputs.workspaceId
