@description('UTC timestamp used to create distinct deployment scripts for each deployment')
param utcValue string = utcNow('u')

@description('Name of the message queue')
param queueName string = 'messagequeue'

@description('Azure region where resources should be deployed')
param location string = resourceGroup().location

@description('Desired name of the storage account')
param storageAccountName string = uniqueString(resourceGroup().id, deployment().name, 'queue')

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

  resource queueService 'queueServices' = {
    name: 'default'

    resource queue 'queues' = {
      name: queueName
    }
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-post-queue-message-${uniqueString(utcValue)}'
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
        value: '${storage.properties.primaryEndpoints.queue}${queueName}/messages'
      }
      {
        name: 'DATE_STRING'
        value: dateHeader
      }
      {
        name: 'MESSAGE_BODY'
        value: loadTextContent('../data/queue.xml')
      }
      {
        name: 'SAS_END_DATE'
        value: sasEndDate
      }
    ]
    scriptContent: loadTextContent('../scripts/queue.sh')
  }
}
