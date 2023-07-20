function Format-RichText
{
    <#
    .Synopsis
        Formats the text color of output
    .Description
        Formats the text color of output

        * ForegroundColor
        * BackgroundColor
        * Bold
        * Underline
    .Notes
        Stylized Output works in two contexts at present:
        * Rich consoles (Windows Terminal, PowerShell.exe, Pwsh.exe) (when $host.UI.SupportsVirtualTerminal)
        * Web pages (Based off the presence of a $Request variable, or when $host.UI.SupportsHTML (you must add this property to $host.UI))
    #>
    [Management.Automation.Cmdlet("Format","Object")]
    [ValidateScript({
        $canUseANSI     = $host.UI.SupportsVirtualTerminal
        $canUseHTML     = $Request -or $host.UI.SupportsHTML -or $OutputMode -eq 'HTML'
        if (-not ($canUseANSI -or $canUseHTML)) { return $false}
        return $true
    })]
    [OutputType([string])]
    param(
    # The input object
    [Parameter(ValueFromPipeline)]
    [PSObject]
    $InputObject,
    
    # The foreground color
    [string]$ForegroundColor,

    # The background color
    [string]$BackgroundColor,

    # If set, will render as bold
    [switch]$Bold,

    # If set, will render as italic.
    [Alias('Italics')]
    [switch]$Italic,

    # If set, will render as faint
    [switch]$Faint,

    # If set, will render as hidden text.
    [switch]$Hide,

    # If set, will render as blinking (not supported in all terminals or HTML)
    [switch]$Blink,    

    # If set, will render as strikethru
    [Alias('Strikethrough', 'Crossout')]
    [switch]$Strikethru,

    # If set, will underline text
    [switch]$Underline,

    # If set, will double underline text.
    [switch]$DoubleUnderline,    

    # If set, will invert text
    [switch]$Invert,

    # If provided, will create a hyperlink to a given uri
    [Alias('Hyperlink', 'Href')]
    [uri]
    $Link,

    # If set, will not clear formatting
    [switch]$NoClear,

    # The alignment.  Defaulting to Left.
    # Setting an alignment will pad the remaining space on each line.
    [ValidateSet('Left','Right','Center')]
    [string]
    $Alignment,

    # The length of a line.  By default, the buffer width
    [int]$LineLength = $($host.UI.RawUI.BufferSize.Width)
    )    

    begin {
        $canUseANSI     = $host.UI.SupportsVirtualTerminal
        $canUseHTML     = $Request -or $host.UI.SupportsHTML -or $OutputMode -eq 'HTML'
        $knownStreams = @{
            Output='';Error='BrightRed';Warning='BrightYellow';
            Verbose='BrightCyan';Debug='Yellow';Progress='Cyan';
            Success='BrightGreen';Failure='Red';Default=''}

        $ansiCode = [Regex]::new(@'
        (?<ANSI_Code>
        (?-i)\e                                                                                   # An Escape
        \[                                                                                        # Followed by a bracket
        (?<ParameterBytes>[\d\:\;\<\=\>\?]{0,})                                                   # Followed by zero or more parameter  
        bytes
        (?<IntermediateBytes>[\s\!\"\#\$\%\&\'\(\)\*\+\,\-\.\/]{0,})                              # Followed by zero or more 
        intermediate bytes
        (?<FinalByte>[\@ABCDEFGHIJKLMNOPQRSTUVWXYZ\[\\\]\^_\`abcdefghijklmnopqrstuvwxyz\{\|\}\~]) # Followed by a final byte
        
        )                
'@)
        $esc = [char]0x1b
        $standardColors = 'Black', 'Red', 'Green', 'Yellow', 'Blue','Magenta', 'Cyan', 'White'
        $brightColors   = 'BrightBlack', 'BrightRed', 'BrightGreen', 'BrightYellow', 'BrightBlue','BrightMagenta', 'BrightCyan', 'BrightWhite'

        $allOutput      = @()

        $n =0
        $cssClasses = @()        
        $colorAttributes =         
            @(:nextColor foreach ($hc in $ForegroundColor,$BackgroundColor) {
                $n++
                if (-not $hc) { continue }
                if ($hc[0] -eq $esc) {
                    if ($canUseANSI) { 
                        $hc; continue
                    }
                }
        
                $ansiStartPoint = if ($n -eq 1) { 30 } else { 40 } 
                if ($knownStreams.ContainsKey($hc)) {
                    $i = $brightColors.IndexOf($knownStreams[$hc])
                    if ($canUseHTML) {
                        $cssClasses += $hc
                    } else {
                        if ($i -ge 0 -and $canUseANSI) {
                            '' + $esc + "[1;$($ansiStartPoint + $i)m"
                        } else {
                            $i = $standardColors.IndexOf($knownStreams[$hc])
                            if ($i -ge 0 -and $canUseANSI) {
                                '' + $esc + "[1;$($ansiStartPoint + $i)m"
                            } elseif ($i -le 0 -and $canUseANSI) {                        
                                '' + $esc + "[$($ansistartpoint + 8):5m"
                            }
                        }
                    }
                    continue nextColor
                }
                elseif ($standardColors -contains $hc) {
                    for ($i = 0; $i -lt $standardColors.Count;$i++) {
                        if ($standardColors[$i] -eq $hc) {
                            if ($canUseANSI -and -not $canUseHTML) {
                                '' + $esc + "[$($ansiStartPoint + $i)m"
                            } else {
                                $cssClasses += $standardColors[$i]
                            }
                            continue nextColor
                        }
                    }
                } elseif ($brightColors -contains $hc) {
                    for ($i = 0; $i -lt $brightColors.Count;$i++) {
                        if ($brightColors[$i] -eq $hc) {
                            if ($canUseANSI -and -not $canUseHTML) {
                                '' + $esc + "[1;$($ansiStartPoint + $i)m"
                            } else {
                                $cssClasses += $standardColors[$i]
                            }
                            continue nextColor
                        }
                    }
                }                
                elseif ($psStyle -and $psStyle.Formatting.$hc -and 
                    $psStyle.Formatting.$hc -match '^\e') {
                    if ($canUseANSI -and -not $canUseHTML) {
                        $psStyle.Formatting.$hc
                    } else {
                        $cssClasses += "formatting-$hc"
                    }
                }
                elseif (-not $n -and $psStyle -and $psStyle.Foreground.$hc -and 
                    $psStyle.Foreground.$hc -match '^\e' ) {
                    if ($canUseANSI -and -not $canUseHTML) {
                        $psStyle.Foreground.$hc
                    } else {
                        $cssClasses += "foreground-$hc"
                    }                   
                }
                elseif ($n -and $psStyle -and $psStyle.Background.$hc -and
                    $psStyle.Background.$hc -match '^\e') {
                    if ($canUseANSI -and -not $canUseHTML) {
                        $psStyle.Background.$hc
                    } else {
                        $cssClasses += "background-$hc"
                    }                    
                }

        
        
                if ($hc -and $hc -notmatch '^[\#\e]') {
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
                    if ($n -eq 1) { $esc+"[38;2;$r;$g;${b}m" }
                    elseif ($n -eq 2) { $esc+"[48;2;$r;$g;${b}m" }
                }
                
            })
        
        $styleAttributes = @() + $colorAttributes
        
        $styleAttributes += @(
            if ($Bold) {
                if ($canUseHTML) {"font-weight:bold"}
                elseif ($canUseANSI) { '' + $esc + "[1m" }
            }
            if ($Faint) {
                if ($canUseHTML) { "opacity:.5" }
                elseif ($canUseANSI) { '' + $esc + "[2m" }
            }
            if ($Italic) {                
                if ($canUseHTML) { "font-weight:bold" }
                elseif ($canUseANSI)  {'' + $esc + "[3m" }
            }
            
            if ($Underline -and -not $doubleUnderline) {             
                if ($canUseHTML) { "text-decoration:underline"} 
                elseif ($canUseANSI) {'' +$esc + "[4m" }
            }

            if ($Blink) {             
                if ($canUseANSI) { '' +$esc + "[5m" }
            }

            if ($invert) {
                if ($canUseHTML) {"filter:invert(100%)"}
                elseif ($canUseANSI) { '' + $esc + "[7m"}
            }

            if ($hide) {
                if ($canUseHTML) {"opacity:0"}
                elseif ($canUseANSI) { '' + $esc + "[8m"}
            }
            
            if ($Strikethru) {             
                if ($canUseHTML) {"text-decoration: line-through"}
                elseif ($canUseANSI) { '' +$esc + "[9m" }
            }
            
            if ($DoubleUnderline) {
                if ($canUseHTML) { "border-bottom: 3px double;"}
                elseif ($canUseANSI) {'' +$esc + "[21m" }
            }

            if ($Alignment -and $canUseHTML) {
                "display:block;text-align:$($Alignment.ToLower())"
            }

            if ($Link) {
                if ($canUseHTML) { 
                    # Hyperlinks need to be a nested element
                    # so we will not add it to style attributes for HTML
                }
                elseif ($canUseANSI) {
                    # For ANSI,
                    '' + $esc + ']8;;' + $Link + $esc + '\'   
                }
            }
            
        )
        
        $header =
            if ($canUseHTML) {        
                "<span$(
                    if ($styleAttributes) { " style='$($styleAttributes -join ';')'"}
                )$(
                    if ($cssClasses) { " class='$($cssClasses -join ' ')'"}
                )>" + $(
                    if ($Link) {
                        "<a href='$link'>"
                    }
                )
            } elseif ($canUseANSI) {
                $styleAttributes -join ''
            }
    }

    process {
        $inputObjectAsString =
            "$(if ($inputObject) { $inputObject | Out-String})".Trim()

        $inputObjectAsString = 
            if ($Alignment -and -not $canUseHTML) {
                (@(foreach ($inputObjectLine in ($inputObjectAsString -split '(?>\r\n|\n)')) {
                    $inputObjectLength = $ansiCode.Replace($inputObjectLine, '').Length
                    if ($inputObjectLength -lt $LineLength) {
                        if ($Alignment -eq 'Left') {
                            $inputObjectLine
                        } elseif ($Alignment -eq 'Right') {
                            (' ' * ($LineLength - $inputObjectLength)) + $inputObjectLine                            
                        } else {
                            $half = ($LineLength - $inputObjectLength)/2
                            (' ' * [Math]::Floor($half)) + $inputObjectLine +
                            (' ' * [Math]::Ceiling($half))
                        }
                    }
                    else {
                        $inputObjectLine
                    }
                }) -join [Environment]::NewLine) + [Environment]::newline
            } else {
                $inputObjectAsString
            }

        $allOutput +=
            if ($header) {
                "$header" + $inputObjectAsString
            }
            elseif ($inputObject) {
                $inputObjectAsString
            }
    }

    end {
        
        if (-not $NoClear) {
            $allOutput += 
                if ($canUseHTML) {
                    if ($Link) {
                        "</a>"
                    }
                    "</span>"
                }
                elseif ($canUseANSI) {
                    if ($Bold -or $Faint -or $colorAttributes -match '\[1;') {
                        "$esc[22m"
                    }
                    if ($Italic) {
                        "$esc[23m"
                    }
                    if ($Underline -or $doubleUnderline) {
                        "$esc[24m"
                    }
                    if ($Blink) {
                        "$esc[25m"
                    }                
                    if ($Invert) {
                        "$esc[27m"
                    }
                    if ($hide) {
                        "$esc[28m"
                    }
                    if ($Strikethru) {
                        "$esc[29m"
                    }
                    if ($ForegroundColor) {
                        "$esc[39m"
                    }
                    if ($BackgroundColor) {
                        "$esc[49m"
                    }

                    if ($Link) {
                        "$esc]8;;$esc\"
                    }
                
                    if (-not ($Underline -or $Bold -or $Invert -or $ForegroundColor -or $BackgroundColor)) {
                        '' + $esc + '[0m'
                    }
                }
        }

        $allOutput -join ''
    }
}
