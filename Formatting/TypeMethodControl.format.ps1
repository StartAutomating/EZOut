Write-FormatView -Action {
    Write-FormatViewExpression -If { -not $script:DisplayingMember  } -ScriptBlock { [Environment]::NewLine }
    Write-FormatViewExpression -ScriptBlock { '  *' }
    Write-FormatViewExpression -If { $_.IsStatic } -ScriptBlock { ' static ' }
    Write-FormatViewExpression -If {$_.IsConstructor } -ScriptBlock { $_.DeclaringType } -ControlName TypeNameControl -ForegroundColor 'Verbose'
    Write-FormatViewExpression -If { -not $_.IsConstructor -and $_.ReturnType } -ScriptBlock { $_.ReturnType } -ControlName TypeNameControl -ForegroundColor 'Verbose'
    Write-FormatViewExpression -If { -not $_.IsConstructor } -ScriptBlock { ' ' +  $_.Name } -ForegroundColor 'Warning'
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