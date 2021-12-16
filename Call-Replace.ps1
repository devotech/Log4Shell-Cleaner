$Server = Read-host "Enter server name for logfile name"
$folder = Read-Host "Paste Common path to run replacement against"
$fileExtension = 'jar'
$patchFileExtension = 'jar.patch'
$backupFileExtension = 'jar.bak'
$fileStartsWith = 'log4j-core'

Start-Transcript -Path ".\Logs\$Server-replace.log"
if(-not(Get-Module ReplaceJarFileWithPatchFile)){Import-Module .\unClass-jar\ReplaceJarFileWithPatchFile.psm}
ReplaceJarFileWithPatchFile -Folder $folder -FileExtension $fileExtension -PatchFileExtension $patchFileExtension -BackupFileExtension $backupFileExtension -FileStartsWith $fileStartsWith -Verbose -Recurse
Stop-Transcript

Remove-Module ReplaceJarFileWithPatchFile
