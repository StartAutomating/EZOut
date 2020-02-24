
param(
[Parameter(Mandatory,ValueFromPipelineByPropertyName)]
[Alias('InnerText','ScriptBlock','ScriptContents')]
[string]$InScript,

[PSModuleInfo[]]
$FromModule = @(Get-Module),

# If set, will look for a part globally if it does not find in any of the modules.
[switch]
$AllowGlobal
)

begin {
    if (-not $script:LookedUpCommands) {
        $script:LookedUpCommands = @{}
    }
    if (-not $script:CommandModuleLookup) {
        $script:CommandModuleLookup = @{}
    }
    $GetVariableValue = {
        param($name)
        $ExecutionContext.SessionState.PSVariable.Get($name).Value
    }

    #region <-- ?<PowerShell_Invoke_Variable>
    $PowerShell_Invoke_Variable = [Regex]::new(@'
(?<![\w\)`])                                            # If the text before the invoke is a word, closing paranthesis, or backtick, do not match
(?<CallOperator>[\.\&])                                 # Match the <CallOperator> (either a . or a &)
\s{0,}                                                  # Followed by Optional Whitespace
\$                                                      # Followed by a Dollar Sign
((?<Variable>\w+)                                       # Followed by a <Variable> (any number of repeated word characters)
|                                                       # Or a <Variable> enclosed in curly brackets
(?:(?<!`){(?<Variable>(?:.|\s)*?(?=\z|(?<!`)}))(?<!`)}) # using backtick as an escape
)
'@, 'IgnoreCase,IgnorePatternWhitespace', '00:00:05')
    #endregion <-- ?<PowerShell_Invoke_Variable>
            
}

    process {
        $in = $_
        foreach ($match in $PowerShell_Invoke_Variable.Matches($InScript)) {
            $variableName = $match.Groups['Variable'].Value
            if (-not $script:LookedUpCommands[$variableName]) {                        
                $foundCommand = 
                    foreach ($module in $FromModule) {
                        $foundIt = & $module $GetVariableValue $variableName
                        if ($foundIt) {
                            $script:CommandModuleLookup[$variableName] = $module
                            if ($foundIt -is [ScriptBlock]) {
                                $PSBoundParameters.InScript = "$foundIt"
                                & $MyInvocation.MyCommand.ScriptBlock @PSBoundParameters
                            }
                            $foundIt; break
                            }
                        }

                if (-not $foundCommand -and $AllowGlobal) {
                    $foundCommand = & $getVariableValue $variableName
                }
                $script:LookedUpCommands[$variableName] = $foundCommand
            }
            [PSCustomObject][Ordered]@{
                Name = $variableName
                ScriptBlock = $script:LookedUpCommands[$variableName]
                Module = $script:CommandModuleLookup[$variableName]
                FindInput = $in
            }
        }
}


    
