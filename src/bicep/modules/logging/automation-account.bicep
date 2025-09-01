targetScope = 'resourceGroup'

@description('Automation account name')
param automationAccountName string

@description('Azure region for deployment')
param location string

@description('Tags to be applied to resources')
param tags object

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: automationAccountName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
    }
  }
}

output automationAccountId string = automationAccount.id
output automationAccountName string = automationAccount.name
