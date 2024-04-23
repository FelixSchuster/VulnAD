using module ".\LocalUserAccount.psm1"
using module ".\RegistryKey.psm1"
using module ".\SetupConfiguration.psm1"

class DomainUserAccount {
    [String] $DomainName
    [String] $SamAccountName
    [String] $GivenName
    [String] $Surname
    [String] $Name
    [String] $Password
    [String] $Path
    [Bool] $IsDomainAdministrator = $false
    [Bool] $HasPreAuthDisabled = $false
    [String] $UserPrincipalName # samaccountname@domain
    [String] $LogonName # domain\samaccountname
    [SecureString] $SecurePassword
    [PSCredential] $Credential

    DomainUserAccount() {}
    
    DomainUserAccount([PSCustomObject] $DomainUserAccountConfiguration, [String] $DomainName) {
        $this.DomainName = $DomainName
        $this.SamAccountName = $DomainUserAccountConfiguration.sam_account_name
        $this.GivenName = $DomainUserAccountConfiguration.given_name
        $this.Surname = $DomainUserAccountConfiguration.surname
        $this.Password = $DomainUserAccountConfiguration.password
        $this.Path = $DomainUserAccountConfiguration.path

        if ($DomainUserAccountConfiguration.PSobject.Properties.Name.Contains("is_domain_administrator")) {
            $this.IsDomainAdministrator = $DomainUserAccountConfiguration.is_domain_administrator
        }

        if ($DomainUserAccountConfiguration.PSobject.Properties.Name.Contains("has_pre_auth_disabled")) {
            $this.HasPreAuthDisabled = $DomainUserAccountConfiguration.has_pre_auth_disabled
        }

        if ($DomainUserAccountConfiguration.PSobject.Properties.Name.Contains("name")) {
            $this.Name = $DomainUserAccountConfiguration.name
        } else {
            $this.Name = "$($this.GivenName) $($this.Surname)"
        }

        $this.UserPrincipalName = "$($this.SamAccountName)@$($this.DomainName)"
        $this.LogonName = "$($this.DomainName)\$($this.SamAccountName)"
        $this.SecurePassword = ConvertTo-SecureString $this.Password -AsPlainText -Force
        $this.Credential = New-Object System.Management.Automation.PSCredential($this.LogonName, $this.SecurePassword)
    }

    [Void] Create() {
        Write-Host "[*] Creating user account '$($this.SamAccountName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        New-ADUser -Name $this.Name -GivenName $this.GivenName -Surname $this.Surname -SamAccountName $this.SamAccountName -UserPrincipalName $this.UserPrincipalName -AccountPassword $this.SecurePassword -Path $this.Path -Enabled $true -PasswordNeverExpires $true
    }

    [Void] CreateAndGrantPrivileges() {
        $this.Create()
        if ($this.IsDomainAdministrator) {
            $this.GrantDomainAdministratorPrivileges()
        }
        if ($this.HasPreAuthDisabled) {
            $this.DisablePreAuthentication()
        }
    }

    [Void] GrantDomainAdministratorPrivileges() {
        Write-Host "[*] Granting '$($this.SamAccountName)' domain administrator privileges ..." -ForegroundColor Yellow -BackgroundColor Black
        Add-ADGroupMember -Identity "Administrators" -Members $this.SamAccountName
        Add-ADGroupMember -Identity "Domain Admins" -Members $this.SamAccountName
        Add-ADGroupMember -Identity "Enterprise Admins" -Members $this.SamAccountName
        Add-ADGroupMember -Identity "Group Policy Creator Owners" -Members $this.SamAccountName
        Add-ADGroupMember -Identity "Schema Admins" -Members $this.SamAccountName
    }

    [Void] DisablePreAuthentication() {
        Write-Host "[*] Disabling pre-authentication for '$($this.SamAccountName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        Set-ADAccountControl -Identity $this.SamAccountName -DoesNotRequirePreAuth:$true
    }

    [Void] Login() {
        Write-Host "[*] Logging in as '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        Start-Process powershell.exe -Wait -NoNewWindow -Credential $this.Credential -ArgumentList "-Command whoami"
    }

    [Void] GrantLocalAdministratorPrivileges() {
        Write-Host "[*] Granting '$($this.LogonName)' local administrator privileges ..." -ForegroundColor Yellow -BackgroundColor Black
        Add-LocalGroupMember -Group Administrators -Member $this.LogonName
    }

    [Void] RemoveLocalAdministratorPrivileges() {
        Write-Host "[*] Removing '$($this.LogonName)' from local administrators ..." -ForegroundColor Yellow -BackgroundColor Black
        Remove-LocalGroupMember -Group Administrators -Member $this.LogonName
    }

    [Void] EnableAutoLogin() {
        Write-Host "[*] Enabling auto login for '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultUserName", $this.SamAccountName).SetValue()
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultPassword", $this.Password).SetValue()
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultDomainName", $this.DomainName).SetValue()
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "AutoAdminLogon", "1").SetValue()
    }

    [Void] DisableAutoLogin() {
        Write-Host "[*] Disabling auto login for '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultUserName").Remove()
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultPassword").Remove()
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultDomainName").Remove()
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "AutoAdminLogon").Remove()
    }

    [Void] CreateScheduledSetupTask([SetupConfiguration] $SetupConfiguration, [String] $HostName) {
        Write-Host "[*] Creating scheduled setup task '$($SetupConfiguration.ScheduledTaskName)' for '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        $SetupFile = Join-Path $SetupConfiguration.SetupFilesPath $SetupConfiguration.SetupFileName
        $ConfigurationFile = Join-Path $SetupConfiguration.SetupFilesPath $SetupConfiguration.ConfigurationFileName
        $Action = New-ScheduledTaskAction -Execute "powershell" -Argument "-ExecutionPolicy Bypass -File $SetupFile $ConfigurationFile $HostName"
        $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $this.LogonName
        Register-ScheduledTask -Action $Action -Trigger $Trigger -User $this.LogonName -TaskName $SetupConfiguration.ScheduledTaskName -RunLevel Highest
    }

    [Void] BrowseFileshare([String] $ScriptPath, [String] $RemotePath) {
        Write-Host "[*] Creating browse fileshare scheduled task for '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        $ScriptFile = Join-Path $ScriptPath "FileshareBrowser.ps1"
        $Action = New-ScheduledTaskAction -Execute "powershell" -Argument "-ExecutionPolicy Bypass -File $ScriptFile $RemotePath"
        $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $this.LogonName
        $TaskName = "Browse Fileshare $RemotePath".replace('\','_') # apparently '\' is not allowed in the task name
        Register-ScheduledTask -Action $Action -Trigger $Trigger -User $this.LogonName -TaskName $TaskName -RunLevel Highest
    }

    [Void] GenerateHttpTraffic([String] $ScriptPath) {
        Write-Host "[*] Creating generate http traffic scheduled task for '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        $ScriptFile = Join-Path $ScriptPath "HTTPTrafficGenerator.ps1"
        $Action = New-ScheduledTaskAction -Execute "powershell" -Argument "-ExecutionPolicy Bypass -File $ScriptFile"
        $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $this.LogonName
        Register-ScheduledTask -Action $Action -Trigger $Trigger -User $this.LogonName -TaskName "Generate HTTP Traffic" -RunLevel Highest
    }

    [Void] GenerateSmbTraffic([String] $ScriptPath) {
        Write-Host "[*] Creating generate smb traffic scheduled task for '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        $ScriptFile = Join-Path $ScriptPath "SMBTrafficGenerator.ps1"
        $Action = New-ScheduledTaskAction -Execute "powershell" -Argument "-ExecutionPolicy Bypass -File $ScriptFile"
        $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $this.LogonName
        Register-ScheduledTask -Action $Action -Trigger $Trigger -User $this.LogonName -TaskName "Generate SMB Traffic" -RunLevel Highest
    }
}
