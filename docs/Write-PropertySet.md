Write-PropertySet
-----------------
### Synopsis
Writes a property set

---
### Description

Writes a property set.

Property sets are a way to conveniently access sets of properties on an object.

Instead of writing:

    Select-Object a,b,c,d

You can write:

    Select-Object mypropertyset

---
### Related Links
* [ConvertTo-PropertySet](ConvertTo-PropertySet.md)



* [Get-PropertySet](Get-PropertySet.md)



* [Out-TypeData](Out-TypeData.md)



* [Add-TypeData](Add-TypeData.md)



---
### Examples
#### EXAMPLE 1
```PowerShell
Write-PropertySet -typename System.IO.FileInfo -name filetimes -propertyname Name, LastAccessTime, CreationTime, LastWriteTime |
    Out-TypeData |
    Add-TypeData
```
dir | select filetimes
---
### Parameters
#### **TypeName**

The typename for the property set



> **Type**: ```[String]```

> **Required**: true

> **Position**: 1

> **PipelineInput**:true (ByPropertyName)



---
#### **Name**

The name of the property set



> **Type**: ```[String]```

> **Required**: true

> **Position**: 2

> **PipelineInput**:true (ByPropertyName)



---
#### **PropertyName**

The names of the properties to include in the property set



> **Type**: ```[String[]]```

> **Required**: true

> **Position**: 3

> **PipelineInput**:true (ByPropertyName)



---
### Syntax
```PowerShell
Write-PropertySet [-TypeName] <String> [-Name] <String> [-PropertyName] <String[]> [<CommonParameters>]
```
---
