@description('Set to true to deploy a blob container')
param deployBlob bool = false

@description('Set to true to deploy a message queue')
param deployQueue bool = false

@description('Set to true to deploy a storage table')
param deployTable bool = false

@description('Set to true to deploy a file share')
param deployFile bool = false

@description('Name of the blob container, message queue, storage table, or file share.')
param entityName string = 'data'

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'st${uniqueString(resourceGroup().id, deployment().name)}'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'

  resource blobService 'blobServices' = if (deployBlob) {
    name: 'default'
    resource container 'containers' = {
      name: entityName
    }
  }

  resource queueService 'queueServices' = if (deployQueue) {
    name: 'default'
    resource queue 'queues' = {
      name: entityName
    }
  }

  resource tableService 'tableServices' = if (deployTable) {
    name: 'default'
    resource table 'tables' = {
      name: entityName
    }
  }

  resource fileService 'fileServices' = if (deployFile) {
    name: 'default'
    resource share 'shares' = {
      name: entityName
    }
  }
}

output accountName string = storage.name
output accountKey string = storage.listKeys().keys[0].value
output endpoints object = storage.properties.primaryEndpoints
