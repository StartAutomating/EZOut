Format-Markdown
---------------
### Synopsis
Formats an object as Markdown

---
### Description

Formats an object as Markdown, with many options to work with

---
### Examples
#### EXAMPLE 1
```PowerShell
Format-Markdown -ScriptBlock {
    Get-Process
}
```

#### EXAMPLE 2
```PowerShell
1..6 | Format-Markdown  -HeadingSize { $_ }
```

---
### Parameters
#### **InputObject**

> **Type**: ```[PSObject]```

> **Required**: false

> **Position**: 1

> **PipelineInput**:true (ByValue, ByPropertyName)



---
#### **MarkdownParagraph**

If set, will treat the -InputObject as a paragraph.
This is the default for strings, booleans, numbers, and other primitive types.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **MarkdownTable**

If set, will generate a markdown table.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **MarkdownTableAlignment**

If provided, will align columnns in a markdown table.



Valid Values:

* Left
* Right
* Center
* 



> **Type**: ```[String[]]```

> **Required**: false

> **Position**: 2

> **PipelineInput**:true (ByPropertyName)



---
#### **Property**

An array of properties.  Providing this implies -MarkdownTable



> **Type**: ```[PSObject[]]```

> **Required**: false

> **Position**: 3

> **PipelineInput**:true (ByPropertyName)



---
#### **Heading**

A heading.
If provided without -HeadingSize, -HeadingSize will default to 2.
If provided with -InputObject, -Heading will take priority.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 4

> **PipelineInput**:true (ByPropertyName)



---
#### **HeadingSize**

The heading size (1-6)
If provided without -Heading, the -InputObject will be considered to be a heading.



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: 5

> **PipelineInput**:true (ByPropertyName)



---
#### **Link**

If set, will create a link.  The -InputObject will be used as the link content



> **Type**: ```[String]```

> **Required**: false

> **Position**: 6

> **PipelineInput**:true (ByPropertyName)



---
#### **ImageLink**

If set, will create an image link.  The -Inputobject will be used as the link content.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 7

> **PipelineInput**:true (ByPropertyName)



---
#### **BulletPoint**

If set, will generate a bullet point list.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Checkbox**

If set, bullet or numbered list items will have a checkbox.
Each piped -InputObject will be an additional list item.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Checked**

If set, bullet or numbered list items will be checked.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **NumberedList**

If set, will generate a numbered list.
Each piped -InputObject will be an additional list item.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **BlockQuote**

If set, will generate a block quote.
Each line of the -InputObject will be block quoted.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **BlockQuoteDepth**

If set, will generate a block quote of a particular depth.
Each line of the -InputObject will be block quoted.



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: 8

> **PipelineInput**:true (ByPropertyName)



---
#### **Number**

If provided, will create a markdown numbered list with this particular item as the number.



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: 9

> **PipelineInput**:true (ByPropertyName)



---
#### **HorizontalRule**

If set, will generate a horizontal rule.  
If other parameters are provided, the horiztonal rule will be placed after.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **Code**

If set, will output the -InputObject as a Markdown code block



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:true (ByPropertyName)



---
#### **CodeLanguage**

If set, will output the -InputObject as a Markdown code block, with a given language
If the -InputObject is a ScriptBlock, -CodeLanguage will be set to PowerShell.



> **Type**: ```[String]```

> **Required**: false

> **Position**: 10

> **PipelineInput**:true (ByPropertyName)



---
#### **ScriptBlock**

If provided, will output a script block as a Markdown code block.



> **Type**: ```[ScriptBlock]```

> **Required**: false

> **Position**: 11

> **PipelineInput**:true (ByPropertyName)



---
### Syntax
```PowerShell
Format-Markdown [[-InputObject] <PSObject>] [-MarkdownParagraph] [-MarkdownTable] [[-MarkdownTableAlignment] <String[]>] [[-Property] <PSObject[]>] [[-Heading] <String>] [[-HeadingSize] <Int32>] [[-Link] <String>] [[-ImageLink] <String>] [-BulletPoint] [-Checkbox] [-Checked] [-NumberedList] [-BlockQuote] [[-BlockQuoteDepth] <Int32>] [[-Number] <Int32>] [-HorizontalRule] [-Code] [[-CodeLanguage] <String>] [[-ScriptBlock] <ScriptBlock>] [<CommonParameters>]
```
---
