function Out-Mermaid
{
    <#
    .SYNOPSIS
        Outputs Mermaid
    .DESCRIPTION
        Outputs Mermaid Diagrams.
    .NOTES    
        This will also attempt to transform non-string objects into the appropriate input for a diagram.
    .EXAMPLE
        Out-Mermaid "flowchart TD
            Start --> Stop"
    .EXAMPLE
        [Ordered]@{
            title="Pets Adopted By Owners"
            Dogs=386
            Cats=85
            Rats=15
        } | 
            Out-Mermaid pie
    .EXAMPLE
        [Ordered]@{
            title = "A Gantt Diagram"
            dateFormat = "YYYY-MM-DD"
            "section Section" = [Ordered]@{
                "A task" = "a1,2014-01-01,30d"
                "Another Task" = "after a1, 20d"
            }
            "section Another" = [Ordered]@{
                "Task in Another" = "2014-01-12",'12d'
                "Another Task" =  "24d"
            }        
        } | Out-Mermaid -Diagram "gantt"
    .EXAMPLE
        '
        Alice->>John: Hello John, how are you?
        John-->>Alice: Great!
        Alice-)John: See you later!    
        '| 
        Out-Mermaid -Diagram sequenceDiagram     
    #>
    [Management.Automation.Cmdlet("Format","Object")]
    [CmdletBinding(PositionalBinding=$false)]
    param(
    # The mermaid diagram.
    [Parameter(Position=0)]
    [string]
    $Diagram,

    # Any input to the diagram.
    # This will be appended to the diagram definition.
    # This tries to serialize properties and arrays into their appropriate format in Mermaid.
    # Strings will be included inine.  Keys/values will be joined with either spaces or colons (depending on depth and type).
    [Parameter(ValueFromPipeline)]
    $InputObject,

    # If set, will include the Mermaid diagram within a `pre` element with the css class `mermaid`.
    [switch]
    $AsHtml,

    # If set, will not include either a markdown code fence or an HTML control around the Mermaid.
    [Alias('Sparse','Bare')]
    [switch]
    $Raw,

    # The String Value Separator (the value that separates a key from it's value).
    # If set, this will override any presumptions Out-Mermaid might make.
    [string]
    $StringValueSeparator = ''
    )

    begin {
        $accumulateInput = [Collections.Queue]::new()
        $recursiveDepth = 0
        foreach ($callstack in Get-PSCallStack) {
            if ($callstack.InvocationInfo.MyCommand.ScriptBlock -eq $MyInvocation.MyCommand.ScriptBlock) {
                $recursiveDepth++
            }
        }
        $mySelf =  $MyInvocation.MyCommand.ScriptBlock
    }

    process {
        if ($InputObject) {
            if ($InputObject -is [Collections.IDictionary]) {
                $accumulateInput.Enqueue([PSCustomObject]$InputObject)
            } else {
                $accumulateInput.Enqueue($InputObject)
            }
            
        }
    }

    end {
        if ($accumulateInput.Count) {
            if ($Diagram) {
                $Diagram += " "
            }
            $Diagram += 
                @(foreach ($acc in $accumulateInput.ToArray()) {
                    if ($acc -is [string]) {
                        # Include strings as is
                        $acc
                        ' ' # with a space after
                    } else {
                        # Otherwise, we're producing a series of nested elements
                        $propList = @($acc.psobject.properties)
                        for ($propIndex = 0 ;$propIndex -lt $propList.Length; $propIndex++) {                        
                            $prop = $propList[$propIndex]

                            if ($prop.Value -is [array]) {
                                if ($prop.Value -as [double[]]) {
                                    $prop.Name + ' ' + '[' + ($prop.Value -join ',') + ']'
                                } elseif ($(
                                    :AllInnerValuesAreStrings do {
                                        foreach ($innerValue in $prop.Value) {
                                            if ($innerValue -isnot [string]) {
                                                $false; break AllInnerValuesAreStrings
                                            }
                                        }
                                        $true
                                    } while ($false)
                                )) {
                                    $prop.Name + ':' + ($prop.Value -join ', ')
                                } else {

                                }
                            }
                            
                            elseif ( # If the values are not strings                                
                                $prop.Value -isnot [string] -and 
                                $prop.Value.GetType -and 
                                $prop.Value.GetType().IsPrimitive # (and are primitive types)
                            ) {
                                # Then we want to quote the name and put the value after a colon.
                                "`"$($prop.Name)`"" + ':' + $prop.Value
                            } elseif ($prop.Value -is [string]) {
                                # Otherwise, we want to include the name and the value.
                                if ($StringValueSeparator) {
                                    $prop.Name + $StringValueSeparator + $prop.Value
                                } elseif ($recursiveDepth -eq 1) {
                                    $prop.Name + ' ' + $prop.Value
                                } else {
                                    $prop.Name + ':' + $prop.Value
                                }                                
                            } else {
                                $prop.Name
                                [Environment]::NewLine
                                (' ' * 4 * ($recursiveDepth + 1))
                                & $mySelf -Raw -InputObject $prop.Value
                            }
                            [Environment]::NewLine
                            if ($propIndex + 1 -lt $propList.Length) {
                                (' ' * 4 * $recursiveDepth)
                            }
                        }
                    }
                }) -join ''
        }
        
        if ($Diagram) {
            if ($raw) {
                $Diagram
            }
            elseif ($AsHtml) {
                @('<pre class="mermaid">'
                $Diagram
                '</pre>') -join [Environment]::NewLine
            } 
            else {
                @('```mermaid'
                $Diagram
                '```') -join [Environment]::NewLine
            }
        }
    }
}
