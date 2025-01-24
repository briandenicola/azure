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

# List all repositories in the ACR
echo -e "\033[1m\e[38;5;45mListing all repositories in ACR: ${ACR_NAME}"
repositories=$(az acr repository list --name ${ACR_NAME} --output tsv)

# Loop through each repository
for repo in ${repositories}; do
    manifestCount=$(az acr repository show --name ${ACR_NAME} --repository ${repo} --query manifestCount --output tsv)
    echo -e "-----------------------------------------------------------------------------------------------------"
    echo -e "🫙 Repo: ${repo} (${manifestCount} manifests)"
    echo -e "-----------------------------------------------------------------------------------------------------"
    az acr repository show-tags --name ${ACR_NAME} --repository ${repo} --query "[].{Tag: digest, LastUpdated: lastUpdateTime}" --output table --detail
    echo -e " "
done