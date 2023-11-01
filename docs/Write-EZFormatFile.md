Write-EZFormatFile
------------------




### Synopsis
Creates a new EZFormat file.



---


### Description

Creates a new EZFormat file.  EZFormat files use EZOut to create format and types files for a module.



---


### Parameters
#### **Format**

Any -FormatView commands.






|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|false   |1       |true (ByPropertyName)|



#### **Type**

Any -TypeView commands.






|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|false   |2       |true (ByPropertyName)|



#### **ModuleName**

The name of the module.  By default, this will be inferred from the name of the file.






|Type      |Required|Position|PipelineInput        |Aliases|
|----------|--------|--------|---------------------|-------|
|`[String]`|false   |3       |true (ByPropertyName)|Name   |



#### **SourcePath**

The source path.  By default, the script's root.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |4       |true (ByPropertyName)|



#### **DestinationPath**

The destination path.  By default, the script's root.






|Type      |Required|Position|PipelineInput        |Aliases |
|----------|--------|--------|---------------------|--------|
|`[String]`|false   |5       |true (ByPropertyName)|DestPath|





---


### Syntax
```PowerShell
Write-EZFormatFile [[-Format] <String[]>] [[-Type] <String[]>] [[-ModuleName] <String>] [[-SourcePath] <String>] [[-DestinationPath] <String>] [<CommonParameters>]
```
