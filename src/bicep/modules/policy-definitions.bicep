targetScope = 'managementGroup'

@description('The prefix for resource names')
param prefix string

@description('The Azure region for deployment')
param location string

@description('Tags to be applied to resources')
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
      source: 'Azure Landing Zone'
      version: '1.0.0'
    }
    policyRule: policy.policy
  }
}]

// Deploy Policy Assignments
module assignments './policy-assignments.bicep' = {
  name: '${prefix}-policy-assignments'
  scope: managementGroup(managementGroupId)
  params: {
    prefix: prefix
    policyDefinitions: [for (policy, i) in policyDefinitions: {
      name: policy.name
      id: policies[i].id
      displayName: policy.displayName
    }]
    managementGroupId: managementGroupId
  }
}

// Outputs
output policyIds array = [for (policy, i) in policyDefinitions: {
  name: policy.name
  id: policies[i].id
}]
output assignmentIds array = assignments.outputs.assignmentIds
