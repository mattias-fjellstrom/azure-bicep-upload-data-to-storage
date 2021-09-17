@description('Name of the blob as it is stored in the blob container')
param filename string = 'blob.txt'

@description('UTC timestamp used to create distinct deployment scripts for each deployment')
param utcValue string = utcNow()

@description('Name of the blob container')
param containerName string = 'data'

module storage 'storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    deployBlob: true
    entityName: containerName
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-upload-blob-${utcValue}'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storage.outputs.accountName
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: storage.outputs.accountKey
      }
      {
        name: 'CONTENT'
        value: loadTextContent('../data/blob.txt')
      }
    ]
    scriptContent: 'echo $CONTENT > ${filename} && az storage blob upload -f ${filename} -c ${containerName} -n ${filename}'
  }
}
