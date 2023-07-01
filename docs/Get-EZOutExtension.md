Get-EZOutExtension
------------------




### Synopsis
Gets Extensions



---


### Description

Gets Extensions.

EZOut Extensions can be found in:

* Any module that includes -ExtensionModuleName in it's tags.
* The directory specified in -ExtensionPath



---


### Examples
#### EXAMPLE 1
```PowerShell
Get-EZOutExtension
```



---


### Parameters
#### **ExtensionPath**

If provided, will look beneath a specific path for extensions.






|Type      |Required|Position|PipelineInput        |Aliases |
|----------|--------|--------|---------------------|--------|
|`[String]`|false   |1       |true (ByPropertyName)|Fullname|



#### **Force**

If set, will clear caches of extensions, forcing a refresh.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **CommandName**

If provided, will get EZOut Extensions that extend a given command






|Type        |Required|Position|PipelineInput        |Aliases            |
|------------|--------|--------|---------------------|-------------------|
|`[String[]]`|false   |2       |true (ByPropertyName)|ThatExtends<br/>For|



#### **ExtensionName**

The name of an extension






|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|false   |3       |true (ByPropertyName)|



#### **Like**

If provided, will treat -ExtensionName as a wildcard.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|



#### **Match**

If provided, will treat -ExtensionName as a regular expression.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|



#### **DynamicParameter**

If set, will return the dynamic parameters object of all the EZOut Extensions for a given command.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|



#### **CouldRun**

If set, will return if the extension could run






|Type      |Required|Position|PipelineInput        |Aliases|
|----------|--------|--------|---------------------|-------|
|`[Switch]`|false   |named   |true (ByPropertyName)|CanRun |



#### **Run**

If set, will run the extension.  If -Stream is passed, results will be directly returned.
By default, extension results are wrapped in a return object.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|



#### **Stream**

If set, will stream output from running the extension.
By default, extension results are wrapped in a return object.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|



#### **DynamicParameterSetName**

If set, will return the dynamic parameters of all EZOut Extensions for a given command, using the provided DynamicParameterSetName.
Implies -DynamicParameter.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |4       |true (ByPropertyName)|



#### **DynamicParameterPositionOffset**

If provided, will return the dynamic parameters of all EZOut Extensions for a given command, with all positional parameters offset.
Implies -DynamicParameter.






|Type     |Required|Position|PipelineInput        |
|---------|--------|--------|---------------------|
|`[Int32]`|false   |5       |true (ByPropertyName)|



#### **NoMandatoryDynamicParameter**

If set, will return the dynamic parameters of all EZOut Extensions for a given command, with all mandatory parameters marked as optional.
Implies -DynamicParameter.  Does not actually prevent the parameter from being Mandatory on the Extension.






|Type      |Required|Position|PipelineInput        |Aliases                     |
|----------|--------|--------|---------------------|----------------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|NoMandatoryDynamicParameters|



#### **ValidateInput**

If set, will validate this input against [ValidateScript], [ValidatePattern], [ValidateSet], and [ValidateRange] attributes found on an extension.






|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[PSObject]`|false   |6       |true (ByPropertyName)|



#### **AllValid**

If set, will validate this input against all [ValidateScript], [ValidatePattern], [ValidateSet], and [ValidateRange] attributes found on an extension.
By default, if any validation attribute returned true, the extension is considered validated.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **ParameterSetName**

The name of the parameter set.  This is used by -CouldRun and -Run to enforce a single specific parameter set.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |7       |true (ByPropertyName)|



#### **Parameter**

The parameters to the extension.  Only used when determining if the extension -CouldRun.






|Type           |Required|Position|PipelineInput        |Aliases                                                  |
|---------------|--------|--------|---------------------|---------------------------------------------------------|
|`[IDictionary]`|false   |8       |true (ByPropertyName)|Parameters<br/>ExtensionParameter<br/>ExtensionParameters|



#### **SteppablePipeline**

If set, will output a steppable pipeline for the extension.
Steppable pipelines allow you to control how begin, process, and end are executed in an extension.
This allows for the execution of more than one extension at a time.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Help**

If set, will output the help for the extensions






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **ParameterHelp**

If set, will get help about one or more parameters of an extension






|Type        |Required|Position|PipelineInput|
|------------|--------|--------|-------------|
|`[String[]]`|false   |9       |false        |



#### **Example**

If set, will get help examples






|Type      |Required|Position|PipelineInput|Aliases |
|----------|--------|--------|-------------|--------|
|`[Switch]`|false   |named   |false        |Examples|



#### **FullHelp**

If set, will output the full help for the extensions






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |





---


### Outputs
* Extension






---


### Syntax
```PowerShell
Get-EZOutExtension [[-ExtensionPath] <String>] [-Force] [[-CommandName] <String[]>] [[-ExtensionName] <String[]>] [-Like] [-Match] [-DynamicParameter] [-CouldRun] [-Run] [-Stream] [[-DynamicParameterSetName] <String>] [[-DynamicParameterPositionOffset] <Int32>] [-NoMandatoryDynamicParameter] [[-ValidateInput] <PSObject>] [-AllValid] [[-ParameterSetName] <String>] [[-Parameter] <IDictionary>] [-SteppablePipeline] [-Help] [[-ParameterHelp] <String[]>] [-Example] [-FullHelp] [<CommonParameters>]
```
