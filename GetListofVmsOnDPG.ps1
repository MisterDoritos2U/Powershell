<#

.SYNOPSIS
This powershell script is used to gather a list of vms on a distribuited port group. Then perform a ping test using the vm name and appends the input of $Domain. The results are stored and saved in C:\temp


Created By:
Diego Villanueva


#>

####################
# Prerequisite check
####################

if (-NOT(Get-Module -List -Name VMware.VimAutomation* )){
    Write-Host "Please Make Sure That PowerCli Is Installed." -ForegroundColor Red
    Pause
    Throw "PowerCli is not installed"
}

###################
# Log file location
###################

$OutputPath = "C:\temp"
$Date = Get-Date -Format yyyy-MM-dd
$LogFile = "Ping Results $Date.log"

#######################
# Setting the variables
#######################

$VCServer = Read-Host -Prompt "Enter the name of the vcenter to connect to "

$DPGName = Read-Host -Prompt "What is the Distribuited Port Group Name "

$Domain = Read-Host -Prompt "Enter Domain to Append to Ping "

$Credentials = Get-Credential -Message "Enter Vcenter Credentials "

#################
# Checks Log Path 
#################

If (!(Test-Path $OutputPath)) {
    
    New-Item -ItemType Directory -Force -Path $OutputPath
}


#######################
# Connection to vcenter 
#######################

$Connection = Connect-VIServer -Server $VCServer -Credential $Credentials


$VMS = Get-VirtualPortGroup -Name $DPGName -WarningAction Ignore | Get-VM


Disconnect-VIServer -Server $Connection -Confirm:$False

#############################
# Tests ping connection to vm 
#############################

$Results = @()

foreach ($VM in $VMS.name){
    $Result = Test-NetConnection -ComputerName "$VM.$Domain"  | Select-Object -Property Computername,RemoteAddress

    Write-Output $Results

    $Results += $Result
    
}

$Results | Format-List | Out-File "$OutputPath\$LogFile"



