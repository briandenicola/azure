 #!/bin/bash 
 
while (( "$#" )); do
  case "$1" in
    -n|--acr-name)
      ACR_NAME=$2
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

let now=`date +%s`

# List all repositories in the ACR
echo -e "\033[1m\e[38;5;45mListing all repositories in ACR: ${ACR_NAME}"
repositories=$(az acr repository list --name ${ACR_NAME} --output tsv)

printf "%-10s %-30s %-80s %-30s %-5s\n" "Registry" "Repo" "Tag" "Last Updated" "Age"
printf "%-10s %-30s %-80s %-30s %-5s\n" "------" "----" "----" "---" "----"

# Loop through each repository
for repo in ${repositories}; do
    details=$(az acr repository show-tags --name ${ACR_NAME} --repository ${repo} --query "[].{Tag: digest, LastUpdated: lastUpdateTime}" --output json --detail)
    
    for tag in $(echo "${details}" | jq -r '.[].Tag'); do
        last_updated=$(echo "${details}" | jq -r --arg tag "$tag" '.[] | select(.Tag == $tag) | .LastUpdated')
        last_updated_epoch=$(date -d "$last_updated" +%s)
        age=$(( (now - last_updated_epoch) / 86400 )) # Convert seconds to days

        printf "%-10s %-30s %-80s %-30s %-5s\n" "${ACR_NAME}" "${repo}" "${tag}" "${last_updated}" "${age} days"
    done
done