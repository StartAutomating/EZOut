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






|Type             |Required|Position|PipelineInput|
|-----------------|--------|--------|-------------|
|`[ScriptBlock[]]`|false   |1       |false        |



#### **Type**

Any -TypeView commands.






|Type             |Required|Position|PipelineInput|
|-----------------|--------|--------|-------------|
|`[ScriptBlock[]]`|false   |2       |false        |



#### **ModuleName**

The name of the module.  By default, this will be inferred from the name of the file.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |3       |false        |



#### **SourcePath**

The source path.  By default, the script's root.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |4       |false        |



#### **DestinationPath**

The destination path.  By default, the script's root.






|Type      |Required|Position|PipelineInput|Aliases |
|----------|--------|--------|-------------|--------|
|`[String]`|false   |5       |false        |DestPath|





---


### Syntax
```PowerShell
Write-EZFormatFile [[-Format] <ScriptBlock[]>] [[-Type] <ScriptBlock[]>] [[-ModuleName] <String>] [[-SourcePath] <String>] [[-DestinationPath] <String>] [<CommonParameters>]
```
