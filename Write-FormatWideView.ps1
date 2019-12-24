function Write-FormatWideView
{
    [CmdletBinding(DefaultParameterSetName='Property')]
    param(
    # The name of the property displayed in the wide view.
    [Parameter(Mandatory=$true,ParameterSetName='OfProperty',ValueFromPipelineByPropertyName=$true)]
    [string]$Property,

    # The script block displayed in the wide view.
    [Parameter(Mandatory=$true,ParameterSetName='OfScriptBlock',ValueFromPipelineByPropertyName=$true)]
    [ScriptBlock]$ScriptBlock,

    # The view type name.  This allows for a view to be displayed selectively, based off of a typename.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $ViewTypeName,

    # The view condition.  This allows for a view to be displayed selectively, based off of a condition.
    # This must be used with -ViewTypeName or -ViewSelectionSet.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ScriptBlock]
    $ViewCondition,

    # The View Selection Set.  This allows for a view to be displayed selectively, based of a selection set name.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $ViewSelectionSet,

    # If set, the view will be automatically sized.
    # This cannot be ignored if a ColumnCount is provided.
    [switch]
    $AutoSize,

    # The number of columns that will be displayed.
    # This will take override -AutoSize
    [Alias('Columns','ColumnNumber')]
    [int]
    $ColumnCount)

    begin {
        $accumulated = [Collections.ArrayList]::new()
    }
    process {
        $null = $accumulated.Add(@{} + $PSBoundParameters)
    }

    end {
        $xml = & {
        '<WideControl>'
        if ($ColumnCount) {
            "<ColumnNumber>$ColumnCount</ColumnNumber>"
        } elseif ($AutoSize) {
            '<AutoSize/>'
        }
        '<WideEntries>'
        foreach ($item in $accumulated) {
            '<WideEntry>'
            if ($item.ViewTypeName -or $item.ViewSelectionSet) {
                "<EntrySelectedBy>"
                if ($item.ViewCondition) {
                    "<SelectionCondition>"
                }
                foreach ($tn in $item.ViewTypeName) {
                    "<TypeName>$([Security.SecurityElement]::Escape($tn))</TypeName>"
                }
                foreach ($ssn in $item.ViewSelectionSet) {
                    "<SelectionSetName>$([Security.SecurityElement]::Escape($ssn))</SelectionSetName>"
                }
                if ($item.ViewCondition) {
                    "<ScriptBlock>$([Security.SecurityElement]::Escape($item.ViewCondition))</ScriptBlock>"
                    "</SelectionCondition>"
                }
                "</EntrySelectedBy>"
            }
            '<WideItem>'
            if ($item.Property) {
                '<PropertyName>'
                [Security.SecurityElement]::Escape($item.Property)
                '</PropertyName>'
            } elseif ($item.ScriptBlock) {
                '<ScriptBlock>'
                [Security.SecurityElement]::Escape($item.ScriptBlock)
                '</ScriptBlock>'
            }
            '</WideItem>'
            '</WideEntry>'
        }
        '</WideEntries>'
        '</WideControl>'
        }

        $xml = [xml]($xml -join '')

        if (-not $xml) { return }
        $xOut=[IO.StringWriter]::new()
        $xml.Save($xOut)
        "$xOut".Substring('<?xml version="1.0" encoding="utf-16"?>'.Length + [Environment]::NewLine.Length)
    }
}
