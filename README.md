# Log4Shell-Cleaner
Log4Shell cleanup instructions when using [Check-Log4j](https://github.com/devotech/Check-log4j) script and [DIVD](https://github.com/dtact/divd-2021-00038--log4j-scanner) script..

![logo](./image/OGDlogo.png)

### Sources:
- [Check-Log4J](https://github.com/devotech/Check-log4j)
- [DIVD-2021-00038](https://github.com/dtact/divd-2021-00038--log4j-scanner)
- [Log4Shell-detector](https://github.com/Neo23x0/log4shell-detector)

# Instructions

### Warning!
This requires (temporarily) stopping services, run this outside of office hours or with the full agreement of the client.

## Prerequisites
* You have already scanned your enivornment using check-log4j
  - Use **[check-ps1](https://github.com/devotech/Check-log4j) script** to find possibly affected files. Instructions can be found in the linked repository.
 * You need to distill the resulting log(s) to their common paths, and preferably UNC paths. This is needed for IOC checks and automating the replacement of .patch files.
 Make a single log file *per server* that needs to be patched
    - see [example](./example) for log output and checklist you need to create
* Create separate logfiles per server you wish to patch. -give this the name of the server. This is used to ingest logfiles and transcribe actions.
  - Ex: SVR-CADTEST.log if the server is called SVR-CADTEST.
* edit the [call-patch.ps1](.\call-patch.ps1) script to include the executable
* Download the latest release of the scanner tool: [releases](https://github.com/dtact/divd-2021-00038--log4j-scanner/releases) and select the relevant build.

## Usage
 *Optional:* save the scanner in an accessible network location to call from UNC path. -  You can either patch from a central server using a UNC path to call the executable, or run the exe locally on the server per file you wish to patch. - this is the described method. If using UNC paths, edit the ps1 file.
* Copy the unClass-jar folder to the server you're patching.
* Place your server logfile in the source folder.
* open an elevated powershell window <br/>
    note: **do this on the machine you're patching!**
* run the call-path powershell and enter the server name to load the found files.
```
call-patch.ps1
```
* Wait until this is finished... 

:bangbang: | The following steps need to be done outside of business hours or in agreement with the client. 
:---: | :---

* Stop services running these JAR files
* Check your common path(s) to run with Replacement script.
   - perferably: (copy from checklist)

```
call-replace.ps1
```
* After this is finished, restart any applications that were stopped for this.
* test, test, test!
 
 #### Questions? 
 Ask in the Issues or DM's

 Internal: Ask the CSIRT team.
 
 <br/>
 
 <br/>

### Patch (single file)
```
\\UNC\path\to\divd-2021-00038--log4j-scanner.exe patch {target-path}
```
