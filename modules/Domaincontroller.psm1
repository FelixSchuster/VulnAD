using module ".\BaseComputer.psm1"
using module ".\OrganizationalUnit.psm1"
using module ".\DomainUserAccount.psm1"
using module ".\ServiceAccount.psm1"
using module ".\Fileshare.psm1"
using module ".\SetupConfiguration.psm1"
using module ".\MsSqlServer.psm1"

class Domaincontroller : BaseComputer {
    [String] $DsrmPassword
    [Fileshare[]] $Fileshares
    [OrganizationalUnit[]] $OrganizationalUnits
    [DomainUserAccount[]] $DomainUserAccounts
    [ServiceAccount[]] $ServiceAccounts
    [Bool] $HasIisInstalled = $false
    [MsSqlServer] $MsSqlServer = $null
    
    Domaincontroller() {}
    
    Domaincontroller([PSCustomObject] $MachineConfiguration, [PSCustomObject] $DomainConfiguration, [SetupConfiguration] $SetupConfiguration) : base($MachineConfiguration, $DomainConfiguration, $SetupConfiguration) {
        # setup user account configuration
        $this.SetupUser = New-Object DomainUserAccount
        $this.SetupUser.DomainName = $this.DomainName
        $this.SetupUser.SamAccountName = $this.DefaultUser.UserName
        $this.SetupUser.GivenName = ""
        $this.SetupUser.Surname = ""
        $this.SetupUser.Name = ""
        $this.SetupUser.Password = $this.DefaultUser.Password
        $this.SetupUser.Path = ""
        $this.SetupUser.IsDomainAdministrator = $true
        $this.SetupUser.HasPreAuthDisabled = $false
        $this.SetupUser.UserPrincipalName = "$($this.SetupUser.SamAccountName)@$($this.SetupUser.DomainName)"
        $this.SetupUser.LogonName = "$($this.SetupUser.DomainName)\$($this.SetupUser.SamAccountName)"
        $this.SetupUser.SecurePassword = ConvertTo-SecureString $this.SetupUser.Password -AsPlainText -Force
        $this.SetupUser.Credential = New-Object System.Management.Automation.PSCredential($this.SetupUser.LogonName, $this.SetupUser.SecurePassword)
        Write-Host "[*] Using '$($this.SetupUser.LogonName)' for the setup ..." -ForegroundColor Yellow -BackgroundColor Black

        # domain controller specific configuration
        $this.DsrmPassword = $MachineConfiguration.dsrm_password

        # fileshare configuration
        foreach ($FileshareConfiguration in $MachineConfiguration.fileshares) {
            $this.Fileshares += [Fileshare]::new($FileshareConfiguration, $this.DomainName, $this.HostName)
        }

        # organizational unit configuration
        foreach ($OrganizationalUnitConfiguration in $DomainConfiguration.organizational_units) {
            $this.OrganizationalUnits += [OrganizationalUnit]::new($OrganizationalUnitConfiguration, $this.DomainName)
        }

        # domain user account configuration
        foreach ($DomainUserAccountConfiguration in $DomainConfiguration.user_accounts) {
            $this.DomainUserAccounts += [DomainUserAccount]::new($DomainUserAccountConfiguration, $this.DomainName)
        }

        # service account configuration
        foreach ($ServiceAccountConfiguration in $DomainConfiguration.service_accounts) {
            $this.ServiceAccounts += [ServiceAccount]::new($ServiceAccountConfiguration, $this.DomainName)
        }

        # iis configuration
        if ($MachineConfiguration.PSobject.Properties.Name.Contains("has_iis_installed")) {
            $this.HasIisInstalled = $MachineConfiguration.has_iis_installed
        }

        # mssqlserver configuration
        if ($MachineConfiguration.PSobject.Properties.Name.Contains("mssqlserver")) {
            # the domain\administrator account cannot be set as sqlsysadminaccount this way
            # since its not mentioned in the config.json file and the script does not know
            # about it. might add an exception for the default domain admin accout later on
            [DomainUserAccount[]] $SqlSysAdminAccounts = $null
            foreach ($ServiceAdministratorAccount in $MachineConfiguration.mssqlserver.service_administrator_accounts) {
                $SqlSysAdminAccounts += $this.CreateDomainAccountBySamAccountName($DomainConfiguration, $ServiceAdministratorAccount)
            }
            [ServiceAccount] $SqlSvcAccount = $null
            foreach ($ServiceAccount in $this.ServiceAccounts) {
                if ($ServiceAccount.SamAccountName -eq $MachineConfiguration.mssqlserver.service_account) {
                    $SqlSvcAccount = $ServiceAccount
                    break
                }
            }
            $this.MsSqlServer = [MsSqlServer]::new($this.SetupConfiguration, $SqlSvcAccount, $SqlSysAdminAccounts)
        }
    }

    [Void] CreateOrganziationalUnits() {
        Write-Host "[*] Creating organizational units ..." -ForegroundColor Yellow -BackgroundColor Black
        foreach ($OrganizationalUnit in $this.OrganizationalUnits) {
            try {
                $OrganizationalUnit.Create()
            } catch {
                Write-Host "[-] Error: $_" -ForegroundColor Red -BackgroundColor Black
            }
        }
    }

    [Void] CreateDomainAccountsAndGrantPrivileges() {
        Write-Host "[*] Creating user accounts ..." -ForegroundColor Yellow -BackgroundColor Black
        foreach ($DomainUserAccount in $this.DomainUserAccounts) {
            try {
                $DomainUserAccount.CreateAndGrantPrivileges()
            } catch {
                Write-Host "[-] Error: $_" -ForegroundColor Red -BackgroundColor Black
            }
        }
        Write-Host "[*] Creating service accounts ..." -ForegroundColor Yellow -BackgroundColor Black
        foreach ($ServiceAccount in $this.ServiceAccounts) {
            try {
                $ServiceAccount.CreateAndGrantPrivileges()
                $ServiceAccount.SetServicePrincipalName()
            } catch {
                Write-Host "[-] Error: $_" -ForegroundColor Red -BackgroundColor Black
            }
        }
    }

    [Void] HostFileshares() {
        Write-Host "[*] Hosting fileshares ..." -ForegroundColor Yellow -BackgroundColor Black
        foreach ($Fileshare in $this.Fileshares) {
            try {
                $Fileshare.Host()
            } catch {
                Write-Host "[-] Error: $_" -ForegroundColor Red -BackgroundColor Black
            }
        }
    }

    [Void] InstallActiveDirectoryDomainServices() {
        Write-Host "[*] Installing Active Directory Domain Services ..." -ForegroundColor Yellow -BackgroundColor Black
        Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
        Install-ADDSForest -DomainName $this.DomainName -SafeModeAdministratorPassword (ConvertTo-SecureString $($this.DsrmPassword) -AsPlainText -Force) -Force -NoRebootOnCompletion
    }

    [Void] InstallActiveDirectoryCertificateServices() {
        Write-Host "[*] Installing Active Directory Certificate Services ..." -ForegroundColor Yellow -BackgroundColor Black
        Install-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
        Install-AdcsCertificationAuthority -CAType StandaloneRootCa -Force
    }

    [Void] WaitForActiveDirectoryDomainServicesToBeSpunUp() {
        Write-Host "[*] Making sure the Active Directory Domain Services are spun up ..." -ForegroundColor Yellow -BackgroundColor Black
        $NtdsIsSpunUp = $false
        while (-not $NtdsIsSpunUp) {
            try {
                # (Get-Service NTDS).status seems to return $true on startup (service is not fully functional at this point)
                # instead try a simple query until it succeeds and send output to hell
                Get-ADUser -Filter 'Name -like "Administrator"' 2>$null 1>$null -ErrorAction Stop
                $NtdsIsSpunUp = $true
            } catch {
                Write-Host "NTDS is not running, retrying in 10 seconds ..." -ForegroundColor Yellow -BackgroundColor Black
                Start-Sleep 10
            }
        }
    }

    [Void] InstallIisWebserver() {
        if ($this.HasIisInstalled) {
            Write-Host "[*] Installing the IIS Webserver ..." -ForegroundColor Yellow -BackgroundColor Black
            Install-WindowsFeature Web-Server -IncludeManagementTools
            Remove-Website -Name "Default Web Site"
            Remove-Item -Path "C:\inetpub\wwwroot\*" -Recurse -Force
            New-Website -Name Democorp -PhysicalPath "C:\inetpub\wwwroot"
    
            Write-Host "[*] Copying website to 'C:\inetpub\wwwroot\' ..." -ForegroundColor Yellow -BackgroundColor Black
            if (-not (Test-Path "C:\inetpub\wwwroot")) {
                Write-Host "[*] Creating directory 'C:\inetpub\wwwroot' ..." -ForegroundColor Yellow -BackgroundColor Black
                New-Item -Path "C:\inetpub\wwwroot" -ItemType Directory
            }
            # current file is 'Domaincontroller.psm1', not 'Setup.ps1' so go back one directory and copy everything recursively
            Copy-Item -Path $(Join-Path $PSScriptRoot "\..\website\*") -Destination "C:\inetpub\wwwroot\" -Recurse
        }
    }

    [Void] InstallMsSqlServer() {
        if ($null -ne $this.MsSqlServer) {
            $this.MsSqlServer.Install()
        }
    }

    [Void] WeakenPasswordPolicy() {
        Write-Host "[*] Weakening the password policy ..." -ForegroundColor Yellow -BackgroundColor Black
        Set-ADDefaultDomainPasswordPolicy -Identity $this.DomainName -ComplexityEnabled $false -MinPasswordLength 3
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
            $this.InstallActiveDirectoryDomainServices()
            $this.InstallActiveDirectoryCertificateServices()
            $this.SetDnsServers()
            $this.EnableSetupUserAccountAutoLogin()
            $this.SetCurrentStage(2)
            $this.Restart()
        } elseif (2 -eq $CurrentStage) {
            $this.WeakenPasswordPolicy()
            $this.CreateOrganziationalUnits()
            $this.CreateDomainAccountsAndGrantPrivileges()
            $this.InstallIisWebserver()
            $this.InstallMsSqlServer()
            $this.HostFileshares()
            $this.SetCurrentStage(3)
            $this.Restart()
        } elseif (3 -eq $CurrentStage) {
            $this.RemoveScheduledSetupTask()
            $this.DisableSetupUserAutoLogin()
            $this.EnableRdp()
            $this.EnableNetworkDiscovery()
            $this.EnableFileAndPrinterSharing()
            $this.RemoveSetupFilesFromSetupFilesPath()
            Write-Host "[+] All Done! Happy Hacking!" -ForegroundColor Green -BackgroundColor Black
            Write-Host "[*] Press any key to reboot." -ForegroundColor Blue -BackgroundColor Black
            pause
            $this.Restart()
        }
    }
}
