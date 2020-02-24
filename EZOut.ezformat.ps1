#requires -Module EZOut
#  Install-Module EZOut or https://github.com/StartAutomating/EZOut
$myFile = $MyInvocation.MyCommand.ScriptBlock.File
$myModuleName = $($myFile | Split-Path -Leaf) -replace '\.ezformat\.ps1', ''
$myRoot = $myFile | Split-Path
$formatting = @(
    # Write-FormatView
<#    Write-FormatTreeView -TypeName System.IO.FileInfo, System.IO.DirectoryInfo -Branch ([char]9500 + [char]9472 + [char]9472) -Property Name -HasChildren {
            if (-not $_.EnumerateFiles) { return $false }
            foreach ($f in $_.EnumerateFiles()) {$f;break}
        },
        {
            if (-not $_.EnumerateDirectories) { return $false }
            foreach ($f in $_.EnumerateDirectories()) {$f;break}
        } -Children {
            $_.EnumerateFiles()
        }, {
            foreach ($d in $_.EnumerateDirectories()) {
                if ($d.Attributes -band 'Hidden') { continue }
                $d
            }
        }
#>
    Join-Path $myRoot Formatting | Import-FormatView -FilePath { $_ }
)
$myFormatFile = Join-Path $myRoot "$myModuleName.format.ps1xml"
$formatting | Out-FormatData -ModuleName EZOut | Set-Content -Path $myFormatFile -Encoding UTF8
$types = @(
    # Write-TypeView
)
$myTypesFile = Join-Path $myRoot "$myModuleName.types.ps1xml"
$types | Out-TypeData | Set-Content $myTypesFile -Encoding UTF8
