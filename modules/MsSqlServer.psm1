using module ".\DomainUserAccount.psm1"
using module ".\SetupConfiguration.psm1"
using module ".\ServiceAccount.psm1"

class MsSqlServer {
    [SetupConfiguration] $SetupConfiguration
    [DomainUserAccount[]] $SqlSysAdminAccounts
    [ServiceAccount] $SqlSvcAccount

    MsSqlServer() {}

    MsSqlServer([SetupConfiguration] $SetupConfiguration, [ServiceAccount] $SqlSvcAccount, [DomainUserAccount[]] $SqlSysAdminAccounts) {
        $this.SetupConfiguration = $SetupConfiguration
        $this.SqlSvcAccount = $SqlSvcAccount
        $this.SqlSysAdminAccounts = $SqlSysAdminAccounts
    }

    [Void] Install() {
        $SysAdminAccountsString = ""
        foreach ($SqlSysAdminAccount in $this.SqlSysAdminAccounts) {
            $SysAdminAccountsString += $SqlSysAdminAccount.LogonName + ' '
        }
        # derived from: https://github.com/majkinetor/Install-SqlServer
        # official documentation: https://learn.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt?view=sql-server-ver16#Feature
        Write-Host "[*] Installing MS SQL Server ..." -ForegroundColor Yellow -BackgroundColor Black
        $DownloadUrl = "https://download.microsoft.com/download/3/8/d/38de7036-2433-4207-8eae-06e247e17b25/SQLServer2022-x64-ENU-Dev.iso"
        $FileName = $DownloadUrl.split("/")[-1]
        $SaveDir = $this.SetupConfiguration.SetupFilesPath
        $SavePath = Join-Path $SaveDir $FileName
        Start-BitsTransfer -Source $DownloadUrl -Destination $SaveDir

        $Volume = Mount-DiskImage $SavePath -StorageType ISO -PassThru | Get-Volume
        $Drive = $Volume.DriveLetter + ":"
        $cmd =@(
            "$($Drive)setup.exe"
            "/QS"
            "/INDICATEPROGRESS"
            "/IACCEPTSQLSERVERLICENSETERMS"
            "/ACTION=install"
            "/FEATURES=SQL"
            "/SQLSYSADMINACCOUNTS=$($SysAdminAccountsString)"
            "/INSTANCENAME=MSSQLSERVER"
            "/SQLSVCACCOUNT=$($this.SqlSvcAccount.LogonName)"
            "/SQLSVCPASSWORD=$($this.SqlSvcAccount.Password)"
            "/SQLSVCSTARTUPTYPE=automatic"
            "/AGTSVCSTARTUPTYPE=automatic"
            "/ASSVCSTARTUPTYPE=manual"
        )
        Write-Host "[*] Using Setup Parameters: $cmd" -ForegroundColor Yellow -BackgroundColor Black
        Invoke-Expression "$cmd"
        Dismount-DiskImage $SavePath
    
        $ComputerManagement = Get-CimInstance -Namespace "root\Microsoft\SqlServer" -ClassName "__NAMESPACE"  | Where-Object name -match "ComputerManagement" | Select-Object -Expand name
        $ServerNetworkProtocol = Get-CimInstance -Namespace "root\Microsoft\SqlServer\$ComputerManagement" -ClassName ServerNetworkProtocol
        $ServerNetworkProtocol | Where-Object ProtocolDisplayName -eq "TCP/IP" | Invoke-CimMethod -Name SetEnable
        $ServerNetworkProtocol | Where-Object ProtocolDisplayName -eq "Named Pipes" | Invoke-CimMethod -Name SetEnable

        # https://learn.microsoft.com/en-us/sql/sql-server/install/configure-the-windows-firewall-to-allow-sql-server-access?view=sql-server-ver16
        New-NetFirewallRule -DisplayName "SQLServer default instance" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow
        New-NetFirewallRule -DisplayName "SQLServer Browser service" -Direction Inbound -LocalPort 1434 -Protocol UDP -Action Allow

        Get-Service "MSSQLSERVER" | Restart-Service -Force
    }
}
