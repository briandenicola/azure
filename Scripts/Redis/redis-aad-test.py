import redis
from azure.identity import DefaultAzureCredential,AzureCliCredential

scope = "acca5fbb-b7e4-4009-81f1-37e38fd66d78/.default"
host = "cod-29415-cache.redis.cache.windows.net"
port = 6380
user_name = "3b66ba55-4bf7-432e-9e21-6219f4f91c1c" #Object ID of the Managed Identity assigned to Redis

cred = AzureCliCredential()
token = cred.get_token(scope)
r = redis.Redis(host=host,
                port=port,
                ssl=True,
                username=user_name,
                password=token.token,
                decode_responses=True)

print("Get Az:key1 == " + r.get("Az:key1"))
print("Set Az:key1")
r.set("Az:key1", "value2")
print("Get Az:key1" + r.get("Az:key1"))
