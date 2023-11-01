Out-Alternate
-------------




### Synopsis
Outputs alternate views



---


### Description

Outputs alternate views of an object or typename.

While it is possible to display multiple views of an object in PowerShell, it's not as straightforward to see what those views are.

Out-Alternate solves this problem, and is embeddable within a format file.



---


### Examples
> EXAMPLE 1

```PowerShell
Out-Alternate -TypeName "System.Diagnostics.Process"
```


---


### Parameters
#### **InputObject**

An input object.  If this is provided, it will infer the typenames






|Type        |Required|Position|PipelineInput |
|------------|--------|--------|--------------|
|`[PSObject]`|false   |1       |true (ByValue)|



#### **PSTypeName**

The typename of the alternate.
If this is not provided, it can be inferred from the `-InputObject`.






|Type        |Required|Position|PipelineInput|Aliases |
|------------|--------|--------|-------------|--------|
|`[String[]]`|false   |2       |false        |TypeName|



#### **CurrentView**

The name of the current view.
If this is provided, it will not be displayed as an alternate.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |3       |false        |



#### **Prefix**

A prefix to each view.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |4       |false        |



#### **Suffix**

A suffix to each view.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |5       |false        |



#### **NoPadding**

If set, will not padd the space between the name of the format control and the -View parameter






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **ModuleName**

The name of one or more modules.
If provided, will provide the -PS1XMLPath of each module's .ExportedFormatFiles






|Type        |Required|Position|PipelineInput|
|------------|--------|--------|-------------|
|`[String[]]`|false   |6       |false        |



#### **PS1XMLPath**

The path to one or more .ps1xml files.
If these are provided (or inferred thru -ModuleName), will look for alternates in PS1XML.






|Type        |Required|Position|PipelineInput|
|------------|--------|--------|-------------|
|`[String[]]`|false   |7       |false        |





---


### Syntax
```PowerShell
Out-Alternate [[-InputObject] <PSObject>] [[-PSTypeName] <String[]>] [[-CurrentView] <String>] [[-Prefix] <String>] [[-Suffix] <String>] [-NoPadding] [[-ModuleName] <String[]>] [[-PS1XMLPath] <String[]>] [<CommonParameters>]
```
