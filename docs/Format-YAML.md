
Format-YAML
-----------
### Synopsis
Formats objects as YAML

---
### Description

Formats an object as YAML.

---
### Examples
#### EXAMPLE 1
```PowerShell
Format-Yaml -InputObject @("a", "b", "c")
```

#### EXAMPLE 2
```PowerShell
@{a="b";c="d";e=@{f=@('g')}} | Format-Yaml
```

---
### Parameters
#### **inputObject**

The InputObject.



|Type            |Requried|Postion|PipelineInput |
|----------------|--------|-------|--------------|
|```[PSObject]```|false   |1      |true (ByValue)|
---
#### **YamlHeader**

If set, will make a YAML header by adding a YAML Document tag above and below output.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
### Syntax
```PowerShell
Format-YAML [[-inputObject] <PSObject>] [-YamlHeader] [<CommonParameters>]
```
---


