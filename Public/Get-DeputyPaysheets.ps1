function Get-DeputyPaysheets {
    [CmdletBinding(DefaultParameterSetName = 'GetAll')]
    param(
        [Parameter(ParameterSetName = 'Date Range')]
        [datetime]$DateStart,
        [Parameter(ParameterSetName = 'Date Range')]
        [datetime]$DateEnd,
        [Parameter(ParameterSetName = 'Timesheet Range')]
        [int]$TimeSheetStart,
        [Parameter(ParameterSetName = 'Timesheet Range')]
        [int]$TimesheetEnd
    )

    #This script uses the search query class (in module load script) to build up the search queries as needed depending on the parameters provided.
    $Timesearch = [DeputySearchQuery]::new()
    if($PSCmdlet.ParameterSetName -eq 'Date Range'){
        if($DateStart){
            $Timesearch.AddField('Date','ge',(Get-Date $DateStart -Format yyyy-MM-dd))
        }
        if($DateEnd){
            $Timesearch.AddField('Date','le',(Get-Date $DateEnd -Format yyyy-MM-dd))
        }
    }
    if($PSCmdlet.ParameterSetName -eq 'Timesheet Range'){
        if($TimeSheetStart){
            $Timesearch.AddField('Id','ge',$TimeSheetStart)
        }
        if($TimesheetEnd){
            $Timesearch.AddField('Id','le',$TimeSheetEnd)
        }
    }

    #Regardless of the parameters we only want approved timesheets
    $Timesearch.AddField('TimeApproved','eq',$true)
    $Timesearch.SetJoin(@('OperationalUnitObject','LeaveRuleObject'))
    $Timesearch.AddSort('Id','asc')

    Write-Verbose "Querying Deputy for Timesheets"
$OhSheet = Get-DeputyResource -Resource Timesheet -Query $Timesearch.HashTable
    Write-Verbose "$($OhSheet.count) timesheets found."
    if($OhSheet.count -eq 0){
        return
    }

#Grab the pay return documents that correspond to the Timesheets we got.
$PayTimeSearch = [deputysearchquery]::new()
    if($PSCmdlet.ParameterSetName -eq 'Date Range'){
        if($DateStart){
            $PayTimeSearch.AddField('Date','ge',(Get-Date $DateStart -Format yyyy-MM-dd),'TimesheetObject')
        }
        if($DateEnd){
            $PayTimeSearch.AddField('Date','le',(Get-Date $DateEnd -Format yyyy-MM-dd),'TimesheetObject')
        }
    }
    if($PSCmdlet.ParameterSetName -eq 'Timesheet Range'){
        if($TimeSheetStart){
            $PayTimeSearch.AddField('Id','ge',$TimeSheetStart,'TimesheetObject')
        }
        if($TimesheetEnd){
            $PayTimeSearch.AddField('Id','le',$TimeSheetEnd,'TimesheetObject')
        }
    }
    if($PSCmdlet.ParameterSetName -eq 'GetAll'){
        $PayTimeSearch.AddField('Id','ge',0)
    }
$PayTimeSearch.AddField('TimeApproved','eq',$true,'TimesheetObject')
$PayTimeSearch.SetJoin('PayRuleObject')
$PayTimeSearch.AddSort('Id','asc')
Write-Verbose "Querying deputy for TimesheetPayReturns"
$Timepay = Get-DeputyResource -Resource TimesheetPayReturn -Query $PayTimeSearch.HashTable
Write-Verbose "$($Timepay.count) Pay return objects found"
$Output = @{
    Timesheets = $OhSheet
    PayReturns = $Timepay
}

return $Output
   
}