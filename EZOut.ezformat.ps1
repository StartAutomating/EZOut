#requires -Module EZOut
#  Install-Module EZOut or https://github.com/StartAutomating/EZOut
$myFile = $MyInvocation.MyCommand.ScriptBlock.File
$myModuleName = $($myFile | Split-Path -Leaf) -replace '\.ezformat\.ps1', ''
$myRoot = $myFile | Split-Path
$formatting = @(
    # Write-FormatView
    Write-FormatTreeView -TypeName System.IO.FileInfo, System.IO.DirectoryInfo -Branch ([char]9500 + [char]9472 + [char]9472) -Property Name -HasChildren {
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

    Write-FormatView -TypeName System.Management.Automation.PSModuleInfo -Property Name, Version, ExportedCommands
    Write-FormatView -TypeName System.Management.Automation.PSModuleInfo, EZOut.RichModuleInfo -Action {
        $module = $_
        @(
            $moduleNameVer = $module.Name + $(
                if ($module.Version) {
                    " [$($module.Version)]"
                }
            )
            $moduleNameVer
            '=' * $moduleNameVer.Length
            if ($module.Description) {
                $module.Description
                '-' * $moduleNameVer.Length
            }

            :findAboutText foreach ($culture in "$(Get-Culture)", 'en-us'| Select-Object -Unique) {
                $aboutTextFile = $module |
                    Split-Path |
                    Join-Path -ChildPath $culture |
                    Join-Path -ChildPath "About_$module.help.txt"
                if (Test-Path $aboutTextFile) {
                    [IO.File]::ReadAllText("$aboutTextFile")
                    break
                } else {
                    Write-Verbose "No help.txt file found at $aboutTextFile"
                }
            }

            $commandSection = if ($module.ExportedCommands.Count) {

                $byVerb = $module.ExportedCommands.Values |
                    Where-Object { $_.Verb } |
                    Group-Object Verb |
                    Sort-Object Name

                $maxVerbLength = $byVerb |
                    Select-Object -ExpandProperty Name |
                    Measure-Object -Property Length -Maximum |
                    Select-Object -ExpandProperty Maximum

                $maxNounLength = $module.ExportedCommands.Values |
                    Select-Object -ExpandProperty Noun |
                    Measure-Object -Property Length -Maximum |
                    Select-Object -ExpandProperty Maximum

                "|$(' ' * [Math]::Max($maxVerbLength - 4, 0))Verb|Noun$(' ' * [Math]::Max($maxNounLength - 4 + 1, 0))|"
                "|$('-' * [Math]::Max($maxVerbLength - 1, 0)):|:$('-' * [Math]::Max($maxNounLength, 0))|"

                foreach ($_ in $byVerb) {
                    $v = "$($_.Name)"

                    '|' +
                        ' ' * ($maxVerbLength - $v.Length) + $v + '|' +
                        $(if ($_.Group.Count -eq 1) {
                            $t = '-' + $_.Group[0].Noun
                            $t + ' ' * ([Math]::Max($maxNounLength - $t.Length + 1, 0)) + '|'
                        } else {
                            (' ' * ($maxNounLength + 1)) + '|'
                        })
                    if ($_.Group.Count -gt 1) {
                        foreach ($i in $_.Group) {
                            '|' + " " * ($maxVerbLength) + '|-' + $i.Noun + ' ' * ([Math]::Max($maxNounLength - $i.Noun.Length, 0)) + '|'
                        }
                    }
                }
            }

            if ($commandSection) {
                $commandLineLength = $commandSection | Measure-Object -Property Length -Maximum | Select-Object -ExpandProperty Maximum
                "Commands"
                '-' * $commandLineLength
                $commandSection -join [Environment]::NewLine
                '-' * $commandLineLength
            }

            if ($module.ExportedAliases.Count) {
                $byResolvedCommand = $module.ExportedAliases.Values |
                    Group-Object ResolvedCommand
            }

        ) -join [Environment]::NewLine
    }
)
$myFormatFile = Join-Path $myRoot "$myModuleName.format.ps1xml"
$formatting | Out-FormatData | Set-Content -Path $myFormatFile -Encoding UTF8 -Verbose
$types = @(
    # Write-TypeView
)
$myTypesFile = Join-Path $myRoot "$myModuleName.types.ps1xml"
$types | Out-FormatData | Set-Content $myTypesFile -Encoding UTF8
