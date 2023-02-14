
# SCRIPT: Convert-VHD.ps1
# =======================
# Converts the format, version type, and block size of a virtual hard disk file.
#
# Type          : Script
# Using         : Windows PowerShell (*.ps1)
#
# Written by    : Andrew D
# Last modified : 01/14/2016

#Requires -Version 3

<#
    .SYNOPSIS
        Converts the format, version type, and block size of a virtual hard disk file.
    .DESCRIPTION
        See Convert-VHD cmdlet.
    .PARAMETER Path
        Specifies the path to the virtual hard disk file to be converted. If a file name or relative path is specified, the path of the converted hard disk path is calculated relative to the current working directory.
    .PARAMETER DestinationPath
        Specifies the path to the converted virtual hard disk file.
    .PARAMETER VHDType
        Specifies the type of the converted virtual hard disk. Allowed values are Fixed, Dynamic, and Differencing. The default is determined by the type of source virtual hard disk.
    .PARAMETER AsJob
        Runs the cmdlet as a background job.
    .PARAMETER DeleteSource
        Specifies that the source virtual hard disk is to be deleted after the conversion.
    .PARAMETER Passthru
        Specifies that an object is to be passed through to the pipeline representing the converted virtual hard disk.
    .PARAMETER Confirm
        Prompts you for confirmation before running the cmdlet.
    .PARAMETER WhatIf
        Shows what would happen if the cmdlet runs. The cmdlet is not run.
    .EXAMPLE
        PS C:\> .\Convert-VHD.ps1 -Path c:\test\testvhd.vhd –DestinationPath c:\test\testvhdx.vhdx
        This example converts a source VHD to a destination VHDX. Because the format is determined by the file extension and the default type is determined by the source virtual hard disk when no type is specified, the destination virtual hard disk will be a VHDX-format disk of the same type as the source virtual hard disk.
    .EXAMPLE
        PS C:\> .Convert-VHD.ps1 –Path c:\test\child1vhdx.vhdx –DestinationPath c:\test\child1vhd.vhd –VHDType Differencing –ParentPath c:\test\parentvhd.vhd
        This example converts a source differencing disk of VHDX format to a destination differencing disk of VHD format that is connected to an existing parent disk.
#>


[CmdletBinding()]
Param
{
    [String] $Path,
    [String] $DestinationPath,
    [String] $VHDType,
    [String] $ParentPath,
    [Switch] $AsJob,
    [Switch] $DeleteSource,
    [Switch] $Passthru,
    [Switch] $Confirm,
    [Switch] $WhatIf
}

Try
{
    if([String]::IsNullOrWhitespace($VHDType))
    {
        Convert-VHD -Path $Path -DestinationPath $DestinationPath `
                    -AsJob:$AsJob -DeleteSource:$DeleteSource -Passthru:$Passthru `
                    -Confirm:$Confirm -WhatIf:$WhatIf
    }
    elseif($VHDType.ToLower() -eq "differencing")
    {
        Convert-VHD -Path $Path -DestinationPath $DestinationPath `
                    -VHDType $VHDType -ParentPath $ParentPath`
                    -AsJob:$AsJob -DeleteSource:$DeleteSource -Passthru:$Passthru `
                    -Confirm:$Confirm -WhatIf:$WhatIf
    }
    else
    {
        Convert-VHD -Path $Path -DestinationPath $DestinationPath -VHDType $VHDType `
                    -AsJob:$AsJob -DeleteSource:$DeleteSource -Passthru:$Passthru `
                    -Confirm:$Confirm -WhatIf:$WhatIf
    }
}
Catch [System.Exception]
{
    Throw $_
}
