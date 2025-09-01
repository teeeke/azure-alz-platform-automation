targetScope = 'resourceGroup'

@description('The prefix for resource names')
param prefix string

@description('The environment (prod, dev, test, qa)')
param environment string

@description('The Azure region for deployment')
param location string

@description('Log Analytics retention period in days')
param retentionDays int

@description('Enabled monitoring solutions')
param enabledSolutions object

@description('Resource tags')
param tags object

var logAnalyticsName = '${prefix}-${environment}-law'
var automationAccountName = '${prefix}-${environment}-aa'

// Deploy Log Analytics Workspace
module logAnalytics './log-analytics.bicep' = {
  name: 'log-analytics-deployment'
  params: {
    workspaceName: logAnalyticsName
    location: location
    retentionDays: retentionDays
    tags: tags
  }
}

// Deploy Automation Account
module automationAccount './automation-account.bicep' = {
  name: 'automation-account-deployment'
  params: {
    automationAccountName: automationAccountName
    location: location
    tags: tags
  }
}

// Deploy Monitoring Solutions
module monitoringSolutions './solutions.bicep' = {
  name: 'monitoring-solutions-deployment'
  params: {
    workspaceName: logAnalyticsName
    location: location
    enabledSolutions: enabledSolutions
    tags: tags
  }
}
