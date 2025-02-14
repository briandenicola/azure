 #!/bin/bash 
 
while (( "$#" )); do
  case "$1" in
    -n|--acr-name)
      ACR_NAME=$2
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./acr-container-lastupdate.sh -n {ACR Name}"
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
query='[].{Tag: digest, LastUpdated: lastUpdateTime, Size: imageSize, Type: configMediaType}'

# List all repositories in the ACR
echo -e "\033[1m\e[38;5;45mListing all repositories in ACR: ${ACR_NAME}"
repositories=$(az acr repository list --name ${ACR_NAME} --output tsv)

printf "%-10s %-30s %-75s %-20s %-10s %-30s %-5s\n" "Registry" "Repository" "SHA" "Type" "Size" "Last Updated" "Age"
printf "%-10s %-30s %-75s %-20s %-10s %-30s %-5s\n" "------" "----" "----" "---" "----" "---" "----"

# Loop through each repository
for repo in ${repositories}; 
do

    details=$(az acr manifest list-metadata --name ${repo} --registry ${ACR_NAME}  --query "${query}" --output json --only-show-errors)
    
    for tag in $(echo "${details}" | jq -r '.[].Tag'); 
    do
        type=$(echo "${details}" | jq -r --arg tag "$tag" '.[] | select(.Tag == $tag) | .Type')
        size=$(echo "${details}" | jq -r --arg tag "$tag" '.[] | select(.Tag == $tag) | .Size')
        last_updated=$(echo "${details}" | jq -r --arg tag "$tag" '.[] | select(.Tag == $tag) | .LastUpdated')
        last_updated_epoch=$(date -d "$last_updated" +%s)
        age=$(( (now - last_updated_epoch) / 86400 )) # Convert seconds to days
        type=$( echo "${type}" | cut -d'/' -f2 | cut -d'.' -f2-3) #Get the last two parts of the string after splitting by '/' and '.'
        size=$(numfmt --to=iec-i --suffix=B "${size}") #Format size

        printf "%-10s %-30s %-75s %-20s %-10s %-30s %-5s\n" "${ACR_NAME}" "${repo}" "${tag}" "${type}" "${size}" "${last_updated}" "${age} days"
    done
done