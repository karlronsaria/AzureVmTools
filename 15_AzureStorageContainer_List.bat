
:: SCRIPT: AzureStorageContainer_List.bat
:: ======================================
:: Displays all storage containers created in a specified or default
:: storage account.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure
::                 Get-AzureStorageContainer.ps1, Write-Full.ps1

:: FLAGS
:: =====
:: /help         : Help. Displays the script documentation.
:: /current, /c  : Current. Sets the current storage account
::                 to the one specified.


@ECHO OFF

FOR %%A IN (%*) DO (
    IF "%%A"=="/help" GOTO help
    IF "%%A"=="/HELP" GOTO help
)

GOTO script


:help

ECHO Displays all storage containers created in a specified or default storage account.
ECHO.
ECHO AzureStorageContainer_List.bat [storageaccountname] [/C]
ECHO.
ECHO   /C[URRENT]  Sets the current storage account to the one specified.
ECHO.
GOTO :EOF


:script

:: Sets the root directory of the PowerShell scripts.
SET ps=PowerShell\

:: Enables PowerShell scripts to run (if not already enabled).
powershell Set-ExecutionPolicy Unrestricted

:: Decides whether or not to set the current storage account
:: based on user input:

SET setCurrent=$false

FOR %%B IN (%*) DO (
    IF "%%B"=="/current" SET setCurrent=$true
    IF "%%B"=="/CURRENT" SET setCurrent=$true
    IF "%%B"=="/c"       SET setCurrent=$true
    IF "%%B"=="/C"       SET setCurrent=$true
)

:: Decides what the command looks like based on user input:

IF [%1]==[] (
    SET command='%~dp0%ps%Get-AzureStorageContainer.ps1'
    GOTO execute
) ELSE (
    SET command='%~dp0%ps%Get-AzureStorageContainer.ps1' -Storage %1 -SetCurrent:%setCurrent%
)

:execute
:: Runs the command.
powershell -Command "{ & %command% } | & '%~dp0%ps%Write-Full.ps1'"
