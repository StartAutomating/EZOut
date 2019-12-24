Write-FormatView -Action {
    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -ScriptBlock { '  *' }
    Write-FormatViewExpression -If {$_.IsConstructor } -ScriptBlock { $_.DeclaringType } -ControlName TypeNameControl -ForegroundColor 'EZOut.Type.TypeName'
    Write-FormatViewExpression -If { -not $_.IsConstructor -and $_.ReturnType } -ScriptBlock { $_.ReturnType } -ControlName TypeNameControl -ForegroundColor 'EZOut.Type.TypeName'
    Write-FormatViewExpression -If { -not $_.IsConstructor } -ScriptBlock { ' ' +  $_.Name } -ForegroundColor 'EZOut.Type.MemberName'
    Write-FormatViewExpression -ScriptBlock { ' (' }
    Write-FormatViewExpression -ScriptBlock {
        $MethodParameters = @($_.GetParameters())
        foreach ($n in 0..($MethodParameters.Count - 1)) {
            $o =[PSObject]::new($MethodParameters[$n])
            $o.psobject.properties.add([PSNoteProperty]::new('N', $N))
            $o
        }
    } -ControlName TypeMethodParameterControl -Enumerate
    Write-FormatViewExpression -ScriptBlock { ')' }

} -TypeName TypeMethodControl -Name TypeMethodControl -AsControl