$showElementIf = {'#text','#whitespace' -notcontains $_.LocalName }
Write-FormatTreeView -Property @({
    Write-FormatViewExpression -ForegroundColor 'EZOut.Xml.Tag' -if $showElementIf -ScriptBlock { '<'.Trim() }
    Write-FormatViewExpression -ForegroundColor 'EZOut.Xml.Element' -if $showElementIf -ScriptBlock {
        $_.LocalName
    }
    Write-FormatViewExpression -ControlName XmlAttributeControl -ScriptBlock {$_.Attributes} -Enumerate -If {
        $_.HasAttributes -and '#text', '#whitespace' -notcontains $_.LocalName
    }
    Write-FormatViewExpression -ForegroundColor 'EZOut.Xml.Tag' -ScriptBlock {
        if ($_.HasChildren -or $_.HasChildNodes) {
            '>'
        } else {
            '/>'
        }
    } -if $showElementIf
    Write-FormatViewExpression -If { $_.LocalName -eq '#text' } -ScriptBlock {$_.InnerText } -ForegroundColor 'EZOut.Xml.InnerText'
}) -TypeName System.Xml.XmlElement -HasChildren { $_.HasChildren -or $_.HasChildNodes -and $_.LocalName -ne '#whitespace'} -Children {
    @(foreach ($cn in $_.ChildNodes) {
        if ($cn.LocalName -eq '#whitespace') { continue }
        $cn
    })
} -EndBranchScript {
    Write-FormatViewExpression -ForegroundColor 'EZOut.Xml.Tag' -ScriptBlock {
        if (-not ($_.HasChildren -or $_.HasChildNodes)) {
            ''
        } else {
            [Environment]::NewLine + (' ' * ($script:TreeDepth - 1)* 4) + '</'
        }
    }
    Write-FormatViewExpression -ForegroundColor 'EZOut.Xml.Element' -ScriptBlock {
         if ($_.HasChildren -or $_.HasChildNodes) { $_.LocalName}
    }
    Write-FormatViewExpression -ForegroundColor 'EZOut.Xml.Tag' -ScriptBlock {
         if ($_.HasChildren -or $_.HasChildNodes) {'>'}
    }
} -ControlName XmlNodeControl
