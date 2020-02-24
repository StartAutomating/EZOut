<#
.Synopsis
    Adds style to a format output
.Description
    Adds style information to a format output, including:

    * ForegroundColor
    * BackgroundColor
    * Bold
    * Underline
.Notes
    Stylized Output works in two contexts at present:
    * Rich consoles (Windows Terminal, PowerShell.exe, Pwsh.exe) (when $host.UI.SupportsVirtualTerminal)
    * Web pages (Based off the presence of a $Request variable, or when $host.UI.SupportsHTML (you must add this property to $host.UI))

    IsFormatPart: true
#>
param(
[string]$ForegroundColor,
[string]$BackgroundColor,
[switch]$Bold,
[switch]$Underline,
[switch]$Invert
)

$canUseANSI = $host.UI.SupportsVirtualTerminal
$canUseHTML = $Request -or $host.UI.SupportsHTML
if (-not ($canUseANSI -or $canUseHTML)) { return }

$n =0
$styleAttributes =
    @(foreach ($hc in $ForegroundColor,$BackgroundColor) {
        $n++
        if (-not $hc) { continue }
        if ($hc[0] -eq [char]0x1b) {
            if ($canUseANSI) { 
                $hc; continue
            }
        }
        if ($hc -and -not $hc.StartsWith('#')) {
            $placesToLook=
                @(if ($hc.Contains('.')) {
                    $module, $setting = $hc -split '\.', 2
                    $theModule = Get-Module $module
                    $theModule.PrivateData.Color,
                        $theModule.PrivateData.Colors,
                        $theModule.PrivateData.Colour,
                        $theModule.PrivateData.Colours,
                        $theModule.PrivateData.EZOut,
                        $global:PSColors,
                        $global:PSColours
                } else {
                    $setting = $hc
                    $moduleColorSetting = $theModule.PrivateData.PSColors.$setting
                })

            foreach ($place in $placesToLook) {
                if (-not $place) { continue }
                foreach ($propName in $setting -split '\.') {
                    $place = $place.$propName
                    if (-not $place) { break }
                }
                if ($place -and "$place".StartsWith('#') -and 4,7 -contains "$place".Length) {
                    $hc = $place
                    continue
                }
            }
            if (-not $hc.StartsWith -or -not $hc.StartsWith('#')) {
                continue
            }
        }
        $r,$g,$b = if ($hc.Length -eq 7) {
            [int]::Parse($hc[1..2]-join'', 'HexNumber')
            [int]::Parse($hc[3..4]-join '', 'HexNumber')
            [int]::Parse($hc[5..6] -join'', 'HexNumber')
        }elseif ($hc.Length -eq 4) {
            [int]::Parse($hc[1], 'HexNumber') * 16
            [int]::Parse($hc[2], 'HexNumber') * 16
            [int]::Parse($hc[3], 'HexNumber') * 16
        }

        if ($canUseHTML) {
            if ($n -eq 1) { "color:$hc" }
            elseif ($n -eq 2) { "background-color:$hc"} 
        }
        elseif ($canUseANSI) {
            if ($n -eq 1) { [char]0x1b+"[38;2;$r;$g;${b}m" }
            elseif ($n -eq 2) { [char]0x1b+"[48;2;$r;$g;${b}m" }
        }
        
    })


if ($Bold) {
    $styleAttributes += 
        if ($canUseHTML) {
            "font-weight:bold"
        }
        elseif ($canUseANSI) 
        {
            [char]0x1b + "[1m"
        }
}

if ($Underline) {
    $styleAttributes += 
        if ($canUseHTML) {
            "text-decoration:underline"
        } elseif ($canUseANSI) {
            [char]0x1b + "[4m"
        }
}

if ($Invert) {
    $styleAttributes += 
        if ($canUseHTML) {
            "filter:invert(100%)"
        } elseif ($canUseANSI) {
            [char]0x1b + "[7m"            
        }
}

if ($canUseHTML) {
    "<span style='$($styleAttributes -join ';')'>"
} elseif ($canUseANSI) {
    $styleAttributes -join ''
}