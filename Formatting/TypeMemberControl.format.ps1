Write-FormatControl -Name TypeMemberControl -Action {
    Write-FormatViewExpression -If { 
        'RuntimeMethodInfo', 'RuntimeConstructorInfo' -contains $_.GetType().Name
    } -ScriptBlock  {$_ } -ControlName TypeMethodControl
    Write-FormatViewExpression -If { $_.GetType().Name -eq 'RuntimePropertyInfo' } -ScriptBlock  {$_ } -ControlName TypePropertyControl
    Write-FormatViewExpression -If { 
        
        'MdFieldInfo', 'RtFieldInfo' -contains $_.GetType().Name 
    } -ScriptBlock  {$_ } -ControlName TypeFieldControl
    Write-FormatViewExpression -If { $_.GetType().Name -eq 'RuntimeEventInfo' } -ScriptBlock  {$_ } -ControlName TypeEventControl
}

