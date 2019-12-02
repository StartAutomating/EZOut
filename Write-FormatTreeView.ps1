function Write-FormatTreeView
{
    <#
    .Synopsis
        Writes the format XML for a TreeView
    .Description
        Writes the .format.ps1xml fragement for a tree view, or a tree node.
    .Link
        Write-FormatCustomView
    .Link
        Write-FormatViewExpression
    .Example
        Write-FormatTreeView -TypeName System.IO.FileInfo, System.IO.DirectoryInfo -NodeProperty Name -HasChildren {
            if (-not $_.EnumerateFiles) { return $false }
            foreach ($f in $_.EnumerateFiles()) {$f;break}
        },
        {
            if (-not $_.EnumerateDirectories) { return $false }
            foreach ($f in $_.EnumerateDirectories()) {$f;break}
        } -Children {
            $_.EnumerateFiles()
        }, {
            foreach ($d in $_.EnumerateDirectories()) {
                if ($d.Attributes -band 'Hidden') { continue }
                $d
            }
        } -Branch ('' + [char]9500 + [char]9472 + [char]9472) -Trunk '|  ' |
            Out-FormatData |
            Add-FormatData

        Get-Module EZOut | Split-Path | Get-Item | Format-Custom
    #>
    param(
    # One or more properties to be displayed.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateScript({
        foreach ($i in $_) {
            if ($i -isnot [string] -and $i -isnot [ScriptBlock] -and $i -isnot [Collections.IDictionary]) {
                throw "Properties must be a [string], [scriptblock], [collections.IDictionary]"
            }
        }
        return $true
    })]
    [Alias('NodeProperty')]
    [PSObject[]]
    $Property,

    # The separator between one or more properties.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Separator,


    # The Tree View's branch.
    # This text will be displayed before the node.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Branch = '',
    # The Tree View's Trunk.
    # This will be displayed once per depth.
    # By default, this is four blank spaces.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Trunk = '    ',

    # One or more type names.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string[]]
    $TypeName,

    # The name of the selection set.  Selection sets are an alternative way to specify a list of types.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('SelectionSetName')]
    [string]
    $SelectionSet,

    # The name of the tree node control.
    # If not provided, this will be Typename1/TypeName2.TreeNode or SelectionSet.TreeNode
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $ControlName,

    # If provided, the table view will only be used if the the typename includes this value.
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
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ScriptBlock]
    $ViewCondition,

    # Text displayed at the end of each branch.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $EndBranch,

    # A script block displayed at the end of each branch.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ScriptBlock]
    $EndBranchScript,

    # A set of script blocks that determine if the node has children.
    # If these script blocks return a value (that is not 0 or $false),
    # then the associated Children scriptblock will be called.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ScriptBlock[]]
    $HasChildren,

    # A set of script blocks to populate the next generation of nodes.
    # By default, the values returned from these script blocks will become child ndoes
    # of the same type of tree control.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ScriptBlock[]]
    $Children,

    # If provided, child nodes will be rendered with a different custom custom control.
    # This control must exist in the same format file.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string[]]
    $ChildNodeControl)


    begin {
        $allOut = @()
    }

    process {
        $allOut += @(
        '<CustomEntry>'
        if ($ViewSelectionSet -or $ViewTypeName) {
            '<EntrySelectedBy>'
            if ($ViewCondition) {
                '<SelectionCondition>'
            }
            if ($ViewTypeName) {
                "<TypeName>$([Security.SecurityElement]::Escape($ViewTypeName))</TypeName>"
            } elseif ($ViewSelectionSet) {
                "<SelectionSetName>$([Security.SecurityElement]::Escape($ViewSelectionSet))</SelectionSetName>"
            }
            if ($ViewCondition) {
                if ($viewCondition) {
                    "<ScriptBlock>$([Security.SecurityElement]::Escape($viewCondition))</ScriptBlock></SelectionCondition>"
                }
            }
            '</EntrySelectedBy>'
        }
        '<CustomItem>'
        Write-FormatViewExpression -ScriptBlock ([ScriptBLock]::Create(@"
`$Branch,`$trunk = '$($Branch.Replace("'","''"))', '$($trunk.Replace("'","''"))'
if (`$script:treeDepth) {
    [Environment]::Newline + (`$trunk * `$script:TreeDepth)+ `$Branch
} else {
    `$Branch
}
`$script:TreeDepth++;
"@))
#

        if ($Property) {
            @(foreach ($p in $Property) {
                if ($p -is [string]) {
                    Write-FormatViewExpression -Property $P
                } elseif ($p -is [ScriptBlock]) {
                    Write-FormatViewExpression -ScriptBlock $p
                } elseif ($p -is [Collections.IDictionary]) {
                    Write-FormatViewExpression @p
                }
            }) -join "<Text>$([Security.SecurityElement]::Escape($Separator))</Text>"
        }

        if ($Children) {
            for ($i =0 ;$i -lt $Children.Count;$i++) {
                if ("$($HasChildren[$i])") {
                    $theChildControl = if ($ChildNodeControl) {
                        if ($ChildNodeControl[$i]) {
                            $ChildNodeControl[$i]
                        } else {
                            $ChildNodeControl[-1]
                        }
                    } elseif ($controlName) {
                        $controlName
                    } elseif ($TypeName) {
                        "$($TypeName -join '/').TreeNode"
                    } elseif ($SelectionSet) {
                        "$SelectionSet.TreeNode"
                    }
                    Write-FormatViewExpression -If $HasChildren[$i] -ScriptBlock $Children[$i] -Enumerate -ActionName $theChildControl
                }
            }
        }

        if ($EndBranch) {
            "<Text>$([Security.SecurityElement]::Escape($EndBranch))</Text>"
        } elseif ($EndBranchScript) {
            Write-FormatViewExpression -ScriptBlock $EndBranchScript
        }

        @'
        <ExpressionBinding>
            <ItemSelectionCondition><ScriptBlock>$script:TreeDepth--;</ScriptBlock></ItemSelectionCondition>
            <ScriptBlock>$null</ScriptBlock>
        </ExpressionBinding>
</CustomItem></CustomEntry>
'@
        )
    }

    end {
        $ControlName = if (-not $ControlName) {
            if ($TypeName) {
                "$($TypeName -join '/').TreeNode"
            } elseif ($SelectionSet) {
                "$SelectionSet.TreeNode"
            }
        } else {
            $ControlName
        }
        if (-not $ControlName) {
            Write-Error "Must Provide a Control Name, TypeName, or SelectionSetName"
            return
        }
        $xmlStr=  @("<Control><Name>$([Security.SecurityElement]::Escape($ControlName))</Name>
<CustomControl>
<CustomEntries>
$($allOut -join '')
</CustomEntries>
</CustomControl></Control>")
        $xml=[xml]$xmlStr
        if (-not $xml) { return }
        $xOut=[IO.StringWriter]::new()
        $xml.Save($xOut)
        "$xOut".Substring('<?xml version="1.0" encoding="utf-16"?>'.Length + 2)
        $xOut.Dispose()
        $rootStart = if ($TypeName) {
            "<View>
                <Name>$([Security.SecurityElement]::Escape(($TypeName -join '/')))</Name>
                <ViewSelectedBy>
                $(foreach ($t in $typename) { "<TypeName>$([Security.SecurityElement]::Escape($t))</TypeName>"})
                </ViewSelectedBy>
            "
        } elseif ($SelectionSet) {
            "<View>
                <Name>$($SelectionSet)</Name>
                <ViewSelectedBy>
                $(foreach ($t in $SelectionSet) { "<SelectionSet>$([Security.SecurityElement]::Escape($t))</SelectionSet>"})
                </ViewSelectedBy>
            "
        }

        if ($rootStart) {
            $restOfView = $rootStart +  "
<CustomControl>
<CustomEntries>
    <CustomEntry>
        <CustomItem>
            $(Write-FormatViewExpression -If ([ScriptBlock]::Create('$script:TreeDepth = 0;$true')) -ScriptBlock ([ScriptBlock]::Create('$_')) -ActionName $ControlName -Enumerate)
            $(Write-FormatViewExpression -If ([ScriptBlock]::Create('$executionContext.SessionState.PSVariable.Remove("script:TreeDepth");$false')) -ScriptBlock ([ScriptBlock]::Create('$null')))
        </CustomItem>
    </CustomEntry>
</CustomEntries>
</CustomControl>
</View>"


            $xml=[xml]$restOfView
            if (-not $xml) { return }
            $xOut=[IO.StringWriter]::new()
            $xml.Save($xOut)
            "$xOut".Substring('<?xml version="1.0" encoding="utf-16"?>'.Length + 2)
            $xOut.Dispose()
        }

    }
}