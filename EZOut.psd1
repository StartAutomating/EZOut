@{
    ModuleToProcess = 'EZOut.psm1'
    ModuleVersion = '2.0.4'
    GUID = 'cef786f0-8a0b-4a5d-a2c6-b433095354cd'
    Author = 'James Brundage'
    CompanyName = 'Start-Automating'
    Copyright = '2011-2024'
    Description = 'Easily Author Rich Format Files to Customize PowerShell Output'
    FunctionsToExport =
        # Core format manipulation functions
        'Push-FormatData','Clear-FormatData', 'Out-FormatData', 'Pop-FormatData',
        'Push-TypeData', 'Clear-TypeData', 'Out-TypeData', 'Pop-TypeData',
        'Get-FormatFile', 'Find-FormatView',
        # Imports
        'Import-FormatView','Import-TypeView',
        # Control authoring
        'Write-FormatControl',
        # Creation of formatting views:  splats to
        'Write-FormatView',            
            'Write-FormatCustomView',
            'Write-FormatTableView',
            'Write-FormatListView',
        # doesn't splat to Write-FormatWideView, because it's not useful        
        'Write-FormatWideView',
        # Write-FormatViewExpression is used in custom actions and controls
        'Write-FormatViewExpression',
        # Write-FormatTreeView is an advanced formatting control
        'Write-FormatTreeView',
        # Most other advanced format controls are extensions to Format-Object
        'Format-Object',
            'Format-Hashtable','Format-Heatmap','Format-JSON',
            'Format-Markdown', 'Format-RichText','Format-YAML',
        # Don't forget types.ps1xml functions
        'Write-TypeView',
            'ConvertTo-PropertySet','Write-PropertySet','Get-PropertySet',
        # or the code generator for .ezout.ps1 files
        'Write-EZFormatFile',
        # or Get-EZOutExtension
        'Get-EZOutExtension',
        
        # More formatting controls.
        # These can be embedded, but do not directly extend Format-Object.
        'Out-Mermaid','Out-Gum','Out-Alternate'
        
    AliasesToExport  = 'Write-CustomAction', 'Add-TypeData', 'Add-FormatData'
    FormatsToProcess = 'EZOut.format.ps1xml'
    TypesToProcess   = 'EZOut.types.ps1xml'
    PrivateData = @{        
        EZOut = @{
            RichText = "Format-RichText"
            Heatmap = "Format-Heatmap"
            Markdown = "Format-Markdown"
            YAML = "Format-YAML"
            Hashtable = "Format-Hashtable"
            JSON = "Format-JSON"
        }

        Taglines = 
            "Easily Output anything from PowerShell",
            "Flexibly Format with PowerShell",
            "Make your formatting fantastic",
            "Easily extend types with PowerShell",
            "Make output that really pops in PowerShell",
            "Extended Types made Easy"

        PSData = @{
            ProjectURI = 'https://github.com/StartAutomating/EZOut'
            LicenseURI = 'https://github.com/StartAutomating/EZOut/blob/master/LICENSE'

            Tags = '.ps1xml', 'Format','Output','Types', 'Colorized'
            ReleaseNotes = @'
## EZOut 2.0.4:

* Write-FormatViewExpression/Write-FormatCustomView now support -Frame, -LeftIndent, -RightIndent, -FirstLineHanging, -FirstLineIndent ( Fixes #164 )
* Push-FormatData/Push-TypeData now create unique files per-process (Fixes #205 )

Thanks @NinMonkey !

---

Additional Release History found in [CHANGELOG](https://github.com/StartAutomating/EZOut/blob/master/CHANGELOG.md)

Like It?  [Star It!](https://github.com/StartAutomating/EZOut)  Love It?  [Support It!](https://github.com/sponsors/StartAutomating)

'@

            Recommends = 'Posh','PipeScript','ShowDemo'
        }
        
        PoshMacros = @{
            'EZOut' = @{
                ScriptBlock = @'
([IO.DirectoryInfo]"$pwd").EnumerateFiles() |
    ? { $_.Name -like '*.ez*.ps1' } |
    % { . $_.FullName }
'@
            }
        }
    }
}
