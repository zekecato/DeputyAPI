<#
.Synopsis
    Use this function to save your API key in your powershell profile to be loaded on module import.
.DESCRIPTION
    Use this function to save your API key in your powershell profile (CurrentUserAllHosts) to be loaded on module import. It can also replace an existing set API key.
.EXAMPLE
   Set-DeputyAPIKey -APIKey 'abc123000'
.PARAMETER APIKey
    string representing the API Key.
.NOTES
   The API key is a global variable. $DeputyAPIKey
#>
function Set-DeputyAPIKey {
    param(
        [Parameter(Mandatory=$true, position=0,HelpMessage="Please enter your Deputy API key")]
        [ValidateNotNullOrEmpty()]
        [string]$APIKey
    )

#if there is no powershell profile, create one.
    if (!(Test-Path $profile.CurrentUserAllHosts)){New-Item -ItemType File $profile.CurrentUserAllHosts}
#Load profile contents into memory
    $profileContent = Get-Content $profile.CurrentUserAllHosts
#check for line in profile which sets api key
    Switch ($profileContent){
        {$_ -like '$DeputyAPIKey*'} {$ProfileSetKeyPath = $true}
    }
#if api key path is set in profile, then replace that line with the new user specified path. Otherwise, append setting to end pf profile.
    if ($ProfileSetKeyPath){
        $profileContent | ForEach-Object { $_ -replace '^\$DeputyAPIKey.*$',"`$DeputyAPIKey = '$APIKey'"} | Set-Content $profile.CurrentUserAllHosts
    }else{
        "" | Out-File $profile.CurrentUserAllHosts -Append
        "`$DeputyAPIKey = `"$APIKey`"" | Add-Content $profile.CurrentUserAllHosts -Force
    }

    $Global:DeputyAPIKey = $APIKey
}
