
Param
(
    [Parameter( ParameterSetName  = 'StringOperation',
                Position          = 0,
                ValueFromPipeline = $true )]
    [String[]]
    $Content,
    
    [Parameter( ParameterSetName                = 'FileOperation',
	            ValueFromPipelineByPropertyName = $true )]
    [Alias("Path", "FullName")]
    [String]
    $FilePath,

    [Alias("Spaces")]
    [Int64]
    $NumberOfSpaces = 4
)

$ErrorActionPreference = "Stop"

$space = " "

Try
{
    if($PSCmdlet.ParameterSetName -eq 'FileOperation')
    {
        $Content = [String[]]
        $Content = (Get-Content $FilePath)
    }

    $newContent = @()
    
    foreach($line in $Content)
    {
        $newContent += $line.Replace("`t", "$($space*$NumberOfSpaces)")
    }

    switch($PSCmdlet.ParameterSetName)
    {
        'StringOperation'
        {
            return $newContent
        }
        'FileOperation'
        {
            Set-Content -Path $FilePath -Value $newContent
            
            return
        }
    }
}
Catch [System.Exception]
{
    Throw $_
}
