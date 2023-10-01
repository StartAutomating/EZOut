ConvertTo-PropertySet
---------------------




### Synopsis
Converts Select-Object results to a property set



---


### Description

Converts Select-Object results to a named property set
Named property sets can be requested from a property



---


### Related Links
* [Out-TypeData](Out-TypeData.md)



* [Add-TypeData](Add-TypeData.md)





---


### Examples
> EXAMPLE 1

```PowerShell
Get-ChildItem |
    Select-Object Name, LastWriteTime, LastModifiedTime, CreationTime |
    ConvertTo-TypePropertySet -Name FileTimes |
    Out-TypeData |
    Add-TypeData
Get-ChildItem |
    Select-Object filetimes
```


---


### Parameters
#### **SelectedObject**

The output from Select-Object






|Type      |Required|Position|PipelineInput |
|----------|--------|--------|--------------|
|`[Object]`|true    |named   |true (ByValue)|



#### **Name**

The name of the selection set to create






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Object]`|true    |1       |false        |





---


### Outputs
* [String](https://learn.microsoft.com/en-us/dotnet/api/System.String)






---


### Syntax
```PowerShell
ConvertTo-PropertySet -SelectedObject <Object> [-Name] <Object> [<CommonParameters>]
```
