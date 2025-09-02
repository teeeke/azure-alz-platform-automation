targetScope = 'tenant'

@description('Prefix for all management groups')
param prefix string

@description('Optional custom management group names')
param mgCustomNames object = {}

var managementGroupNames = union({
  platform: '${prefix}-platform'
  identity: '${prefix}-identity'
  management: '${prefix}-mgmt'
  connectivity: '${prefix}-connectivity'
  landingZones: '${prefix}-landingzones'
  corp: '${prefix}-corp'
  online: '${prefix}-online'
  sandbox: '${prefix}-sandbox'
  decommissioned: '${prefix}-decom'
}, mgCustomNames)

resource mgPlatform 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupNames.platform
  properties: {
    displayName: 'Platform Management Group'
  }
}

resource mgIdentity 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupNames.identity
  properties: {
    displayName: 'Identity Management Group'
  }
}

output platformId string = mgPlatform.id
