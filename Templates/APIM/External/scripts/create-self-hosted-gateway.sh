#!/bin/bash

SUBSCRIPTION_ID=$1
RG=$2
APIM_NAME=$3
GW_LOCATION=$4
GW_NAME="${APIM_NAME}-sgw"

URI="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}/providers/Microsoft.ApiManagement/service/${APIM_NAME}/gateways/${GW_NAME}?api-version=2024-10-01-preview"

BODY=$(cat <<EOF
    {
        "properties": {
            "locationData": {
                "name": "${GW_LOCATION}"
            },
            "description": "Self-hosted gateway"
        }
    }
EOF
)

echo -e "➡️\033[1m\e[38;5;45mCreating Self-Hosted Gateaway for ${APIM_NAME} . . ."
az rest --method put --uri "$URI" --body "${BODY}"