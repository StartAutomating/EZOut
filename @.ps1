#region Splatter [ 0.4 ] : Simple Scripts to Supercharge Splatting (Install-Module Splatter, then Initialize-Splatter -Verb Get,Use )

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="This Declares Variables for Other Scripts")]
param()
${?@}=${GetSplat}=${gSplat}={
    <#
    .Synopsis
        Gets a splat
    .Description
        Gets a splat for a command
    .Link
        Find-Splat
    .Link
        Use-Splat
    .Example
        @{id=$pid} | Get-Splat
    .Example
        @{id=$Pid} | ?@ # ?@ is an alias for Get-Splat
    .Example
        @{id=$pid} | & ${?@} # Get-Splat as a script block
    #>
    param(
    # The command that is being splatted.
    [Parameter(Mandatory=$true,Position=0)]
    [PSObject[]]
    $Command,

    # The input object
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=1)]
    [Alias('InputObject')]
    [PSObject]
    $Splat,

    # If set, will return regardless of if parameters map,  are valid, and have enough mandatory parameters
    [switch]
    $Force
    )
    begin {
        if (-not ${script:_@p}) { ${script:_@p} = @{} }
        if (-not ${script:_@c}) { ${script:_@c} = @{} }
        if (-not ${script:_@mp}) { ${script:_@mp} = @{} }
    }
    process {
        $ap,$ac,$amp = ${script:_@p},${script:_@c}, ${script:_@mp}
        if ($Splat -is [Collections.IDictionary]) {
            if ($splat.GetType().Name -ne 'PSBoundParametersDictionary') {
                $Splat = [PSCustomObject]$Splat
            } else {
                $splat = [PSCustomObject]([Ordered]@{} +  $Splat)
            }
        }

        $in = $Splat
        foreach ($cmd in $Command) {
            $rc =
                if ($ac.$cmd) {
                    $ac.$cmd
                } elseif ($cmd -is [string]) {
                    $fc = $ExecutionContext.SessionState.InvokeCommand.GetCommand($cmd,'Function,Cmdlet,ExternalScript,Alias')
                    $fc =
                        if ($fc -is [Management.Automation.AliasInfo]) {
                            $fc.ResolvedCommand
                        } else {
                            $fc
                        }
                    $ac.$cmd = $fc
                    $fc
                } elseif ($cmd -is [ScriptBlock]) {
                    $hc = $cmd.GetHashCode()
                    $ExecutionContext.SessionState.PSVariable.Set("function:f$hc", $cmd)
                    $c = $ExecutionContext.SessionState.InvokeCommand.GetCommand("f$hc",'Function')
                    $ac.$cmd = $c
                    $c
                } elseif ($cmd -is [Management.Automation.CommandInfo]) {
                    $ac.$cmd = $cmd
                    $cmd
                }
            if (-not $rc) {continue}
            $cmd = $rc
            $splat,$Invalid,$Unmapped,$paramMap,$Pipe,$NoPipe = foreach ($_ in 1..6){[ordered]@{}}
            $params = [Collections.ArrayList]::new()
            $props = @($in.psobject.properties)
            $pc = $props.Count

            $problems = @(foreach ($prop in $props) {
                $cp=$cmd.Parameters
                $pn = $prop.Name
                $pv = $prop.Value
                if (-not $cp) { continue }
                $param = $cp.$pn
                if (-not $param) {
                    $k = "${cmd}:$pn"
                    $param =
                        if ($ap[$k]) {
                            $ap[$k]
                        } else {
                            foreach ($p in $cp.Values) {
                                foreach ($a in $p.Aliases) {
                                    $ap["${cmd}:$a"] = $p
                                }
                                if ($ap[$k]) { $ap[$k]; break }
                            }
                        }
                }

                if (-not $param) {
                    $pn
                    continue
                }
                $paramMap[$param.Name] = $pn
                if ($params -contains $param) { continue }
                $pt=$param.ParameterType
                $v = $pv -as $pt
                if (-not $v -and
                    ($pt -eq [ScriptBlock] -or
                    $pt -eq [ScriptBlock[]])) {
                    $sb = try { foreach ($_ in $pv) { [ScriptBlock]::Create($_) }} catch {$null}
                    if ($sb) { $v = $sb }
                }
                if ($v -ne $null) {
                    $nv = try {
                        [PSVariable]::new("$pn", $v, 'Private',$param.Attributes)
                    } catch {
                        @{$pn=$_}
                    }
                    if ($nv -is [PSVariable] -or $Force) {
                        $null = $params.Add($param)
                        :CanItPipe do {
                            foreach ($attr in $param.Attributes) {
                                if ($attr.ValueFromPipeline -or $attr.ValueFromPipelineByPropertyName) {
                                    $pipe[$prop.Name] = $v
                                    break CanItPipe
                                }
                            }
                            $NoPipe[$prop.Name] = $v
                        } while ($false)
                        $splat[$prop.Name] = $v
                    }

                    if ($nv -isnot [PSVariable]) { $nv }
                } else {
                    @{$pn = $param}
                }
            })

            if (-not $amp.$cmd) {
                $Mandatory = @{}
                $cmdMd = $cmd -as [Management.Automation.CommandMetaData]
                foreach ($param in $cmdMd.Parameters.Values) {
                    foreach ($a in $param.Attributes) {
                        if (-not $a.Mandatory) { continue }
                        if ($a -isnot [Management.Automation.ParameterAttribute]) { continue }
                        if (-not $Mandatory[$a.ParameterSetName]) { $Mandatory[$a.ParameterSetName] = @{} }
                        $mp = ($paramMap.($param.Name))
                        $Mandatory[$a.ParameterSetName].($param.Name) = if ($mp) { $splat.$mp }
                    }
                }
                $amp.$cmd = $Mandatory
            }
            $mandatory = $amp.$cmd

            $missingMandatory = @{}
            foreach ($m in $Mandatory.GetEnumerator()) {
                $missingMandatory[$m.Key] =
                    @(foreach ($_ in $m.value.GetEnumerator()) {
                        if (-not $_.Value) { $_.Key }
                    })
            }
            $couldRun =
                if (-not $Mandatory.Count) { $true }
                elseif ($missingMandatory.'__AllParameterSets') {
                    $false
                }
                else {
                    foreach ($_ in $missingMandatory.GetEnumerator()) {
                        if (-not $_.Value) { $true;break }
                    }
                }

            if (-not $couldRun -and -not $Force) { continue }
            foreach ($p in $problems) {
                if ($p -is [Hashtable]) {
                    $Invalid += $p
                } else { $Unmapped[$p] = $in.$p }
            }
            if ($Invalid.Count -eq 0) { $Invalid = $null }
            if ($Unmapped.Count -eq 0) { $Unmapped = $null }

            $realCmd =
                if ($cmd -is [Management.Automation.FunctionInfo] -and
                    $cmd.Name.Contains($cmd.ScriptBlock.GetHashCode().ToString())) {
                    $cmd.ScriptBlock
                } else { $cmd }

            foreach($_ in ([Ordered]@{
                Command = $realCmd
                CouldRun = $couldRun
                Invalid = $Invalid
                Missing = $missingMandatory
                PercentFit = $(if ($pc) {$Splat.Count / $pc } else { 0})
                Unmapped = $Unmapped
                PipelineParameter = $Pipe
                NonPipelineParameter = $NoPipe
            }).GetEnumerator()) {
                $splat.psobject.properties.Add([Management.Automation.PSNoteProperty]::new($_.Key,$_.Value))
            }
            $splat
        }
    }
}
${.@}=${UseSplat}=${uSplat}={
    <#
    .Synopsis
        Uses a splat.
    .Description
        Uses a splat to call a command.
        If passed from Find-Splat,Get-Splat or Test-Splat, the command will be automatically detected.
        If called as .@, this will run only provided commands
        If called as *@, this will run any found commands
    .Link
        Get-Splat
    .Link
        Find-Splat
    .Link
        Test-Splat
    .Example
        @{id=$pid} | Use-Splat gps # When calling Use-Splat is globally imported
    .Example
        @{id=$pid} | & ${.@} gps # When calling Use-Splat is nested
    .Example
        @{LogName='System';InstanceId=43,44},
        @{LogName='Application';InstanceId=10000,10005} |
            .@ Get-EventLog # get a bunch of different log events
    #>
    param(
    # One or more commands
    [Parameter(Position=0)]
    [PSObject[]]
    $Command,

    # Any additional positional arguments that would be passed to the command
    [Parameter(Position=1,ValueFromRemainingArguments=$true)]
    [PSObject[]]
    $ArgumentList = @(),

    # The splat
    [Parameter(ValueFromPipeline=$true)]
    [PSObject[]]
    $Splat,

    # If set, will run regardless of if parameters map, are valid, and have enough mandatory parameters.
    [switch]
    $Force,

    # If set, will run the best fit out of multiple commands.
    # The best fit is the command that will use the most of the input splat.
    [Alias('BestFit','BestFitFunction', 'BF','BFF')]
    [switch]
    $Best,

    # If set, will stream input into a single pipeline of each command.
    # The non-pipeable parameters of the first input splat will be used to start the pipeline.
    # By default, a command will be run once per input splat.
    [Alias('Pipe')]
    [switch]
    $Stream)

    begin {
        $pipelines = @{}
    }
    process {
        $WeTrustTheSplat = $false
        if (-not $Command -and
            $splat.Length -eq 1 -and
            $splat[0] -is [Collections.IDictionary] -and
            $Splat[0].psobject.Properties['Command']) {
            $Command = $Splat[0].psobject.Properties['Command'].Value
            $WeTrustTheSplat = $true
        } elseif (-not $command -and $_ -is [PSObject] -and $_.Command -and $_.Splat) {
            $WeTrustTheSplat = $true
            $splat = $_.Splat
            $command = $_.Command
        }

        if ($Best -and $command.Count) {
            $command = $splat |
                & ${?@} -Command $command |
                Sort-Object PercentFit -Descending |
                Select-Object -ExpandProperty Command -First 1
        }

        if (-not $Command) {
            Write-Error -Message "No command found" -Category ObjectNotFound -ErrorId 'Use-Splat.CommandNotFound' ;return
        }
        #region UseTheSplat
        foreach ($cmd in $Command) {
            if ($WeTrustTheSplat) {
                if ($cmd -is [Management.Automation.CommandInfo] -or $cmd -is [ScriptBlock]) {
                    foreach ($s in $splat) {
                        if ($argumentList) {
                            & $cmd @s @ArgumentList
                        } else {
                            & $cmd @s
                        }
                    }
                }
            } else {
                $Splat |
                    & ${?@} $cmd -Force:$Force |
                    & { process {

                        $i = $_
                        $np = $i.NonPipelineParameter
                        $c = $_.psobject.properties['Command'].Value
                        if ($Stream) {
                            if (-not $pipelines[$c]) {

                                $stepScript = if ($argumentList) { {& $c @np @argumentList} } else { {& $c @np} }

                                $stepPipeline = $stepScript.GetSteppablePipeline()
                                $pipelines[$c] = $stepPipeline
                                $stepPipeline.Begin($true)
                            } else {
                                $stepPipeline = $pipelines[$c]
                            }
                            $stepPipeline.Process([PSCustomObject]$i.PipelineParameter)
                            return
                        }

                        if ($c -is [Management.Automation.CommandInfo] -or $c -is [ScriptBlock]) {
                            if ($ArgumentList) {
                                & $c @i @ArgumentList
                            } else {
                                & $c @i
                            }
                        }
                    }}
            }
        }
        #endregion UseTheSplat
    }

    end {
        if ($pipelines.Count) {
            foreach ($v in $pipelines.Values) { $v.End() }
        }
    }
}
#endregion Splatter [ 0.4 ] : Simple Scripts to Supercharge Splatting (Install-Module Splatter, then Initialize-Splatter -Verb Get,Use )
