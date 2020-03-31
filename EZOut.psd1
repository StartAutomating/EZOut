@{
    ModuleToProcess = 'EZOut.psm1'
    ModuleVersion = '1.8'
    GUID = 'cef786f0-8a0b-4a5d-a2c6-b433095354cd'
    Author = 'James Brundage'
    CompanyName = 'Start-Automating'
    Copyright = '2011'
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
        'Get-FormatFile', 'Find-FormatView', 'Get-PropertySet', 'Write-EZFormatFile'
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
            Type = @{
                TypeName = '#00d1b1'
                MemberName = '#ffa82d'
            }
        }
        PSData = @{
            ProjectURI = 'https://github.com/StartAutomating/EZOut'
            LicenseURI = 'https://github.com/StartAutomating/EZOut/blob/master/LICENSE'

            Tags = '.ps1xml', 'Format','Output','Types', 'Colorized'
            ReleaseNotes = @'
Now in Living Color!
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
