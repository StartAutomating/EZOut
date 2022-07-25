
Remove-TypeData
---------------
### Synopsis
Removes Type information from the current session.

---
### Description

The Remove-TypeData command removes the Typeting data for the current session.

---
### Parameters
#### **ModuleName**

The name of the Type module.  If there is only one type name,then
this is the name of the module.



|Type          |Requried|Postion|PipelineInput |
|--------------|--------|-------|--------------|
|```[String]```|true    |named  |true (ByValue)|
---
### Syntax
```PowerShell
Remove-TypeData -ModuleName <String> [<CommonParameters>]
```
---
Remove-TypeData
---------------
### Synopsis

Remove-TypeData -TypeData <TypeData> [-WhatIf] [-Confirm] [<CommonParameters>]

Remove-TypeData [-TypeName] <string> [-WhatIf] [-Confirm] [<CommonParameters>]

Remove-TypeData -Path <string[]> [-WhatIf] [-Confirm] [<CommonParameters>]


---
### Description
---
### Related Links
* [https://go.microsoft.com/fwlink/?LinkID=2096622](https://go.microsoft.com/fwlink/?LinkID=2096622)
---
### Parameters
#### **Confirm**
-Confirm is an automatic variable that is created when a command has ```[CmdletBinding(SupportsShouldProcess)]```.
-Confirm is used to -Confirm each operation.
    
If you pass ```-Confirm:$false``` you will not be prompted.
    
    
If the command sets a ```[ConfirmImpact("Medium")]``` which is lower than ```$confirmImpactPreference```, you will not be prompted unless -Confirm is passed.

#### **Path**

|Type            |Requried|Postion|PipelineInput|
|----------------|--------|-------|-------------|
|```[string[]]```|true    |Named  |false        |
---
#### **TypeData**

|Type            |Requried|Postion|PipelineInput |
|----------------|--------|-------|--------------|
|```[TypeData]```|true    |Named  |true (ByValue)|
---
#### **TypeName**

|Type          |Requried|Postion|PipelineInput                 |
|--------------|--------|-------|------------------------------|
|```[string]```|true    |0      |true (ByValue, ByPropertyName)|
---
#### **WhatIf**
-WhatIf is an automatic variable that is created when a command has ```[CmdletBinding(SupportsShouldProcess)]```.
-WhatIf is used to see what would happen, or return operations without executing them
---
### Inputs
System.String
System.Management.Automation.Runspaces.TypeData


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
{@{name=Remove-TypeData; CommonParameters=True; parameter=System.Object[]}, @{name=Remove-TypeData; CommonParameters=Tr…
```
---


