targetScope = 'managementGroup'

@description('Prefix for resource names')
param prefix string

@description('Tags to apply')
param tags object

// Example: deploy custom security baseline initiative
resource securityBaseline 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: '${prefix}-asc-security-baseline'
  properties: {
    displayName: 'Azure Security Baseline'
    description: 'Custom security baseline for CAF'
    policyType: 'Custom'
    metadata: {
      category: 'Security'
      source: 'CAF Bootstrap'
      version: '1.0.0'
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/2e214eb5-2f92-4f2f-bdd9-c52d5dcf805f'
        parameters: {}
      }
    ]
  }
}

output securityBaselineId string = securityBaseline.id
