# to run this script use 'powershell -ExecutionPolicy Bypass .\HTTPTrafficGenerator.ps1'

# timeout in seconds
$Timeout = 120

# powershell defaults to Invoke-WebRequest when curl is called
# save the path to the original curl command to use it later on
$curl = (Get-Command curl.exe).Source

Write-Host "[*] HTTP Traffic Generator" -ForegroundColor Blue -BackgroundColor Black
Write-Host "[*] To kill this script hit CTRL+C`n" -ForegroundColor Blue -BackgroundColor Black

while ($true) {
    Write-Host "[*] Flushing DNS cache ..." -ForegroundColor Yellow -BackgroundColor Black
    ipconfig /flushdns 1>$null

    # 'ipconfig /renew6' should make windows check the network for ipv6 dns servers
    # however there is no option to set a timeout if no ipv6 dns server exists on the network
    # to work around this issue, start the command in a new powershell window and kill it after X seconds

    Write-Host "[*] Searching for IPv6 DNS servers on the network ..." -ForegroundColor Yellow -BackgroundColor Black
    Start-Process -FilePath "ipconfig" -ArgumentList "/renew6" -WindowStyle Hidden -PassThru | ForEach-Object { 
        $process = $_
        Start-Sleep -Seconds 3
        if (!$process.HasExited) {
            Write-Host "[-] IPv6 DNS server not found" -ForegroundColor Red -BackgroundColor Black
            Stop-Process -InputObject $process -Force
        } else {
            Write-Host "[+] IPv6 DNS server found!" -ForegroundColor Green -BackgroundColor Black
            Write-Host "[*] Trying to resolve hostname DC-1.DEMOCORP.local ..."  -ForegroundColor Yellow -BackgroundColor Black
            $ip = (Resolve-DnsName -Name DC-1.democorp.local -Type A).IPAddress 2>$null
            if ($ip) {
                Write-Host "[+] Hostname resolved, sending request to http://$ip/ ..." -ForegroundColor Green -BackgroundColor Black
                & $curl http://$ip --ntlm --negotiate -u Felix:F-P@ssword 2>$null
            } else {
                Write-Host "[-] Unable to resolve hostname" -ForegroundColor Red -BackgroundColor Black
            }
        }
    }

    timeout $Timeout; Write-Host ""
}
