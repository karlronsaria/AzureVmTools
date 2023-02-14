
# SCRIPT: Query-AzureVM.ps1
# =========================
# Query's Azure for a list of properties applying to all virtual machines in the
# current subscription.
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
        Query's Azure for a list of properties applying to all virtual machines in the current subscription.
    .DESCRIPTION
        See cmdlets:
			Get-AzureVM
			Get-Member
			Select-Object
    .PARAMETER Property
        Specifies the properties to select. Wildcards are permitted.
    .PARAMETER ExcludeProperty
        Removes the specified properties from the selection. Wildcards are permitted. This parameter is effective only when the command also includes the Property parameter.
    .PARAMETER ExpandProperty
        Specifies a property to select, and indicates that an attempt should be made to expand that property. Wildcards are permitted in the property name.
    .PARAMETER ShowProperties
        Specifies that you want to see a list of property names to query for.
    .EXAMPLE
        PS C:\> .\Query-AzureVM.ps1 -Property Name, PowerState
        This example provides a list of virtual machines of the current subscription by name and whether they are powered on or not.
    .EXAMPLE
        PS C:\> .\Query-AzureVM.ps1 -Property Instance* -ExcludeProperty *Status
        This example shows all Azure virtual machine data with property names starting with "Instance" but not ending with "Status".
    .EXAMPLE
        PS C:\> .Query-AzureVM.ps1 -ExpandProperty VM
        This example expands the "VM" property for every virtual machine of the current subscription.
    .EXAMPLE
        PS C:\> .\Query-AzureVM.ps1 -ShowProperties
        This example shows all of the properties of the Azure virtual machine type.
    .EXAMPLE
        PS C:\> .\Query-AzureVM.ps1 Name, ServiceName, InstanceSize, PowerState | Format-List
        This example shows the name, service name, instance size, and power state of every Azure virtual machine of the current subscription in list format.
#>


[CmdletBinding()]
Param
(
    [String[]]
    $Property,
    
    [String[]]
    $ExcludeProperty,
    
    [String]
    $ExpandProperty,
    
    [Switch]
    $ShowProperties
)

$ErrorActionPreference = "Stop"

# Checks if the user is connected.
Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

Try
{
    if($GetMembers) { return (Get-AzureVM)[0] | Get-Member | where { $_.MemberType -eq "Property" } | Select Name }
}
Catch [System.Exception]
{
    Throw "No virtual machines have been created on your account."
}

return Get-AzureVM | Select-Object -Property $Property -ExcludeProperty $ExcludeProperty -ExpandProperty $ExpandProperty
