# to run this script use 'powershell -ExecutionPolicy Bypass .\SMBTrafficGenerator.ps1'

# timeout in seconds
$Timeout = 120

Write-Host "[*] SMB Traffic Generator" -ForegroundColor Blue -BackgroundColor Black
Write-Host "[*] To kill this script hit CTRL+C`n" -ForegroundColor Blue -BackgroundColor Black

while ($true) {
    Write-Host "[*] Connecting to SMB share \\DC-1 ..." -ForegroundColor Yellow -BackgroundColor Black
    New-SMBMapping -RemotePath \\DC-1 2>$null

    timeout $Timeout; Write-Host ""
}
