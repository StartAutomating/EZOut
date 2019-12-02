function Write-FormatCustomView
{
    <#
    .Synopsis
        Writes the format XML for a custom view.
    .Description
        Writes the .format.ps1xml fragement for a custom control view, or a custom control.
    .Link
        Write-FormatViewExpression
    .Link
        Write-FormatView
    #>
    param(
    # The script block used to fill in the contents of a custom control.
    # The script block can either be an arbitrary script, which will be run, or it can include a
    # number of speicalized commands that will translate into parts of the formatter.
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('ScriptBlock')]
    [ScriptBlock[]]$Action,

    # The indentation depth of the custom control
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [int]$Indent,

    # If set, the content will be created as a control.  Controls can be reused by other formatters.
    [Switch]$AsControl,

    # The name of the action
    [String]$Name,

    # The VisibilityCondition parameter is used to add a condition that will determine
    # if the content will be rendered.
    [ScriptBlock[]]$VisibilityCondition = {},

    # If provided, the table view will only be used if the the typename is this value.
    # This is distinct from the overall typename, and can be used to have different table views for different inherited objects.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $ViewTypeName,

    # If provided, the table view will only be used if the the typename is in a SelectionSet.
    # This is distinct from the overall typename, and can be used to have different table views for different inherited objects.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $ViewSelectionSet,

    # If provided, will selectively display items.
    # Must be used with -ViewSelectionSet and -ViewTypeName.
    # At least one view must have no conditions.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ScriptBlock]
    $ViewCondition)


    begin {
        $entries = @()
    }
    process {
        $entrySelectedBy =
            if ($ViewTypeName -or $ViewSelectionSet) {
                "<EntrySelectedBy>"
                    if ($ViewCondition) {
                        "<SelectionCondition>"
                    }
                    if ($ViewTypeName) {
                        "<TypeName>$([Security.SecurityElement]::Escape($ViewTypeName))</TypeName>"
                    } else {
                        "<SelectionSetName>$([Security.SecurityElement]::Escape($ViewSelectionSet))</SelectionSetName>"
                    }
                    if ($viewCondition) {
                        "<ScriptBlock>$([Security.SecurityElement]::Escape($viewCondition))</ScriptBlock></SelectionCondition>"
                    }
                "</EntrySelectedBy>"
            } else {
                ''
            }



$header = @"
    <CustomEntry>
        $entrySelectedBy
        <CustomItem>
            $(if ($Indent) { "<Frame><LeftIndent>$Indent</LeftIndent><CustomItem>" } )

"@

$footer = @"
$(if ($indent) {"</CustomItem></Frame>"})
        </CustomItem>
    </CustomEntry>
"@


            $c =0
            $middle = foreach ($sb in $Action) {
                $VisibilityXml =""
                if ("$($VisibilityCondition[$c])") {
                    $VisibilityXml = "<ItemSelectionCondition><ScriptBlock>
$([Security.SecurityElement]::Escape($VisibilityCondition[$c]))
</ScriptBlock></ItemSelectionCondition>"
                }
                $c++
                $tokens = @([Management.Automation.PSParser]::Tokenize($sb, [ref]$null) |
                    Where-Object { "Comment", "NewLine" -notcontains $_.Type })
                Write-Verbose "$($tokens | Out-String)"
                if ($tokens.Count -eq 1) {
                    if ($tokens[0].Type -eq "Command" -and $tokens[0].Content -ieq "Write-Newline") {
                        "<NewLine />"
                    } elseif ($tokens[0].Type -eq "String") {
                        $content = $tokens[0].Content
                        # If the expanded size is the same as the original size, then the string most likely didn't
                        # contain expansion, and we can write out a text field instead
                        if (-not ($content.Contains('$'))) {
                            "<Text>$([Security.SecurityElement]::Escape($content))</Text>"
                        } else {
                            "<ExpressionBinding>
                                $VisibilityXml
                                <ScriptBlock>`"$([Security.SecurityElement]::Escape($content))`"</ScriptBlock>
                            </ExpressionBinding>"
                        }
                    } else {
                        "<ExpressionBinding>
                            $VisibilityXml
                            <ScriptBlock>$([Security.SecurityElement]::Escape($sb))</ScriptBlock>
                        </ExpressionBinding>"
                    }
                } elseif ($tokens[0].Type -eq "Command" -and 'Show-CustomAction','Write-FormatViewExpression' -contains $tokens[0].Content) {
                    & $MyInvocation.MyCommand.ScriptBlock.Module $sb
                } else {
                    "<ExpressionBinding>
                        $VisibilityXml
                        <ScriptBlock>$([Security.SecurityElement]::Escape($sb))</ScriptBlock>
                    </ExpressionBinding>"
                }
            }

        $entries += ( $header + $middle + $footer)
    }

    end {
        if (-not $AsControl) {
            "<CustomControl><CustomEntries>" + ($entries -join [Environment]::NewLine) + "</CustomEntries></CustomControl>"
        } else {
            if (-not $Name) {
                Write-Error "Custom Controls must be named"
                return
            }

            "<Control><Name>$Name</Name><CustomControl><CustomEntries>" +
                $($entries -join [Environment]::NewLine) +
            "</CustomEntries></CustomControl></Control>"
        }
    }
}
