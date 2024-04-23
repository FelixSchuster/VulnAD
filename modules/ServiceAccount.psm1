using module ".\DomainUserAccount.psm1"

class ServiceAccount : DomainUserAccount {
    [String] $ServicePrincipalName

    ServiceAccount() {}
    
    ServiceAccount([PSCustomObject] $ServiceAccountConfiguration, [String] $DomainName) : base($ServiceAccountConfiguration, $DomainName) {
        $this.ServicePrincipalName = $ServiceAccountConfiguration.service_principal_name
    }

    [Void] SetServicePrincipalName() {
        Write-Host "[*] Setting service principal name '$($this.ServicePrincipalName)' for '$($this.SamAccountName)' ..." -ForegroundColor Yellow -BackgroundColor Black
        setspn -A $this.ServicePrincipalName $this.LogonName
    }
}
