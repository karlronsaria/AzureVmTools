
# SCRIPT: Save-AzureVHD.ps1
# =============================
# Downloads virtual hard disk (.vhd) a from a blob or virtual machine to a file.
#
# Type          : Script
# Using         : Windows PowerShell (*.ps1)
#
# Written by    : Garreth J, Andrew D
# Last modified : 01/14/2016

#Requires -Version 3
#Requires -Modules Azure

<#
    .SYNOPSIS
        Downloads virtual hard disk (.vhd) a from a blob or virtual machine to a file.
    .DESCRIPTION
        See Save-AzureVHD cmdlet.
		
			"This script can be executed to download a virtual disk (VHD) from Microsoft
			Azure. The script accepts storage account information from the user, then
			connects to Microsoft Azure, finds the target hard drive, and downloads
			the drive to the local machine. The script uses four threads to download
			the file.
			
			NOTE: Download time should be doubled, as the download is checked for an
			almost equal amount of time."
			
			Gareth Jensen (9/8/2014)
		
    .PARAMETER Source
        Specifies the URI to the blob in Azure.
    .PARAMETER StorageKey
        Specifies the storage key of the blob storage account. If it is not provided, the cmdlet tries to determine the storage key of the account in the Source URI from Azure.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER VM
        Specifies the virtual machine object from which to save the virtual OS disk.
    .PARAMETER LocalFilePath
        Specifies the path to save the VHD.
    .PARAMETER Overwrite
        Specifies that you want to delete an existing file, if one exists as specified by local file path.
    .EXAMPLE
        PS C:\> .\Save-AzureVHD.ps1 -Source http://mytestaccount.blob.core.windows.net/vhdstore/win7baseimage.vhd
        This example downloads the specified blob to the default local file path as a .vhd of the name "win7baseimage.vhd".
    .EXAMPLE
        PS C:\> .\Save-AzureVHD.ps1 -Source http://mytestaccount.blob.core.windows.net/vhdstore/win7baseimage.vhd -LocalFilePath C:\vhd\MyWin7Image.vhd
        This example downloads the specified blob to the specified local file path.
    .EXAMPLE
        PS C:\> .\Save-AzureVHD.ps1 -Source http://mytestaccount.blob.core.windows.net/vhdstore/win7baseimage.vhd -LocalFilePath C:\vhd\MyWin7Image.vhd -Overwrite
        This example downloads the specified blob to the specified local file path and overwrites the existing file, if present.
    .EXAMPLE
        PS C:\> .\Save-AzureVHD.ps1 -ServiceName "MySvc" -VMName "MyVM"
        This example downloads the virtual OS disk from "MyVM" to the default local file path, keeping its original name.
#>


# Default parameters:
[CmdletBinding(DefaultParameterSetName="FromURI")]
Param
(
    [Parameter( ParameterSetName  = "FromURI",
                Mandatory         = $true)]
    [String]
    $Source,
    
    [Parameter( ParameterSetName  = "FromURI")]
    [String]
    $StorageKey,
    
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
    
    [String]
    $LocalFilePath = "$PSScriptRoot\..\downloads\",
    
    [Switch]
    $Overwrite
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    if($PSCmdlet.ParameterSetName -eq "FromURI")
    {
        # Gets the name of the .vhd file from the online source.
        $vhdName = $Source.Split('/')[-1]
        
        # Throws an exception if the online blob is not a .vhd file.
        if(!$vhdName.EndsWith(".vhd"))
        {
            Throw "The given blob is not a .vhd file."
        }
        
        # Gets the storage account name from the online source.
        $storageAccountName = $Source.Split("/.")[2]
        
        # Retrieves the primary storage key.
        if([String]::IsNullOrWhitespace($StorageKey))
        {
            $StorageKey = Get-AzureStorageKey $storageAccountName | %{$_.Primary}
        }
    }
    else
    {
        if($PSCmdlet.ParameterSetName -eq "FromVMByName"
        {
            # Retrieves the virtual machine by parameter if it wasn't passed
            # through the pipeline.
            $VM = & "$PSScriptRoot\Get-AzureVM.ps1" $ServiceName $VMName
        }
    
        # Retrieves the storage account name.
        $storageAccountName = $VM | & "$PSScriptRoot\Get-AzureStorageAccountName.ps1"
        
        # Retrieves the primary storage key.
        $StorageKey = Get-AzureStorageKey $storageAccountName | %{$_.Primary}

        # Gets the OS virtual disk.
        $osDisk  = $VM | Get-AzureOSDisk
    
        # Retrieves information from the OS virtual disk.
        $Source  = $osDisk.MediaLink
        $vhdName = $osDisk.DiskName
    }
        
    # Adds the name of the .vhd file to the local file path if it was
    # passed in without it.
    if(!$LocalFilePath.EndsWith(".vhd"))
    {
        if(!$LocalFilePath.EndsWith('\')) { $LocalFilePath += "\" }
        
        $LocalFilePath += $vhdName
    }

    Write-Output "Now downloading the virtual disk..."

    # Saves the virtual disk to the local directory:
    Save-AzureVHD -Source $Source -LocalFilePath $LocalFilePath -NumberOfThreads 4 -StorageKey $StorageKey -Overwrite:$Overwrite
}
Catch [System.Exception]
{
    Throw $_
}
