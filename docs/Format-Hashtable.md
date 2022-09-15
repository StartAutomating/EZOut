
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
[Ordered]@{Foo=&#39;Bar&#39;;Baz=&#39;Bing&#39;;Boo=@{Bam=&#39;Blang&#39;}} | Format-Hashtable
```

---
### Parameters
#### **InputObject**

The hashtable or PSObject that will be written as a PowerShell Hashtable



> **Type**: ```[PSObject]```

> **Required**: false

> **Position**: 1

> **PipelineInput**:true (ByValue, ByPropertyName)



---
#### **AsScriptBlock**

Returns the content as a script block, rather than a string



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **AsPSObject**

If set, will return the hashtable and all nested hashtables as custom objects.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Sort**

If set, items in the hashtable will be sorted alphabetically



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **ExpandCredential**

If set, credentials will be expanded out into a hashtable containing the username and password.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Compress**

If set, the outputted hashtable will not contain any extra whitespace.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Safe**

If set, will embed ScriptBlocks as literal strings,
so that the resulting hashtable could work in data language mode.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Depth**

The maximum depth to enumerate.
Beneath this depth, items will simply be returned as $null.



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
### Outputs
[string]


[ScriptBlock]


---
### Syntax
```PowerShell
Format-Hashtable [[-InputObject] &lt;PSObject&gt;] [-AsScriptBlock] [-AsPSObject] [-Sort] [-ExpandCredential] [-Compress] [-Safe] [-Depth &lt;Int32&gt;] [&lt;CommonParameters&gt;]
```
---


