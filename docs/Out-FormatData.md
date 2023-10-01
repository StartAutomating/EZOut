Out-FormatData
--------------




### Synopsis
Takes a series of format views and format actions and outputs a format data XML



---


### Description

A Detailed Description of what the command does



---


### Examples
Create a quick view for any XML element.
Piping it into Out-FormatData will make one or more format views into a full format XML file
Piping the output of that into Add-FormatData will create a temporary module to hold the formatting data
There's also a Remove-FormatData and

```PowerShell
Write-FormatView -TypeName "System.Xml.XmlNode" -Wrap -Property "Xml" -VirtualProperty @{
    "Xml" = {
        $strWrite = New-Object IO.StringWriter
        ([xml]$_.Outerxml).Save($strWrite)
        "$strWrite"
    }
} |
    Out-FormatData
```


---


### Parameters
#### **FormatXml**

The Format XML Document.  The XML document can be supplied directly,
but it's easier to use Write-FormatView to create it






|Type           |Required|Position|PipelineInput |
|---------------|--------|--------|--------------|
|`[XmlDocument]`|true    |1       |true (ByValue)|



#### **ModuleName**

The name of the module the format.ps1xml applies to.
This is required if you are using colors.
This is required if you use any dynamic parts (named script blocks stored a /Parts) directory.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |





---


### Outputs
* [String](https://learn.microsoft.com/en-us/dotnet/api/System.String)






---


### Syntax
```PowerShell
Out-FormatData [-FormatXml] <XmlDocument> [[-ModuleName] <String>] [<CommonParameters>]
```
