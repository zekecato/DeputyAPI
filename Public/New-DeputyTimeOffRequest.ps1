<#
.Synopsis
   Creates a leave object in Deputy that represents a request for time off. Objects can be created with various levels of approval.
.DESCRIPTION
   Creates a leave object in Deputy that represents a request for time off. Objects can be created with various levels of approval. It's best to create these as awaiting approval.
.EXAMPLE
   
.PARAMETER EmployeeId
    Deputy Id of the employee who we are requesting leave for.
.PARAMETER Status
    Integer representing the status of the request.
    Status : 0 - awaiting approval. 1 - approved. 2 - Declined. 3 - Cancelled
.PARAMETER DateStart
    First date of the leave request
.PARAMETER DateEnd
    Last date of the leave request
.PARAMETER TotalHours
    Number of PTO hours requested to take off.
.PARAMETER Comment
    Comment from the employee about the leave request
.PARAMETER ApprovalComment
    Comment from approving manager about the leave request
.INPUTS
   none
.OUTPUTS
   Object representing the leave request after creation
.NOTES
   relies on Invoke-DeputyCall
#>
function New-DeputyTimeOffRequest {

    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]$EmployeeID,

        [Parameter()]
        [ValidateSet(0,1,2,3,4,5)]
        [int]$Status,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [DateTime]$DateStart,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [DateTime]$DateEnd,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [decimal]$TotalHours,

        [string]$Comment,

        [string]$ApprovalComment
    )

    $ConvertedDateStart = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($DateStart, [System.TimeZoneInfo]::Local.Id, 'GMT Standard Time')
    $ConvertedDateEnd = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($DateEnd, [System.TimeZoneInfo]::Local.Id, 'GMT Standard Time')

    $Leave = @{
        Employee = $EmployeeID
        StartTimeLocalized=(get-date $DateStart -Format $Config.API.DateTimeFormat)
        DateStart=(get-date $ConvertedDateStart -Format $Config.API.DateTimeFormat)
        Start=[int](get-date $ConvertedDateStart -UFormat %s)
        EndTimeLocalized=(get-date $DateEnd -Format $Config.API.DateTimeFormat)
        DateEnd=(get-date $ConvertedDateEnd -Format $Config.API.DateTimeFormat)
        End=[int](get-date $ConvertedDateEnd -UFormat %s)
        Status = $Status
        TotalHours = $TotalHours
    }

    if($Comment){$Leave.Add('Comment',$Comment)}
    if($ApprovalComment){$Leave.Add('ApprovalComment',$ApprovalComment)
}

    $CallBody = $Leave | Convertto-JSON

    $CallArgs = @{
        Uri = '/resource/Leave'
        Method = 'POST'
        Body = $CallBody
    }

    Invoke-DeputyCall @CallArgs

}
