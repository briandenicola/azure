 
# Multiregion Redis Enterprise on Azure

## Infrastructure 
```bash 
    az login --scope https://graph.microsoft.com/.default
    task up
```

## Validate
### Machine 1
```bash
    task environment
    source .env
    task copy
    ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no manager@${SSH_HOST_1}
        git clone https://github.com/briandenicola/tooling
        cd tooling
        bash ./redis-cli.sh
        sudo apt install jq
        KEY=$(uuidgen); echo $KEY 
        redis-cli -h ${REDIS_CACHE_REGION_1} -p 10000 -a ${REDIS_KEY} -c --tls set ${KEY} $(openssl rand -hex 16 | base64)
        redis-cli -h ${REDIS_CACHE_REGION_1} -p 10000 -a ${REDIS_KEY} -c --tls get ${KEY}
 ```

### Machine 2
```bash
    task environment
    source .env
    task copy
    ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no manager@${SSH_HOST_2}
        git clone https://github.com/briandenicola/tooling
        cd tooling
        bash ./redis-cli.sh
        sudo apt install jq
        KEY=__COPIED_FROM_MACHINE_1
        redis-cli -h ${REDIS_CACHE_REGION_2} -p 10000 -a ${REDIS_KEY} -c --tls get ${KEY}
 ```

## Clean Up
```bash
    task down
```