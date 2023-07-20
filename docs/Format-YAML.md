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
#### **InputObject**

The InputObject.






|Type        |Required|Position|PipelineInput |
|------------|--------|--------|--------------|
|`[PSObject]`|false   |1       |true (ByValue)|



#### **YamlHeader**

If set, will make a YAML header by adding a YAML Document tag above and below output.






|Type      |Required|Position|PipelineInput|Aliases     |
|----------|--------|--------|-------------|------------|
|`[Switch]`|false   |named   |false        |YAMLDocument|



#### **Indent**




|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |2       |false        |



#### **Depth**

The maximum depth of objects to include.
Beyond this depth, an empty string will be returned.






|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |3       |false        |





---


### Syntax
```PowerShell
Format-YAML [[-InputObject] <PSObject>] [-YamlHeader] [[-Indent] <Int32>] [[-Depth] <Int32>] [<CommonParameters>]
```
