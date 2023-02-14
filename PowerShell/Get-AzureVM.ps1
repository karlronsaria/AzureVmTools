
# SCRIPT: Get-AzureVM.ps1
# =======================
# Retrieves information from one or more Azure virtual machines.
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
        Retrieves information from one or more Azure virtual machines.
    .DESCRIPTION
        See Get-AzureVM cmdlet.
    .PARAMETER ServiceName
        Specifies an Azure cloud service name.
    .PARAMETER VMName
        Specifies a virtual machine name.
    .EXAMPLE
        PS C:\> .\Get-AzureVM.ps1 -ServiceName "MySvc1" -Name "MyVM1"
        This command returns an object with information on the "MyVM1" virtual machine running in the "MySvc1" cloud service.
    .EXAMPLE
        PS C:\> .\Get-AzureVM.ps1 -ServiceName "MySvc1"
        This command retrieves a list object with information on all of the virtual machines running in the "MySvc1" cloud service.
    .EXAMPLE
        PS C:\> .\Get-AzureVM.ps1 -ServiceName "MySvc1" | Format-Table –auto "Name",@{Expression={$_.InstanceUpgradeDomain};Label="UpgDom";Align="Right"},"InstanceStatus"
        This command displays a table showing the virtual machines running on the "MySvc1" service, their Upgrade Domain, and the current status of each machine.
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

# Check if the user is connected.
Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

if([String]::IsNullOrWhitespace($ServiceName))
{
    if([String]::IsNullOrWhitespace($VMName))
    {
        $vm = Get-AzureVM
    }
    else
    {
        Throw "A cloud service must be specified when searching for a virtual machine."
    }
}
elseif([String]::IsNullOrWhitespace($VMName))
{
    $vm = Get-AzureVM -ServiceName $ServiceName
}
elseif(($vm = Get-AzureVM -ServiceName $ServiceName -Name $VMName) -eq $null)
{
    Throw "No machine was found in $ServiceName with the name $VMName."
}

return $vm
