Write-FormatView -Action {
    Write-FormatViewExpression -If { $_.N -gt 0} -ScriptBlock  { ', ' }
    Write-FormatViewExpression -Property ParameterType -ControlName TypeNameControl -ForegroundColor 'Verbose'
    Write-FormatViewExpression -ScriptBlock { '$' + $_.Name } -ForegroundColor 'Warning'
    Write-FormatViewExpression -ScriptBlock { ' ' }
} -TypeName TypeMethodParameterControl -Name TypeMethodParameterControl -AsControl
