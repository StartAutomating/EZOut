@{
    ModuleToProcess = 'EZOut.psm1'
    ModuleVersion = '2.0'
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
        'Out-Mermaid','Out-Gum'
        
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
## 2.0:

* EZOut Turns 2.0!
* EZOut Supports Sponsorship (please show your support) (#120)
* $PSStyle Support
  * Write-FormatViewExpression now supports -PSStyle/-Style (#106)
    * Use any property from $PSStyle in a formatter, if present
    * This is faster and smaller than other color customizations, and will only work on core.
  * Write-FormatTableView supports -StyleProperty/-StyleRow (#129)
  * Write-FormatListView supports -StyleProperty (#130)
* New Commands:
  * Out-Gum      - Use [CharmBraclet's Gum](https://github.com/charmbracelet/gum) to prompt for input (#111)
  * Out-Mermaid  - Generate Diagrams with [MermaidJS](https://mermaid.js.org/)  (#112)
* _Example Formatting Has Moved to [Posh](https://github.com/StartAutomating/Posh)_ (#127)
* Write-TypeView now supports -Debug (#114) 
  If you Import-TypeView with -Debug or Write-TypeView with -Debug, 
  Update-TypeData will be called to force the types to be loaded with the exact values you provide
  (thus enabling you to put a breakpoint in and -Debug a type!)
  (when you're done debugging, Remove-Module EZOut to clear any dynamic typea)
* Import-TypeView improvements
  * Psuedo-inheritance (#143)
  * Better Markdown file support (#144)  
  * No longer over-hiding (#142)
  * Skipping Empty ScriptBlocks (#108)
  * Improving Empty get Property (#109)
  * Allowing NoteProperties to be hidden (#110)
* Format/JSON-YAML:  -Depth defaults to $FormatEnumerationLimit (#107)
* Module / Repository Improvements
  * Refactored Repository (#115)
    * Build files are now beneath `/Build` (#116)
    * Commands are now beneath `/Commands` (#117)
  * Added Issue Templates (#125)
  * Added Contribution Guide (#126)
* Breaking Changes (for the better)
  * The module no longer requires -AllowClobber (#105)
  * Add/Remove-TypeData/FormatData are now Push/Pop-TypeData/FormatData (#113)
  * These functions are only used during authorship and other interactive use.
  * Most users should be unaffected.  

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
