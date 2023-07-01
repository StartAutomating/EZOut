Write-FormatControl
-------------------




### Synopsis
Writes the Format XML for a Control



---


### Description

Writes the .format.ps1xml for a custom control.  Custom Controls can be reused throughout the formatting file.



---


### Related Links
* [Write-FormatCustomView](Write-FormatCustomView.md)





---


### Examples
#### EXAMPLE 1



---


### Parameters
#### **Name**

The name of the control






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|true    |1       |true (ByPropertyName)|



#### **Action**

The script block used to fill in the contents of a custom control.


The script block can either be an arbitrary script, which will be run,
or it can contain a series of Write-FormatViewExpression commands.

If the ScriptBlock contains Write-FormatViewExpression,
code in between Write-FormatViewExpression will not be included in the formatter






|Type           |Required|Position|PipelineInput        |Aliases                      |
|---------------|--------|--------|---------------------|-----------------------------|
|`[ScriptBlock]`|true    |2       |true (ByPropertyName)|ScriptBlock<br/>DefaultAction|





---


### Syntax
```PowerShell
Write-FormatControl [-Name] <String> [-Action] <ScriptBlock> [<CommonParameters>]
```
