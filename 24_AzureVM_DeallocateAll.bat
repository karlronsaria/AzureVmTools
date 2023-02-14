
:: SCRIPT: AzureVM_DeallocateAll.bat
:: =================================
:: Deallocates all virtual machines in Microsoft Azure.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure
::                 AzureVM_StopAll.bat

:: FLAGS
:: =====
:: See AzureVM_StopAll.bat script.


@ECHO OFF


:script

:: Deallocates every virtual machine that's still running.
%~dp0.\AzureVM_StopAll.bat /D %*

FOR %%A IN (%*) DO (
    IF "%%A"=="/help" GOTO help
    IF "%%A"=="/HELP" GOTO help
)

GOTO :EOF


:help

ECHO DEALLOCATE has been set.
ECHO.
