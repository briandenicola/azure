#!/bin/bash

while (( "$#" )); do
  case "$1" in
    -n|--acr-name)
      ACR_NAME=$2
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./acr-container-purge.sh -n {ACR Name}"
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

REPOS=`az acr repository list --name ${ACR_NAME} --output tsv`
for REPO_NAME in $REPOS; do

  tags=`az acr repository show-tags --name ${ACR_NAME} --repository ${REPO_NAME} --orderby time_asc --output tsv --only-show-errors`
  tags_array=($tags)
  num_tags=${#tags_array[@]}

  if [ $num_tags -gt 1 ]; 
  then
      for ((i=0; i<$num_tags-1; i++)); 
      do
          tag=${tags_array[$i]}
          echo "${REPO_NAME}: Deleting tag: ${tag}"
          az acr repository delete --name ${ACR_NAME} --repository ${REPO_NAME} --tag ${tag} --yes --only-show-errors
      done
  else
      echo "${REPO_NAME}: Only one tag found, no tags to delete. Checking untagged images..."
      UNTAGGED_CONTAINERS=`az acr manifest list-metadata --name ${REPO_NAME} --registry ${ACR_NAME} --query "[?tags[0]==null].digest" --output tsv --only-show-errors`

      for UNTAGGED in ${UNTAGGED_CONTAINERS}; do
        echo "${REPO_NAME}: Purging Untagged image - ${UNTAGGED}..."
        az acr repository delete --name ${ACR_NAME} --image ${REPO_NAME}@${UNTAGGED} --yes --only-show-errors
      done
  fi
done