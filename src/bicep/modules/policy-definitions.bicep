targetScope = 'managementGroup'

@description('The prefix for resource names')
param prefix string

@description('The environment (prod, dev, test)')
param environment string

@description('The Azure region for deployment')
param location string

@description('Tags to be applied to all resources')
param tags object

// Variables
var policyDefinitions = [
  {
    name: 'Require-Resource-Tags'
    displayName: 'Require specified tags on resources'
    description: 'Requires specified tags when deploying resources'
    policy: {
      if: {
        allOf: [
          {
            field: 'tags.Environment'
            exists: false
          }
          {
            field: 'tags.CostCenter'
            exists: false
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
  {
    name: 'Allowed-Locations'
    displayName: 'Allowed locations for resource deployment'
    description: 'This policy enables you to restrict the locations your organization can specify when deploying resources'
    policy: {
      if: {
        not: {
          field: 'location'
          in: [
            location
          ]
        }
      }
      then: {
        effect: 'deny'
      }
    }
  }
]

// Policy Definitions
resource policies 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for policy in policyDefinitions: {
  name: '${prefix}-${policy.name}'
  properties: {
    displayName: policy.displayName
    description: policy.description
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Custom'
      tags: tags
    }
    policyRule: policy.policy
  }
}]

// Policy Assignments
resource policyAssignments 'Microsoft.Authorization/policyAssignments@2021-06-01' = [for (policy, i) in policyDefinitions: {
  name: '${prefix}-${policy.name}-assignment'
  properties: {
    displayName: '${policy.displayName} Assignment'
    policyDefinitionId: policies[i].id
    parameters: {}
  }
}]

// Outputs
output policyIds array = [for (policy, i) in policyDefinitions: {
  name: policy.name
  id: policies[i].id
}]
