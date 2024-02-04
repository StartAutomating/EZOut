Write-FormatCustomView
----------------------

### Synopsis
Writes the format XML for a custom view.

---

### Description

Writes the .format.ps1xml fragement for a custom control view, or a custom control.

---

### Related Links
* [Write-FormatViewExpression](Write-FormatViewExpression.md)

* [Write-FormatView](Write-FormatView.md)

* [Write-FormatControl](Write-FormatControl.md)

---

### Examples
> EXAMPLE 1

```PowerShell
Write-FormatCustomView -Action {  "This is a message from Process $pid" }
```

---

### Parameters
#### **Action**
The script block used to fill in the contents of a custom control.
The script block can either be an arbitrary script, which will be run, or it can include a
number of speicalized commands that will translate into parts of the formatter.

|Type             |Required|Position|PipelineInput        |Aliases    |
|-----------------|--------|--------|---------------------|-----------|
|`[ScriptBlock[]]`|true    |1       |true (ByPropertyName)|ScriptBlock|

#### **Frame**
If set, will put the expression within a <Frame> element.

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|

#### **LeftIndent**
If provided, will indent by a number of characters.  This implies -Frame.

|Type     |Required|Position|PipelineInput        |Aliases|
|---------|--------|--------|---------------------|-------|
|`[Int32]`|false   |2       |true (ByPropertyName)|Indent |

#### **RightIndent**
If provided, will indent the right by a number of characters.  This implies -Frame.

|Type     |Required|Position|PipelineInput        |
|---------|--------|--------|---------------------|
|`[Int32]`|false   |3       |true (ByPropertyName)|

#### **FirstLineHanging**
Specifies how many characters the first line of data is shifted to the left.  This implies -Frame.

|Type     |Required|Position|PipelineInput        |
|---------|--------|--------|---------------------|
|`[Int32]`|false   |4       |true (ByPropertyName)|

#### **FirstLineIndent**
Specifies how many characters the first line of data is shifted to the right.  This implies -Frame.

|Type     |Required|Position|PipelineInput        |
|---------|--------|--------|---------------------|
|`[Int32]`|false   |5       |true (ByPropertyName)|

#### **AsControl**
If set, the content will be created as a control.  Controls can be reused by other formatters.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **Name**
The name of the action

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |6       |false        |

#### **VisibilityCondition**
The VisibilityCondition parameter is used to add a condition that will determine
if the content will be rendered.

|Type             |Required|Position|PipelineInput|
|-----------------|--------|--------|-------------|
|`[ScriptBlock[]]`|false   |7       |false        |

#### **ViewTypeName**
If provided, the table view will only be used if the the typename is this value.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |8       |true (ByPropertyName)|

#### **ViewSelectionSet**
If provided, the table view will only be used if the the typename is in a SelectionSet.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |9       |true (ByPropertyName)|

#### **ViewCondition**
If provided, will selectively display items.
Must be used with -ViewSelectionSet and -ViewTypeName.
At least one view must have no conditions.

|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[ScriptBlock]`|false   |10      |true (ByPropertyName)|

---

### Syntax
```PowerShell
Write-FormatCustomView [-Action] <ScriptBlock[]> [-Frame] [[-LeftIndent] <Int32>] [[-RightIndent] <Int32>] [[-FirstLineHanging] <Int32>] [[-FirstLineIndent] <Int32>] [-AsControl] [[-Name] <String>] [[-VisibilityCondition] <ScriptBlock[]>] [[-ViewTypeName] <String>] [[-ViewSelectionSet] <String>] [[-ViewCondition] <ScriptBlock>] [<CommonParameters>]
```
