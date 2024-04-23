using module ".\RegistryKey.psm1"
using module ".\SetupConfiguration.psm1"

class LocalUserAccount {
    [String] $HostName
    [String] $UserName
    [String] $Password
    [String] $FullName = ""
    [Bool] $IsLocalAdministrator = $false
    [String] $LogonName
    [SecureString] $SecurePassword
    [PSCredential] $Credential

    LocalUserAccount() {}
    
    LocalUserAccount([PSCustomObject] $LocalUserAccountConfiguration, [String] $HostName) {
        $this.HostName = $HostName
        $this.UserName = $LocalUserAccountConfiguration.user_name
        $this.Password = $LocalUserAccountConfiguration.password

        if ($LocalUserAccountConfiguration.PSobject.Properties.Name.Contains("is_local_administrator")) {
            $this.IsLocalAdministrator = $LocalUserAccountConfiguration.is_local_administrator
        }

        if ($LocalUserAccountConfiguration.PSobject.Properties.Name.Contains("name")) {
            $this.FullName = $LocalUserAccountConfiguration.name
        }

        $this.LogonName = "$($this.HostName)\$($this.UserName)"
        $this.SecurePassword = ConvertTo-SecureString $this.Password -AsPlainText -Force
        $this.Credential = New-Object System.Management.Automation.PSCredential($this.UserName, $this.SecurePassword)
    }

    [Void] Create() {
        Write-Host "[*] Creating local user account '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        New-LocalUser -Name $this.UserName -Password $this.SecurePassword -FullName $this.FullName
    }

    [Void] Login() {
        Write-Host "[*] Logging in as '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        Start-Process powershell.exe -Wait -NoNewWindow -Credential $this.Credential -ArgumentList "-Command whoami" -WorkingDirectory "C:\Windows\System32"
    }

    [Void] GrantLocalAdministratorPrivileges() {
        Write-Host "[*] Granting '$($this.LogonName)' local administrator privileges ..." -ForegroundColor Yellow -BackgroundColor Black
        Add-LocalGroupMember -Group Administrators -Member $this.UserName
    }

    [Void] Remove() {
        Write-Host "[*] Removing local user account '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        Remove-LocalUser -Name $this.UserName
    }

    [Void] RemoveLocalAdministratorPrivileges() {
        Write-Host "[*] Removing '$($this.LogonName)' from local administrators ..." -ForegroundColor Yellow -BackgroundColor Black
        Remove-LocalGroupMember -Group Administrators -Member $this.UserName
    }

    [Void] ChangePassword([String] $NewPassword) {
        Write-Host "[*] Changing password of '$($this.LogonName)' to '$NewPassword'..." -ForegroundColor Yellow -BackgroundColor Black
        $this.SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force
        $this.Credential = New-Object System.Management.Automation.PSCredential($this.LogonName, $this.SecurePassword)
        Set-LocalUser -Name $this.UserName -Password $this.SecurePassword
        $this.Password = $NewPassword
    }

    [Void] EnableAutoLogin() {
        Write-Host "[*] Enabling auto login for '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultUserName", $this.UserName).SetValue()
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultPassword", $this.Password).SetValue()
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "AutoAdminLogon", "1").SetValue()
    }

    [Void] DisableAutoLogin() {
        Write-Host "[*] Disabling auto login for '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultUserName").Remove()
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultPassword").Remove()
        [RegistryKey]::new("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "AutoAdminLogon").Remove()
    }

    [Void] CreateScheduledSetupTask([SetupConfiguration] $SetupConfiguration, [String] $HostName) {
        Write-Host "[*] Creating scheduled setup task '$($SetupConfiguration.ScheduledTaskName)' for '$($this.LogonName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        $SetupFile = Join-Path $SetupConfiguration.SetupFilesPath $SetupConfiguration.SetupFileName
        $ConfigurationFile = Join-Path $SetupConfiguration.SetupFilesPath $SetupConfiguration.ConfigurationFileName
        $Action = New-ScheduledTaskAction -Execute 'powershell' -Argument "-ExecutionPolicy Bypass -File $SetupFile $ConfigurationFile $HostName"
        $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $this.UserName
        Register-ScheduledTask -Action $Action -Trigger $Trigger -User $this.UserName -TaskName $SetupConfiguration.ScheduledTaskName -RunLevel Highest
    }
}
