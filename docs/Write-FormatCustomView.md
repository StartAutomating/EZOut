
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
#### EXAMPLE 1
```PowerShell
Write-FormatCustomView -Action {  "This is a message from Process $pid" }
```

---
### Parameters
#### **Action**

The script block used to fill in the contents of a custom control.
The script block can either be an arbitrary script, which will be run, or it can include a
number of speicalized commands that will translate into parts of the formatter.



|Type                 |Requried|Postion|PipelineInput        |
|---------------------|--------|-------|---------------------|
|```[ScriptBlock[]]```|true    |1      |true (ByPropertyName)|
---
#### **Indent**

The indentation depth of the custom control



|Type         |Requried|Postion|PipelineInput        |
|-------------|--------|-------|---------------------|
|```[Int32]```|false   |2      |true (ByPropertyName)|
---
#### **AsControl**

If set, the content will be created as a control.  Controls can be reused by other formatters.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Name**

The name of the action



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[String]```|false   |3      |false        |
---
#### **VisibilityCondition**

The VisibilityCondition parameter is used to add a condition that will determine
if the content will be rendered.



|Type                 |Requried|Postion|PipelineInput|
|---------------------|--------|-------|-------------|
|```[ScriptBlock[]]```|false   |4      |false        |
---
#### **ViewTypeName**

If provided, the table view will only be used if the the typename is this value.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|false   |5      |true (ByPropertyName)|
---
#### **ViewSelectionSet**

If provided, the table view will only be used if the the typename is in a SelectionSet.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.



|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[String]```|false   |6      |true (ByPropertyName)|
---
#### **ViewCondition**

If provided, will selectively display items.
Must be used with -ViewSelectionSet and -ViewTypeName.
At least one view must have no conditions.



|Type               |Requried|Postion|PipelineInput        |
|-------------------|--------|-------|---------------------|
|```[ScriptBlock]```|false   |7      |true (ByPropertyName)|
---
### Syntax
```PowerShell
Write-FormatCustomView [-Action] <ScriptBlock[]> [[-Indent] <Int32>] [-AsControl] [[-Name] <String>] [[-VisibilityCondition] <ScriptBlock[]>] [[-ViewTypeName] <String>] [[-ViewSelectionSet] <String>] [[-ViewCondition] <ScriptBlock>] [<CommonParameters>]
```
---


