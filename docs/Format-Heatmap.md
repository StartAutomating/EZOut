
Format-Heatmap
--------------
### Synopsis
Formats a value as a heatmap

---
### Description

Returns the color used to generate a heatmap for a given value.

---
### Parameters
#### **InputObject**

The value that will be heatmapped.



> **Type**: ```[Object]```

> **Required**: false

> **Position**: 1

> **PipelineInput**:true (ByValue)



---
#### **HeatMapMax**

The Heatmap maximum, by default 1gb



> **Type**: ```[Object]```

> **Required**: true

> **Position**: 2

> **PipelineInput**:false



---
#### **HeatMapMiddle**

The Heatmap middle value, by default 512mb



> **Type**: ```[Object]```

> **Required**: false

> **Position**: 3

> **PipelineInput**:false



---
#### **HeatMapMin**

The Heatmap minimum value, by default 0



> **Type**: ```[Object]```

> **Required**: false

> **Position**: 4

> **PipelineInput**:false



---
#### **HeatMapCool**

The color for cool.
To pass a Hex color as an int, simply replace # with 0x
(e.g. 0x00ff00 for green instead of '#00ff00')



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: 5

> **PipelineInput**:false



---
#### **HeatMapHot**

The color for hot.
To pass a Hex color as an int, simply replace # with 0x
(e.g. 0xff0000 for red instead of '#ff0000')



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: 6

> **PipelineInput**:false



---
### Syntax
```PowerShell
Format-Heatmap [[-InputObject] <Object>] [-HeatMapMax] <Object> [[-HeatMapMiddle] <Object>] [[-HeatMapMin] <Object>] [[-HeatMapCool] <Int32>] [[-HeatMapHot] <Int32>] [<CommonParameters>]
```
---


