Write-FormatView -TypeName "System.Management.Automation.PSModuleInfo", "EZOut.RichModuleInfo" -Action {
$module = $_
@(
    $moduleNameVer = $module.Name + $(
        if ($module.Version) {
            " [$($module.Version)]"
        }
    )
    Format-Markdown -Heading $moduleNameVer -HeadingSize 1
    if ($module.Description) {
        Format-Markdown -Heading $module.Description -HeadingSize 2
    }

    $commandSection = 
        if ($module.ExportedCommands.Count) {
            $sortedByVerb = $module.ExportedCommands.Values |
                Where-Object { $_.Verb -and $_.Noun } |
                Sort-Object Verb, Noun |
                Select-Object Verb, Noun
            
            $sortedByVerb | Format-Markdown -MarkdownTable
        }

    if ($commandSection) {
        $commandLineLength = $commandSection | Measure-Object -Property Length -Maximum | Select-Object -ExpandProperty Maximum
        "### Commands"        
        $commandSection -join [Environment]::NewLine        
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
) -join [Environment]::NewLine
}