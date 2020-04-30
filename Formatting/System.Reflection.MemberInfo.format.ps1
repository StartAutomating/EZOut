Write-FormatView -TypeName System.Reflection.MemberInfo -Action {
    Write-FormatViewExpression -If { $ExecutionContext.SessionState.PSVariable.Set('Script:DisplayingMember',$true) } -ScriptBlock { $null } 
    Write-FormatViewExpression -ControlName TypeMemberControl -ScriptBlock { $_ } 
    Write-FormatViewExpression -If { $ExecutionContext.SessionState.PSVariable.Remove('Script:DisplayingMember') } -ScriptBlock { $null } 
}
