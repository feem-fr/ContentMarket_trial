$logDir = "C:\Users\hp1\Desktop\content-market"
$serverDir = "$logDir\server"
$clientDir = "$logDir\client"

$serverLog = "$logDir\server_output.txt"
$clientLog = "$logDir\client_output.txt"

# Kill old nodes
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Start server
$serverProcess = New-Object System.Diagnostics.Process
$serverProcess.StartInfo.FileName = "node"
$serverProcess.StartInfo.Arguments = "server.js"
$serverProcess.StartInfo.WorkingDirectory = $serverDir
$serverProcess.StartInfo.UseShellExecute = $false
$serverProcess.StartInfo.RedirectStandardOutput = $true
$serverProcess.StartInfo.RedirectStandardError = $true
$serverProcess.StartInfo.CreateNoWindow = $true
$serverProcess.Start() | Out-Null
$serverProcess.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal
$serverProcess.StandardOutput.ReadToEndAsync() | Out-Null
$serverProcess.StandardError.ReadToEndAsync() | Out-Null
Write-Host "Server started (PID: $($serverProcess.Id))"

# Start client
$clientProcess = New-Object System.Diagnostics.Process
$clientProcess.StartInfo.FileName = "cmd.exe"
$clientProcess.StartInfo.Arguments = "/c npx vite --host --port 3000"
$clientProcess.StartInfo.WorkingDirectory = $clientDir
$clientProcess.StartInfo.UseShellExecute = $false
$clientProcess.StartInfo.RedirectStandardOutput = $true
$clientProcess.StartInfo.RedirectStandardError = $true
$clientProcess.StartInfo.CreateNoWindow = $true
$clientProcess.Start() | Out-Null
$clientProcess.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal
$clientProcess.StandardOutput.ReadToEndAsync() | Out-Null
$clientProcess.StandardError.ReadToEndAsync() | Out-Null
Write-Host "Client started (PID: $($clientProcess.Id))"

Start-Sleep -Seconds 5

# Test
try {
    $health = Invoke-WebRequest -Uri "http://localhost:5000/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "Server: $($health.StatusCode)"
} catch {
    Write-Host "Server health check failed: $_"
}

try {
    $client = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
    Write-Host "Client: $($health.StatusCode)"
} catch {
    Write-Host "Client check: $_"
}

Write-Host "DONE"
Read-Host "Press Enter to exit (services will keep running)"
