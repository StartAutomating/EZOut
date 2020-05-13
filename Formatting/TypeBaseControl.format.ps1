Write-FormatView -Action {
    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -ScriptBlock { '  *' }
    Write-FormatViewExpression -ControlName TypeNameControl -ScriptBlock  {$_ } -ForegroundColor 'Verbose'
} -TypeName TypeBase -Name TypeBase -AsControl
