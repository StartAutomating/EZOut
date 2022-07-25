
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

|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[switch]```|false   |Named  |false        |
---
#### **ColumnCount**

|Type       |Requried|Postion|PipelineInput|
|-----------|--------|-------|-------------|
|```[int]```|false   |Named  |false        |
---
#### **Property**

|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[string]```|true    |Named  |true (ByPropertyName)|
---
#### **ScriptBlock**

|Type               |Requried|Postion|PipelineInput        |
|-------------------|--------|-------|---------------------|
|```[scriptblock]```|true    |Named  |true (ByPropertyName)|
---
#### **ViewCondition**

|Type               |Requried|Postion|PipelineInput        |
|-------------------|--------|-------|---------------------|
|```[scriptblock]```|false   |Named  |true (ByPropertyName)|
---
#### **ViewSelectionSet**

|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[string]```|false   |Named  |true (ByPropertyName)|
---
#### **ViewTypeName**

|Type          |Requried|Postion|PipelineInput        |
|--------------|--------|-------|---------------------|
|```[string]```|false   |Named  |true (ByPropertyName)|
---
### Inputs
System.String
System.Management.Automation.ScriptBlock


---
### Outputs
System.Object


---
### Syntax
```PowerShell
[32;1msyntaxItem[0m
```
```PowerShell
[32;1m----------[0m
```
```PowerShell
{@{name=Write-FormatWideView; CommonParameters=True; parameter=System.Object[]}, @{name=Write-FormatWideView; CommonPar…
```
---


