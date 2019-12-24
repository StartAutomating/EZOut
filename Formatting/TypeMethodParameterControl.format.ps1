Write-FormatView -Action {
    Write-FormatViewExpression -If { $_.N -gt 0} -ScriptBlock  { ', ' }
    Write-FormatViewExpression -Property ParameterType -ControlName TypeNameControl -ForegroundColor 'EZOut.Type.TypeName'
    Write-FormatViewExpression -ScriptBlock { '$' + $_.Name } -ForegroundColor 'EZOut.Type.MemberName'
    Write-FormatViewExpression -ScriptBlock { ' ' }
} -TypeName TypeMethodParameterControl -Name TypeMethodParameterControl -AsControl
