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

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Automation Account
resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: automationAccountName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'Basic'
    }
    publicNetworkAccess: true
    encryption: {
      keySource: 'Microsoft.Automation'
    }
  }
}

// Link Automation Account to Log Analytics
resource linkedService 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  parent: logAnalytics
  name: 'Automation'
  properties: {
    resourceId: automationAccount.id
  }
}

// Deploy solutions if enabled
resource updateManagement 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enabledSolutions.updateManagement) {
  name: 'Updates(${logAnalytics.name})'
  location: location
  properties: {
    workspaceResourceId: logAnalytics.id
  }
  plan: {
    name: 'Updates(${logAnalytics.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/Updates'
    promotionCode: ''
  }
}

resource changeTracking 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enabledSolutions.changeTracking) {
  name: 'ChangeTracking(${logAnalytics.name})'
  location: location
  properties: {
    workspaceResourceId: logAnalytics.id
  }
  plan: {
    name: 'ChangeTracking(${logAnalytics.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/ChangeTracking'
    promotionCode: ''
  }
}

resource securityInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enabledSolutions.securityInsights) {
  name: 'SecurityInsights(${logAnalytics.name})'
  location: location
  properties: {
    workspaceResourceId: logAnalytics.id
  }
  plan: {
    name: 'SecurityInsights(${logAnalytics.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
  }
}

// Outputs
output workspaceId string = logAnalytics.id
output workspaceName string = logAnalytics.name
output automationAccountId string = automationAccount.id
output automationAccountName string = automationAccount.name
