<#
.Synopsis
    Heatmaps a value
.Description
    Determines the appropriate temperature color of a value, given a -Cool and -Hot color (passed as ints)
.Notes
    IsFormatPart: true
#>
param(
# The value that will be heatmapped.
$Value,

# The maximum, by default 1gb
[Parameter(Mandatory)]
$Max = 1gb,

# The middle value, by default 512mb
$Middle = 512mb,

# The minimum value, by default 0
$Min = 0,

# The color for cool.
# To pass a Hex color as an int, simply replace # with 0x
# (e.g. 0x00ff00 for green instead of '#00ff00') 
[int]
$Cool =0x05dd00,

# The color for hot.
# To pass a Hex color as an int, simply replace # with 0x
# (e.g. 0xff0000 for red instead of '#ff0000') 
[int]
$Hot = 0xef1100
)

# Separate out the segments of the color,
$coolRedPart = [byte](($Cool -band 0xff0000) -shr 16) # by bitmasking and then shifting right until it's bytes
$coolGreenPart = [byte](($Cool -band 0x00ff00) -shr 8)
$coolBluePart = [byte]($Cool -band 0x0000ff)

$hotRedPart = [byte](($hot -band 0xff0000) -shr 16)
$hotGreenPart = [byte](($hot -band 0x00ff00) -shr 8)
$hotBluePart = [byte]($hot -band 0x0000ff)

"#{0:x2}{1:x2}{2:x2}" -f @(

if ($Value -le $Min) 
{
    $coolRedPart, $coolGreenPart, $coolBluePart
}
elseif ($Value -ge $Max) 
{
    $hotRedPart, $hotGreenPart, $hotBluePart
} else {
    if ($Value -le $Middle) 
    {
        $d = 1 - ([double]$value / ($Middle - $min))
        [Byte][Math]::Min(255, $hotRedPart * $d + $coolRedPart)
        [Byte][Math]::Min(255, $hotGreenPart * $d + $coolGreenPart)            
        [Byte][Math]::Min(255, $hotBluePart * $d + $coolBluePart)
    } else
    {
        $d = 1 - ([double]$value / ($Max - $Middle))
        [Byte][Math]::Min(255, $coolRedPart * $d + $hotRedPart)
        [Byte][Math]::Min(255, $coolGreenPart * $d + $hotGreenPart)            
        [Byte][Math]::Min(255, $coolBluePart * $d + $hotBluePart)
    }
}
)