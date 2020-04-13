Write-FormatView -Action {
    Write-FormatViewExpression -If { -not $script:DisplayingMember  } -ScriptBlock { [Environment]::NewLine }
    Write-FormatViewExpression -ScriptBlock { '  * ' }
    Write-FormatViewExpression -Property Name -ForegroundColor 'EZOut.Type.MemberName'
    Write-FormatViewExpression -Text '('
    Write-FormatViewExpression -If { $_.EventHandlerType.GetMethod('Invoke') } -ScriptBlock {
        $MethodParameters = @($_.EventHandlerType.GetMethod('Invoke').GetParameters())
        foreach ($n in 0..($MethodParameters.Count - 1)) {
            $o =[PSObject]::new($MethodParameters[$n])
            $o.psobject.properties.add([PSNoteProperty]::new('N', $N))
            $o
        }
    } -ControlName TypeMethodParameterControl -Enumerate
    Write-FormatViewExpression -Text ')'
} -TypeName TypeEventControl -Name TypeEventControl -AsControl