targetScope = 'subscription'

@description('Deploy the blob example')
param blobExample bool = false

@description('Deploy the message queue example')
param queueExample bool = false

@description('Deploy the storage table example')
param tableExample bool = false

@description('Deploy the file share example')
param fileExample bool = false

param location string = deployment().location

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-upload-to-storage-example'
  location: location
  tags: {
    'application': 'azure-bicep-upload-data-to-storage'
  }
}

module blob 'modules/blob.bicep' = if (blobExample) {
  name: 'blob-example'
  scope: rg
  params: {
    location: location
  }
}

module queue 'modules/queue.bicep' = if (queueExample) {
  name: 'queue-example'
  scope: rg
  params: {
    location: location
  }
}

module table 'modules/table.bicep' = if (tableExample) {
  name: 'table-example'
  scope: rg
  params: {
    location: location
  }
}

module file 'modules/file.bicep' = if (fileExample) {
  name: 'file-example'
  scope: rg
  params: {
    location: location
  }
}
