# SmoRenewableToken
A simple Powershell module to implement Microsoft.SqlServer.Management.Common.IRenewableToken for authenticating SMO to Azure SQL Databases with an access token from the Az.Accounts module. It has a single command to create a new instance of the object.

If you don't want to install the module for whatever reason, the copy of New-SmoRenewableToken.ps1 at the root of the repo is setup to be executed as a script (rather than containing a function) and contains the necessary class definition.

## Dependencies
- [SqlServer](https://www.powershellgallery.com/packages/SqlServer) >= v21.1.18256
- [Az.Accounts](https://www.powershellgallery.com/packages/Az.Accounts) >= v2.7.3

## Installation
This module can be installed from the PSGallery by running
```
Install-Module SmoRenewableToken
```

## Example Usage
### Getting an Smo.Server object and Smo.Database object
Note: The account you use to connect with Connect-AzAccount must have the necessary permissions on the Azure SQL Server or Database instance you want to perform operations on
```
Import-Module SmoRenewableToken

# You must run Connect-AzAccount so that an access token can be obtained
# using Get-AzAccessToken
Connect-AzAccount

$SmoRenewableToken = New-SmoRenewableToken

$Server     = "myazuresqlserver.database.windows.net"
$Database   = "MyDatabase"

$ConnectionInfo = [Microsoft.SqlServer.Management.Common.SqlConnectionInfo]::new($Server)
$ConnectionInfo.DatabaseName = $Database
$ConnectionInfo.AccessToken  = $AzRenewableToken
$ConnectionInfo.UserName     = $AzRenewableToken.UserId

$ServerConnection = [Microsoft.SqlServer.Management.Common.ServerConnection]::new($ConnectionInfo)
$ServerInstance   = [Microsoft.SqlServer.Management.Smo.Server]::new($ServerConnection)
$DatabaseInstance = $ServerInstance.Databases | where Name -EQ $Database
```