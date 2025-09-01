targetScope = 'tenant'

@description('The management group prefix for the hierarchy')
param mgPrefix string

@description('The location for the deployment')
param location string = deployment().location

// Management Group Module
module managementGroups 'modules/management-groups.bicep' = {
  name: 'mg-${mgPrefix}-deployment'
  params: {
    mgPrefix: mgPrefix
  }
}

// Policy Definitions Module
module policyDefinitions 'modules/policy-definitions.bicep' = {
  name: 'policy-definitions-deployment'
  params: {
    location: location
  }
  dependsOn: [
    managementGroups
  ]
}

// Logging and Monitoring Module
module logging 'modules/logging.bicep' = {
  name: 'logging-deployment'
  params: {
    location: location
  }
  dependsOn: [
    managementGroups
  ]
}
