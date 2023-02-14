
# SCRIPT: Add-AzureDataDisk.ps1
# =============================
# Adds a new data disk to a virtual machine object.
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
        Adds a new data disk to a virtual machine object.
    .DESCRIPTION
        See Add-AzureDataDisk cmdlet.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER VM
        Specifies the virtual machine object to which the data disk will attach.
    .PARAMETER CreateNew
        Specifies that you want to add a new data disk to a virtual machine object.
    .PARAMETER DiskSizeInGB
        Specifies the logical disk size in gigabytes.
    .PARAMETER Import
        Specifies that you want to import an existing data disk from the disk library.
    .PARAMETER DiskName
        Specifies the name of the data disk in the disk repository.
    .PARAMETER ImportFrom
        Specifies that you want to import an existing data disk from a blob in a storage account.
    .PARAMETER MediaLocation
        Specifies the location of the blob in an Azure storage account where the data disk will be stored. If no location is specified, the data disk will be stored in the VHDs container within the default storage account for the current subscription. If the container doesn't exist, the container is created.
    .PARAMETER DiskLabel
        Specifies the disk label when creating a new data disk.
    .PARAMETER LUN
        Specifies the logical unit number (LUN) location for the data drive in the virtual machine. Valid LUN values are 0-15 and each data disk must have a unique LUN.
    .EXAMPLE
        PS C:\> Get-AzureVM "myservice" -Name "MyVM" | .\Add-AzureDataDisk.ps1 -Import -DiskName "MyExistingDisk" -LUN 0
        This example gets a virtual machine object for the virtual machine named "MyVM" in the "myservice" cloud service, updates the virtual machine object by attaching an existing data disk from the repository using the disk name, and then updates the Azure virtual machine.
    .EXAMPLE
        PS C:\> Get-AzureVM "myservice" -Name "MyVM" | .\Add-AzureDataDisk.ps1 -CreateNew -DiskSizeInGB 128 -DiskLabel "main"
        This example updates the virtual machine by creating the new blank data disk "MyNewDisk.vhd" in the vhds container within the default storage account of the current subscription.
    .EXAMPLE
        PS C:\> Get-AzureVM "myservice" -Name "MyVM" | Add-AzureDataDisk -ImportFrom -MediaLocation "https://mystorage.blob.core.windows.net/mycontainer/MyExistingDisk.vhd"
        This example updates a virtual machine by attaching an existing data disk from a storage location.
#>


[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true, Position=0)]
    [String]
    $ServiceName,
    
    [Parameter(Mandatory=$true, Position=1)]
    [String]
    $VMName,
    
    [Parameter(ValueFromPipeline=$true)]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.IPersistentVM]
    $VM,
    
    [Switch][Parameter(ParameterSetName='CreateNew')]  $CreateNew,
    [Int32] [Parameter(ParameterSetName='CreateNew')]  $DiskSizeInGB = 50,
    
    [Switch][Parameter(ParameterSetName='Import')]     $Import,
    [String][Parameter(ParameterSetName='Import')]     $DiskName,
    
    [Switch][Parameter(ParameterSetName='ImportFrom')] $ImportFrom,
    [String][Parameter(ParameterSetName='ImportFrom')] $MediaLocation,
    
    [String] $DiskLabel,
        
    [Int32]  $LUN = 0
)

$ErrorActionPreference = "Stop"

Try
{
    if($VM -eq $null) { $VM = & "$PSScriptRoot\Get-AzureVM.ps1" $ServiceName $VMName }

    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    if($CreateNew)
    {
        # Creates a new disk and attaches it.
        $VM | Add-AzureDataDisk -CreateNew -DiskSizeInGB $DiskSizeInGB -DiskLabel $DiskLabel -LUN $LUN `
            | Update-AzureVM -ServiceName $VM.ServiceName
    }
    elseif($Import)
    {
        # Imports a disk from the disk library and attaches it.
        $VM | Add-AzureDataDisk -Import -DiskName $DiskName -LUN $LUN `
            | Update-AzureVM -ServiceName $VM.ServiceName
    }
    elseif($ImportFrom)
    {
        # Imports an existing data disk from a blob in a storage account and attaches it.
        $VM | Add-AzureDataDisk -ImportFrom -MediaLocation $MediaLocation -DiskLabel $DiskLabel -LUN $LUN `
            | Update-AzureVM -ServiceName $VM.ServiceName
    }
}
Catch [System.Exception]
{
    Throw $_
}
