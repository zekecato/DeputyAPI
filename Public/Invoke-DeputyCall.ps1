function Invoke-DeputyCall {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Uri,

        [Parameter(Mandatory=$true)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,

        [Parameter()]
        $Body,

        [Parameter()]
        [int]$MaxRetries = 2,

        [Parameter()]
        [int]$RetryTime = 2000,

        [Parameter()]
        [string]$APIKey
    )

    #Load parameters for the web call
    $FullUri = $config.API.Endpoint + $Uri
    $RestArgs = @{
        ContentType = 'application/json'
        Uri = $FullUri
        Headers = @{
           # 'Content-type'= 'application/json'
            Authorization = 'OAuth '+ $APIKey
            Accept = 'application/json'
        }
        Method = $Method
    }

    if($Body){
        $RestArgs.Add('Body',$Body) | Out-Null
    }

    #region retry loop
    $StopRetry = $false
    $tries = 0
    do{
        try{
            Invoke-RestMethod @RestArgs
            $StopRetry = $true
        }catch{
            #retry for timeouts and server busy
            if($_.Exception -notmatch '(503|504)' -or $tries -gt $MaxRetries){
                throw $_
            }else{
                Write-Verbose "$($_.exception). Retrying Deputy Call."
                $tries++
                Start-Sleep -Milliseconds $RetryTime
            }
        }
    }while($StopRetry -eq $false)
    #endregion
}