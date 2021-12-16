# Renames each patch file in folder to file. Create a backup file of file. 
# If backup file already exists, delete it first unless SkipPatchFileIfPreviousBackupFileExists
#
# Changes from first version to V2:
# - Default behaviour is changed to NOT remove the backup file if it exists. Instead it skips the patch file.
# This will prevent the original backed-up file from being lost forever. 
# - Remove leading dots from file extension parameters (if any)
Function ReplaceJarFileWithPatchFile
{
    Param
    (
        $Folder,              # Ex. \\server\folder\subfolder, or c:\folder\subfolder
        $FileExtension,       # Ex. jar (no leading dot, so not .jar)
        $PatchFileExtension,  # Ex. jar.patch (no leading dot)
        $BackupFileExtension, # Ex. jar.bak (no leading dot)        
        $FileStartsWith,      # Ex. log4j- (no wildcards, the function adds wildcards)
        [switch]$SkipPatchFileIfPreviousBackupFileExists, # If this is set, do not delete a previously made backup file and skip the rename action for the current patch file V2: this is the default action now
        [siwtch]$ReplacePreviousBackupFile, # Override default behaviour
        [switch]$Verbose,     # Show verbose logging
        [switch]$Recurse,     # Also search all subfolders of folder
        [switch]$Debug        # Pretend to rename files, but don't rename of delete anything
    )

    if ($Verbose)
    {
        # Enable verbose logging
        $VerbosePreference = "Continue"
    }

    if ($Recurse)
    {
        $patchFilesFound = Get-ChildItem -Path $Folder -Recurse | Where { $_.Name -like "$FileStartsWith"+'*.'+"$PatchFileExtension" }
        $nrPatchFiles = $patchFilesFound.Count
        Write-Verbose "Number of patch files found in folder and subfolders: $nrPatchFiles"
    }
    else
    {
        $patchFilesFound = Get-ChildItem -Path $Folder | Where { $_.Name -like "$FileStartsWith"+'*.'+"$PatchFileExtension" }
        $nrPatchFiles = $patchFilesFound.Count
        Write-Verbose "Number of patch files found in folder: $nrPatchFiles"
    }

    # Remove leading dot from extension, if any
    $FileExtension = $FileExtension.TrimStart('.')
    $PatchFileExtension = $PatchFileExtension.TrimStart('.')
    $BackupFileExtension = $BackupFileExtension.TrimStart('.')

    # Rename file to backupfile, rename patch file to file
    foreach ($patchFile in $patchFilesFound)
    {
        # Directory name must be retrieved from patch file name, else recursive operation will critically fail and destroy your files
        $currentPatchFileDirectory = $patchFile.DirectoryName
        Write-Verbose "Current patch file is located in directory: $currentPatchFileDirectory"

        ($currentPatchFileName, $currentPatchFileExtension) = ($patchFile.Name).Split('.', 2) # There could be multiple patch files with different names for different jar files
        Write-Verbose "Current patch file name: $patchFile"
        
        # Find the corresponding file to this patch file
        $matchingFile = Get-ChildItem -Path $currentPatchFileDirectory | Where { $_.Name -eq "$currentPatchFileName"+'.'+"$FileExtension" }
        Write-Verbose "Looking for $matchingFile"
        if ($matchingFile)
        {
            Write-Verbose "Matching file found: $matchingFile"

            # Find the corresponding backup file to this file, if it exists
            $matchingBackupFile = Get-ChildItem -Path $currentPatchFileDirectory | Where { $_.Name -eq "$currentPatchFileName"+'.'+"$BackupFileExtension" }
            
            # Delete the backup file (or not) if it exists
            if ($matchingBackupFile)
            {
                if ($ReplacePreviousBackupFile)
                {
                    if (!$Debug)
                    {
                        # Delete backup file
                        Remove-Item $matchingBackupFile.FullName
                        Write-Verbose "Deleted previous backup file"
                    }
                    else
                    {
                        Write-Output "Debug: Previous backup file would have been deleted"
                    }
                }
                else
                {
                    Write-Verbose "Backup file of matching file found: $matchingBackupFile"
                    Write-Output "Backup file $matchingBackupFile already exists, skipping this patch file (override possible with -ReplacePreviousBackupFile)"
                    Continue # Go to next loop iteration, because this patch file is skipped
                }
            }
            else
            {
                Write-Verbose "Backup file of matching file $matchingFile does not exist yet"
            }

            # Store the original file name for later
            $originalFileNameFullPath = $matchingFile.FullName
            $originalFileName = $matchingFile.Name
            
            # Create file name for backup file
            $newBackupFileName = ($originalFileName.Split('.', 2))[0] + '.' + "$BackupFileExtension"

            # Store patch file name for later
            $patchFileNameFullPath = $patchFile.FullName
            $patchFileName = $patchFile.Name

            if (!$Debug)
            {                        
                # Rename file to backup file
                Rename-Item -Path $originalFileNameFullPath -NewName $newBackupFileName
                Write-Output "Renamed $originalFileNameFullPath to $newBackupFileName"

                # Rename patch file to file
                Rename-Item -Path $patchFileNameFullPath -NewName $originalFileName
                Write-Output "Renamed $patchFileNameFullPath to $originalFileName"
            }
            else
            {
                Write-Output "Debug: Would have renamed $originalFileNameFullPath to $newBackupFileName"
                Write-Output "Debug: Would have renamed $patchFileNameFullPath to $originalFileName"
            }
        }
        else
        {
            Write-Output "No matching file found for patch file: $patchFile, skipping this patch file"
        }
    }
}

<#
Example:

$folder = '.\log4jtest\'
$fileExtension = 'jar'
$patchFileExtension = 'jar.patch'
$backupFileExtension = 'jar.bak'
$fileStartsWith = 'log4j-core'
ReplaceJarFileWithPatchFile -Folder $folder -FileExtension $fileExtension -PatchFileExtension $patchFileExtension -BackupFileExtension $backupFileExtension -FileStartsWith $fileStartsWith -Verbose -Recurse -Debug

Example output:
VERBOSE: Number of patch files found in folder and subfolders: 2
VERBOSE: Current patch file is located in directory: C:\log4jtest
VERBOSE: Current patch file name: log4j-core.jar.patch
VERBOSE: Looking for log4j-core.jar
VERBOSE: Matching file found: log4j-core.jar
VERBOSE: Backup file of matching file log4j-core.jar does not exist yet
Debug: Would have renamed C:\log4jtest\log4j-core.jar to log4j-core.jar.bak
Debug: Would have renamed C:\log4jtest\log4j-core.jar.patch to log4j-core.jar
VERBOSE: Current patch file is located in directory: C:\log4jtest\recursion test\somefolder
VERBOSE: Current patch file name: log4j-core.jar.patch
VERBOSE: Looking for log4j-core.jar
VERBOSE: Matching file found: log4j-core.jar
VERBOSE: Backup file of matching file log4j-core.jar does not exist yet
Debug: Would have renamed C:\log4jtest\recursion test\somefolder\log4j-core.jar to log4j-core.jar.bak
Debug: Would have renamed C:\log4jtest\recursion test\somefolder\log4j-core.jar.patch to log4j-core.jar

Example non debug output:
VERBOSE: Number of patch files found in folder and subfolders: 2
VERBOSE: Current patch file is located in directory: C:\log4jtest
VERBOSE: Current patch file name: log4j-core.jar.patch
VERBOSE: Looking for log4j-core.jar
VERBOSE: Matching file found: log4j-core.jar
VERBOSE: Backup file of matching file log4j-core.jar does not exist yet
Renamed C:\log4jtest\log4j-core.jar to log4j-core.jar.bak
Renamed C:\log4jtest\log4j-core.jar.patch to log4j-core.jar
VERBOSE: Current patch file is located in directory: C:\log4jtest\recursion test\somefolder
VERBOSE: Current patch file name: log4j-core.jar.patch
VERBOSE: Looking for log4j-core.jar
VERBOSE: Matching file found: log4j-core.jar
VERBOSE: Backup file of matching file log4j-core.jar does not exist yet
Renamed C:\log4jtest\recursion test\somefolder\log4j-core.jar to log4j-core.jar.bak
Renamed C:\log4jtest\recursion test\somefolder\log4j-core.jar.patch to log4j-core.jar
#>

