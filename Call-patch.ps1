$server = Read-Host "Enter current server name"
$files = @()
$files = (Get-Content -Path ".\source\$server.log")

if!(Test-path Logs){mkdir Logs}

Start-Transcript -Path ".\Logs\$server-patch.log"

foreach ($file in $files){
    .\unClass-jar\DIVD-2021-00038--log4j-scanner.exe patch $file
}

Stop-Transcript

