Write-FormatWideView
--------------------

### Synopsis

Write-FormatWideView [-ViewTypeName <string>] [-ViewCondition <scriptblock>] [-ViewSelectionSet <string>] [-AutoSize] [-ColumnCount <int>] [<CommonParameters>]

Write-FormatWideView -Property <string> [-ViewTypeName <string>] [-ViewCondition <scriptblock>] [-ViewSelectionSet <string>] [-AutoSize] [-ColumnCount <int>] [<CommonParameters>]

Write-FormatWideView -ScriptBlock <scriptblock> [-ViewTypeName <string>] [-ViewCondition <scriptblock>] [-ViewSelectionSet <string>] [-AutoSize] [-ColumnCount <int>] [<CommonParameters>]

---

### Description

---

### Parameters
#### **AutoSize**

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[switch]`|false   |Named   |false        |

#### **ColumnCount**

|Type   |Required|Position|PipelineInput|Aliases                 |
|-------|--------|--------|-------------|------------------------|
|`[int]`|false   |Named   |false        |Columns<br/>ColumnNumber|

#### **Property**

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[string]`|true    |Named   |true (ByPropertyName)|

#### **ScriptBlock**

|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[scriptblock]`|true    |Named   |true (ByPropertyName)|

#### **ViewCondition**

|Type           |Required|Position|PipelineInput        |
|---------------|--------|--------|---------------------|
|`[scriptblock]`|false   |Named   |true (ByPropertyName)|

#### **ViewSelectionSet**

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[string]`|false   |Named   |true (ByPropertyName)|

#### **ViewTypeName**

|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[string]`|false   |Named   |true (ByPropertyName)|

---

### Inputs
System.String
System.Management.Automation.ScriptBlock

---

### Outputs
* [Object](https://learn.microsoft.com/en-us/dotnet/api/System.Object)

---

### Syntax
```PowerShell
syntaxItem
```
```PowerShell
----------
```
```PowerShell
{@{name=Write-FormatWideView; CommonParameters=True; parameter=System.Object[]}, @{name=Write-FormatWideView; CommonPar…
```
