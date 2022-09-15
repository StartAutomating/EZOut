
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
Write-FormatCustomView -Action {  &quot;This is a message from Process $pid&quot; }
```

---
### Parameters
#### **Action**

The script block used to fill in the contents of a custom control.
The script block can either be an arbitrary script, which will be run, or it can include a
number of speicalized commands that will translate into parts of the formatter.



> **Type**: ```[ScriptBlock[]]```

> **Required**: true

> **Position**: 1

> **PipelineInput**:true (ByPropertyName)



---
#### **Indent**

The indentation depth of the custom control



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: 2

> **PipelineInput**:true (ByPropertyName)



---
#### **AsControl**

If set, the content will be created as a control.  Controls can be reused by other formatters.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Name**

The name of the action



> **Type**: ```[String]```

> **Required**: false

> **Position**: 3

> **PipelineInput**:false



---
#### **VisibilityCondition**

The VisibilityCondition parameter is used to add a condition that will determine
if the content will be rendered.



> **Type**: ```[ScriptBlock[]]```

> **Required**: false

> **Position**: 4

> **PipelineInput**:false



---
#### **ViewTypeName**

If provided, the table view will only be used if the the typename is this value.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 5

> **PipelineInput**:true (ByPropertyName)



---
#### **ViewSelectionSet**

If provided, the table view will only be used if the the typename is in a SelectionSet.
This is distinct from the overall typename, and can be used to have different table views for different inherited objects.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 6

> **PipelineInput**:true (ByPropertyName)



---
#### **ViewCondition**

If provided, will selectively display items.
Must be used with -ViewSelectionSet and -ViewTypeName.
At least one view must have no conditions.



> **Type**: ```[ScriptBlock]```

> **Required**: false

> **Position**: 7

> **PipelineInput**:true (ByPropertyName)



---
### Syntax
```PowerShell
Write-FormatCustomView [-Action] &lt;ScriptBlock[]&gt; [[-Indent] &lt;Int32&gt;] [-AsControl] [[-Name] &lt;String&gt;] [[-VisibilityCondition] &lt;ScriptBlock[]&gt;] [[-ViewTypeName] &lt;String&gt;] [[-ViewSelectionSet] &lt;String&gt;] [[-ViewCondition] &lt;ScriptBlock&gt;] [&lt;CommonParameters&gt;]
```
---


