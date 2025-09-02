targetScope = 'tenant'

@description('Prefix for resource names')
param prefix string

@description('Deployment environment (dev/test/prod)')
@allowed(['dev','test','prod','qa'])
param environment string

@description('Azure region for platform resource group')
param location string = 'eastus'

@description('Tags applied to all resources')
param tags object = {}

@description('Management group custom names (optional)')
param mgCustomNames object = {}

@description('Log retention days')
param logRetentionDays int = 30

// --- Management Group Hierarchy ---
var managementGroupNames = union({
  platform: '${prefix}-platform'
  identity: '${prefix}-identity'
  management: '${prefix}-mgmt'
  connectivity: '${prefix}-connectivity'
  landingZones: '${prefix}-landingzones'
}, mgCustomNames)

module managementGroups 'modules/management-groups.bicep' = {
  name: 'mg-bootstrap'
  params: {
    prefix: prefix
    managementGroupNames: managementGroupNames
  }
}

// --- Platform Resource Group ---
var platformRGName = '${prefix}-${environment}-platform-rg'
resource platformRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: platformRGName
  location: location
  tags: tags
}

// --- Logging Resource Group ---
var loggingRGName = '${prefix}-${environment}-logging-rg'
resource loggingRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: loggingRGName
  location: location
  tags: tags
}

// --- Log Analytics Workspace ---
module logAnalytics 'modules/logging/log-analytics.bicep' = {
  name: 'log-analytics-bootstrap'
  scope: resourceGroup(loggingRG.name)
  params: {
    workspaceName: '${prefix}-${environment}-logs'
    location: location
    retentionDays: logRetentionDays
    tags: tags
  }
}

// --- Outputs ---
output managementGroupIds object = managementGroups.outputs.managementGroupIds
output platformRGName string = platformRG.name
output loggingRGName string = loggingRG.name
output workspaceId string = logAnalytics.outputs.workspaceId
