function Out-Gum {
<#
.Synopsis
    Outputs using Gum
.Description
    
    Allows you to format objects using [CharmBraclet's Gum](https://github.com/charmbracelet/gum).
    
.Example
    'live', 'die' | Out-Gum choose
.Example
    'What is best in life?' | Out-Gum -Command input
.Link
    https://github.com/charmbraclet/gum
#>
[CmdletBinding(PositionalBinding=$false)]
[Management.Automation.Cmdlet("Format", "Object")]
[Alias("gum")]
param(
<#
The Command in Gum.
|CommandName|Description|
|-|-|
|choose|Choose an option from a list of choices|
|confirm|Ask a user to confirm an action|
|file|Pick a file from a folder|
|filter|Filter items from a list|
|format|Format a string using a template|
|input|Prompt for some input|
|join|Join text vertically or horizontally|
|pager|Scroll through a file|
|spin|Display spinner while running a command|
|style|Apply coloring, borders, spacing to text|
|table|Render a table of data|
|write|Prompt for long-form text|
#>
[Parameter(Mandatory,Position=0)]
[ValidateSet('choose','confirm','file','filter','format','input','join','pager','spin','style','table','write')]
[String]
$Command,
# The input object.
[Parameter(ValueFromPipeline)]
[Management.Automation.PSObject]
$InputObject,
# Any additional arguments to gum (and any remaining arguments)
[Parameter(ValueFromRemainingArguments)]
[Alias('GumArguments')]
[String[]]
$GumArgument
)
begin {
   
$isPipedFrom=$($myInvocation.PipelinePosition -lt $myInvocation.PipelineLength)
 $accumulateInput = [Collections.Queue]::new()
}
process {
    if ($inputObject) {
        $accumulateInput.Enqueue($inputObject)
    }
}
end {
    $gumCmd = $ExecutionContext.SessionState.InvokeCommand.GetCommand('gum', 'Application')
    if (-not $gumCmd) {
        Write-Error "Gum not installed"
        return
    }
    #region Fix Gum Arguments
    $allGumArgs = @(
        foreach ($gumArg in $gumArgument) {
            # Fix single dashing / slashing parameter convention.
            if ($gumArg -match '^[-/]\w') {
                $gumArg -replace '^[-/]', '--'
            } else {
                $gumArg
            }
        }
    )
    #endregion Fix Gum Arguments
    Write-Verbose "Calling gum with $allGumArgs"
    if ($accumulateInput.Count) {
        $MustConvert = $false
        $filteredInput = @(
        foreach ($inputObject in $accumulateInput) {
            if (-not $inputObject.GetType) { continue } 
            if ($inputObject -is [string] -or $inputObject.IsPrimitive) {
                $inputObject
            } else {
                $MustConvert = $true
                $inputObject
            }
        })
        if ($MustConvert) {
            $filteredInput = $filteredInput | ConvertTo-Csv
        }
        if ($isPipedFrom) {
            $gumOutput = $filteredInput | & $gumCmd $Command @allGumArgs
            $gumOutput
        } else {
            $filteredInput | & $gumCmd $Command @allGumArgs
        }
    } else {
        if ($isPipedFrom) {
            $gumOutput = $filteredInput | & $gumCmd $Command @allGumArgs
            $gumOutput
        } else {
            & $gumCmd $Command @allGumArgs
        }
    }
}
} 

