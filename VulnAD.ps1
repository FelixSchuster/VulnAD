using module ".\modules\SetupConfiguration.psm1"
using module ".\modules\Domaincontroller.psm1"
using module ".\modules\Workstation.psm1"

param (
    [Parameter(Mandatory=$true, HelpMessage="Enter the path to the json configuration file")] $ConfigurationFile,
    [Parameter(Mandatory=$true, HelpMessage="Enter the hostname for the machine you want to configure")] $HostName
)

# START OF SETUP CONFIGURATION BLOCK
#
# specify what the setup should do before restart
# |-----------------|---------------------------------------------------|
# | value           | action before restart                             |
# |-----------------|---------------------------------------------------|
# | 0               | restart immediately                               |
# | any value < 0   | pause                                             |
# | any value > 0   | sleep for <value> seconds and restart afterwards  |
# |-----------------|---------------------------------------------------|
$ActionBeforeRestart = 0
#
# path where setup files are to be stored temporarily
# all users MUST have read and write permissions to this directory
# the folder will be removed after setup is finished, so this SHOULD be a directory that is either empty or does not exist yet
$SetupFilesPath = "C:\Users\Public\VulnAD"
#
# path where scheduled task script files are to be stored
# all users MUST have read and write permissions to this directory
$ScheduledTaskScriptsPath = "C:\Users\Public\VulnAD-Scripts"
#
# name of the scheduled task that continues the setup in case of restart
$ScheduledTaskName = "VulnAD"
#
# here all the setup registry keys are temporarily stored
$RegistryPath = "HKLM:\SOFTWARE\VulnAD"
#
# name of the registry key where the current stage of the setup is temporarily stored
$RegistryKeyStage = "VulnAD-Stage"
#
# END OF SETUP CONFIGURATION BLOCK

function StartSetup([String] $HostName, [String] $ConfigurationFile, [SetupConfiguration] $SetupConfiguration) {
    Write-Host "[*] Checking if script is run with administrator privileges ..." -ForegroundColor Yellow -BackgroundColor Black

    if (-not (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Host "[-] Script needs to be run with administrator privileges! Exiting ..." -ForegroundColor Red -BackgroundColor Black
        pause
        exit
    }

    Write-Host "[*] Reading configuration file ..." -ForegroundColor Yellow -BackgroundColor Black

    [PSCustomObject] $Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json

    if (-not $Configuration) {
        Write-Host "[-] ConfigurationFile '$ConfigurationFile' does not exist or is empty! Exiting ..." -ForegroundColor Red -BackgroundColor Black
        pause
        exit
    }

    [Bool] $HostNameFound = $false
    
    if ($Configuration.domaincontroller.host_name -eq $HostName) {
        $HostNameFound = $true
        $CurrentMachine = [Domaincontroller]::new($Configuration.domaincontroller, $Configuration, $SetupConfiguration)
    }

    foreach($MachineConfiguration in $Configuration.workstations) {
        if ($MachineConfiguration.host_name -eq $HostName) {
            $HostNameFound = $true
            $CurrentMachine = [Workstation]::new($MachineConfiguration, $Configuration, $SetupConfiguration)
            break
        }
    }

    if (-not $HostNameFound) {
        Write-Host "[-] Hostname '$HostName' not found in '$ConfigurationFile'! Exiting ..." -ForegroundColor Red -BackgroundColor Black
        pause
        exit
    }

    Write-Host "[*] Domain: $($Configuration.domain_name)" -ForegroundColor Blue -BackgroundColor Black
    Write-Host "[*] Hostname: $HostName" -ForegroundColor Blue -BackgroundColor Black
    try {
        $CurrentMachine.Setup()
    } catch {
        Write-Host "[-] Error: $_ Exiting ..." -ForegroundColor Red -BackgroundColor Black
        pause
    }
}

$Host.ui.rawui.backgroundcolor = "Black"
Clear-Host

# https://patorjk.com/software/taag/#p=display&f=Slant&t=VulnAD

Write-Host "   _    __      __      ___    ____ " -ForegroundColor Blue -BackgroundColor Black
Write-Host "  | |  / /_  __/ /___  /   |  / __ \" -ForegroundColor Blue -BackgroundColor Black
Write-Host "  | | / / / / / / __ \/ /| | / / / /" -ForegroundColor Blue -BackgroundColor Black
Write-Host "  | |/ / /_/ / / / / / ___ |/ /_/ / " -ForegroundColor Blue -BackgroundColor Black
Write-Host "  |___/\__,_/_/_/ /_/_/  |_/_____/  " -ForegroundColor Blue -BackgroundColor Black
Write-Host ""
Write-Host "  Version: 1.0.0 - 2024/04/16" -ForegroundColor Blue -BackgroundColor Black
Write-Host "  GitHub: github.com/FelixSchuster" -ForegroundColor Blue -BackgroundColor Black
Write-Host ""

Write-Host "[+] Starting setup. The machine will reboot a few times." -ForegroundColor Green -BackgroundColor Black

$SetupConfiguration = New-Object SetupConfiguration
$SetupConfiguration.SetupFilesPath = $SetupFilesPath
$SetupConfiguration.ScheduledTaskScriptsPath = $ScheduledTaskScriptsPath
$SetupConfiguration.SetupFile = $(Join-Path $SetupFilesPath $MyInvocation.MyCommand)
if (-not $(Test-Path "$($PSScriptRoot)\$($ConfigurationFile.split('\')[-1])")) {
    # copy config file to script root folder so we dont have to worry about absolute/relative path
    Copy-Item $ConfigurationFile $PSScriptRoot
}
$SetupConfiguration.ConfigurationFile = $(Join-Path $SetupFilesPath $ConfigurationFile.split('\')[-1])
$SetupConfiguration.ScheduledTaskName = $ScheduledTaskName
$SetupConfiguration.RegistryPath = $RegistryPath
$SetupConfiguration.RegistryKeyStage = $RegistryKeyStage
$SetupConfiguration.ActionBeforeRestart = $ActionBeforeRestart

StartSetup -HostName $HostName -ConfigurationFile $ConfigurationFile -SetupConfiguration $SetupConfiguration
