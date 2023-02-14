
# SCRIPT: Get-AzureDiskBlob.ps1
# =============================
# Returns the storage blob of a virtual hard disk object.
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
        Returns the storage blob of a virtual hard disk object.
    .DESCRIPTION
        See Get-AzureStorageBlob cmdlet.
    .PARAMETER OSDisk
        Specifies an operating system virtual hard disk object.
    .PARAMETER DataDisk
        Specifies a virtual data disk object.
    .EXAMPLE
        PS C:\> Get-AzureVM MySvc MyVM | Get-AzureOSDisk | .\Get-AzureDiskBlob.ps1
        This example returns a reference to the storage blob in use by MyVM's OS disk.
    .EXAMPLE
        PS C:\> Get-AzureVM MySvc MyVM | Get-AzureDataDisk -LUN 0 | .\Get-AzureDiskBlob.ps1
        This example returns a reference to the storage blob in use by MyVM's data disk connected at LUN 0.
#>


[CmdletBinding()]
Param
(
    [Parameter(ValueFromPipeline=$true, ParameterSetName="ByOSDisk")]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.OSVirtualHardDisk]
    $OSDisk,
    
    [Parameter(ValueFromPipeline=$true, ParameterSetName="ByDataDisk")]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.DataVirtualHardDisk]
    $DataDisk
)

$ErrorActionPreference = "Stop"

Try
{
    # Check if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    switch($PSCmdlet.ParameterSetName)
    {
        "ByOSDisk"
        {
            $disk = $OSDisk
        }
        "ByDataDisk"
        {
            $disk = $DataDisk
        }
    }

    $path = $disk.MediaLink.Segments

    return Get-AzureStorageBlob -Blob $path[-1] -Container ($path[-2].TrimEnd("/"))
}
Catch [System.Exception]
{
    Throw $_
}
