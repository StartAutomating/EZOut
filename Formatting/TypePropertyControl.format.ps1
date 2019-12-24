Write-FormatView -Action {
    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -ScriptBlock { '  * '}
    Write-FormatViewExpression -Property Name -ForegroundColor 'EZOut.Type.MemberName'
    Write-FormatViewExpression -Property PropertyType -ControlName TypeNameControl -ForegroundColor 'EZOut.Type.TypeName'
    Write-FormatViewExpression -ScriptBlock {
        ' {' +
        $(if ($_.CanRead) {'get;'}) +
        $(if ($_.CanWrite) {'set;'})+
        '}'
    }
} -TypeName TypePropertyControl -Name TypePropertyControl -AsControl
