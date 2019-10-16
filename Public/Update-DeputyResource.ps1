<#
.Synopsis
   Updates a given deputy resource identified by id and resource type using a hashtable of properties.
.DESCRIPTION
   Updates a given deputy resource identified by id and resource type using a hashtable of properties.
.EXAMPLE
   Update-DeputyResource -Resource Employee -Id 911 -PostBody @{FirstName='Roy'}
.PARAMETER Resource
    The name of the resource being updated. Resource names and schema available at https://www.deputy.com/api-doc/Resources
.PARAMETER Id
    The Deputy Id of the resource being updated
.PARAMETER PostBody
    A hashtable of property names and values to be updated.
.INPUTS
   none
.OUTPUTS
   Object representing the resource after the update.
.NOTES
   This function is a convenience layer on top of Invoke-DeputyCall

   Invoke-DeputyCall -Uri "/resource/$Resource/$Id" -Method Post -Body ($PostBody | ConvertTo-Json)
#>
function Update-DeputyResource {
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [DeputyResource]$Resource,

        [Parameter(Mandatory=$true,Position=1)]
        [int]$Id,

        [Parameter(Mandatory=$true, Position=2)]
        [hashtable]$PostBody
    )

    Invoke-DeputyCall -Uri "/resource/$Resource/$Id" -Method Post -Body ($PostBody | ConvertTo-Json)

}