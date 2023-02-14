
:: SCRIPT: AzureVM_Create.bat
:: ==========================
:: Creates a new virtual machine in Microsoft Azure.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure
::                 Get-AzureVMImageName.ps1, Get-Hashtable.ps1, New-AzureVM.ps1

:: FLAGS
:: =====
:: /help    : Help. Displays the script documentation.
:: /config  : Configuration. Specifies to get parameters from a text file.


@ECHO OFF

FOR %%A IN (%*) DO (
    IF "%%A"=="/help" GOTO help
    IF "%%A"=="/HELP" GOTO help
)

GOTO script


:help

ECHO Creates a new virtual machine in Microsoft Azure.
ECHO.
ECHO AzureVM_Create.bat [/C [drive:][path]filename[ ...]]
ECHO.
ECHO   /C[ONFIG]  Specifies to get parameters from a text file.
ECHO.
GOTO :EOF


:script

:: Sets the root directory of the PowerShell scripts.
SET ps=PowerShell\

:: Enables PowerShell scripts to run (if not already enabled).
powershell Set-ExecutionPolicy Unrestricted


IF "%1"=="/config" GOTO config
IF "%1"=="/CONFIG" GOTO config
IF "%1"=="/c"      GOTO config
IF "%1"=="/C"      GOTO config
GOTO default


:config
:: Extracts the command parameters from a text file provided by the user.
powershell -Command "$param = & '%~dp0%ps%Get-Hashtable.ps1' %2; & '%~dp0%ps%New-AzureVM.ps1' @param"
GOTO :EOF


:default

:: DEFAULTS
:: ========
:: SET        imageFamily=Windows Server 2012 R2 Datacenter

:: Use this block if you know the image you want to use by family name.
SET        imageFamily=Windows 7
SET          imageName=(^& '%~dp0%ps%\Get-AzureVMImageName.ps1' -ImageFamily '%imageFamily%' -First 1)

:: Use this block if you know the name of the image you want to use.
:: SET          imageName=

SET storageAccountName=newstorage
SET        serviceName=NewService
SET             vmName=NewVM
SET       instanceSize=Medium
SET      adminUserName=wwuser
SET           password=Wonderware777

:: Runs the command with default arguments.
powershell -Command "& { & '%~dp0%ps%\New-AzureVM.ps1' " ^
                                " -ImageName           %imageName% " ^
                                " -StorageAccountName  %storageAccountName% " ^
                                " -ServiceName         %serviceName% " ^
                                " -VMName              %vmName% " ^
                                " -InstanceSize        %instanceSize% " ^
                                " -AdminUsername       %adminUserName% " ^
                                " -Password            %password% }"
                                
