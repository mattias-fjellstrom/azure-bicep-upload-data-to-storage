#/bin/bash

# generate SAS token
SAS_TOKEN=$(az storage account generate-sas \
    --permissions a \
    --services t \
    --resource-types o \
    --expiry $SAS_END_DATE \
    --output tsv)

# add message to queue using the REST API
az rest \
    --method post \
    --uri "$REST_URI?$SAS_TOKEN" \
    --headers Date="$DATE_STRING" "Content-Type"="application/json" "Content-Length"="$CONTENT_LENGTH" \
    --body "$TABLE_ROW" \
    --skip-authorization-header