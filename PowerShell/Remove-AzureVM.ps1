
# SCRIPT: Remove-AzureVM.ps1
# ==========================
# Removes a Windows Azure virtual machine.
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
        Removes a Windows Azure virtual machine.
    .DESCRIPTION
        See Remove-AzureVM cmdlet.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .PARAMETER VM
        Specifies a virtual machine object.
    .PARAMETER GetDisks
        Specifies that you want links to all the disks attached to the virtual machine.
    .PARAMETER DeleteDisks
        Specifies that you want to delete all disks attached to the virtual machine.
    .PARAMETER GetVHDs
        Specifies that you want links to all the .vhd files of the disks attached to the virtual machine.
    .PARAMETER DeleteVHDs
        Specifies that you want to delete all .vhd files of the disks attached to the virtual machine.
    .EXAMPLE
        PS C:\> Get-AzureVM "MySvc" "MyVM" | .\Remove-AzureVM.ps1
        This example removes the "MyVM" virtual machine running in the "MySvc" service.
    .EXAMPLE
        PS C:\> $vhds = Get-AzureVM "MySvc" "MyVM" | .\Remove-AzureVM.ps1 -DeleteDisks -GetVHDs
        This example removes "MyVM" running in "MySvc", deletes all disks attached to the machine, and stores in the variable a list of links to the .vhd files associated with those disks.
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
    $GetDisks,
    
    [Switch]
    $DeleteDisks,
    
    [Switch]
    $GetVHDs,
    
    [Switch]
    $DeleteVHDs
)

$ErrorActionPreference = "Stop"

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    # Retrieves the virtual machine by parameter if it wasn't passed
    # through the pipeline.
    if($VM -eq $null) { $VM = & "$PSScriptRoot\Get-AzureVM.ps1" $ServiceName $VMName }

    if($GetDisks -and $DeleteDisks) { Throw "'GetDisks' and 'DeleteDisks' cannot both be selected." }

    if($GetVHDs  -and $DeleteVHDs)  { Throw "'GetVHDs' and 'DeleteVHDs' cannot both be selected." }

    if($GetDisks -or $GetVHDs -or $DeleteDisks -or $DeleteVHDs)
    {
        # Starts a list of the disks attached to the virtual machine.
        $disks = @()
        
        # Adds the virtual machine's OD disk to the list.
        $disks += ($VM | Get-AzureOSDisk)
        
        # Adds all of the virtual machine's data disks to the list.
        foreach($disk in ($VM | Get-AzureDataDisk))
        {
            $disks += $disk
        }
    }

    # Removes the virtual machine.
    Remove-AzureVM -ServiceName $VM.ServiceName -Name $VM.Name

    if($disks.Count -gt 0)
    {
        # Returns references to all disks that were attached.
        if($GetDisks) { return $disks }
        
        # Returns URI's to all .vhd's that were attached.
        if($GetVHDs)
        {
            $vhds = $disks | Select -Property MediaLink
        }
        
        # Deletes the attached disks.
        if($DeleteDisks)
        {
            foreach($disk in $disks)
            {
                # Waits for each disk to completely detach from the virtual machine.
                while((Get-AzureDisk -DiskName $disk.DiskName).AttachedTo)
                {
                    $disk | Remove-AzureDisk -DeleteVHD:$DeleteVHDs
                }
            }
        }
        
        # Deletes the attached .vhd's.
        if($GetVHDs) { return $vhds }
    }
}
Catch [System.Exception]
{
    Throw $_
}
