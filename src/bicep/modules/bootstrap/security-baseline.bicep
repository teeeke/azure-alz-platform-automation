targetScope = 'managementGroup'

@description('Prefix for resource names')
param prefix string

@description('Tags to apply')
param tags object

// Example: deploy built-in ASC regulatory compliance initiative
resource securityBaseline 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: '${prefix}-asc-security-baseline'
  properties: {
    displayName: 'Azure Security Baseline'
    description: 'Built-in security baseline for CAF'
    policyType: 'BuiltIn'
    metadata: {
      category: 'Security'
      source: 'CAF Bootstrap'
      version: '1.0.0'
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/2e214eb5-2f92-4f2f-bdd9-c52d5dcf805f' // Example ASC built-in
      }
    ]
  }
  tags: tags
}

output securityBaselineId string = securityBaseline.id
