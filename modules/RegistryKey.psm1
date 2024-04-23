class RegistryKey {
    [String] $Path
    [String] $Key
    [String] $Value = ""

    RegistryKey() {}

    RegistryKey([String] $Path, [String] $Key) {
        $this.Path = $Path
        $this.Key = $Key
    }

    RegistryKey([String] $Path, [String] $Key, [String] $Value) {
        $this.Path = $Path
        $this.Key = $Key
        $this.Value = $Value
    }

    # NOTE: naming convention for setvalue and getvalue can be confusing, might change this later on

    [Void] SetValue() {
        Write-Host "[*] Setting registry key '$($this.Path)\$($this.Key)' -> '$($this.Value)'" -ForegroundColor Yellow -BackgroundColor Black
    
        # if the path does not exist, create the path
        if (-not (Test-Path $this.Path)) {
            Write-Host "[*] Path '$($this.Path)' does not exist yet, creating path ..." -ForegroundColor Yellow -BackgroundColor Black
            New-Item -Path $this.Path
        }
    
        # if the key already exists, just update the value
        # first statement returns false if key is non existent or empty, so we need to check if the key exists but is empty in second statement
        if ((Get-ItemProperty -Path $this.Path).($this.Key) -Or (Get-ItemProperty -Path $this.Path).($this.Key) -eq "") {
            Write-Host "[*] Key '$($this.Path)\$($this.Key)' already exists, updating value ..." -ForegroundColor Yellow -BackgroundColor Black
            Set-ItemProperty -Path $this.Path -Name $this.Key -Value $this.Value
        }
    
        # if the key does not exist, create the key
        else {
            Write-Host "[*] Key '$($this.Path)\$($this.Key)' does not exist yet, creating key ..." -ForegroundColor Yellow -BackgroundColor Black
            New-ItemProperty -Path $this.Path -Name $this.Key -Value $this.Value
        }
    }

    [String] GetValue() {
        Write-Host "[*] Retrieving registry key '$($this.Path)\$($this.Key)' ..." -ForegroundColor Yellow -BackgroundColor Black
        if (-not (Test-Path $this.Path)) {
            return $null
        }
        return (Get-ItemProperty -Path $this.Path).($this.Key)
    }

    [Void] Remove() {
        Write-Host "[*] Removing registry key '$($this.Path)\$($this.Key)' ..." -ForegroundColor Yellow -BackgroundColor Black
        Remove-ItemProperty -Path $this.Path -Name $this.Key
    }
}
