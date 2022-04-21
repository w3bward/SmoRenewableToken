#Requires -Modules @{ModuleName="SqlServer"; ModuleVersion="21.1.18245"} 
#Requires -Modules @{ModuleName="Az.Accounts"; ModuleVersion="2.7.3"}

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [System.Uri]$ResourceUrl = 'https://database.windows.net'
)


class SmoRenewableToken : Microsoft.SqlServer.Management.Common.IRenewableToken {
    [string]$Resource
    [string]$Tenant
    [DateTimeOffset]$TokenExpiry
    [string]$UserId
    [string] hidden $Token

    SmoRenewableToken(
        [System.Uri]$ResourceUrl
    ) {
        $AzAccessToken  = Get-AzAccessToken -ResourceUrl $ResourceUrl
        $this.Tenant    = $AzAccessToken.TenantId
        $this.Resource  = $ResourceUrl
        $this.TokenExpiry = $AzAccessToken.ExpiresOn
        $this.UserId    = $AzAccessToken.UserId
        $this.Token = $AzAccessToken.Token
    }

    [string]GetAccessToken() {
        if ($this.TokenExpiry.AddMinutes(-10) -gt (Get-Date)) {
            return $this.Token
        }
        $AzAccessToken = Get-AzAccessToken -ResourceUrl $this.Resource
        $this.TokenExpiry = $AzAccessToken.ExpiresOn
        $this.Tenant = $AzAccessToken.TenantId
        $this.UserId = $AzAccessToken.UserId
        return $AzAccessToken.Token
    }

    [DateTimeOffset]get_TokenExpiry() {
        return $this.TokenExpiry
    }

    [string]get_Resource() {
        return $this.Resource
    }

    [string]get_Tenant() {
        return $this.Tenant
    }

    [string]get_UserId() {
        return $this.UserId
    }

}

New-Object SmoRenewableToken -ArgumentList $ResourceUrl