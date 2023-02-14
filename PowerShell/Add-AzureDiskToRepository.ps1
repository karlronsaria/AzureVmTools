
# SCRIPT: Add-AzureDiskToRepository.ps1
# =====================================
# Adds a new disk to the Azure disk repository.
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
        Adds a new disk to the Azure disk repository.
    .DESCRIPTION
        See Add-AzureDisk cmdlet.
    .PARAMETER DiskName
        Specifies the name of the disk.
    .PARAMETER MediaLocation
        Specifies the physical location of the disk in Azure storage. This link refers to a blob page in the current subscription and storage account.
    .PARAMETER Label
        Specifies a disk label.
    .PARAMETER OS
        If specified, the disk is bootable. This parameter accepts either "Windows" or "Linux" values.
    .EXAMPLE
        PS C:\> .\Add-AzureDiskToRepository.ps1 -DiskName "MyWinDisk" -MediaLocation "http://yourstorageaccount.blob.core.azure.com/vhds/winserver-system.vhd" -Label "BootDisk" -OS "Windows"
        This example adds a new, bootable Windows disk.
    .EXAMPLE
        PS C:\> .\Add-AzureDiskToRepository.ps1 -DiskName "MyDataDisk" -MediaLocation "http://yourstorageaccount.blob.core.azure.com/vhds/winserver-data.vhd" -Label "DataDisk"
        This example adds a new data disk.
    .EXAMPLE
        PS C:\> .\Add-AzureDiskToRepository.ps1 -DiskName "MyLinuxDisk" -MediaLocation "http://yourstorageaccount.blob.core.azure.com/vhds/linuxsys.vhd" -OS "Linux"
        This example adds a new Linux boot disk. The disk name and label are the same.
#>


[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true, Position=1)]
    [String]
    $DiskName,

    [String]
    $MediaLocation,
    
    [String]
    $Label,
    
    [String]
    $OS
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    $MediaLocation += @{$true = $DiskName; $false = "\" + $DiskName}[$MediaLocation.EndsWith('\')]

    if([String]::IsNullOrWhitespace($OS))
    {
        Add-AzureDisk -DiskName $DiskName -MediaLocation $MediaLocation -Label $Label
    }
    else
    {
        Add-AzureDisk -DiskName $DiskName -MediaLocation $MediaLocation -Label $Label -OS $OS
    }
}
Catch [System.Exception]
{
    Throw $_
}
