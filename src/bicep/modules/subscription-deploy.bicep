targetScope = 'subscription'

@description('The prefix for resource names')
param prefix string

@description('The environment (prod, dev, test, qa)')
param environment string

@description('The Azure region for deployment')
param location string

@description('Name of the resource group to create')
param rgName string

@description('Tags to be applied to all resources')
param tags object

resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: tags
}

output resourceGroupName string = platformResourceGroup.name
