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
    [ScriptBlock[]]
    $Format,

    # Any -TypeView commands.
    [ScriptBlock[]]
    $Type,

    [string]
    $ModuleName = @'
$($myFile | Split-Path -Leaf) -replace '\.ezformat\.ps1', '' -replace '\.ezout\.ps1', ''
'@,

    

    [string]
    $SourcePath = @'
$myFile | Split-Path
'@,

    [Alias('DestPath')]
    [string]
    $DestinationPath = @'
$myRoot
'@
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
    # Add your own Write-FormatView here, or put them in a Formatting or Views directory

    foreach ($potentialDirectory in 'Formatting','Views') {
        Join-Path $myRoot $potentialDirectory |
            Get-ChildItem -ea ignore |
            Import-FormatView -FilePath {$_.Fullname}
    }
)

$destinationRoot = $_MyDestination

if ($formatting) {
    $myFormatFile = Join-Path $destinationRoot "$myModuleName.format.ps1xml"
    $formatting | Out-FormatData -Module $MyModuleName | Set-Content $myFormatFile -Encoding UTF8
}

$types = @(
    # Add your own Write-TypeView statements here
)

if ($types) {
    $myTypesFile = Join-Path $destinationRoot "$myModuleName.types.ps1xml"
    $types | Out-TypeData | Set-Content $myTypesFile -Encoding UTF8
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

        return $ezFormatTemplate
    }
}
