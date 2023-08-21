@{
    ModuleToProcess = 'EZOut.psm1'
    ModuleVersion = '2.0.1'
    GUID = 'cef786f0-8a0b-4a5d-a2c6-b433095354cd'
    Author = 'James Brundage'
    CompanyName = 'Start-Automating'
    Copyright = '2011-2023'
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
        Colors = @{
            Xml = @{
                AttributeName = '#fafa00'
                AttributeValue = '#00bfff'
                Punctuation  = '#a9a9a9'
                Tag = '#00ffff'
                Element = '#00af00'
                InnerText = '#8bda8b'
            }
        }
        EZOut = @{
            RichText = "Format-RichText"
            Heatmap = "Format-Heatmap"
            Markdown = "Format-Markdown"
            YAML = "Format-YAML"
            Hashtable = "Format-Hashtable"
            JSON = "Format-JSON"
        }
        PSData = @{
            ProjectURI = 'https://github.com/StartAutomating/EZOut'
            LicenseURI = 'https://github.com/StartAutomating/EZOut/blob/master/LICENSE'

            Tags = '.ps1xml', 'Format','Output','Types', 'Colorized'
            ReleaseNotes = @'
## 2.0.1

* Formatting can now live in the Types directory!
  * Import-TypeView - Skipping format files (#151)
  * Import-FormatView - Skipping non-format files (#157)
  * Import-FormatView - Setting $PSTypeName (if file is present) (#159)
  * Write-EZFormatFile - Adding 'Types' to Import-FormatView (#158)
  * Moving Hello.EZOut to 'Types' (#150)
* -Style Parameter improvements
  * Infinite dotting (#148)
  * Arbitrary variable support (#155)
* Write-FormatView - Defaulting -ViewName to first -TypeName (Fixes #160)
* New Command: Out-Alternate (Fixes #156)

---

Additional Release History found in [CHANGELOG](https://github.com/StartAutomating/EZOut/blob/master/CHANGELOG.md)
            
'@
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
