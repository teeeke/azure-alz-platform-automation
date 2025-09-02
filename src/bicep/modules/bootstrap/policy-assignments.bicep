targetScope = 'managementGroup'

@description('The prefix for resource names')
param prefix string

@description('The policy definitions to assign')
param policyDefinitions array

@description('The management group ID where policies will be assigned')
param managementGroupId string

// Deploy Policy Assignments
resource policyAssignments 'Microsoft.Authorization/policyAssignments@2021-06-01' = [
  for policy in policyDefinitions: {
    name: '${prefix}-${policy.name}-assignment'
    scope: managementGroup(managementGroupId) // correct scope
    properties: {
      displayName: '${policy.displayName} Assignment'
      policyDefinitionId: policy.id
      enforcementMode: 'Default'
      parameters: {}
    }
  }
]

// Outputs
output assignmentIds array = [for (policy, i) in policyDefinitions: {
  name: policy.name
  id: policyAssignments[i].id
}]
