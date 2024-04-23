# To run this script use 'powershell -ExecutionPolicy Bypass .\FileshareBrowser.ps1 <Fileshare>'

param (
    [Parameter(Mandatory=$true)] $Fileshare
)

# timeout in seconds
$Timeout = 120

Write-Host "[*] Fileshare Browser" -ForegroundColor Blue -BackgroundColor Black
Write-Host "[*] To kill this script hit CTRL+C`n" -ForegroundColor Blue -BackgroundColor Black

while ($true) {
    Write-Host "[*] Browsing fileshare $Fileshare ..." -ForegroundColor Yellow -BackgroundColor Black
    explorer $Fileshare
    
    timeout $Timeout; Write-Host ""
}
