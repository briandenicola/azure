using System;
using System.Dynamic;
using System.Collections.Generic; 
using System.Security.Authentication;
using MongoDB.Driver;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using Newtonsoft.Json;

namespace cosmosdb
{
    
    class GetLastRequestStatisticsCommand : Command<Dictionary<string, object>>
    {
        public override RenderedCommand<Dictionary<string, object>> Render(IBsonSerializerRegistry serializerRegistry)
        {
            return new RenderedCommand<Dictionary<string, object>>(new BsonDocument("getLastRequestStatistics", 1), serializerRegistry.GetSerializer<Dictionary<string, object>>());
        }
    }

    class Program
    {
        private static readonly string userName = "bjdmongo001";
        private static readonly string host = "bjdmongo001.documents.azure.com";
        private static readonly string password = "";
        private static readonly string databaseName = "db001";
        private static readonly string databaseCollection = "loans001";

        static void Main(string[] args)
        {
            MongoClientSettings settings = new MongoClientSettings();
            settings.Server = new MongoServerAddress(host, 10255);
            settings.UseTls = true;
            settings.SslSettings = new SslSettings();
            settings.SslSettings.EnabledSslProtocols = SslProtocols.Tls12;

            MongoIdentity identity = new MongoInternalIdentity(databaseName, userName);
            MongoIdentityEvidence evidence = new PasswordEvidence(password);

            settings.Credential = new MongoCredential("SCRAM-SHA-1", identity, evidence);

            MongoClient client = new MongoClient(settings);
            var database = client.GetDatabase(databaseName);

            string data = System.IO.File.ReadAllText(@"..\dotnet.json");
            ExpandoObject loan = JsonConvert.DeserializeObject<ExpandoObject>(data);
            
            var collection = database.GetCollection<ExpandoObject>(databaseCollection);
            collection.InsertOne(loan);

            Dictionary<string, object> stats = database.RunCommand(new GetLastRequestStatisticsCommand());
            double requestCharge = (double)stats["RequestCharge"];
            Console.Out.WriteLine($"Request Charge - {requestCharge}");
        }
    }
}


