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

    <# 
        Despite some documentation stating otherwise, it appears that PowerShell v5.1 does not automatically implement accessors (get/set) that the interface
        recognizes. When the following methods were omitted, this function threw errors along the lines of "get_TokenExpiry... does not have an implementation"

        At some point, this issue was fixed in PowerShell Core, and testing in 7.2.1 revealed that these lines could be safely omitted, but their presence does
        not appear to cause any problems either. For the sake of compatibility, they stay.
    #>
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

function New-SmoRenewableToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [System.Uri]$ResourceUrl = 'https://database.windows.net'
    )
    New-Object SmoRenewableToken -ArgumentList $ResourceUrl
}