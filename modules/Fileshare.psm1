class Fileshare {
    [String] $DomainName
    [String] $HostName
    [String] $Name
    [String] $Path
    [String] $Drive

    Fileshare() {}
    
    Fileshare([PSCustomObject] $FileshareConfiguration, [String] $DomainName, [String] $HostName) {
        $this.DomainName = $DomainName
        $this.HostName = $HostName
        $this.Name = $FileshareConfiguration.name
        $this.Path = $FileshareConfiguration.path
        $this.Drive = $FileshareConfiguration.drive
    }

    [Void] Host() {
        if (-not (Test-Path $this.Path)) {
            Write-Host "[*] Directory '$($this.Path)' does not exist yet, creating directory ..." -ForegroundColor Yellow -BackgroundColor Black
            New-Item -Path $this.Path -ItemType Directory
        }
        Write-Host "[*] Hosting fileshare '$($this.Name)' ..." -ForegroundColor Yellow -BackgroundColor Black
        New-SmbShare -Name $this.Name -Path $this.Path -FullAccess Everyone # could manage permissions here by granting access to specific users instead

        # current file is 'Fileshare.psm1', not 'Setup.ps1' so go back one directory
        if (Test-Path $(Join-Path $PSScriptRoot "\..\fileshares\$($this.Name)")) {
            Write-Host "[*] Copying files to $($this.Path) ..." -ForegroundColor Yellow -BackgroundColor Black
            Copy-Item -Path $(Join-Path $PSScriptRoot "\..\fileshares\$($this.Name)\*") -Destination $this.Path -Recurse
        }

        Write-Host "[*] Creating group policy for fileshare '$($this.Name)' ..." -ForegroundColor Yellow -BackgroundColor Black
        
        $GpoName = "Map Fileshare '$($this.Name)'"
        $RemotePath = "\\$($this.HostName)\$($this.Name)"

        # create a random uid for the drive
        $RandomUid = (New-Guid).Guid.ToUpper()

        # create a new gpo
        $Gpo = New-GPO -Name $GPOName

        # link the new gpo to the domain
        $Domain = Get-ADDomain | Select-Object -ExpandProperty DistinguishedName
        New-GPLink -Name $GpoName -Target $Domain -LinkEnabled Yes

        # good luck deciphering this... there is no proper official documentation, for further information visit the following blogbosts:
        # https://social.technet.microsoft.com/forums/en-US/0bfdd917-5267-45b0-bb99-bf1485bfe88c/create-gpo-map-drive-over-windows-powershell-script
        # https://learn.microsoft.com/en-us/answers/questions/936325/create-drives-gpo-via-powershellscript
        Set-ADObject -Identity "CN=`{$($Gpo.Id)`},CN=Policies,CN=System,$Domain" -Add @{gPCUserExtensionnames='[{00000000-0000-0000-0000-000000000000}{2EA1A81B-48E5-45E9-8BB7-A6E3AC170006}][{5794DAFD-BE60-433F-88A2-1A31939AC01F}{2EA1A81B-48E5-45E9-8BB7-A6E3AC170006}]'}
        Set-ADObject -Identity "CN=`{$($Gpo.Id)`},CN=Policies,CN=System,$Domain" -Replace @{versionNumber=111111}

# do not indent or vscode will scream at you, also it will break the script
$xml = @"
<?xml version="1.0" encoding="utf-8"?>
<Drives clsid="{8FDDCC1A-0C3C-43cd-A6B4-71A6DF20DA8C}">
<Drive clsid="{935D1B74-9CB8-4e3c-9914-7DD559B7A417}" name="$($this.Drive):" status="$($this.Drive):" image="2" changed="2024-01-01 12:00:00" uid="`{$RandomUid`}" bypassErrors="1">
<Properties action="U" thisDrive="SHOW" allDrives="SHOW" userName="" path="$RemotePath" label="" persistent="1" useLetter="1" letter="$($this.Drive)"/>
</Drive>
</Drives>
"@

        # write the xml file to sysvol
        $xml | Out-File "$(New-Item -Force -Type Directory -Path "\\$($this.HostName)\SYSVOL\$($this.DomainName)\Policies\`{$($Gpo.Id)`}\User\Preferences\Drives")\Drives.xml" -Encoding utf8 -Force
        
        # update the group policy
        gpupdate /force
    }
}
