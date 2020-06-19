#!/bin/bash

while (( "$#" )); do
  case "$1" in
    -s|--subscription-name)
        subscription=$2
        shift 2
        ;;
    -g|--resource-group)
        RG=$2
        shift 2
        ;;
    -n|--name)
        apimName=$2
        shift 2
        ;;
    --gateway)
        gateway=$2
        shift 2
        ;;
    -k|--key)
        keyType=$2
        shift 2
        ;;
    -h|--help)
      echo "Usage: ./rotate.sh -n {AP Management Name} -g {Resource Group} --gateway {gateway} -k {primary|secondary} -s {Subscription Name}"
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

echo "Set Azure Subscription to ${subscription}"
az account set -s ${subscription}
id=`az account show -o tsv --query id`
uri="https://management.azure.com/subscriptions/${id}/resourceGroups/${RG}/providers/Microsoft.ApiManagement/service/${apimName}/gateways/${gateway}"

echo "Get Initial Keys for ${apimName}'s ${gateway} gateway"
az rest --method POST --uri "${uri}/listKeyS?api-version=2019-12-01" 

expiry=`date --date='30 days' +"%Y-%m-%dT%H:%m:00Z"`
echo "Get Token set to expired on ${expiry}"
token=`az rest --method POST --uri "${uri}/generateToken/?api-version=2019-12-01" --body "{ \"expiry\": \"${expiry}\", \"keyType\": \"${keyType}\" }" | jq .value | tr -d "\"" `

echo "Update Secret in Kubernetes"
kubectl delete secret ${gateway}-token
kubectl create secret generic ${gateway}-token --from-literal=value="GatewayKey ${token}"  --type=Opaque
kubectl rollout restart deployment ${gateway}
sleep 5

echo "Get Status"
kubectl logs deployment/${gateway}

if [ $keyType == "primary" ]; then 
    rotatedKey="secondary"
else
    rotatedKey="primary"
fi

echo "Rotate ${rotatedKey} Key"
az rest --method POST --uri "${uri}/regenerateKey?api-version=2019-12-01" --body "{ \"keyType\": \"${rotatedKey}\" }" 
az rest --method POST --uri "${uri}/listKeyS?api-version=2019-12-01" 