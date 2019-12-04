import os
import re
import sys

from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.resource import ResourceManagementClient

TENANT_ID = os.environ['AZURE_TENANTID']
CLIENT_ID = os.environ['AZURE_CLIENTID']
CLIENT_KEY = os.environ['AZURE_CLIENTSECRET']
SUBSCRIPTION_ID = os.environ['AZURE_SUBSCRIPTIONID'] 

#GROUP_NAME = "DevSub01_PythonTesting_RG"
#RESOURCE_ID = "/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Storage/storageAccounts/teststorage001".format(SUBSCRIPTION_ID, GROUP_NAME)

GROUP_NAME = sys.argv[1]
RESOURCE_ID = sys.argv[2]

def print_item(group):
    """Print a ResourceGroup instance."""
    print("\tName: {}".format(group.name))
    print("\tId: {}".format(group.id))
    print("\tLocation: {}".format(group.location))
    print("\tTags: {}".format(group.tags))

def get_latest_api_version(client, namespace,component ):
    provider_object = client.providers.get(namespace)
    resource_type = [x for x in provider_object.resource_types if x.resource_type == component]
    return resource_type[0].api_versions[0]

def get_resource_provider_from_id(id):
    m = re.search('providers/(\w+.\w+)/(\w+)', id)
    return m.group(1), m.group(2)

if __name__ == "__main__":
    
    credentials = ServicePrincipalCredentials(
        client_id = CLIENT_ID,
        secret = CLIENT_KEY,
        tenant = TENANT_ID
    )

    client = ResourceManagementClient(credentials, SUBSCRIPTION_ID) 
    ns, component = get_resource_provider_from_id(RESOURCE_ID)
    api_version = get_latest_api_version(client, ns, component)  
    
    resource = client.resources.get_by_id(RESOURCE_ID, api_version)
 
    key = 'Creator'
    if not key in resource.tags:
        """Adding Key to Resource"""
        resource.tags[key] = "Sample Creator"
        updated_resource = {
            'tags': resource.tags
        }
        client.resources.update_by_id(RESOURCE_ID, api_version, updated_resource)

    for item in client.resources.list_by_resource_group(GROUP_NAME):
        print_item(item)