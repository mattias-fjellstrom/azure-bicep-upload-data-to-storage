#/bin/bash

# generate SAS token
SAS_TOKEN=$(az storage account generate-sas \
    --permissions a \
    --services q \
    --resource-types o \
    --expiry $SAS_END_DATE \
    --output tsv)

# add message to queue using the REST API
az rest \
    --method post \
    --uri "$REST_URI?$SAS_TOKEN" \
    --headers Date="$DATE_STRING" \
    --body "$MESSAGE_BODY" \
    --skip-authorization-header