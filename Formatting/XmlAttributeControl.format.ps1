Write-FormatCustomView -AsControl -Action {
    Write-FormatViewExpression -ForegroundColor 'EZOut.Xml.AttributeName' -ScriptBlock {
        ' ' + $_.Name
    }
    Write-FormatViewExpression -ForegroundColor 'EZOut.Xml.Punctuation' -ScriptBlock {
        $null = $_.OuterXml -match '=\s{0,}(?<q>["''])'
        if ($matches.Q) {
            '=' + $matches.Q
        }
    }
    Write-FormatViewExpression -ForegroundColor 'EZOut.Xml.AttributeValue' -ScriptBlock {
        [security.SecurityElement]::Escape($_.Value)
    }
    Write-FormatViewExpression -ForegroundColor 'EZOut.Xml.Punctuation' -ScriptBlock {
        $null = $_.OuterXml -match '=\s{0,}(?<q>["''])'
        $matches.Q
    }

} -Name XmlAttributeControl