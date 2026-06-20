$portName = "COM5"
$baudRate = 115200

Write-Host "Opening $portName..."
$port = New-Object System.IO.Ports.SerialPort $portName, $baudRate, None, 8, one
$port.DtrEnable = $true
$port.RtsEnable = $true
$port.ReadTimeout = 1000

try {
    $port.Open()
    Write-Host "Successfully opened $portName. Reading data (Press Ctrl+C to stop)..."
    
    $startTime = Get-Date
    while (((Get-Date) - $startTime).TotalSeconds -lt 30) {
        if ($port.BytesToRead -gt 0) {
            $line = $port.ReadLine()
            Write-Host $line
        }
        Start-Sleep -Milliseconds 10
    }
}
catch {
    Write-Error $_
}
finally {
    if ($port -and $port.IsOpen) {
        $port.Close()
        Write-Host "Port closed."
    }
}
