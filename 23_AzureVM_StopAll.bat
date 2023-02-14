
:: SCRIPT: AzureVM_StopAll.bat
:: ===========================
:: Shuts down all virtual machines running in Microsoft Azure.
:: 
:: Type          : Script
:: Using         : Windows Batch Command (*.bat)
:: 
:: Written by    : Andrew D
:: Last modified : 01/14/2016
:: 
:: Prerequisites : PowerShell Version 3
::                 PowerShell Module Azure
::                 Query-AzureVM.ps1, Stop-AzureVM.ps1, Write-Full.ps1

:: FLAGS
:: =====
:: /help              : Help. Displays the script documentation.
:: /deallocate, /d    : Deallocate. Deallocates the virtual machines.
::                      (Saves money.)
:: /quiet, /q         : Quiet. Specifies that the script will not generate
::                      console output.
:: /notable, /nt, /s  : Short. Specifies that the script will not list
::                      the VM power states.
:: /wait, /w          : Wait. Waits for each machine to finish before
::                      displaying the results.


@ECHO OFF

FOR %%A IN (%*) DO (
    IF "%%A"=="/help" GOTO help
    IF "%%A"=="/HELP" GOTO help
)

GOTO script


:help

ECHO Shuts down all virtual machines running in Microsoft Azure.
ECHO.
ECHO AzureVM_StopAll.bat [/D] [/Q] [/S] [/W]
ECHO.
ECHO   /D[EALLOCATE]          Deallocates the virtual machines. (Saves money.)
ECHO   /Q[UIET]               Runs the script quietly (without console output).
ECHO   /S[HORT] /NT /NOTABLE  Runs the script without displaying the power states of VM's.
ECHO   /W[AIT]                Waits for each machine to finish before displaying the results.
ECHO.
GOTO :EOF


:script

SET provisioned=$true
SET       quiet=$false
SET       short=$false
SET        wait=$false

FOR %%B IN (%*) DO (

    IF "%%B"=="/deallocate" SET provisioned=$false
    IF "%%B"=="/DEALLOCATE" SET provisioned=$false
    IF "%%B"=="/d"          SET provisioned=$false
    IF "%%B"=="/D"          SET provisioned=$false
    
    IF "%%B"=="/quiet"      SET quiet=$true
    IF "%%B"=="/QUIET"      SET quiet=$true
    IF "%%B"=="/q"          SET quiet=$true
    IF "%%B"=="/Q"          SET quiet=$true
    
    IF "%%B"=="/notable"    SET short=$true
    IF "%%B"=="/NOTABLE"    SET short=$true
    IF "%%B"=="/nt"         SET short=$true
    IF "%%B"=="/NT"         SET short=$true
    
    IF "%%B"=="/short"      SET short=$true
    IF "%%B"=="/SHORT"      SET short=$true
    IF "%%B"=="/s"          SET short=$true
    IF "%%B"=="/S"          SET short=$true
    
    IF "%%B"=="/wait"       SET wait=$true
    IF "%%B"=="/WAIT"       SET wait=$true
    IF "%%B"=="/w"          SET wait=$true
    IF "%%B"=="/W"          SET wait=$true
)

:: Sets the root directory of the PowerShell scripts.
SET ps=PowerShell\

:: Enables PowerShell scripts to run (if not already enabled).
powershell Set-ExecutionPolicy Unrestricted

:: Shuts down every virtual machine that's still running.
powershell -Command "Get-AzureVM | Where { $_.PowerState -notlike 'Stop*' } | " ^
                       " ForEach { if(-not %quiet%) { Write-Host ('Shutting down '+$_.Name+'...') }; " ^
                                 " $_ | & '%~dp0%ps%Stop-AzureVM.ps1' -StayProvisioned:%provisioned% -Force -Wait:%wait% | Out-Null }"

IF "%quiet%"=="$false" (
    IF "%short%"=="$false" (
        :: Displays all virtual machine power states.
        powershell -Command "{ %~dp0%ps%Query-AzureVM.ps1 Name, ServiceName, PowerState, Status } | %~dp0%ps%Write-Full.ps1"
    )
)
