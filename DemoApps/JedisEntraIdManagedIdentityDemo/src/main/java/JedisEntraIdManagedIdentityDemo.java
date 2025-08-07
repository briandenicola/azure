import java.util.Set;

import redis.clients.jedis.DefaultJedisClientConfig;
import redis.clients.jedis.HostAndPort;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.RedisCredentials;
import redis.clients.jedis.UnifiedJedis;
import redis.clients.jedis.authentication.*;

import redis.clients.authentication.core.*;
import redis.clients.authentication.entraid.*;
import redis.clients.authentication.entraid.ManagedIdentityInfo.UserManagedIdentityType;

public class JedisEntraIdManagedIdentityDemo 
{   
    private static final int REDIS_PORT = 6380; // SSL port for Azure Managed Redis

    private static final String REDIS_HOST = System.getenv("AZURE_REDIS_CACHE_HOSTNAME"); //"cockatoo-20634-cache.redis.cache.windows.net";
    private static final String USER_ASSIGNED_MANAGED_IDENTITY_CLIENT_ID = System.getenv("AZURE_REDIS_CLIENT_CLIENT_ID"); //"30c12a4c-f827-49a0-ad6a-476d56537e7b";
    private static final String USER_ASSIGNED_MANAGED_IDENTITY_OBJECT_ID = System.getenv("AZURE_REDIS_CLIENT_OBJECT_ID"); //"23c6baea-a682-4db1-887f-8475271457a0";
    private static final String scopes = "https://redis.azure.com/.default";

    public static void main(String[] args) {
        System.out.println("=== Azure Redis with User Assigned Managed Identity Demo ===\n");
        
        JedisPool pool = null;
        Jedis jedis = null;
        boolean useSsl = true;

        try {

            TokenAuthConfig authConfig = EntraIDTokenAuthConfigBuilder.builder()
                .expirationRefreshRatio(0.25f)
                .lowerRefreshBoundMillis(100)
                .tokenRequestExecTimeoutInMs(100) 
                .maxAttemptsToRetry(10)
                .delayInMsToRetry(200)
                .userAssignedManagedIdentity
                    UserManagedIdentityType.CLIENT_ID,
                    USER_ASSIGNED_MANAGED_IDENTITY_CLIENT_ID
                )
                .scopes(Set.of(scopes))
                .build();

            AuthXManager authXManager = new AuthXManager(authConfig);
            authXManager.start();

            RedisCredentials credentials = authXManager.get();
            System.out.println("   Credentials obtained: " + credentials.getPassword());

            DefaultJedisClientConfig config = DefaultJedisClientConfig.builder()
                .authXManager(authXManager)
                .ssl(useSsl)
                .build();

            UnifiedJedis jedis2 = new UnifiedJedis(
                new HostAndPort(REDIS_HOST, REDIS_PORT),
                config
            );
            System.out.println("   ✓ Redis connection established");

            System.out.println("\nPerforming Redis operations...");
            System.out.println( "\nCache Command  : Ping" );
            System.out.println( "Cache Response : " + jedis2.ping());

            // Simple get and put of integral data types into the cache
            System.out.println( "\nCache Command  : GET Message" );
            System.out.println( "Cache Response : " + jedis2.get("Message"));

            System.out.println( "\nCache Command  : SET Message" );
            System.out.println( "Cache Response : " + jedis2.set("Message", "Hello! The cache is working from Java!"));

            // Demonstrate "SET Message" executed as expected...
            System.out.println( "\nCache Command  : GET Message" );
            System.out.println( "Cache Response : " + jedis2.get("Message"));
            
        } 
        catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        } 
        finally {
            // Cleanup
            if (jedis != null && jedis.isConnected()) {
                jedis.close();
                pool.close();
                System.out.println("\n✓ Redis connection pool closed");
            }
        }

        System.out.println("\n=== Demo completed ===");        
    }
}