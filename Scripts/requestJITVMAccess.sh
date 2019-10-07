 #!/bin/bash 
 
while (( "$#" )); do
  case "$1" in
    -n|--virtual-machine)
      vmName=$2
      shift 2
      ;;
    -g|--resource-group)
      rgName=$2
      shift 2
      ;;
    -s|--subscription-name)
      subscriptionName=$2
      shift 2
      ;;
    -p|--port)
      port=$2
      shift 2
      ;;
    -a|--ip-address)
      ipAddress=$2
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./requestJITVMAccess.sh -n {VM Name} -g {Resource Group} -s {Subscription} -p {22|3389} -a {IP Address or 0.0.0.0/0 for Any}"
      exit 0
      ;;
    --) 
      shift
      break
      ;;
    -*|--*=) 
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${ipAddress}" ]]; then
  allowedIPAddress="0.0.0.0/0"
else
  allowedIPAddress="${ipAddress}"
fi

if [[ -z "${port}" ]]; then
  port="22"
fi

az account show  >> /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  az login 
fi
az account set -s ${subscriptionName}

echo Getting Subscription Id ${subscriptionName}
subid=`az account show -o tsv --query "id"`       
listUri="https://management.azure.com/subscriptions/${subid}/providers/Microsoft.Security/jitNetworkAccessPolicies?api-version=2015-06-01-preview"

echo Getting ASC Loction and Name
ascPolicy=`az rest -m GET --uri ${listUri} -o json --query "value" --headers content-type=application/json`
ascName=`echo ${ascPolicy} | jq ".[0].name" | tr -d '"'`   
ascLocation=`echo ${ascPolicy} | jq ".[0].location" | tr -d '"'`

requestUri="https://management.azure.com/subscriptions/${subid}/resourceGroups/${rgName}/providers/Microsoft.Security/locations/${ascLocation}/jitNetworkAccessPolicies/${ascName}/initiate?api-version=2015-06-01-preview"



read -d '' requestBody << EOF
{
  \"virtualMachines\": [
    {
      \"id\": \"/subscriptions/$subid/resourceGroups/${rgName}/providers/Microsoft.Compute/virtualMachines/${vmName}\",
      \"ports\": [
        {
          \"number\": ${port},
          \"duration\": \"PT3H\",
          \"allowedSourceAddressPrefix": \"${allowedIPAddress}\"
        }
      ]
    }
  ]
}
EOF

echo Request ASC Policy Update to ${requestUri}
echo Request Body - ${requestBody}
az rest -m post --uri ${requestUri} --body "${requestBody}" --headers content-type=application/json --verbose 