
Format-Hashtable
----------------
### Synopsis
Takes an creates a script to recreate a hashtable

---
### Description

Allows you to take a hashtable and create a hashtable you would embed into a script.

Handles nested hashtables and indents nested hashtables automatically.

---
### Related Links
* [about_hash_tables](about_hash_tables.md)
---
### Examples
#### EXAMPLE 1
```PowerShell
# Corrects the presentation of a PowerShell hashtable
[Ordered]@{Foo='Bar';Baz='Bing';Boo=@{Bam='Blang'}} | Format-Hashtable
```

---
### Parameters
#### **InputObject**

The hashtable or PSObject that will be written as a PowerShell Hashtable



|Type            |Requried|Postion|PipelineInput                 |
|----------------|--------|-------|------------------------------|
|```[PSObject]```|false   |1      |true (ByValue, ByPropertyName)|
---
#### **AsScriptBlock**

Returns the content as a script block, rather than a string



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **AsPSObject**

If set, will return the hashtable and all nested hashtables as custom objects.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Sort**

If set, items in the hashtable will be sorted alphabetically



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **ExpandCredential**

If set, credentials will be expanded out into a hashtable containing the username and password.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Compress**

If set, the outputted hashtable will not contain any extra whitespace.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Safe**

If set, will embed ScriptBlocks as literal strings,
so that the resulting hashtable could work in data language mode.



|Type          |Requried|Postion|PipelineInput|
|--------------|--------|-------|-------------|
|```[Switch]```|false   |named  |false        |
---
#### **Depth**

The maximum depth to enumerate.
Beneath this depth, items will simply be returned as $null.



|Type         |Requried|Postion|PipelineInput|
|-------------|--------|-------|-------------|
|```[Int32]```|false   |named  |false        |
---
### Outputs
[string]


[ScriptBlock]


---
### Syntax
```PowerShell
Format-Hashtable [[-InputObject] <PSObject>] [-AsScriptBlock] [-AsPSObject] [-Sort] [-ExpandCredential] [-Compress] [-Safe] [-Depth <Int32>] [<CommonParameters>]
```
---


