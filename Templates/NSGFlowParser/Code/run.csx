#r "Newtonsoft.Json"
#load "NsgFlowLogEvents.csx"
#load "OmsNsgEvent.csx"

using System;
using System.Security.Cryptography;
using System.Text;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;

public static string FromUnixTime( string seconds ) 
{
    DateTime epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
    return epoch.AddSeconds(Convert.ToDouble(seconds)).ToUniversalTime().ToString();
}

public static string BuildSignature(string message, string secret)
{
    var encoding = new System.Text.UTF8Encoding();
    byte[] keyByte = Convert.FromBase64String(secret);
    byte[] messageBytes = encoding.GetBytes(message);
    using (var hmacsha256 = new HMACSHA256(keyByte))
    {
        byte[] hash = hmacsha256.ComputeHash(messageBytes);
        return Convert.ToBase64String(hash);
    }
}

public static void PostData(string customerId, string LogName, string signature, string date, string json)
{
    string TimeStampField = "";

    string url = "https://" + customerId + ".ods.opinsights.azure.com/api/logs?api-version=2016-04-01";

    System.Net.Http.HttpClient client = new System.Net.Http.HttpClient();
    client.DefaultRequestHeaders.Add("Accept", "application/json");
    client.DefaultRequestHeaders.Add("Log-Type", LogName);
    client.DefaultRequestHeaders.Add("Authorization", signature);
    client.DefaultRequestHeaders.Add("x-ms-date", date);
    client.DefaultRequestHeaders.Add("time-generated-field", TimeStampField);

    System.Net.Http.HttpContent httpContent = new StringContent(json, Encoding.UTF8);
    httpContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
    Task<System.Net.Http.HttpResponseMessage> response = client.PostAsync(new Uri(url), httpContent);

    System.Net.Http.HttpContent responseContent = response.Result.Content;
    string result = responseContent.ReadAsStringAsync().Result;
}

public static void Run(string nsgFlowLog, string name, TraceWriter log)
{
    log.Info($"C# Blob trigger function Processed blob\n Name:{name} \n");
    
    string customerId = System.Environment.GetEnvironmentVariable("customerId", EnvironmentVariableTarget.Process);
    string sharedKey  = System.Environment.GetEnvironmentVariable("sharedKey", EnvironmentVariableTarget.Process);
    string logName    = System.Environment.GetEnvironmentVariable("LogName", EnvironmentVariableTarget.Process);

    NsgFlowEvents nsgEvents = Newtonsoft.Json.JsonConvert.DeserializeObject<NsgFlowEvents>(nsgFlowLog);

    foreach( var record in nsgEvents.records ) 
    {
        var datestring = DateTime.UtcNow.ToString("r");
        char delimiter = '/';
        string[] resources = record.resourceId.Split(delimiter);

        foreach( var flows in record.properties.flows) 
        {
            foreach( var flow in flows.flows ) 
            {
                foreach( string tupleflow in flow.flowTuples ) 
                {
                    delimiter = ',';
                    string[] tuple = tupleflow.Split(delimiter);
                    OmsNsgEvent omsEvent = new OmsNsgEvent 
                    {
                        SubscriptionId = resources[2],
                        ResourceGroup = resources[4],
                        NSG = resources[8],
                        Rule = flows.rule,
                        MAC =   flow.mac,
                        DateTime = FromUnixTime(tuple[0]),
                        SourceIp = tuple[1],
                        SourcePort = tuple[3],
                        DestinationIp = tuple[2],
                        DestinationPort = tuple[4],
                        TcpOrUdp = tuple[5],
                        InOrOut = tuple[6],
                        AllowOrDeny = tuple[7] 
                    };
                    
                    var json = Newtonsoft.Json.JsonConvert.SerializeObject(omsEvent);
                    string stringToHash = "POST\n" + json.Length + "\napplication/json\n" + "x-ms-date:" + datestring + "\n/api/logs";
                    string hashedString = BuildSignature(stringToHash, sharedKey);
                    string signature = "SharedKey " + customerId + ":" + hashedString;
                
                    PostData(customerId, logName, signature,  datestring, json);
                }
            }
        }
    }
}