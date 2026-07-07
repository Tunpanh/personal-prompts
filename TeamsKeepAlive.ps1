try {
    Add-Type -AssemblyName System.Windows.Forms
    Write-Host "Teams Keep Alive - Started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""

    $count = 0
    while ($true) {
        $count++
        [System.Windows.Forms.SendKeys]::SendWait("{SCROLLLOCK}")
        Write-Host "[$count] $(Get-Date -Format 'HH:mm:ss') - Sent SCROLLLOCK"
        Start-Sleep -Seconds 180
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
