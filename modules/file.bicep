@description('Name of the file as it is stored in the file share')
param filename string = 'file.txt'

@description('UTC timestamp used to create distinct deployment scripts for each deployment')
param utcValue string = utcNow()

@description('Name of the file share')
param fileShareName string = 'datashare'

module storage 'storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    deployFile: true
    entityName: fileShareName
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-upload-file-${utcValue}'
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
        value: loadTextContent('../data/file.txt')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${filename} && az storage file upload --source ${filename} -s ${fileShareName}'
  }
}
