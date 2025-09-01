targetScope = 'resourceGroup'

@description('Log Analytics workspace name')
param workspaceName string

@description('Azure region for deployment')
param location string

@description('Enabled monitoring solutions')
param enabledSolutions object

@description('Tags to be applied to resources')
param tags object

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspaceName
}

// Security Insights Solution
resource securityInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if(enabledSolutions.securityInsights) {
  name: 'SecurityInsights(${workspace.name})'
  location: location
  tags: tags
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: 'SecurityInsights(${workspace.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
  }
}

// Update Management Solution
resource updateManagement 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if(enabledSolutions.updateManagement) {
  name: 'Updates(${workspace.name})'
  location: location
  tags: tags
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: 'Updates(${workspace.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/Updates'
    promotionCode: ''
  }
}

// Change Tracking Solution
resource changeTracking 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if(enabledSolutions.changeTracking) {
  name: 'ChangeTracking(${workspace.name})'
  location: location
  tags: tags
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: 'ChangeTracking(${workspace.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/ChangeTracking'
    promotionCode: ''
  }
}
