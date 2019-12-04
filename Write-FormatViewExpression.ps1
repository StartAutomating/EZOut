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
    [ValidateScript({$_.StartsWith('#') -and 4,7 -contains $_.Length})]
    [Alias('FG')]
    [string]
    $ForegroundColor,

    # If provided, will display the content using the given background color.
    # This will only be displayed on hosts that support rich color.
    [ValidateScript({$_.StartsWith('#') -and 4,7 -contains $_.Length})]
    [Alias('BG')]
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
            $n =0    
            $ci =@(foreach ($hc in $ForegroundColor,$BackgroundColor) {
                if (-not $hc) { continue }
                if (-not $hc.StartsWith('#')) { continue }
                $r,$g,$b = if ($hc.Length -eq 7) {
                    [int]::Parse($hc[1..2]-join'', 'HexNumber')
                    [int]::Parse($hc[3..4]-join '', 'HexNumber')
                    [int]::Parse($hc[5..6] -join'', 'HexNumber')
                }elseif ($hc.Length -eq 4) {
                    [int]::Parse($hc[1], 'HexNumber') * 16
                    [int]::Parse($hc[2], 'HexNumber') * 16
                    [int]::Parse($hc[3], 'HexNumber') * 16
                }                                            
                if ($n) { "[48;2;$r;$g;${b}m" }
                else { "[38;2;$r;$g;${b}m" }                
                $n++
                if ($n -eq 2) { break }
            })

            $colorInstructions = 
                @(foreach ($i in $ci) {
                    "'' + [char]0x1b+'$i'"
                }) -join '+'

            @(
                if ($ForegroundColor) {"<!-- color:$ForegroundColor -->"}
                if ($BackgroundColor) {"<!-- background-color:$BackgroundColor -->"}
                Write-FormatViewExpression -If ([ScriptBlock]::Create('$host.ui.SupportsVirtualTerminal')) -ScriptBlock ([ScriptBlock]::Create($colorInstructions))
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
