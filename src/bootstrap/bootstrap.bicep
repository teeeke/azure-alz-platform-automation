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

@description('Array of principal IDs for RBAC assignments')
param principalIds array

@description('Array of role definition IDs for RBAC assignments')
param rolesArray array

@description('Subscription ID for resource group deployment')
param subscriptionId string

@description('Optional enabled monitoring solutions')
param enabledSolutions object = {
  securityInsights: true
  updateManagement: true
  changeTracking: true
}

// ---------------------------
// MANAGEMENT GROUPS
// ---------------------------
module managementGroups '../bicep/modules/bootstrap/management-groups.bicep' = {
  name: 'mg-deployment'
  params: {
    prefix: prefix
    mgCustomNames: mgCustomNames
  }
}

// ---------------------------
// RESOURCE GROUP
// ---------------------------
module resourceGroupModule '../bicep/modules/bootstrap/resource-group.bicep' = {
  name: 'rg-deployment'
  scope: subscription(subscriptionId)
  params: {
    resourceGroupName: '${prefix}-${environment}-logging-rg'
    location: location
    tags: tags
  }
}

// ---------------------------
// POLICY DEFINITIONS
// ---------------------------
module policyDefinitions '../bicep/modules/bootstrap/policy-definitions.bicep' = {
  name: 'policy-definitions-deployment'
  scope: managementGroup('${prefix}-platform')
  dependsOn: [
    managementGroups
  ]
  params: {
    prefix: prefix
    location: location
    tags: tags
  }
}

// ---------------------------
// POLICY ASSIGNMENTS
// ---------------------------
module policyAssignments '../bicep/modules/bootstrap/policy-assignments.bicep' = {
  name: 'policy-assignments-deployment'
  scope: managementGroup('${prefix}-platform')
  params: {
    prefix: prefix
    policyDefinitions: policyDefinitions.outputs.policyIds
    managementGroupId: '${prefix}-platform'
  }
}

// ---------------------------
// LOG ANALYTICS
// ---------------------------
module logAnalytics '../bicep/modules/bootstrap/log-analytics.bicep' = {
  name: 'log-analytics-deployment'
  scope: resourceGroup(subscriptionId, '${prefix}-${environment}-logging-rg')
  dependsOn: [
    resourceGroupModule
  ]
  params: {
    workspaceName: '${prefix}-${environment}-logs'
    location: location
    retentionDays: logRetentionDays
    tags: tags
  }
}

// ---------------------------
// RBAC ASSIGNMENTS
// ---------------------------
module rbacAssignments '../bicep/modules/bootstrap/rbac-assignment.bicep' = {
  name: 'rbac-deployment'
  scope: managementGroup('${prefix}-platform')
  dependsOn: [
    managementGroups
  ]
  params: {
    prefix: prefix
    roles: rolesArray
    principalIds: principalIds
  }
}

// ---------------------------
// SECURITY BASELINES
// ---------------------------
module securityBaselines '../bicep/modules/bootstrap/security-baseline.bicep' = {
  name: 'security-baselines-deployment'
  scope: managementGroup('${prefix}-platform')
  dependsOn: [
    managementGroups
  ]
  params: {
    prefix: prefix
    tags: tags
  }
}

// ---------------------------
// OUTPUTS
// ---------------------------
output platformMGId string = '${prefix}-platform'
output policyIds array = policyDefinitions.outputs.policyIds
output assignmentIds array = policyAssignments.outputs.assignmentIds
output logWorkspaceId string = logAnalytics.outputs.workspaceId
output rbacAssignmentIds array = rbacAssignments.outputs.roleAssignmentIds
output securityBaselineId string = securityBaselines.outputs.securityBaselineId
output resourceGroupName string = resourceGroupModule.outputs.resourceGroupName
