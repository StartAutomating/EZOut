Write-FormatView -AsControl -Name TypeNameControl -Action {
    Write-FormatViewExpression -Text ' ['
    Write-FormatViewExpression -ScriptBlock {
        if ($_.FullName) {
            $_.Fullname -replace '`.+', '' -replace '^System\.', ''
        } else {
            $_.Name -replace '`.+', '' -replace '^System\.', ''
        }
    }

    Write-FormatViewExpression -If {
        $_.IsGenericType
    } -ControlName TypeNameControl -ScriptBlock {
        $_.GenericTypeArguments
    } -Enumerate
    Write-FormatViewExpression -Text ']'
} -TypeName TypeNameControl