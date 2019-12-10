[OutputType([xml])]
param()

Write-FormatViewExpression -If {$script:TreeDepth = 0;$true} -ControlName XmlNodeControl -ScriptBlock { 
    @(foreach ($cn in $_.ChildNodes) {
        if ($cn -is [xml.xmldeclaration]) { continue }
        $cn
    })
} -Enumerate
Write-FormatViewExpression -If {$ExecutionContext.SessionState.PSVariable.Remove('script:TreeDepth'); $false} -ScriptBlock { $null }
