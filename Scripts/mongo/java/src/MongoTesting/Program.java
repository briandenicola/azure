package MongoTesting;

import org.bson.Document;

import com.mongodb.BasicDBObject;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Iterator; 
import java.util.Map; 
  
public class Program {
	
    public static void main(String[] args)
    {
        MongoClient mongoClient = new MongoClient(new MongoClientURI("mongodb://bjdmongo001:<<PASSWORD>>@bjdmongo001.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@bjdmongo001@"));
        MongoDatabase database = mongoClient.getDatabase("db001");
        MongoCollection<Document> collection = database.getCollection("loans001");

        System.out.println( "Connected to Mongo" );  
        
        try {
            
            //File file = new File("../brian.large.json");
            File file = new File("../sha.notworking.json");
            //File file = new File("../philip.orig.json");
            
            byte[] data = Files.readAllBytes(file.toPath());           
            collection.insertOne(Document.parse(new String(data)));

            Document stats = database.runCommand(new Document("getLastRequestStatistics", 1));
            Double requestCharge = stats.getDouble("RequestCharge");
            System.out.println( "Request Charge - " + String.valueOf(requestCharge) );  
        } 
        catch(Exception e) {
            e.printStackTrace();           
        } finally {
        	if (mongoClient != null) {
        		mongoClient.close();
        	}
        }
    }
}
