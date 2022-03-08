@description('UTC timestamp used to create distinct deployment scripts for each deployment')
param utcValue string = utcNow('u')

@description('Name of the storage table')
param tableName string = 'datatable'

@description('Azure region where resources should be deployed')
param location string = resourceGroup().location

@description('Desired name of the storage account')
param storageAccountName string = uniqueString(resourceGroup().id, deployment().name, 'table')

// set SAS expiration to 30 minutes in the future
var sasEndDate = dateTimeAdd(utcValue, 'PT30M')

// specific datetime format required for REST header
param dateHeader string = utcNow('ddd, d MMM yyyy HH:mm:ss GMT') // e.g. Tue, 30 Aug 2011 01:03:21 GMT

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'

  resource tableService 'tableServices' = {
    name: 'default'

    resource table 'tables' = {
      name: tableName
    }
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-add-table-row-${uniqueString(utcValue)}'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storage.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: storage.listKeys().keys[0].value
      }
      {
        name: 'REST_URI'
        value: '${storage.properties.primaryEndpoints.table}${tableName}'
      }
      {
        name: 'DATE_STRING'
        value: dateHeader
      }
      {
        name: 'TABLE_ROW'
        value: loadTextContent('../data/table.json')
      }
      {
        name: 'CONTENT_LENGTH'
        value: '${length(loadTextContent('../data/table.json'))}'
      }
      {
        name: 'SAS_END_DATE'
        value: sasEndDate
      }
    ]
    scriptContent: loadTextContent('../scripts/table.sh')
  }
}
