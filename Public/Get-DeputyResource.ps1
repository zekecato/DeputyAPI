function Get-DeputyResource {
    param(
        [Parameter(Mandatory=$true,ParameterSetName='Individual',Position=0)]
        [Parameter(Mandatory=$true,ParameterSetName='Schema',Position=0)]
        [Parameter(Mandatory=$true,ParameterSetName='Bulk',Position=0)]
        [DeputyResource]$Resource,

        [Parameter(Mandatory=$true,ParameterSetName='Individual',Position=1)]
        [int]$Id,

        [Parameter(ParameterSetName='Individual')]
        [string]$ForeignObject,

        [Parameter(Mandatory=$true,ParameterSetName='Schema')]
        [switch]$Schema,

        [Parameter(ParameterSetName='Bulk')]
        [hashtable]$Query,

        [Parameter(ParameterSetName='Bulk')]
        [switch]$NoLoop
    )

    $Uri = "/resource/$Resource"
        
    if($PSCmdlet.ParameterSetName -ne 'Bulk'){
        #If we are getting a specific object or schema then build up the URI here
        if($Id){
            $Uri += "/$Id"
            if ($ForeignObject){
                $Uri += "/$ForeignObject"+'Object'
            }
        }
        if($Schema.IsPresent){
            $Uri += '/INFO'
        }

        $CallArgs = @{
            Uri = $Uri
            Method = 'GET'
        }
        return Invoke-DeputyCall @CallArgs
    }else{
        #If we have a query to submit or just want all records for a particular resource then build up the URI here.
        $Uri += '/QUERY'

        if ($Query){
            if(!$Query.ContainsKey('start')){
                $Query.Add('start',0)
            }
        }else{
            #This is the default query for getting all records
            $Query = @{
                search = @{
                    'getall' = @{
                        field='Id'
                        type='gt'
                        data=0
                    }
                }
                start = 0
            }
        }

        [int]$offset=$Query.'start'
        $allresults=@()
        do{
            Write-Verbose "Calling for records from Deputy"
            $Query.'start' = $offset
            $resultset = Invoke-DeputyCall -Uri $Uri -Method Post -Body ($Query | ConvertTo-Json -Depth 100)

            $allresults += $resultset
            $offset +=500
        }while($resultset.count -eq 500 -and -not $NoLoop.IsPresent)

        Write-Verbose "Found $($allresults.count) records at Deputy"
        return $allresults
    }

        
}