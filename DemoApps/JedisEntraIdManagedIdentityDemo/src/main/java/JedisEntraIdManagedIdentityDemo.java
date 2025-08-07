import com.azure.identity.DefaultAzureCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.core.credential.TokenRequestContext;
import redis.clients.jedis.DefaultJedisClientConfig;
import redis.clients.jedis.Jedis;

public class JedisEntraIdManagedIdentityDemo 
{   
    private static final int REDIS_PORT = 6380; // SSL port for Azure Managed Redis

    private static final String REDIS_HOST = System.getenv("AZURE_REDIS_CACHE_HOSTNAME"); //"cockatoo-20634-cache.redis.cache.windows.net";
    private static final String USER_ASSIGNED_MANAGED_IDENTITY_CLIENT_ID = System.getenv("AZURE_REDIS_CLIENT_CLIENT_ID"); //"30c12a4c-f827-49a0-ad6a-476d56537e7b";
    private static final String USER_ASSIGNED_MANAGED_IDENTITY_OBJECT_ID = System.getenv("AZURE_REDIS_CLIENT_OBJECT_ID"); //"23c6baea-a682-4db1-887f-8475271457a0";

    public static void main(String[] args) {
        System.out.println("=== Azure Redis with User Assigned Managed Identity Demo ===\n");
        
        Jedis jedis = null;
        boolean useSsl = true;

        try {
            
            System.out.println("1. Configuring User Assigned Managed Identity authentication...");
            
            DefaultAzureCredential creds = new DefaultAzureCredentialBuilder()
                .managedIdentityClientId(USER_ASSIGNED_MANAGED_IDENTITY_CLIENT_ID)
                .build();
            System.out.println("   ✓ Credentials provider configured");
            System.out.println("   ✓ Token  provider configured");

            var tokenRequestContext = creds
                    .getToken(new TokenRequestContext()
                            .addScopes("https://redis.azure.com/.default"))
                            .block();
            String token = tokenRequestContext.getToken();

            if (token == null) {
                throw new RuntimeException("Failed to obtain access token");
            }

            System.out.println("\n2. Testing credentials resolution...");
            System.out.println("   ✓ Access token obtained successfully");
            System.out.println("   Token expires at: " + tokenRequestContext.getExpiresAt());
            System.out.println("   Token: " + token);
            
            System.out.println("\n3. Building Redis connection URI...");
            DefaultJedisClientConfig jedisClientConfig = DefaultJedisClientConfig.builder()
                .password(token) // Microsoft Entra access token as password is required.
                .user(USER_ASSIGNED_MANAGED_IDENTITY_OBJECT_ID) 
                .ssl(useSsl)
                .build();
            System.out.println("   ✓ Jedis Client Configured");

            jedis = new Jedis(REDIS_HOST, REDIS_PORT, jedisClientConfig);
            System.out.println("   ✓ Redis connection established");

            System.out.println("\n6. Performing Redis operations...");
            System.out.println( "\nCache Command  : Ping" );
            System.out.println( "Cache Response : " + jedis.ping());

            // Simple get and put of integral data types into the cache
            System.out.println( "\nCache Command  : GET Message" );
            System.out.println( "Cache Response : " + jedis.get("Message"));

            System.out.println( "\nCache Command  : SET Message" );
            System.out.println( "Cache Response : " + jedis.set("Message", "Hello! The cache is working from Java!"));

            // Demonstrate "SET Message" executed as expected...
            System.out.println( "\nCache Command  : GET Message" );
            System.out.println( "Cache Response : " + jedis.get("Message"));

            // Get the client list, useful to see if connection list is growing...
            System.out.println( "\nCache Command  : CLIENT LIST" );
            System.out.println( "Cache Response : " + jedis.clientList());

            
        } 
        catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        } 
        finally {
            // Cleanup
            if (jedis != null && jedis.isConnected()) {
                jedis.close();
                System.out.println("\n✓ Redis connection pool closed");
            }
        }

        System.out.println("\n=== Demo completed ===");        
    }
}