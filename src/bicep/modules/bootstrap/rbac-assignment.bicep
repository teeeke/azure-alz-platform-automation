targetScope = 'managementGroup'

@description('Prefix for resource names')
param prefix string

@description('Array of role assignments to create')
param roles array

@description('Array of principal IDs (users, groups, service principals)')
param principalIds array

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for i in range(0, length(roles)): {
  name: guid(managementGroup().id, principalIds[i], roles[i])
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roles[i])
    principalId: principalIds[i]
    principalType: 'ServicePrincipal'
  }
}]

output roleAssignmentIds array = [for r in roleAssignments: r.id]
