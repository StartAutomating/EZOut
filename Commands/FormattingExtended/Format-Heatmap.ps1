function Format-Heatmap {
    <#
    .SYNOPSIS
        Formats a value as a heatmap
    .DESCRIPTION
        Returns the color used to generate a heatmap for a given value.
    #>
    [Management.Automation.Cmdlet("Format", "Object")]
    [ValidateScript({return $true})]
    param(
    # The value that will be heatmapped.
    [Parameter(ValueFromPipeline)]    
    $InputObject,
    
    # The Heatmap maximum, by default 1gb
    [Parameter(Mandatory)]    
    $HeatMapMax = 1gb,
    
    # The Heatmap middle value, by default 512mb
    $HeatMapMiddle = 512mb,
    
    # The Heatmap minimum value, by default 0
    $HeatMapMin = 0,
    
    # The color for cool.
    # To pass a Hex color as an int, simply replace # with 0x
    # (e.g. 0x00ff00 for green instead of '#00ff00') 
    [int]
    $HeatMapCool =0x05dd00,
    
    # The color for hot.
    # To pass a Hex color as an int, simply replace # with 0x
    # (e.g. 0xff0000 for red instead of '#ff0000') 
    [int]
    $HeatMapHot = 0xef1100
    )

    process {
        # Separate out the segments of the color,
        $coolRedPart = [byte](($HeatMapCool -band 0xff0000) -shr 16) # by bitmasking and then shifting right until it's bytes
        $coolGreenPart = [byte](($HeatMapCool -band 0x00ff00) -shr 8)
        $coolBluePart = [byte]($HeatMapCool -band 0x0000ff)

        $hotRedPart = [byte](($HeatMapHot  -band 0xff0000) -shr 16)
        $hotGreenPart = [byte](($HeatMapHot -band 0x00ff00) -shr 8)
        $hotBluePart = [byte]($HeatMapHot -band 0x0000ff)

        "#{0:x2}{1:x2}{2:x2}" -f @(
        if ($InputObject -le $HeatMapMin) 
        {
            $coolRedPart, $coolGreenPart, $coolBluePart
        }
        elseif ($InputObject -ge $HeatMapMax) 
        {
            $hotRedPart, $hotGreenPart, $hotBluePart
        } else {
            if ($InputObject -le $HeatMapMiddle) 
            {
                $d = 1 - ([double]$InputObject / ($HeatMapMiddle - $HeatMapMin))
                [Byte][Math]::Min(255, $hotRedPart * $d + $coolRedPart)
                [Byte][Math]::Min(255, $hotGreenPart * $d + $coolGreenPart)            
                [Byte][Math]::Min(255, $hotBluePart * $d + $coolBluePart)
            } else
            {
                $d = 1 - ([double]$InputObject / ($HeatMapMax - $HeatMapMiddle))
                [Byte][Math]::Min(255, $coolRedPart * $d + $hotRedPart)
                [Byte][Math]::Min(255, $coolGreenPart * $d + $hotGreenPart)            
                [Byte][Math]::Min(255, $coolBluePart * $d + $hotBluePart)
            }
        })
    }
}
