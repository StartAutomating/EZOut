@{
    ModuleToProcess = 'EZOut.psm1'
    ModuleVersion = '1.8.9'
    GUID = 'cef786f0-8a0b-4a5d-a2c6-b433095354cd'
    Author = 'James Brundage'
    CompanyName = 'Start-Automating'
    Copyright = '2011-2022'
    Description = 'Easily Author Rich Format Files to Customize PowerShell Output'
    FunctionsToExport =
        'Add-FormatData', 'Clear-FormatData', 'Out-FormatData', 'Remove-FormatData',
        'Add-TypeData', 'Clear-TypeData', 'Out-TypeData', 'Remove-TypeData',
        'Import-FormatView','Import-TypeView',
        'Write-FormatControl','Write-FormatView',
        'Write-FormatCustomView', 'Write-FormatTableView',
        'Write-FormatTreeView','Write-FormatWideView', 'Write-FormatListView',
        'Write-FormatViewExpression',
        'Write-TypeView','ConvertTo-PropertySet','Write-PropertySet',
        'Get-FormatFile', 'Find-FormatView', 'Get-PropertySet', 'Write-EZFormatFile', 'Get-EZOutExtension', 
        'Format-Object','Format-RichText', 'Format-Markdown', 'Format-YAML','Format-Heatmap','Format-Hashtable'
    AliasesToExport = 'Write-CustomAction'
    FormatsToProcess = 'EZOut.format.ps1xml'
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
        }
        PSData = @{
            ProjectURI = 'https://github.com/StartAutomating/EZOut'
            LicenseURI = 'https://github.com/StartAutomating/EZOut/blob/master/LICENSE'

            Tags = '.ps1xml', 'Format','Output','Types', 'Colorized'
            ReleaseNotes = @'
## 1.8.9:
* Added Format-Hashtable (Fixes #61)
* Import-TypeView now supports hidden properties (Fixes #62)
---

## 1.8.8.1:
* Format-YAML now supports -Indent (Fixes #59)
* Format-YAML now supports all primitive types (Fixes #58). Thanks @dfinke!
---

## 1.8.8:
* Write-EZFormatFile generates scripts that output files.  Fixes #56 and #43.
---

## 1.8.7:
* Out-FormatData: Now supports -Debug (#46)
* Format-YAML: Fixing Indentation (#49)
* Import-TypeView: Allowing Typename.txt file to redefine typename (#48)
* Self-hosting action (#52)
* GitHub Action now carries on commit message (#54)
---
## 1.8.6
* Format-Markdown:  Adding -ImageLink
* Format-Markdown:  Adding -MarkdownTableAlignment, additional documentation.
* Format-Markdown:  Normalizing tables and fixing issues with Dictionaries
* Format-YAML: Fixing minor issue with -YAMLHeader and multiple objects
* Updating tests:  Adding test for Format-Object
* Adding EZOut GitHub Action (#36)
* Out-FormatData:  Fixing error when a node has an empty scriptblock (#19)
* Write-FormatListView:  Updating Colorization (#33)
* Write-FormatTableView:  Fixing encoding and updating colorization (#34)
* Fixing RichModuleInfo (#41)
* Write-FormatViewExpression:  Updating Colorization (#35)
* Format-RichText:  Adding help, and fixing color lookup logic
* Format-Markdown:  Changes to -Heading/-HeadingSize (re #41)
* Adding Format- commands (#24, #25, #26, #27, #28, #29, #30) and making EZOut format take precedence.
* Fixing Colorization in System.Diagnostics.Process (#32)
* Adding Get-EZOutExtension: (helps fix #25)
* Write-FormatViewExpression:  Support for localization (#39)
* Out-FormatData:  Format-Object embedability (#26), Parts cleanup (#38)
* #38 - Removing single use parts
* Adding Format-Heatmap (#30)
* Adding Format-Markdown (#29)
* Adding Format-YAML (#28)
* Adding Format-RichText (#27)
* Adding Format-Object (#25, #26)
* Adding workflow definition (#37)
---
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
