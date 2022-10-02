
Write-FormatTreeView
--------------------
### Synopsis
Writes the format XML for a TreeView

---
### Description

Writes the .format.ps1xml fragement for a tree view, or a tree node.

---
### Related Links
* [Write-FormatCustomView](Write-FormatCustomView.md)



* [Write-FormatViewExpression](Write-FormatViewExpression.md)



---
### Examples
#### EXAMPLE 1
```PowerShell
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
```
Get-Module EZOut | Split-Path | Get-Item | Format-Custom
---
### Parameters
#### **Property**

One or more properties to be displayed.



> **Type**: ```[PSObject[]]```

> **Required**: false

> **Position**: 1

> **PipelineInput**:true (ByPropertyName)



---
#### **Separator**

The separator between one or more properties.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 2

> **PipelineInput**:true (ByPropertyName)



---
#### **Branch**

The Tree View's branch.
This text will be displayed before the node.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 3

> **PipelineInput**:true (ByPropertyName)



---
#### **Trunk**

The Tree View's Trunk.
This will be displayed once per depth.
By default, this is four blank spaces.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 4

> **PipelineInput**:true (ByPropertyName)



---
#### **TypeName**

One or more type names.



> **Type**: ```[String[]]```

> **Required**: false

> **Position**: 5

> **PipelineInput**:true (ByPropertyName)



---
#### **SelectionSet**

The name of the selection set.  Selection sets are an alternative way to specify a list of types.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 6

> **PipelineInput**:true (ByPropertyName)



---
#### **ControlName**

The name of the tree node control.
If not provided, this will be Typename1/TypeName2.TreeNode or SelectionSet.TreeNode



> **Type**: ```[String]```

> **Required**: false

> **Position**: 7

> **PipelineInput**:true (ByPropertyName)



---
#### **ViewTypeName**

If provided, the table view will only be used if the the typename includes this value.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 8

> **PipelineInput**:true (ByPropertyName)



---
#### **ViewSelectionSet**

If provided, the table view will only be used if the the typename is in a SelectionSet.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 9

> **PipelineInput**:true (ByPropertyName)



---
#### **ViewCondition**

If provided, will selectively display items.



> **Type**: ```[ScriptBlock]```

> **Required**: false

> **Position**: 10

> **PipelineInput**:true (ByPropertyName)



---
#### **EndBranch**

Text displayed at the end of each branch.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 11

> **PipelineInput**:true (ByPropertyName)



---
#### **EndBranchScript**

A script block displayed at the end of each branch.



> **Type**: ```[ScriptBlock]```

> **Required**: false

> **Position**: 12

> **PipelineInput**:true (ByPropertyName)



---
#### **HasChildren**

A set of script blocks that determine if the node has children.
If these script blocks return a value (that is not 0 or $false),
then the associated Children scriptblock will be called.



> **Type**: ```[ScriptBlock[]]```

> **Required**: false

> **Position**: 13

> **PipelineInput**:true (ByPropertyName)



---
#### **Children**

A set of script blocks to populate the next generation of nodes.
By default, the values returned from these script blocks will become child ndoes
of the same type of tree control.



> **Type**: ```[ScriptBlock[]]```

> **Required**: false

> **Position**: 14

> **PipelineInput**:true (ByPropertyName)



---
#### **ChildNodeControl**

If provided, child nodes will be rendered with a different custom custom control.
This control must exist in the same format file.



> **Type**: ```[String[]]```

> **Required**: false

> **Position**: 15

> **PipelineInput**:true (ByPropertyName)



---
### Syntax
```PowerShell
Write-FormatTreeView [[-Property] <PSObject[]>] [[-Separator] <String>] [[-Branch] <String>] [[-Trunk] <String>] [[-TypeName] <String[]>] [[-SelectionSet] <String>] [[-ControlName] <String>] [[-ViewTypeName] <String>] [[-ViewSelectionSet] <String>] [[-ViewCondition] <ScriptBlock>] [[-EndBranch] <String>] [[-EndBranchScript] <ScriptBlock>] [[-HasChildren] <ScriptBlock[]>] [[-Children] <ScriptBlock[]>] [[-ChildNodeControl] <String[]>] [<CommonParameters>]
```
---


