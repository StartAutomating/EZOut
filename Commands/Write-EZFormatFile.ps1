function Write-EZFormatFile
{
    <#
    .Synopsis
        Creates a new EZFormat file.
    .Description
        Creates a new EZFormat file.  EZFormat files use EZOut to create format and types files for a module.
    #>
    param(
    # Any -FormatView commands.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ScriptBlock[]]
    $Format,

    # Any -TypeView commands.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ScriptBlock[]]
    $Type,

    # The name of the module.  By default, this will be inferred from the name of the file.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Name')]    
    [string]
    $ModuleName = @'
$($myFile | Split-Path -Leaf) -replace '\.ezformat\.ps1', '' -replace '\.ezout\.ps1', ''
'@,


    # The source path.  By default, the script's root.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $SourcePath = @'
$myFile | Split-Path
'@,

    # The destination path.  By default, the script's root.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('DestPath')]
    [string]
    $DestinationPath = @'
$myRoot
'@,

    # The output path for the .ezout file.
    # If no output path is provided, the code will be outputted directly.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $OutputPath
    )

    begin {
        $ezFormatTemplate = @'
#requires -Module EZOut
#  Install-Module EZOut or https://github.com/StartAutomating/EZOut
$myFile = $MyInvocation.MyCommand.ScriptBlock.File
$myModuleName = $_ModuleName
$myRoot = $_MyRoot
Push-Location $myRoot
$formatting = @(
    # Add your own Write-FormatView here,
    # or put them in a Formatting or Views directory
    foreach ($potentialDirectory in 'Formatting','Views','Types') {
        Join-Path $myRoot $potentialDirectory |
            Get-ChildItem -ea ignore |
            Import-FormatView -FilePath {$_.Fullname}
    }
)

$destinationRoot = $_MyDestination

if ($formatting) {
    $myFormatFilePath = Join-Path $destinationRoot "$myModuleName.format.ps1xml"
    # You can also output to multiple paths by passing a hashtable to -OutputPath.
    $formatting | Out-FormatData -Module $MyModuleName -OutputPath $myFormatFilePath
}

$types = @(
    # Add your own Write-TypeView statements here
    # or declare them in the 'Types' directory
    Join-Path $myRoot Types |
        Get-Item -ea ignore |
        Import-TypeView

)

if ($types) {
    $myTypesFilePath = Join-Path $destinationRoot "$myModuleName.types.ps1xml"
    # You can also output to multiple paths by passing a hashtable to -OutputPath.
    $types | Out-TypeData -OutputPath $myTypesFilePath
}
Pop-Location
'@
    }


    process {
        $ezFormatTemplate = $ezFormatTemplate.Replace('$_ModuleName', $(
            if ($ModuleName.StartsWith('$')) {
                $ModuleName
            } else {
                "'$($ModuleName.Replace("'","''"))'"
            }
        ))
        $ezFormatTemplate = $ezFormatTemplate.Replace('$_MyRoot', $(
            if ($SourcePath.StartsWith('$')) {
                $SourcePath
            } else {
                "'$($SourcePath.Replace("'","''"))'"
            }
        ))
        $ezFormatTemplate = $ezFormatTemplate.Replace('$_MyDestination', $(
            if ($DestinationPath.StartsWith('$')) {
                $DestinationPath
            } else {
                "'$($DestinationPath.Replace("'","''"))'"
            }
        ))
        if ($Type) {
            $ezFormatTemplate = $ezFormatTemplate.Replace('# Write-TypeView', $Type -join [Environment]::NewLine)
        }
        if ($Format) {
            $ezFormatTemplate = $ezFormatTemplate.Replace('# Write-FormatView', $Format -join [Environment]::NewLine)
        }

        if (-not $OutputPath) {
            return $ezFormatTemplate
        }

        $ezFormatTemplate | Set-Content -Path $OutputPath
        if ($?) { Get-Item -LiteralPath $OutputPath }
        
    }
}
