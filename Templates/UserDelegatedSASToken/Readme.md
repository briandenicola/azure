# Overview
This is a quick example on how to generate User Generated SAS tokens. 

It builds a Storage Account with the following properties:
* Public access                      - Disabled
* Storage Account Keys               - Disabled
* Network Access                     - Locked down current system's public IP Address
* Storage Blob Data Contributor      - Granted to SPN account used to create resources

# Build
* `task up`

# Test
* Setup Azure Identity for Environmental Credentials
* `dotnet run /AccountName kiwi30156sa /FileName "files/testfile.txt"`
```
    User delegation key properties:
    Key signed start: 05/11/2023 14:19:20 +00:00
    Key signed expiry: 05/18/2023 14:19:20 +00:00
    Key signed object ID: 413e7d0c-40ec-474a-91dc-21d04d17459f
    Key signed tenant ID: 16b3c013-d300-468d-ac64-7eda0820b6d3
    Key signed service: b
    Key signed version: 2022-11-02
    SAS token: https://kiwi30156sa.blob.core.windows.net/files/testfile.txt?skoid=413e7d0c-40ec-474a-91dc-21d04d17459f&sktid=16b3c013-d300-468d-ac64-7eda0820b6d3&skt=2023-05-11T14%3A19%3A20Z&ske=2023-05-18T14%3A19%3A20Z&sks=b&skv=2022-11-02&sv=2022-11-02&st=2023-05-11T14%3A19%3A21Z&se=2023-05-11T15%3A19%3A21Z&sr=b&sp=r&sig={redacted}
```
* `Invoke-WebRequest -Uri 'https://kiwi30156sa.blob.core.windows.net/files/testfile.txt?skoid=413e7d0c-40ec-474a-91dc-21d04d16459f&sktid=16b3c013-d300-468d-ac64-7eda0820b6d3&skt=2023-05-11T14%3A19%3A20Z&ske=2023-05-18T14%3A19%3A20Z&sks=b&skv=2022-11-02&sv=2022-11-02&st=2023-05-11T14%3A19%3A21Z&se=2023-05-11T15%3A19%3A21Z&sr=b&sp=r&sig={redacted}' -OutFile test.txt -UseBasicParsing`
```
    cat .\test.txt
    This is a test file for access
```

# Troubleshooting
* https://github.com/Azure/azure-sdk-for-net/blob/main/sdk/identity/Azure.Identity/TROUBLESHOOTING.md#troubleshoot-environmentcredential-authentication-issues
