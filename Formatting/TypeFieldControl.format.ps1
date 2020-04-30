Write-FormatControl -Name TypeFieldControl -Action {
    Write-FormatViewExpression -If { -not $script:DisplayingMember  } -ScriptBlock { [Environment]::NewLine }
    Write-FormatViewExpression -ScriptBlock { '  * '}
    Write-FormatViewExpression -Property FieldType -ControlName TypeNameControl -ForegroundColor 'EZOut.Type.TypeName'
    Write-FormatViewExpression -Property Name -ForegroundColor 'EZOut.Type.MemberName'
}