$Server = Read-host "Enter server name for logfile name"
$folder = Read-Host "Paste Common path to run replacement against"
$fileExtension = 'jar'
$patchFileExtension = 'jar.patch'
$backupFileExtension = 'jar.bak'
$fileStartsWith = 'log4j-core'

Start-Transcript -Path ".\Logs\$Server-replace.log"
Import-Module .\unClass-jar\ReplaceJarFileWithPatchFile.ps1
ReplaceJarFileWithPatchFile -Folder $folder -FileExtension $fileExtension -PatchFileExtension $patchFileExtension -BackupFileExtension $backupFileExtension -FileStartsWith $fileStartsWith -Verbose -Recurse
Stop-Transcript
