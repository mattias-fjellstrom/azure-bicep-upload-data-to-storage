# Use Azure Bicep to upload data to an Azure Storage Account

![lint](https://github.com/mattias-fjellstrom/azure-bicep-upload-data-to-storage/actions/workflows/lint.yml/badge.svg)

These examples demonstrate how to upload data to the different storage services in a Storage Account using Azure Bicep.

### Motivation

Two reasons why you might want to do this:

- You want to create a certain resource that requires you to point to a script located at a URI in blob storage. You can then upload the blob and then reference it in your other resource, all from the same Bicep deployment. A concrete example for this scenario is if you want to create an Azure Automation runbook. In this case you have to provide a URI to the script that makes up the runbook.
- You want to set up an infrastructure with sample data available in any or all of the storage services for demonstration purposes.

## Prerequisites

- Azure CLI ([install](https://docs.microsoft.com/cli/azure/install-azure-cli))
- Azure Bicep CLI (install with `az bicep install`)
- Set a default subscription with `az account set --subscription <name or id of subscription>`
- You should be an Owner of the subscription you use

## Instructions

Set a location for the deployment. To see available locations run `az account list-locations -o table`.

```bash
location=northeurope
```

### Blob example

A new storage account is created with a blob container. The blob in [data/blob.txt](./data/blob.txt) will be uploaded to the blob container. Deploy the example with the Azure CLI.

```bash
az deployment sub create \
    --name blob-example \
    --location $location \
    --template-file ./main.bicep \
    --parameters blobExample=true
```

### Queue example

A new storage account is created with a message queue. The queue data in [data/queue.xml](./data/queue.xml) will be posted as a message in the queue. The operation requires a SAS token, this is generated using the Azure CLI. There is no direct support to post messages to a storage queue using the Azure CLI, thus the REST API is used through the `az rest` command. The script that generates the SAS token and issues the REST API call is available in [scripts/queue.sh](./scripts/queue.sh). Deploy the example with the Azure CLI.

```bash
az deployment sub create \
    --name queue-example \
    --location $location \
    --template-file ./main.bicep \
    --parameters queueExample=true
```

### Table example

A new storage account is created with a storage table. The table row data in [data/table.json](./data/table.json) will be added as a row in the table. The operation requires a SAS token, this is generated using the Azure CLI. There is no direct support to add a row to a table using the Azure CLI, thus the REST API is used through the `az rest` command. The script that generates the SAS token and issues the REST API call is available in [scripts/table.sh](./scripts/table.sh). Deploy the example with the Azure CLI.

```bash
az deployment sub create \
    --name table-example \
    --location $location \
    --template-file ./main.bicep \
    --parameters tableExample=true
```

### File example

A new storage account is created with a file share. The file in [data/file.txt](./data/file.txt) will be uploaded to the file share. Deploy the example with the Azure CLI.

```bash
az deployment sub create \
    --name file-example \
    --location $location \
    --template-file ./main.bicep \
    --parameters fileExample=true
```

### All examples

Try all examples at the same time.

```bash
az deployment sub create \
    --name all-examples \
    --location $location \
    --template-file ./main.bicep \
    --parameters blobExample=true queueExample=true tableExample=true fileExample=true
```

## Clean-up

Delete the resource group.

```bash
rgName=$(az group list \
    --query "[?@.tags.application && tags.application == 'azure-bicep-upload-data-to-storage'] | [0].name" \
    --output tsv)
az group delete --name $rgName --yes --no-wait
```

## Limitations

- In the current version of Azure Bicep ([v0.5.6](https://github.com/Azure/bicep/releases/tag/v0.5.6)) it is not possible to use dynamic strings in the `loadTextContent` function. This prohibits us from using a loop construct for the deployment script resources, which would have allowed us to add several blobs, queue messages, table rows, and files, in the same deployment. A workaround is to expand the script used to perform the upload in creative ways (e.g. use a loop in Bash).
- Working with blobs and files is convenient because the Azure CLI supports upload operations out of the box. Working with queues and tables is not supported out of the box, which means we have to generate SAS-tokens to authenticate directly to the REST API. This is why separate scripts are provided for these services in order to keep the Bicep code clean.
