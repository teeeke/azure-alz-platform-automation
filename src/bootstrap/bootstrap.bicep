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

@description('Optional enabled monitoring solutions')
param enabledSolutions object = {
  securityInsights: true
  updateManagement: true
  changeTracking: true
}

// ---------------------------
// MANAGEMENT GROUPS
// ---------------------------
module managementGroups '../../bicep/modules/bootstrap/management-groups.bicep' = {
  name: 'mg-deployment'
  params: {
    prefix: prefix
    mgCustomNames: mgCustomNames
  }
}

// ---------------------------
// POLICY DEFINITIONS
// ---------------------------
module policyDefinitions '../../bicep/modules/bootstrap/policy-definitions.bicep' = {
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
// POLICY ASSIGNMENTS
// ---------------------------
module policyAssignments '../../bicep/modules/bootstrap/policy-assignments.bicep' = {
  name: 'policy-assignments-deployment'
  scope: managementGroup(managementGroups.outputs.platformId)
  params: {
    prefix: prefix
    policyDefinitions: policyDefinitions.outputs.policyIds
    managementGroupId: managementGroups.outputs.platformId
  }
  dependsOn: [
    policyDefinitions
  ]
}

// ---------------------------
// LOG ANALYTICS
// ---------------------------
module logAnalytics '../../bicep/modules/bootstrap/log-analytics.bicep' = {
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
// RBAC ASSIGNMENTS
// ---------------------------
module rbacAssignments '../../bicep/modules/bootstrap/rbac-assignments.bicep' = {
  name: 'rbac-deployment'
  scope: managementGroup(managementGroups.outputs.platformId)
  params: {
    prefix: prefix
    roles: rolesArray
    principalIds: principalIds
  }
  dependsOn: [
    managementGroups
  ]
}

// ---------------------------
// SECURITY BASELINES
// ---------------------------
module securityBaselines '../../bicep/modules/bootstrap/security-baselines.bicep' = {
  name: 'security-baselines-deployment'
  scope: managementGroup(managementGroups.outputs.platformId)
  params: {
    prefix: prefix
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
output policyIds array = policyDefinitions.outputs.policyIds
output assignmentIds array = policyAssignments.outputs.assignmentIds
output logWorkspaceId string = logAnalytics.outputs.workspaceId
output rbacAssignmentIds array = rbacAssignments.outputs.roleAssignmentIds
output securityBaselineId string = securityBaselines.outputs.securityBaselineId
