using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Sas;
using Microsoft.Extensions.Configuration;

var builder = new ConfigurationBuilder().AddCommandLine(args);
var config = builder.Build();

var accountName = config["AccountName"]; 
var fileName = config["FileName"];

string blobEndpoint = $"https://{accountName}.blob.core.windows.net";
var uri = new Uri($"{blobEndpoint}/{fileName}");

BlobServiceClient blobClient = new(new Uri(blobEndpoint), new EnvironmentCredential() ); //new DefaultAzureCredential());
UserDelegationKey delegationKey = await blobClient.GetUserDelegationKeyAsync(DateTimeOffset.UtcNow, DateTimeOffset.UtcNow.AddDays(7));

Console.WriteLine("User delegation key properties:");
Console.WriteLine($"Key signed start: {delegationKey.SignedStartsOn}");
Console.WriteLine($"Key signed expiry: {delegationKey.SignedExpiresOn}");
Console.WriteLine($"Key signed object ID: {delegationKey.SignedObjectId}");
Console.WriteLine($"Key signed tenant ID: {delegationKey.SignedTenantId}");
Console.WriteLine($"Key signed service: {delegationKey.SignedService}");
Console.WriteLine($"Key signed version: {delegationKey.SignedVersion}");

BlobSasBuilder sasBuilder = new BlobSasBuilder()
{
    BlobContainerName = uri.Segments[1].Trim('/'),
    BlobName = uri.Segments[2],
    Resource = "b",
    StartsOn = DateTimeOffset.UtcNow,
    ExpiresOn = DateTimeOffset.UtcNow.AddHours(1)
};

sasBuilder.SetPermissions(BlobSasPermissions.Read);
var sasQueryParams = sasBuilder.ToSasQueryParameters(delegationKey, accountName).ToString();

UriBuilder sasUri = new UriBuilder()
{
    Scheme = "https",
    Host = uri.Host,
    Path = uri.AbsolutePath,
    Query = sasQueryParams
};
Console.WriteLine($"SAS token: {sasUri.Uri} ");