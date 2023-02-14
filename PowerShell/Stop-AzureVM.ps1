
# SCRIPT: Stop-AzureVM.ps1
# ========================
# Stops a running virtual machine.
#
# Type          : Script
# Using         : Windows PowerShell (*.ps1)
#
# Written by    : Andrew D
# Last modified : 01/14/2016

#Requires -Version 3
#Requires -Modules Azure

<#
    .SYNOPSIS
        Stops a running virtual machine.
    .DESCRIPTION
        See Stop-AzureVM cmdlet.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER VM
        Specifies a virtual machine object.
    .PARAMETER StayProvisioned
        Keeps the virtual machine provisioned when it is stopped.
    .PARAMETER Wait
        Waits until the task is complete.
    .EXAMPLE
        PS C:\> Get-AzureVM MySvc MyVM | .\Stop-AzureVM.ps1
        This example shuts down MyVM.
    .EXAMPLE
        PS C:\> Get-AzureVM MySvc MyVM | .\Stop-AzureVM.ps1 -StayProvisioned -Wait
        This example shuts down and deallocates MyVM and waits until the task is complete.
#>


[CmdletBinding()]
Param
(
    [Parameter( ParameterSetName  = "FromVMByName",
                Mandatory         = $true,
                Position          = 0 )]
    [String]
    $ServiceName,
    
    [Parameter( ParameterSetName  = "FromVMByName",
                Mandatory         = $true,
                Position          = 1 )]
    [String]
    $VMName,
    
    [Parameter( ParameterSetName  = "FromVMByObject",
                ValueFromPipeline = $true )]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.IPersistentVM]
    $VM,
    
    [Switch]
    $StayProvisioned,
    
    [Switch]
    $Wait
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    # Retrieves the virtual machine by parameter if it wasn't passed
    # through the pipeline.
    if($VM -eq $null) { $VM = & "$PSScriptRoot\Get-AzureVM.ps1" $ServiceName $VMName }
    
    $wasRunning = $false
    
    # Checks whether the virtual machine needs to be stopped or deprovisioned.
    if(($VM.InstanceStatus -eq "ReadyRole") -and (!$StayProvisioned -or $VM.PowerState -eq "Started"))
    {
        $wasRunning = $true
        
        Write-Output "Shutting down $($VM.Name)..."
        
        # Stops or deprovisions the virtual machine.
        Stop-AzureVM $VM.ServiceName $VM.Name -StayProvisioned:$StayProvisioned | Out-Null
        
        if($Wait)
        {
            # Waits for the machine to shut down.
            do
            {
                Start-Sleep -Seconds 5
                $VM = $VM | Get-AzureVM
            }
            while(($VM.InstanceStatus -eq "ReadyRole") -and (!$StayProvisioned -or $VM.PowerState -eq "Started"))
        }
    }

    return $wasRunning
}
Catch [System.Exception]
{
    Throw $_
}
