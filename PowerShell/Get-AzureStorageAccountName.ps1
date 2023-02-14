
# SCRIPT: Get-AzureStorageAccountName.ps1
# =======================================
# Returns the name of the storage account in use by a virtual machine.
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
        Returns the name of the storage account in use by a virtual machine.
    .DESCRIPTION
        This script is useful for automatically retrieving a storage account name when given the name of a cloud service and a virtual machine.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .EXAMPLE
        PS C:\> .\Get-AzureStorageAccountName.ps1 -ServiceName "MySvc" -VMName "MyVM"
        This example returns the name of the storage account in use by "MyVM".
#>


[CmdletBinding()]
Param
(
    [Parameter( Mandatory                       = $true,
                Position                        = 0,
                ValueFromPipelineByPropertyName = $true )]
    [String]
    $ServiceName,
    
    [Alias("Name")]
    [Parameter( Mandatory                       = $true,
                Position                        = 1,
                ValueFromPipelineByPropertyName = $true )]
    [String]
    $VMName
)

$ErrorActionPreference = "Stop"

# Checks if the user is connected.
Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

Try
{
    return (Get-AzureVM $ServiceName $VMName | Get-AzureOSDisk).MediaLink.Host.Split('.')[0]
}
Catch [System.Exception]
{
    Throw "Your VM could not be found."
}
