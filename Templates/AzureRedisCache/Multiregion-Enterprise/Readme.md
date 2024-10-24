 
# Multiregion Redis Enterprise on Azure

## Infrastructure 
```bash 
    az login --scope https://graph.microsoft.com/.default
    task up
```

## Validate
### Generate Environment Details
```bash
    task environment
    source sshenv
    task copy
```

### Machine 1
```bash
    ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no manager@${SSH_HOST_canadacentral}
        source ~/.env
        git clone https://github.com/briandenicola/tooling
        cd tooling
        bash ./redis-cli.sh
        KEY=$(uuidgen); echo $KEY 
        redis-cli -h ${REDIS_CACHE_canadacentral} -p 10000 -a ${REDIS_KEY_eastus2} -c --tls set ${KEY} $(openssl rand -hex 16 | base64)
        redis-cli -h ${REDIS_CACHE_canadacentral} -p 10000 -a ${REDIS_KEY_eastus2} -c --tls get ${KEY}
 ```

### Machine 2..3
```bash
    ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no manager@${SSH_HOST_eastus2}
        source ~/.env
        git clone https://github.com/briandenicola/tooling
        cd tooling
        bash ./redis-cli.sh
        KEY=__COPIED_FROM_MACHINE_1__
        redis-cli -h ${SSH_HOST_eastus2} -p 10000 -a ${REDIS_KEY_2} -c --tls get ${KEY}
 ```

## Clean Up
```bash
    task down
```
