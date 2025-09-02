targetScope = 'managementGroup'

@description('Prefix for resource names')
param prefix string

@description('Azure region for deployment')
param location string

@description('Tags to be applied to resources')
param tags object

var policyDefinitions = [
  {
    name: 'Require-Resource-Tags'
    displayName: 'Require specified tags on resources'
    description: 'Requires tags on resources'
    policy: {
      if: {
        anyOf: [
          { field: 'tags.Environment'; exists: false }
          { field: 'tags.CostCenter'; exists: false }
        ]
      }
      then: { effect: 'deny' }
    }
  }
  {
    name: 'Allowed-Locations'
    displayName: 'Allowed locations'
    description: 'Restrict deployment locations'
    policy: {
      if: { not: { field: 'location'; in: [location] } }
      then: { effect: 'deny' }
    }
  }
]

resource policies 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for (policy, i) in policyDefinitions: {
  name: '${prefix}-${policy.name}'
  properties: {
    displayName: policy.displayName
    description: policy.description
    policyType: 'Custom'
    mode: 'All'
    metadata: { category: 'Custom'; source: 'Azure Landing Zone'; version: '1.0.0' }
    policyRule: policy.policy
  }
}]

output policyIds array = [for (policy, i) in policyDefinitions: { name: policy.name; id: policies[i].id }]
