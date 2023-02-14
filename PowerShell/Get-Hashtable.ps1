
# SCRIPT: Get-Hashtable.ps1
# =========================
# Gets a set of key-value pairs from a file and returns a hashtable.
#
# Type          : Script
# Using         : Windows PowerShell (*.ps1)
#
# Written by    : Andrew D
# Last modified : 01/14/2016

#Requires -Version 2

<#
    .SYNOPSIS
        Gets a set of key-value pairs from a file and returns a hashtable.
    .DESCRIPTION
        Input consists of at least one file containing only key-value pairs, pairs separated by semicolons (;), key and value separated by an equal sign (=):
		
			VMName   = Win7Base001;
			VHD      = Win7Base_Template.vhd;
			Size     = Small;
			Username = drdendrite;
			Password = securitynotanissue
			
        Whitespace within a key or value name is preserved:
		
			File: Directory = C:\Program Files (x86)\;
			Hash: @{Directory=C:\Program Files (x86)\}
			
    .PARAMETER Path
        Specifies the path to an item. Wildcards are permitted. The parameter name ("Path" or "FilePath") is optional.
    .EXAMPLE
        PS C:\> .\Get-Hashtable.ps1 -Path .\config.txt
        This example returns a hashtable containing a list of key-value pairs in config.txt.
    .EXAMPLE
        PS C:\> Import-Module Azure; New-AzureVM @{.\Get-Hashtable.ps1 .\vmConfig.txt}
        This example calls an Azure cmdlet using parameters from a config .txt file.
#>


[CmdletBinding()]
Param
(
    [Parameter(ValueFromPipeline, Position=0)]
    [Alias("FilePath")]
    [String[]]
    $Path
)

$delim       = "[=;]"
$comment     = "#.*$"
$block       = "<#(.|\r|\n)*#>"
$trimPattern = "($block)|(?<=^|$delim)\s+(?=$delim|.|$)|(?<=^|$delim|.)\s+(?=$delim|$)"

$table = @{}
$lines = (Get-Content -Path $Path) | foreach { $_ -Replace $comment, "" }

([String]$lines -Replace $trimPattern, "").Split(";") `
    | where   { ![String]::IsNullOrEmpty($_) } `
    | foreach { $pair = $_.Split("="); $table.Add($pair[0], $pair[1]) }

return $table
