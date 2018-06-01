# azure-functions-durable

This is a sample for writing durable functions with docker support enabled.

__Requirements:__

- [.Net Core](https://www.microsoft.com/net/download/windows)  (>= 2.1.104)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) (>= 2.0.32)
- [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools) (>= 2.0)
- [Azure Storage Emulator](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-emulator) (>= 5.3)
- [httpie](https://github.com/jakubroztocil/httpie) (>= 0.9.8)
- [docker](https://docs.docker.com/install/) (>= 17.12.0-ce)


## Deployment
### Automatically Deploy the Solution
> _Github Deployment Sync Enabled._

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdanielscholl%2Fazure-functions-durable%2Fmaster%2Ftemplates%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### Manually Deploy the Solution
```powershell
$Subscription = "<your_subscription>"
$Prefix = "<unique_prefix>"
.\install.ps1 -Prefix $Prefix -Subscription $Subscription
```

## Development
### Clone the repo

```powershell
git clone https://github.com/danielscholl/azure-functions-durable.git azure-functions-durable
```

### Build it yourself

#### Initialize a new dotnet function project
```powershell
# Initialize a new Function App
func init --worker-runtime dotnet

# Create a dotnet project
dotnet new lib --name azure-functions-durable -o .
rm Class1.cs

# Add Library Dependencies
dotnet add package Microsoft.AspNetCore.Http -v 2.1.0-rc1-final
dotnet add package Microsoft.AspNetCore.Mvc -v 2.1.0-rc1-final
dotnet add package Microsoft.AspNetCore.Mvc.WebApiCompatShim -v 2.1.0-rc1-final
dotnet add package Microsoft.Azure.WebJobs -v 3.0.0-beta5
dotnet add package Microsoft.Azure.WebJobs.Extensions.DurableTask -v 1.4.1
dotnet add package Microsoft.Azure.WebJobs.Script.ExtensionsMetadataGenerator -v 1.0.0-beta3
```

- Option 1: Use Azure Storage Emulator

```bash
AzureStorageEmulator.exe start
```

- Option 1: Use Azure Storage Account
> For this section shell out to bash (ubuntu)

```bash
# Login to Azure and set subscription if necessary
Subscription='<azure_subscription_name>'
az login
az account set --subscription ${Subscription}

# Create Resource Group
ResourceGroup="azure-functions-durable"
Location="southcentralus"
az group create --name ${ResourceGroup} \
  --location ${Location} \
  -ojsonc

# Create a Storage Account
StorageAccount="durablefunctions"$(date "+%m%d%Y")
if $(az storage account check-name --name ${StorageAccount} --query nameAvailable -otsv); then
  az storage account create --name ${StorageAccount} \
  --resource-group ${ResourceGroup} \
  --location ${Location} \
  --sku "Standard_LRS" \
  -ojsonc
fi

# Set Storage Account Context
export STORAGE_CONNECTION=$(az storage account show-connection-string \
  --name ${StorageAccount} \
  --resource-group ${ResourceGroup} \
  --query connectionString -otsv)

# Set Storage Account into .envrc file
echo "export STORAGE_ACCOUNT='${STORAGE_CONNECTION}'" > .envrc

# Create local.settings.json file
cat > local.settings.json << EOF1
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "${STORAGE_CONNECTION}",
    "AzureWebJobsDashboard": "${STORAGE_CONNECTION}"
  }
}
EOF1
```

#### Create and test a _Ping/Pong_ Function

- Create It

```powershell
func new -l C# -t "Http Trigger" -n ping
```

- Edit It

Modify the ping/run.csx file to be a simple pong return

```c#
using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;

public static IActionResult Run(HttpRequest req, TraceWriter log)
{
    log.Info("C# HTTP trigger function processed a request.");
    return (ActionResult)new OkObjectResult($"Pong");
}
```

- Test It

```powershell
func start
http post http://localhost:7071/api/ping
```
