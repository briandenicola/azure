 
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
        source ~/.env
        git clone https://github.com/briandenicola/tooling
        cd tooling
        bash ./redis-cli.sh
        KEY=$(uuidgen); echo $KEY 
        redis-cli -h ${REDIS_CACHE_REGION_1} -p 10000 -a ${REDIS_KEY_1} -c --tls set ${KEY} $(openssl rand -hex 16 | base64)
        redis-cli -h ${REDIS_CACHE_REGION_1} -p 10000 -a ${REDIS_KEY_1} -c --tls get ${KEY}
 ```

### Machine 2
```bash
    task environment
    source .env
    task copy
    ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no manager@${SSH_HOST_2}
        source ~/.env
        git clone https://github.com/briandenicola/tooling
        cd tooling
        bash ./redis-cli.sh
        KEY=__COPIED_FROM_MACHINE_1__
        redis-cli -h ${REDIS_CACHE_REGION_2} -p 10000 -a ${REDIS_KEY_2} -c --tls get ${KEY}
 ```

## Clean Up
```bash
    task down
```