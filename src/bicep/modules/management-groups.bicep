targetScope = 'tenant'

@description('Prefix for the management group hierarchy')
param prefix string

@description('Management group display names')
param managementGroupNames object

@description('Tags to be applied to all resources')
param tags object = {}

// Create Platform Management Groups
resource platformMG 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: '${prefix}-platform'
  properties: {
    displayName: managementGroupNames.platform
    details: {
      parent: {
        id: tenant().tenantId
      }
    }
  }
  tags: tags
}

// Identity Management Group
resource identityMG 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupNames.identity
  properties: {
    displayName: 'Identity'
    details: {
      parent: {
        id: platformMG.id
      }
    }
  }
}

// Management Management Group
resource managementMG 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupNames.management
  properties: {
    displayName: 'Management'
    details: {
      parent: {
        id: platformMG.id
      }
    }
  }
}

// Connectivity Management Group
resource connectivityMG 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupNames.connectivity
  properties: {
    displayName: 'Connectivity'
    details: {
      parent: {
        id: platformMG.id
      }
    }
  }
}

// Landing Zones Management Group
resource landingZonesMG 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupNames.landingZones
  properties: {
    displayName: 'Landing Zones'
    details: {
      parent: {
        id: tenant().tenantId
      }
    }
  }
}

// Corp Landing Zone Management Group
resource corpMG 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupNames.corp
  properties: {
    displayName: 'Corp'
    details: {
      parent: {
        id: landingZonesMG.id
      }
    }
  }
}

// Online Landing Zone Management Group
resource onlineMG 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupNames.online
  properties: {
    displayName: 'Online'
    details: {
      parent: {
        id: landingZonesMG.id
      }
    }
  }
}

// Sandbox Management Group
resource sandboxMG 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupNames.sandbox
  properties: {
    displayName: 'Sandbox'
    details: {
      parent: {
        id: tenant().tenantId
      }
    }
  }
}

// Decommissioned Management Group
resource decommissionedMG 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupNames.decommissioned
  properties: {
    displayName: 'Decommissioned'
    details: {
      parent: {
        id: tenant().tenantId
      }
    }
  }
}

// Outputs for use in other modules
output platformMGId string = platformMG.id
output identityMGId string = identityMG.id
output managementMGId string = managementMG.id
output connectivityMGId string = connectivityMG.id
output landingZonesMGId string = landingZonesMG.id
output corpMGId string = corpMG.id
output onlineMGId string = onlineMG.id
output sandboxMGId string = sandboxMG.id
output decommissionedMGId string = decommissionedMG.id
