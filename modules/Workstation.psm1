using module ".\BaseComputer.psm1"
using module ".\SetupConfiguration.psm1"

class Workstation : BaseComputer {
    Workstation() {}
    
    Workstation([PSCustomObject] $MachineConfiguration, [PSCustomObject] $DomainConfiguration, [SetupConfiguration] $SetupConfiguration) : base($MachineConfiguration, $DomainConfiguration, $SetupConfiguration) {
        # setup user account configuration
        if ($this.LocalAdministrators) {
            # if there is a local administrator, use the first available account for setup
            $this.SetupUser = $this.LocalAdministrators[0]
        } else {
            # if there is none, just use the first logged on user and grant local administrator privileges for now
            # remember to remove the account from local administrators later on
            $this.SetupUser = $this.LoggedInUsers[0]
        }
        Write-Host "[*] Using '$($this.SetupUser.LogonName)' for the setup ..." -ForegroundColor Yellow -BackgroundColor Black
    }

    [Void] Setup() {
        $CurrentStage = $this.GetCurrentStage()
        if (-not $CurrentStage) {
            $this.CopySetupFiles()
            $this.CopyScheduledTaskScriptFiles()
            $this.DefaultUser.ChangePassword($this.DefaultUser.Password)
            $this.RenameComputer()
            $this.SetDnsServers()
            $this.SetCurrentStage(1)
            $this.CreateScheduledSetupTaskForDefaultUser()
            $this.EnableDefaultUserAccountAutoLogin()
            $this.Restart()
        } elseif (1 -eq $CurrentStage) {
            $this.JoinDomain()
            $this.SetCurrentStage(2)
            $this.Restart()
        } elseif (2 -eq $CurrentStage) {
            $this.LoginAsLoggedInUsersAndLocalAdministrators()
            $this.GrantDomainUsersLocalAdministratorPrivileges()
            $this.GrantSetupUserAccountLocalAdministratorPrivileges()
            $this.EnableSetupUserAccountAutoLogin()
            $this.RemoveScheduledSetupTask()
            $this.CreateScheduledSetupTaskForSetupUser()
            $this.SetCurrentStage(3)
            $this.Restart()
        } elseif (3 -eq $CurrentStage) {
            $this.RemoveScheduledSetupTask()
            $this.DisableSetupUserAutoLogin()
            $this.EnableRdp()
            $this.EnableNetworkDiscovery()
            $this.EnableFileAndPrinterSharing()
            $this.RemoveSetupUserAccountLocalAdministratorPrivileges()
            $this.SimulateUserBehaviour()
            $this.RemoveSetupFilesFromSetupFilesPath()
            Write-Host "[+] All Done! Happy Hacking!" -ForegroundColor Green -BackgroundColor Black
            Write-Host "[*] Press any key to reboot." -ForegroundColor Blue -BackgroundColor Black
            pause
            $this.Restart()
        }
    }
}
