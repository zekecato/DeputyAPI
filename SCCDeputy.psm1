[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#region Import Functions
#Get public and private function definition files.
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
    $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }
#endregion

#Load the config file
$Script:Config = Import-PowerShellDataFile $PSScriptRoot\config.psd1

#If there's no API Key loaded in the profile, prompt the user to set one, unless it's the task scheduling user. In that case, load from config.
if(!$DeputyAPIKey -and $env:USERNAME -ne $Config.ScheduledTask.User){
    Set-DeputyAPIKey
}

if($env:USERNAME -eq $Config.ScheduledTask.User){
    $Global:DeputyAPIKey = $Config.ScheduledTask.APIKey
}

Export-ModuleMember -Function $Public.Basename


enum DeputyResource {
    Address
    Category
    Comment
    Company
    CompanyPeriod
    Contact
    Country
    CustomAppData
    CustomField
    CustomFieldData
    Employee
    EmployeeAgreement
    EmployeeAgreementHistory
    EmployeeAppraisal
    EmployeeAvailability
    EmployeeHistory
    EmployeePaycycle
    EmployeePaycycleReturn
    EmployeeRole
    EmployeeSalaryOpunitCosting
    EmployeeWorkplace
    EmploymentCondition
    EmploymentContract
    EmploymentContractLeaveRules
    Event
    Geo
    Journal
    Kiosk
    Leave
    LeaveAccrual
    LeavePayLine
    LeaveRules
    Memo
    OperationalUnit
    PayPeriod
    PayRules
    PublicHoliday
    Roster
    RosterOpen
    RosterSwap
    SalesData
    Schedule
    SmsLog
    State
    StressProfile
    SystemUsageBalance
    SystemUsageTracking
    Task
    TaskGroup
    TaskGroupSetup
    TaskOpunitConfig
    TaskSetup
    Team
    Timesheet
    TimesheetPayReturn
    TrainingModule
    TrainingRecord
    Webhook
}

class DeputySearchQuery {
    [hashtable]$HashTable

    DeputySearchQuery(){
        $this.HashTable = @{search = @{}}
    }

    DeputySearchQuery([string]$Field,[string]$Opr,$Data){
        $this.HashTable = @{search = @{}}
        $this.addfield($Field,$Opr,$Data)
    }

    DeputySearchQuery([string]$Field,[string]$Opr,$Data,[string]$Join){
        $this.HashTable = @{search = @{}}
        $this.addfield($Field,$Opr,$Data,$Join)
    }

    [string]Json(){
        return ($this.HashTable | ConvertTo-Json -Depth 100)
    }

    [void]AddField([string]$Field,[string]$Opr,$Data){
        $fCount = $this.HashTable.search.keys.count
        $fname = 'f'+($fcount+1)
        $this.HashTable.search.add($fname,@{})
        $this.HashTable.search.$fname.add('field',$Field)
        $this.HashTable.search.$fname.add('type',$Opr)
        $this.HashTable.search.$fname.add('data',$Data)
    }

    [void]AddField([string]$Field,[string]$Opr,$Data,[string]$Join){
        $fCount = $this.HashTable.search.keys.count
        $fname = 'f'+($fcount+1)
        $this.HashTable.search.add($fname,@{})
        $this.HashTable.search.$fname.add('field',$Field)
        $this.HashTable.search.$fname.add('type',$Opr)
        $this.HashTable.search.$fname.add('data',$Data)
        $this.HashTable.search.$fname.add('join',$Join)
    }

    [void]AddSort([string]$Field,[string]$Sort){
        if($Sort -inotin @('asc','desc')){
            throw 'sort must be asc or desc'
        }

        if(!$this.HashTable.ContainsKey('sort')){
            $this.HashTable.sort = @{$Field = $Sort}
        }else{
            $this.HashTable.sort.Add($Field,$Sort)
        }
    }

    [void]SetJoin([string[]]$JoinObjects){
        $this.HashTable.join = $JoinObjects
    }

    [void]SetAssoc([string[]]$AssocObjects){
        $this.HashTable.assoc = $AssocObjects
    }

    [void]SetOffset([int]$Offset){
        $this.HashTable.start = $Offset
    }

}
