
# SCRIPT: Get-AzureVMDisk.ps1
# ===========================
# Retrieves a reference to a disk attached to a virtual machine.
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
        Retrieves a reference to a disk attached to a virtual machine.
    .DESCRIPTION
        See cmdlets:
			Get-AzureDataDisk
			Get-AzureOSDisk
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER VM
        Specifies the virtual machine object from which to get disk objects.
    .PARAMETER CopyOSDisk
        Specifies to retrieve the VM's OS disk.
    .PARAMETER LUN
        Specifies the logical unit number, or set of numbers, at which data disks reside on the VM.
    .EXAMPLE
        PS C:\> Get-AzureVM "MySvc" "MyVM" | .\Get-AzureVMDisk.ps1
        This command returns a list of all disks attached to "MyVM".
    .EXAMPLE
        PS C:\> Get-AzureVM "MySvc" "MyVM" | .\Get-AzureVMDisk.ps1 -CopyOSDisk
        This command returns the OS disk in use by "MyVM".
    .EXAMPLE
        PS C:\> Get-AzureVM "MySvc" "MyVM" | .\Get-AzureVMDisk.ps1 -LUN 0, 1
        This command returns the data disks attached to "MyVM" at LUN's 0 and 1.
    .EXAMPLE
        PS C:\> Get-AzureVM "MySvc" "MyVM" | .\Get-AzureVMDisk.ps1 -CopyOSDisk -LUN 0, 1
        This command returns OS disk in use by "MyVM" and the data disks attached to "MyVM" at LUN's 0 and 1.
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
    
    [Switch]
    $CopyOSDisk,
    
    [Int64[]]
    $LUN
)

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    # Retrieves the virtual machine by parameter if it wasn't passed
    # through the pipeline.
    if($VM -eq $null) { $VM = & "$PSScriptRoot\Get-AzureVM.ps1" $ServiceName $VMName }

    $totalDisks = @()

    if($CopyOSDisk -or $LUN.Length -eq 0)
    {
        # Retrieves the OS disk.
        $osDisk = $vm | Get-AzureOSDisk

        # Adds the OS disk to the list.
        $totalDisks += $osDisk
    }

    if(!$CopyOSDisk -or $LUN.Length -gt 0)
    {
        # Retrieve all data disks specified, or all disks if none specified.
        $dataDisks = $vm | Get-AzureDataDisk | where { @{$true = $LUN -contains $_.LUN; $false = $true}[$LUN.Length -gt 0] }
        
        # Adds each data disk to the list.
        foreach($disk in $dataDisks)
        {
            $totalDisks += $disk
        }
    }

    return $totalDisks
}
Catch [System.Exception]
{
    Throw $_
}
