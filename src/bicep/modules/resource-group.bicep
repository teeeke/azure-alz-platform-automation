targetScope = 'subscription'

@description('Name of the resource group')
param name string

@description('Location for the resource group')
param location string

@description('Tags for the resource group')
param tags object

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
  tags: tags
}

output name string = rg.name
output id string = rg.id
