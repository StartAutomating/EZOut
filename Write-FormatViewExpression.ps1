function Write-FormatViewExpression
{
    <#
    .Synopsis
        Writes a Format XML View Expression
    .Description
        Writes an expression for a Format .PS1XML.
        Expressions are used by custom format views and controls to conditionally display content.
    #>
    [CmdletBinding(DefaultParameterSetName='ScriptBlock')]
    [OutputType([string])]
    param(
    # The name of the control.  If this is provided, it will be used to display the property or script block.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('ActionName','Name')]
    [String]
    $ControlName,
    
    # If a property name is provided, then the custom action will show the contents
    # of the property
    [Parameter(Mandatory=$true,ParameterSetName='Property',Position=0,ValueFromPipelineByPropertyName=$true)]
    [Alias('PropertyName')]
    [String]
    $Property,
        
    # If a script block is provided, then the custom action shown in formatting
    # will be the result of the script block.            
    [Parameter(Mandatory=$true,ParameterSetName='ScriptBlock',Position=0,ValueFromPipelineByPropertyName=$true)]
    [ScriptBlock]
    $ScriptBlock,

    # If provided, will make the expression conditional.  -If it returns a value, the script block will run 
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('ItemSelectionCondition')]
    [ScriptBlock]
    $If,

    # If provided, will output the provided text.  All other parameters are ignored.
    [Parameter(Mandatory=$true,ParameterSetName='Text',ValueFromPipelineByPropertyName=$true)]
    [string]
    $Text,

    # If provided, will output a <NewLine /> element.  All other parameters are ignored.
    [Parameter(Mandatory=$true,ParameterSetName='NewLine',ValueFromPipelineByPropertyName=$true)]
    [switch]
    $Newline,


    # If provided, will output the format using this format string.
    [string]
    $FormatString,
    
    # If this is set, collections will be enumerated.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('EnumerateCollection')]
    [Switch]
    $Enumerate,
        
    # If provided, will display the content using the given foreground color.
    # This will only be displayed on hosts that support rich color.

    [Alias('FG', 'ForegroundColour')]
    [string]
    $ForegroundColor,

    # If provided, will display the content using the given background color.
    # This will only be displayed on hosts that support rich color.
    [Alias('BG', 'BackgroundColour')]
    [string]
    $BackgroundColor)
    
    process {
        # If this is calling itself recursively in ScriptBlock 
        if ($ScriptBlock -and $ScriptBlock -like "*$($MyInvocation.MyCommand.Name)*") {
            & $ScriptBlock # run the script and return.
            return
        }

        if ($Text) {
            return "<Text>$([Security.SecurityElement]::Escape($Text))</Text>"
        }
        if ($Newline) {
            return "<NewLine/>"
        }
         
        if ($ForegroundColor -or $BackgroundColor) {
            @(
                if ($ForegroundColor) {"<!-- color:$ForegroundColor -->"}
                if ($BackgroundColor) {"<!-- background-color:$BackgroundColor -->"}
                $colorize = [ScriptBlock]::Create("`$ci = '$ForegroundColor', '$BackgroundColor';" + $ConvertCiToEscapeSequence + ';$ci -join ""')
                Write-FormatViewExpression -If ([ScriptBlock]::Create('$host.ui.SupportsVirtualTerminal')) -ScriptBlock $colorize
            ) -join ''
}
$ControlChunk = if ($ControlName) { "<CustomControlName>$([Security.SecurityElement]::Escape($ControlName))</CustomControlName>" }
$EnumerationChunk = if ($Enumerate) { '<EnumerateCollection/>' } else { '' }
$formatChunk = if ($FormatString) { "<FormatString>$([Security.SecurityElement]::Escape($FormatString))</FormatString>"}

@"
<ExpressionBinding>
    $(if ($If) {
        "<ItemSelectionCondition><ScriptBlock>$([Security.SecurityElement]::Escape($if))</ScriptBlock></ItemSelectionCondition>"
    })
    $(if ($Property) { "<PropertyName>$([Security.SecurityElement]::Escape($Property))</PropertyName>" })
    $(if ($ScriptBlock) { "<ScriptBlock>$([Security.SecurityElement]::Escape($ScriptBlock))</ScriptBlock>"})
    $EnumerationChunk
    $formatChunk
    $ControlChunk    
</ExpressionBinding>
"@

if ($ForegroundColor -or $BackgroundColor) {
    $(if ($ForegroundColor) {"<!-- color:unset -->"}) +
    $(if ($BackgroundColor) {"<!-- background-color:unset -->"}) +
    $(Write-FormatViewExpression -If ([ScriptBlock]::Create('$host.ui.SupportsVirtualTerminal')) -ScriptBlock ([ScriptBlock]::Create('@([char]0x1b + "[39m" + [char]0x1b + "[49m") -join ""')))
}
    }
}
