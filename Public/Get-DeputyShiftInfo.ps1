function Get-DeputyShiftInfo {
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'EmployeeID', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [int]$EmployeeID
    )

    return Invoke-DeputyCall -Uri "/supervise/empshiftinfo/$EmployeeID" -Method Get
}