<#
.Synopsis
   Clocks in an employee in Deputy and creates a timesheet by Deputy ID and Operational Unit ID, or by using a schedule object.
.DESCRIPTION
   Clocks in an employee in Deputy and creates a timesheet by Deputy ID and Operational Unit ID, or by using a schedule object.
.EXAMPLE
   
.PARAMETER EmployeeId
    Deputy Id of the employee who we are starting a timesheet for.
.PARAMETER OpUnitId
    Id of the operational unit that the employee is being clocked into. It should be grabbed from the shift info object if possible.
.PARAMETER ShiftInfo
    Roster document that shows the scheduled shift of an employee that they are starting.
.INPUTS
   none
.OUTPUTS
   Object representing the timesheet after starting it.
.NOTES
   This function utilizes a supervise call in deputy that takes employee id and operational unit id.
#>
function Start-DeputyTimesheet {
#returns a timesheet
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [ValidateNotnUllOrEmpty()]
        [int]$EmployeeID,

        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [ValidateNotnUllOrEmpty()]
        [int]$OpUnitId,

        [Parameter(Mandatory = $true, ParameterSetName = 'ShiftInfo')]
        [ValidateNotnUllOrEmpty()]
        $ShiftInfo
    )

    if ($PSCmdlet.ParameterSetName -eq 'ShiftInfo'){
        if ($ShiftInfo.Object._DPMetaData.System -ne 'Roster'){
            throw 'Employee has already clocked in'
        }
        $EmployeeID = $ShiftInfo.Emp.Id
        $OpUnitId = $ShiftInfo.Object.OperationalUnit
        if(!$EmployeeID -or !$OpUnitId){
            throw 'Incomplete ShiftInfo object supplied'
        }
    }

    $punch = @{
    intEmployeeId = $EmployeeID
    intOpunitId = $OpUnitId
    }

    return Invoke-DeputyCall -Uri '/supervise/timesheet/start' -Method Post -Body ($punch | ConvertTo-Json)

}