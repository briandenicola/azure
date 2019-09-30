 #!/bin/bash 
 
export vmName=$1
export rgName=$2
export port=$3
export ipAddress=$4

#az login 

subid=`az account show -o tsv --query "id"`       
listUri="https://management.azure.com/subscriptions/$subid/providers/Microsoft.Security/jitNetworkAccessPolicies?api-version=2015-06-01-preview"

ascPolicy=`az rest -m GET --uri $listUri -o json --query "value"`
ascName=`echo $ascPolicy | jq ".[0].name" | tr -d '"'`   
ascLocation=`echo $ascPolicy | jq ".[0].location" | tr -d '"'`

requestUri="https://management.azure.com/subscriptions/$subid/resourceGroups/$rgName/providers/Microsoft.Security/locations/$ascLocation/jitNetworkAccessPolicies/$ascName/initiate?api-version=2015-06-01-preview"

if [[ -z "${ipAddress}" ]]; then
  allowedIPAddress="0.0.0.0/0"
else
  allowedIPAddress="${ipAddress}"
fi

read -d '' requestBody << EOF
{
  \"virtualMachines\": [
    {
      \"id\": \"/subscriptions/$subid/resourceGroups/$rgName/providers/Microsoft.Compute/virtualMachines/$vmName\",
      \"ports\": [
        {
          \"number\": $port,
          \"duration\": \"PT3H\",
          \"allowedSourceAddressPrefix": \"$allowedIPAddress\"
        }
      ]
    }
  ]
}
EOF

az rest -m post --uri $requestUri --body "$requestBody" --verbose 