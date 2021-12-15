$Server = Read-host "Enter server name for logfile name"
$folder = Read-Host "Paste Common path to run replacement against"
$fileExtension = 'jar'
$patchFileExtension = 'jar.patch'
$backupFileExtension = 'jar.bak'
$fileStartsWith = 'log4j-core'

Start-Transcript -Path ".\Logs\$Server-replace.log"
.\unClass-jar\ReplaceJarFileWithPatchFile.ps1 -Folder $folder -FileExtension $fileExtension -PatchFileExtension $patchFileExtension -BackupFileExtension $backupFileExtension -FileStartsWith $fileStartsWith -Verbose -Recurse -Debug
Stop-Transcript