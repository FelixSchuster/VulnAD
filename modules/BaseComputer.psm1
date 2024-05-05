using module ".\Fileshare.psm1"
using module ".\SetupConfiguration.psm1"
using module ".\DomainUserAccount.psm1"
using module ".\LocalUserAccount.psm1"
using module ".\ServiceAccount.psm1"
using module ".\RegistryKey.psm1"

class BaseComputer {
    [String] $DomainName
    [String] $HostName
    [String] $NetworkInterface = "Ethernet"
    [String] $IpAddress
    [String] $SubnetMask
    [String] $DefaultGateway
    [String] $PrimaryDns
    [String] $SecondaryDns
    [LocalUserAccount] $DefaultUser
    [DomainUserAccount] $SetupUser
    [DomainUserAccount[]] $LoggedInUsers
    [DomainUserAccount[]] $LocalAdministrators
    [SetupConfiguration] $SetupConfiguration
    [DomainUserAccount] $SimulateUserAccount = $null
    [String[]] $BrowseFileshares = $null
    [Bool] $IsGeneratingHttpTraffic = $false
    [Bool] $IsGeneratingSmbTraffic = $false
    [Bool] $HasRdpEnabled = $false

    BaseComputer() {}
    
    BaseComputer([PSCustomObject] $MachineConfiguration, [PSCustomObject] $DomainConfiguration, [SetupConfiguration] $SetupConfiguration) {
        # base computer configuration
        $this.HostName = $MachineConfiguration.host_name
        $this.DomainName = $DomainConfiguration.domain_name

        # use the user name of the currently logged on user for the setup for now
        # the default_user.user_name attribute of the config file will be ignored
        # might change this later on once i can think of a better way to do this
        $MachineConfiguration.default_user.user_name = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.split('\')[-1]

        $this.DefaultUser = [LocalUserAccount]::new($MachineConfiguration.default_user, $this.HostName)
        if ($MachineConfiguration.PSobject.Properties.Name.Contains("network_interface")) {
            $this.NetworkInterface = $MachineConfiguration.network_interface
        }
        $this.IpAddress = $MachineConfiguration.ip_address
        $this.SubnetMask = $MachineConfiguration.subnet_mask
        $this.DefaultGateway = $MachineConfiguration.default_gateway
        $this.PrimaryDns = $MachineConfiguration.primary_dns
        $this.SecondaryDns = $MachineConfiguration.secondary_dns

        # simulate user behaviour
        if ($MachineConfiguration.PSobject.Properties.Name.Contains("simulate_user_account")) {
            if ($MachineConfiguration.simulate_user_account.PSobject.Properties.Name.Contains("user_name")) {
                $SamAccountName = $MachineConfiguration.simulate_user_account.PSobject.Properties.Name.Contains("user_name")
                $this.SimulateUserAccount = $this.CreateDomainAccountBySamAccountName($DomainConfiguration, $SamAccountName)
                if ($MachineConfiguration.simulate_user_account.PSobject.Properties.Name.Contains("browse_fileshares")) {
                    foreach ($Fileshare in $MachineConfiguration.simulate_user_account.browse_fileshares) {
                        $this.BrowseFileshares += $Fileshare
                    }
                }
                if ($MachineConfiguration.simulate_user_account.PSobject.Properties.Name.Contains("is_generating_http_traffic")) {
                    $this.IsGeneratingHttpTraffic = $MachineConfiguration.simulate_user_account.is_generating_http_traffic
                }
                if ($MachineConfiguration.simulate_user_account.PSobject.Properties.Name.Contains("is_generating_smb_traffic")) {
                    $this.IsGeneratingSmbTraffic = $MachineConfiguration.simulate_user_account.is_generating_smb_traffic
                }
            }
        }

        # enable rdp
        if ($MachineConfiguration.PSobject.Properties.Name.Contains("has_rdp_enabled")) {
            $this.HasRdpEnabled = $MachineConfiguration.has_rdp_enabled
        }

        # logged in users configuration
        foreach ($LoggedInUserSamAccountName in $MachineConfiguration.logged_in_users) {
            $this.LoggedInUsers += $this.CreateDomainAccountBySamAccountName($DomainConfiguration, $LoggedInUserSamAccountName)
        }

        # local administrators configuration
        foreach ($LocalAdministratorSamAccountName in $MachineConfiguration.local_administrators) {
            $this.LoggedInUsers += $this.CreateDomainAccountBySamAccountName($DomainConfiguration, $LocalAdministratorSamAccountName)
        }

        # setup configuration
        $this.SetupConfiguration = $SetupConfiguration
    }

    [DomainUserAccount] CreateDomainAccountBySamAccountName($DomainConfiguration, $SamAccountName) {
        foreach ($DomainUserAccountConfiguration in $DomainConfiguration.user_accounts) {
            if ($SamAccountName -eq $DomainUserAccountConfiguration.sam_account_name) {
                return [DomainUserAccount]::new($DomainUserAccountConfiguration, $this.DomainName)
            }
        }
        foreach ($ServiceAccountConfiguration in $DomainConfiguration.service_accounts) {
            if ($SamAccountName -eq $ServiceAccountConfiguration.sam_account_name) {
                return [ServiceAccount]::new($ServiceAccountConfiguration, $this.DomainName)
            }
        }
        return $null
    }

    [Void] RenameComputer() {
        Write-Host "[*] Renaming computer to '$($this.HostName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        Rename-Computer -NewName $this.HostName -Force
    }

    [Void] SetCurrentStage([String] $Value) {
        Write-Host "[*] Saving the current stage of the setup to registry ..." -ForegroundColor Yellow -BackgroundColor Black
        [RegistryKey]::new($this.SetupConfiguration.RegistryPath, $this.SetupConfiguration.RegistryKeyStage, $Value).SetValue()
    }

    [String] GetCurrentStage() {
        Write-Host "[*] Retrieving the current stage of the setup from registry ..." -ForegroundColor Yellow -BackgroundColor Black
        return [RegistryKey]::new($this.SetupConfiguration.RegistryPath, $this.SetupConfiguration.RegistryKeyStage).GetValue()
    }

    [Void] Restart() {
        Write-Host "[*] Restart approaching ..." -ForegroundColor Yellow -BackgroundColor Black
        if ($this.SetupConfiguration.ActionBeforeRestart -lt 0) {
            pause
        } elseif ($this.SetupConfiguration.ActionBeforeRestart -gt 0) {
            Write-Host -NoNewline "[*] Restarting in $($this.SetupConfiguration.ActionBeforeRestart) seconds, press any key to restart immediately ..." -ForegroundColor Yellow -BackgroundColor Black
            timeout $this.SetupConfiguration.ActionBeforeRestart
        }
        Write-Host "[*] Restarting ..." -ForegroundColor Yellow -BackgroundColor Black
        Restart-Computer
    }

    [Void] SetDnsServers() {
        Write-Host "[*] Setting dns servers ..." -ForegroundColor Yellow -BackgroundColor Black
        netsh interface ipv4 set address name=$($this.NetworkInterface) static $($this.IpAddress) $($this.SubnetMask) $($this.DefaultGateway)
        netsh interface ipv4 set dns name=$($this.NetworkInterface) static $($this.PrimaryDns)
        netsh interface ipv4 add dns name=$($this.NetworkInterface) $($this.SecondaryDns) index=2
    }

    [Void] EnableNetworkDiscovery() {
        Write-Host "[*] Enabling network discovery ..." -ForegroundColor Yellow -BackgroundColor Black
        netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
    }

    [Void] EnableFileAndPrinterSharing() {
        Write-Host "[*] Enabling file and printer sharing ..." -ForegroundColor Yellow -BackgroundColor Black
        netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
    }

    [Void] CopySetupFiles() {
        Write-Host "[*] Copying setup files to '$($this.SetupConfiguration.SetupFilesPath)' ..." -ForegroundColor Yellow -BackgroundColor Black
        if (-not (Test-Path $this.SetupConfiguration.SetupFilesPath)) {
            Write-Host "[*] Creating directory '$($this.SetupConfiguration.SetupFilesPath)' ..." -ForegroundColor Yellow -BackgroundColor Black
            New-Item -Path $this.SetupConfiguration.SetupFilesPath -ItemType Directory
        }
        # current file is 'BaseComputer.psm1', not 'Setup.ps1' so go back one directory and copy everything recursively
        Copy-Item -Path $(Join-Path $PSScriptRoot "\..\*") -Destination $this.SetupConfiguration.SetupFilesPath -Recurse
    }

    [Void] CopyScheduledTaskScriptFiles() {
        Write-Host "[*] Copying scheduled task script files to '$($this.SetupConfiguration.ScheduledTaskScriptsPath)' ..." -ForegroundColor Yellow -BackgroundColor Black
        if (-not (Test-Path $this.SetupConfiguration.ScheduledTaskScriptsPath)) {
            Write-Host "[*] Creating directory '$($this.SetupConfiguration.ScheduledTaskScriptsPath)' ..." -ForegroundColor Yellow -BackgroundColor Black
            New-Item -Path $this.SetupConfiguration.ScheduledTaskScriptsPath -ItemType Directory
        }
        # current file is 'BaseComputer.psm1', not 'Setup.ps1' so go back one directory and copy everything recursively
        Copy-Item -Path $(Join-Path $PSScriptRoot "\..\scheduled_tasks\*") -Destination $this.SetupConfiguration.ScheduledTaskScriptsPath -Recurse
    }

    [Void] RemoveSetupFilesFromSetupFilesPath() {
        Write-Host "[*] Removing setup files from '$($this.SetupConfiguration.SetupFilesPath)' ..." -ForegroundColor Yellow -BackgroundColor Black
        Remove-Item -Path $this.SetupConfiguration.SetupFilesPath -Recurse -Force
    }

    [Void] EnableDefaultUserAccountAutoLogin() {
        Write-Host "[*] Enabling auto login for default account '$($this.DefaultUser.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        $this.DefaultUser.EnableAutoLogin()
    }

    [Void] EnableSetupUserAccountAutoLogin() {
        Write-Host "[*] Enabling auto login for setup account '$($this.SetupUser.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        $this.SetupUser.EnableAutoLogin()
    }

    [Void] DisableSetupUserAutoLogin() {
        Write-Host "[*] Disabling auto login for setup account '$($this.SetupUser.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        $this.SetupUser.DisableAutoLogin()
    }

    [Void] CreateScheduledSetupTaskForDefaultUser() {
        Write-Host "[*] Creating scheduled setup task '$($this.SetupConfiguration.ScheduledTaskName)' for default user..." -ForegroundColor Yellow -BackgroundColor Black
        $this.DefaultUser.CreateScheduledSetupTask($this.SetupConfiguration, $this.HostName)
    }

    [Void] CreateScheduledSetupTaskForSetupUser() {
        Write-Host "[*] Creating scheduled setup task '$($this.SetupConfiguration.ScheduledTaskName)' for setup user..." -ForegroundColor Yellow -BackgroundColor Black
        $this.SetupUser.CreateScheduledSetupTask($this.SetupConfiguration, $this.HostName)
    }

    [Void] RemoveScheduledSetupTask() {
        Write-Host "[*] Removing scheduled task '$($this.SetupConfiguration.ScheduledTaskName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        Unregister-ScheduledTask -TaskName $this.SetupConfiguration.ScheduledTaskName -Confirm:$false
    }

    [Void] LoginAsLoggedInUsersAndLocalAdministrators() {
        Write-Host "[*] Logging in as logged on users ..." -ForegroundColor Yellow -BackgroundColor Black
        foreach ($LoggedInUser in $this.LoggedInUsers) {
            $LoggedInUser.Login()
        }
        Write-Host "[*] Logging in as local administrators ..." -ForegroundColor Yellow -BackgroundColor Black
        foreach ($LocalAdministrator in $this.LocalAdministrators) {
            $LocalAdministrator.Login()
        }
        Write-Host "[*] Logging in as simulated user ..." -ForegroundColor Yellow -BackgroundColor Black
        if ($this.SimulateUserAccount) {
            $this.SimulateUserAccount.Login()
        }
    }

    [Void] GrantDomainUsersLocalAdministratorPrivileges() {
        Write-Host "[*] Granting domain users local administrator privileges ..." -ForegroundColor Yellow -BackgroundColor Black
        foreach ($LocalAdministrator in $this.LocalAdministrators) {
            $LocalAdministrator.GrantLocalAdministratorPrivileges()
        }
    }

    [Void] GrantSetupUserAccountLocalAdministratorPrivileges() {
        if (-not $this.LocalAdministrators) {
            Write-Host "[*] Granting setup account '$($this.SetupUser.LogonName)' local administrator privileges ..." -ForegroundColor Yellow -BackgroundColor Black
            $this.SetupUser.GrantLocalAdministratorPrivileges()
        }
    }

    [Void] RemoveSetupUserAccountLocalAdministratorPrivileges() {
        if (-not $this.LocalAdministrators) {
            Write-Host "[*] Removing setup account '$($this.SetupUser.LogonName)' from local administrators ..." -ForegroundColor Yellow -BackgroundColor Black
            $this.SetupUser.RemoveLocalAdministratorPrivileges()
        }
    }

    [Void] JoinDomain() {
        Write-Host "[*] Joining domain '$($this.DomainName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        Add-Computer -DomainName $this.DomainName -Credential $this.SetupUser.Credential -Force
    }

    [Void] SimulateUserBehaviour() {
        if ($this.SimulateUserAccount) {
            Write-Host "[*] Simulating user behaviour of '$($this.SimulateUserAccount.LogonName)'" -ForegroundColor Yellow -BackgroundColor Black
            $this.SimulateUserAccount.EnableAutoLogin()
            if ($this.BrowseFileshares) {
                foreach ($Fileshare in $this.BrowseFileshares) {
                    $this.SimulateUserAccount.BrowseFileshare($this.SetupConfiguration.ScheduledTaskScriptsPath, $Fileshare)
                }
            }
            if ($this.IsGeneratingHttpTraffic) {
                $this.SimulateUserAccount.GenerateHttpTraffic($this.SetupConfiguration.ScheduledTaskScriptsPath)
            }
            if ($this.IsGeneratingSmbTraffic) {
                $this.SimulateUserAccount.GenerateSmbTraffic($this.SetupConfiguration.ScheduledTaskScriptsPath)
            }
        }
    }

    [Void] EnableRdp() {
        if ($this.HasRdpEnabled) {
            Write-Host "[*] Enabling RDP ..." -ForegroundColor Yellow -BackgroundColor Black
            reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
            Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
            # disable restricted admin mode to enable pth attacks
            # see https://medium.com/@jakemcgreevy/pass-the-hash-pth-with-rdp-80595fb38bef
            reg add "HKLM\System\CurrentControlSet\Control\Lsa" /t REG_DWORD /v DisableRestrictedAdmin /d 0x0 /f
        }
    }
}
