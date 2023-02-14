
# SCRIPT: Remove-AzureDataDisk.ps1
# ================================
# Removes a data disk from a virtual machine object.
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
        Removes a data disk from a virtual machine object.
    .DESCRIPTION
        See Remove-AzureDataDisk cmdlet.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER VM
        Specifies the virtual machine object to which the data disk is mounted.
    .PARAMETER LUN
        Specifies the slot where the data disk to be detached is currently mounted.
    .PARAMETER DeleteVHD
        Indicates that this cmdlet removes the data disk and the underlying disk blob.
    .EXAMPLE
        PS C:\> Get-AzureVM "MySvc" -Name "MyVM" | .\Remove-AzureDataDisk.ps1 -LUN 2
        This example detaches the data disk on LUN 2 from "MyVM".
#>


[CmdletBinding()]
Param
(
    [Parameter( ParameterSetName  = "ByVMName",
                Mandatory         = $true,
                Position          = 0 )]
    [String]
    $ServiceName,
    
    [Parameter( ParameterSetName  = "ByVMName",
                Mandatory         = $true,
                Position          = 1 )]
    [String]
    $VMName,
    
    [Parameter( ParameterSetName  = "ByVMObject",
                ValueFromPipeline = $true )]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.IPersistentVM]
    $VM,

    [Parameter( Mandatory         = $true )]
    [Int32]
    $LUN,
    
    [Switch] $DeleteVHD
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    # Retrieves the virtual machine by parameter if it wasn't passed
    # through the pipeline.
    if($VM -eq $null) { $VM = & "$PSScriptRoot\Get-AzureVM.ps1" $ServiceName $VMName }

    Remove-AzureDataDisk -LUN $LUN -DeleteVHD:$DeleteVHD -VM $VM | Update-AzureVM
}
Catch [System.Exception]
{
    Throw $_
}
