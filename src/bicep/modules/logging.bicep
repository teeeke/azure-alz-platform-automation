targetScope = 'subscription'

@description('The prefix for resource names')
param prefix string

@description('The environment (prod, dev, test)')
param environment string

@description('The Azure region for deployment')
param location string

@description('Number of days to retain logs')
param retentionDays int

@description('Enabled monitoring solutions')
param enabledSolutions object

@description('Tags to be applied to all resources')
param tags object

// Variables
var workspaceName = '${prefix}-${environment}-logs'
var automationAccountName = '${prefix}-${environment}-automation'

// Resource Group
resource logAnalyticsRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${prefix}-${environment}-logging-rg'
  location: location
  tags: tags
}

// Log Analytics Workspace
module logAnalytics 'logging/log-analytics.bicep' = {
  scope: logAnalyticsRG
  name: 'log-analytics-deployment'
  params: {
    workspaceName: workspaceName
    location: location
    retentionDays: retentionDays
    tags: tags
  }
}

// Automation Account
module automationAccount 'logging/automation-account.bicep' = {
  scope: logAnalyticsRG
  name: 'automation-account-deployment'
  params: {
    automationAccountName: automationAccountName
    location: location
    tags: tags
  }
}

// Solutions
module solutions 'logging/solutions.bicep' = if(!empty(enabledSolutions)) {
  scope: logAnalyticsRG
  name: 'solutions-deployment'
  params: {
    workspaceName: workspaceName
    location: location
    enabledSolutions: enabledSolutions
    tags: tags
  }
  dependsOn: [
    logAnalytics
  ]
}

// Outputs
output workspaceId string = logAnalytics.outputs.workspaceId
output workspaceName string = logAnalytics.outputs.workspaceName
output automationAccountId string = automationAccount.outputs.automationAccountId
