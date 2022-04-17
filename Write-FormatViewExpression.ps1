function Write-FormatViewExpression
{
    <#
    .Synopsis
        Writes a Format XML View Expression
    .Description
        Writes an expression for a Format .PS1XML.
        Expressions are used by custom format views and controls to conditionally display content.
    .Example
        Write-FormatViewExpression -ScriptBlock {
            "hello world"
        }
    .Example
        Write-FormatViewExpression -If { $_.Complete } -ScriptBlock { "Complete" }
    .Example
        Write-FormatViewExpression -Text 'Hello World'
    .Example
        # This will render the property 'Name' property of the underlying object
        Write-FormatViewExpression -Property Name
    .Example
        # This will render the property 'Status' of the current object,
        # if the current object's 'Complete' property is $false.
        Write-FormatViewExpression -Property Status -If { -not $_.Complete }

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
    [Parameter(Mandatory,ParameterSetName='Text',ValueFromPipelineByPropertyName=$true)]
    [string]
    $Text,

    # If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.
    [Parameter(Mandatory,ParameterSetName='LocalizedText',ValueFromPipelineByPropertyName)]
    [string]
    $AssemblyName,

    # If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.
    [Parameter(Mandatory,ParameterSetName='LocalizedText',ValueFromPipelineByPropertyName)]
    [string]
    $BaseName,

    # If -AssemblyName, -BaseName, and -ResourceID are provided, localized text resources will be outputted.
    [Parameter(Mandatory,ParameterSetName='LocalizedText',ValueFromPipelineByPropertyName)]
    [string]
    $ResourceID,

    # If provided, will output a <NewLine /> element.  All other parameters are ignored.
    [Parameter(Mandatory=$true,ParameterSetName='NewLine',ValueFromPipelineByPropertyName=$true)]
    [switch]
    $Newline,

    # If set, will bold the -Text, -Property, or -ScriptBlock.
    # This is only valid in consoles that support ANSI terminals ($host.UI.SupportsVirtualTerminal),
    # or while rendering HTML
    [switch]
    $Bold,

    # If set, will underline the -Text, -Property, or -ScriptBlock.
    # This is only valid in consoles that support ANSI terminals, or in HTML
    [switch]
    $Underline,

    # If set, will invert the -Text, -Property, -or -ScriptBlock
    # This is only valid in consoles that support ANSI terminals, or in HTML.
    [switch]
    $Invert,

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
    # Colors can be:
    # * An RGB color
    # * The name of a color stored in a .Colors section of a .PrivateData in a manifest
    # * The name of a Standard Concole Color
    # * The name of a PowerShell stream, e.g. Output, Warning, Debug, etc 
    [Alias('FG', 'ForegroundColour')]
    [string]
    $ForegroundColor,

    # If provided, will display the content using the given background color.
    # This will only be displayed on hosts that support rich color.
    # Colors can be:
    # * An RGB color
    # * The name of a color stored in a .Colors section of a .PrivateData in a manifest
    # * The name of a Standard Concole Color
    # * The name of a PowerShell stream, e.g. Output, Warning, Debug, etc
    [Alias('BG', 'BackgroundColour')]
    [string]
    $BackgroundColor,

    # The number of times the item will be displayed.
    # With script blocks, the variables $N and $Number will be set to indicate the current iteration.
    [ValidateRange(1,10kb)]
    [uint32]
    $Count = 1)

    process {
        # If this is calling itself recursively in ScriptBlock
        if ($ScriptBlock -and $ScriptBlock -like "*$($MyInvocation.MyCommand.Name)*") {
            & $ScriptBlock # run the script and return.
            return
        }

        if ($Newline) {
            foreach ($n in 1..$Count) {
                "<NewLine/>"
            }
            return
        }

        foreach ($n in 1..$count) {
            if ($ForegroundColor -or $BackgroundColor -or $Bold -or $Underline) {                
                $colorize = [ScriptBlock]::Create("@(Format-RichText $(@(
                    if ($ForegroundColor) {
                        "-ForegroundColor '$ForeGroundColor'"
                    }
                    if ($BackgroundColor) {
                        "-BackgroundColor '$BackgroundColor'"
                    }
                    if ($Bold) { '-Bold' }
                    if ($Underline) { '-Underline'}
                    if ($Invert) { '-Invert' }
                    '-NoClear'
                ) -join ' ')) -join ''")
                Write-FormatViewExpression -ScriptBlock $colorize
            }
            $ControlChunk = if ($ControlName) { "<CustomControlName>$([Security.SecurityElement]::Escape($ControlName))</CustomControlName>" }
            $EnumerationChunk = if ($Enumerate) { '<EnumerateCollection/>' } else { '' }
            $formatChunk = if ($FormatString) { "<FormatString>$([Security.SecurityElement]::Escape($FormatString))</FormatString>"}

            if ($Text) {
                "<Text>$([Security.SecurityElement]::Escape($Text))</Text>"
            } 
            elseif ($AssemblyName -and $BaseName -and $ResourceID) {
                "<Text AssemblyName='$AssemblyName' BaseName='$BaseName' ResourceId='$ResourceID' />"
            }
            else {
                if ($Count -gt 1 -and $PSBoundParameters.ContainsKey('ScriptBlock')) {
                    $ScriptBlock = [ScriptBlock]::Create("`$n = `$number = $n;
$($PSBoundParameters['ScriptBlock'])
")
                }

    $formatExpression = @"
<ExpressionBinding>
    $(if ($If) {
        if ($count -gt 1) {
            $if = [ScriptBlock]::Create("`$n = `$number = $n;
$if")
        }
        "<ItemSelectionCondition><ScriptBlock>$([Security.SecurityElement]::Escape($if))</ScriptBlock></ItemSelectionCondition>"
    })
    $(if ($Property) { "<PropertyName>$([Security.SecurityElement]::Escape($Property))</PropertyName>" })
    $(if ($ScriptBlock) { "<ScriptBlock>$([Security.SecurityElement]::Escape($ScriptBlock))</ScriptBlock>"})
    $EnumerationChunk
    $formatChunk
    $ControlChunk
</ExpressionBinding>
"@

                $xml = [xml]$formatExpression
                if (-not $xml) { return }
                $xOut=[IO.StringWriter]::new()
                $xml.Save($xOut)
                "$xOut".Substring('<?xml version="1.0" encoding="utf-16"?>'.Length + [Environment]::NewLine.Length)
                $xOut.Dispose()
            }
            if ($ForegroundColor -or $BackgroundColor -or $Bold -or $Underline -or $Invert) {

                Write-FormatViewExpression -ScriptBlock ([ScriptBlock]::Create(($colorize -replace '-NoClear')))
            }
        }
    }
}
