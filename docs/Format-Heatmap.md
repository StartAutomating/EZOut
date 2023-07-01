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






|Type      |Required|Position|PipelineInput |
|----------|--------|--------|--------------|
|`[Object]`|false   |1       |true (ByValue)|



#### **HeatMapMax**

The Heatmap maximum, by default 1gb






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Object]`|true    |2       |false        |



#### **HeatMapMiddle**

The Heatmap middle value, by default 512mb






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Object]`|false   |3       |false        |



#### **HeatMapMin**

The Heatmap minimum value, by default 0






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Object]`|false   |4       |false        |



#### **HeatMapCool**

The color for cool.
To pass a Hex color as an int, simply replace # with 0x
(e.g. 0x00ff00 for green instead of '#00ff00')






|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |5       |false        |



#### **HeatMapHot**

The color for hot.
To pass a Hex color as an int, simply replace # with 0x
(e.g. 0xff0000 for red instead of '#ff0000')






|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |6       |false        |





---


### Syntax
```PowerShell
Format-Heatmap [[-InputObject] <Object>] [-HeatMapMax] <Object> [[-HeatMapMiddle] <Object>] [[-HeatMapMin] <Object>] [[-HeatMapCool] <Int32>] [[-HeatMapHot] <Int32>] [<CommonParameters>]
```
