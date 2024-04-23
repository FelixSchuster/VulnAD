class OrganizationalUnit {
    [String] $DomainName
    [String] $Name
    [String] $Path

    OrganizationalUnit() {}

    OrganizationalUnit([PSCustomObject] $OrganizationalUnitConfiguration, [String] $DomainName) {
        $this.DomainName = $DomainName
        $this.Name = $OrganizationalUnitConfiguration.name
        $this.Path = $OrganizationalUnitConfiguration.path
    }

    [Void] Create() {
        Write-Host "[*] Creating organizational unit '$($this.Name)' ..." -ForegroundColor Yellow -BackgroundColor Black
        New-ADOrganizationalUnit -Name $this.Name -Path $this.Path
    }
}
