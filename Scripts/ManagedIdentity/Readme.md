# Overview 

# Setup
```bash
    RG="DevSub01_Test_RG"
    sb="bjdsb001"
    vm="bjdvm001"
    az group create -n ${RG} -l southcentralus
    $id=$(az servicebus namespace create -n ${SB} -g ${RG} -o tsv --query id)
    az servicebus queue create -n data --namespace-name ${SB} -g ${RG}
    az vm create -n ${VM} -g ${RG} --image ubuntults --assign-identity --ssh-key-values ~/.ssh/id_rsa.pub
    $msi = $(az vm identity show -n ${VM}  -g ${RG} -o tsv --query principalId)
    az role assignment create --assignee-object-id $msi --role "Azure Service Bus Data Sender"  --scope $id
```
# Execute
* $ip=$(az vm list-ip-addresses -n ${VM} -g ${RG} -o tsv --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress"
* scp .\Program.cs .\servicebus.csproj brian@{$IP}:/home/brian/.
* ssh brian@${IP}
* Install [dotnet core](https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu#1804-)
    * wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    * sudo dpkg -i packages-microsoft-prod.deb
    * sudo apt-get update
    * sudo apt-get install -y apt-transport-https  && \
        sudo apt-get update && \
        sudo apt-get install -y dotnet-sdk-3.1
* dotnet restore
* dotnet build
* dotnet run 

# Validate 
* 