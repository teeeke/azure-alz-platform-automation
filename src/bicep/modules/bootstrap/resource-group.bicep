// Save as: /bicep/modules/bootstrap/resource-group.bicep
targetScope = 'subscription'

@description('Name of the resource group to create')
param resourceGroupName string

@description('Location for the resource group')
param location string

@description('Tags to apply to the resource group')
param tags object = {}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

output resourceGroupName string = resourceGroup.name
output resourceGroupId string = resourceGroup.id
