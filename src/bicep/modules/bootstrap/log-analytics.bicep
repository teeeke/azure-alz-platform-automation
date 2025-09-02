targetScope = 'resourceGroup'

@description('Log Analytics workspace name')
param workspaceName string

@description('Azure location for deployment')
param location string

@description('Retention days')
param retentionDays int

@description('Tags to apply')
param tags object

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: retentionDays
  }
  tags: tags
}

output workspaceId string = logAnalytics.id
output workspaceName string = logAnalytics.name
