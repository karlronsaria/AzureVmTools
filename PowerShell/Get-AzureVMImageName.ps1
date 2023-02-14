
# SCRIPT: Get-AzureVMImageName.ps1
# ================================
# Returns the name or list of names for operating system objects associated with
# an image family or label.
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
        Returns the name or list of names for operating system objects associated with an image family or label.
    .DESCRIPTION
        See Get-AzureVMImage cmdlet.
    .PARAMETER ImageFamily
        Specifies an image family that an image object belongs to.
    .PARAMETER Label
        Specifies a label applied to an image object.
    .PARAMETER First
        Specifies how many results to select from top of the output.
    .EXAMPLE
        PS C:\> .\Get-AzureVMImage.ps1 -First 10
        This example returns the first 10 names of images in order by published date.
    .EXAMPLE
        PS C:\> .\Get-AzureVMImage.ps1 -ImageFamily "Windows Server 2012" -First 10
        This example returns the first 10 names of images belonging to some family with "Windows Server 2012" in the name.
    .EXAMPLE
        PS C:\> .\Get-AzureVMImage.ps1 -Label "Pre-Requisites for Dynamics AX7 Developer on Windows Server 2012 R2 CTP8"
        This example returns the first name result of all images with labels containing the specified string.
#>


[CmdletBinding(DefaultParameterSetName='byImageFamily')]
Param
(
    [Parameter(ParameterSetName="ByImageFamily", Mandatory=$true)]
    [String]
    $ImageFamily,
    
    [Parameter(ParameterSetName="ByLabel", Mandatory=$true)]
    [String]
    $Label,
    
    [Int32]
    $First = 1
)

Try
{
    # Checks if the user is connected.
    Invoke-Expression "$PSScriptRoot\Connect-AzureSubscription.ps1"

    if([String]::IsNullOrWhitespace($ImageFamily) -and [String]::IsNullOrWhitespace($Label))
    {
        $images = Get-AzureVMImage
    }
    else
    {
        switch($PSCmdlet.ParameterSetName)
        {
            "ByImageFamily" { $images = Get-AzureVMImage | where { $_.ImageFamily -like "*$($ImageFamily)*" } }
            "ByLabel"       { $images = Get-AzureVMImage | where { $_.Label       -like "*$($Label)*" }       }
        }
    }

    return $images | Sort PublishedDate -Descending | Select -ExpandProperty ImageName -First $First
}
Catch [System.Exception]
{
    Throw $_
}
