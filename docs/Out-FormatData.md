
Out-FormatData
--------------
### Synopsis
Takes a series of format views and format actions and outputs a format data XML

---
### Description

A Detailed Description of what the command does

---
### Examples
#### EXAMPLE 1
```PowerShell
# Create a quick view for any XML element.
# Piping it into Out-FormatData will make one or more format views into a full format XML file
# Piping the output of that into Add-FormatData will create a temporary module to hold the formatting data
# There's also a Remove-FormatData and
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



> **Type**: ```[XmlDocument]```

> **Required**: true

> **Position**: 1

> **PipelineInput**:true (ByValue)



---
#### **ModuleName**

The name of the module the format.ps1xml applies to.
This is required if you are using colors.
This is required if you use any dynamic parts (named script blocks stored a /Parts) directory.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 2

> **PipelineInput**:false



---
### Outputs
System.String


---
### Syntax
```PowerShell
Out-FormatData [-FormatXml] <XmlDocument> [[-ModuleName] <String>] [<CommonParameters>]
```
---


