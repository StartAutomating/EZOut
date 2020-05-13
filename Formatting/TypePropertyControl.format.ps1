Write-FormatView -Action {
    Write-FormatViewExpression -If { -not $script:DisplayingMember  } -ScriptBlock { [Environment]::NewLine }
    Write-FormatViewExpression -ScriptBlock { '  * '}
    Write-FormatViewExpression -Property PropertyType -ControlName TypeNameControl -ForegroundColor 'Verbose'
    Write-FormatViewExpression -Property Name -ForegroundColor 'Warning'
    Write-FormatViewExpression -ScriptBlock {
        ' {' +
        $(if ($_.CanRead) {'get;'}) +
        $(if ($_.CanWrite) {'set;'})+
        '}'
    }
} -TypeName TypePropertyControl -Name TypePropertyControl -AsControl
