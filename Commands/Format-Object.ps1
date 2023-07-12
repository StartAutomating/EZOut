function Format-Object
{
    <#
    .SYNOPSIS
        Formats an Object
    .DESCRIPTION
        Formats any object, using any number of Format-Object extensions.

        Any of the extensions to Format-Object can be embedded into a FormatXML file.
    .EXAMPLE
        "red" | Format-Object -ForegroundColor "red"
    .EXAMPLE
        1..10 | Format-Object -NumberedList
    .LINK
        Get-EZOutExtension
    .LINK
        Format-RichText
    .LINK
        Format-Markdown
    .LINK
        Format-YAML
    .LINK
        Format-Heatmap
    #>
    param(
    [Parameter(ValueFromPipeline)]
    [PSObject]
    $InputObject
    )

    dynamicParam {
        $myCmdName = $MyInvocation.MyCommand
        $dynamicParams = Get-EZOutExtension -DynamicParameter -NoMandatoryDynamicParameter -ParameterSetName "__AllParameterSets" -CommandName $myCmdName
        $null = $dynamicParams.Remove("InputObject")
        $dynamicParams
    }

    begin {
        # First, we make a copy of our parameters
        $paramCopy = @{} + $PSBoundParameters
        $paramCopy.Remove('InputObject')
        # let's initialize an empty variable to keep any extension validation errors.
        $extensionValidationErrors = $null
        # Then we create a hashtable containing the parameters to Get-EZOutExtension:
        $ezOutExtensionParams = @{
            CommandName   = $MyInvocation.MyCommand      # We want extensions for this command
            CouldRun      = $true
            Parameter     = $paramCopy
            ValidateInput = $host                        # that are valid, given the $host.
        }

        # If -Verbose is -Debug is set, we will want to populate extensionValidationErrors
        if ($VerbosePreference -ne 'silentlyContinue' -or 
            $DebugPreference -ne 'silentlyContinue') {
            $ezOutExtensionParams.ErrorAction   = 'SilentlyContinue'           # We do not want to display errors
            $ezOutExtensionParams.ErrorVariable = 'extensionValidationErrors'  # we want to redirect them into $extensionValidationErrors.
            $ezOutExtensionParams.AllValid      = $true                        # and we want to see that all of the validation attributes are correct.
        } else {
            $ezOutExtensionParams.ErrorAction = 'Ignore'
        }

        # Now we get a list of extensions.
        $formatObjectExtensions = @(Get-EZOutExtension @ezOutExtensionParams | Where-Object { $_.ExtensionParameter.Count})

        # If any of them had errors, and we want to see the -Verbose channel
        if ($extensionValidationErrors -and $VerbosePreference -ne 'silentlyContinue')  {
            foreach ($validationError in $extensionValidationErrors) {
                Write-Verbose "$validationError" # write the validation errors to verbose.
                # It should be noted that there will almost always be validation errors,
                # since most extensions will not apply to a given $GitCommand
            }
        }
        
         # Next we want to create a collection of SteppablePipelines.
        # These allow us to run the begin/process/end blocks of each Extension.
        $steppablePipelines =
            [Collections.ArrayList]::new(@(if ($formatObjectExtensions) {
                foreach ($ext in $formatObjectExtensions) {
                    $extParams = $ext.ExtensionParameter
                    $extCmd = $ext.ExtensionCommand
                    $scriptCmd = {& $extCmd @extParams}
                    $scriptCmd.GetSteppablePipeline()
                }
            }))


        # Next we need to start any steppable pipelines.
        # Each extension can break, continue in it's begin block to indicate it should not be processed.
        $spi = 0
        $spiToRemove = @()
        $beginIsRunning = $false
        # Walk over each steppable pipeline.
        :NextExtension foreach ($steppable in $steppablePipelines) {            
            if ($beginIsRunning) { # If beginIsRunning is set, then the last steppable pipeline continued
                $spiToRemove+=$steppablePipelines[$spi] # so mark it to be removed.
            }
            $beginIsRunning = $true      # Note that beginIsRunning=$false,
            try {
                $steppable.Begin($true) # then try to run begin
            } catch {
                $PSCmdlet.WriteError($_) # Write any exceptions as errors
            }
            $beginIsRunning = $false     # Note that beginIsRunning=$false
            $spi++                       # and increment the index.
        }

        # If this is still true, an extenion used 'break', which signals to stop processing of it any subsequent pipelines.
        if ($beginIsRunning) {         
            $spiToRemove += @(for (; $spi -lt $steppablePipelines.Count; $spi++) {
                $steppablePipelines[$spi]
            })
        }

        # Remove all of the steppable pipelines that signaled they no longer wish to run.
        foreach ($tr in $spiToRemove) {
            $steppablePipelines.Remove($tr)
        }
    }
    
    process {
        $myInv = $MyInvocation
        if (-not $steppablePipelines) {                
            # If we do not have any steppable pipelines, output the input object unchanged.
            $InputObject
        }
        else { 
            # If we have steppable pipelines, then we have to do a similar operation as we did for begin.                
            $spi = 0
            $spiToRemove = @()
            $processIsRunning = $false
            # We have to walk thru each steppable pipeline,
            :NextExtension foreach ($steppable in $steppablePipelines) {
                if ($processIsRunning) {  # if $ProcessIsRunning, the pipeline was skipped with continue.
                    $spiToRemove+=$steppablePipelines[$spi] # and we should add it to the list of pipelines to remove
                }
                $processIsRunning = $true # Set $processIsRunning,
                try {
                    # if ($paramCopy.ContainsKey('InputObject')) { # If InputObject was passed positionally
                    #     $steppable.Process() # run process, using no pipelined input.
                    # } else { # otherwise
                    if ($formatObjectExtensions[$spi]) {
                        $steppable.Process([PSObject]$InputObject) # attempt to run process, using $InputObject as the pipelined input.
                    }
                    # }
                } catch {
                    $err  = $_
                    $PSCmdlet.WriteError($_)    # (catch any exceptions and write them as errors).
                }
                $processIsRunning = $false # Set $processIsRunning to $false for the next step.
            }
            
            
            if ($processIsRunning) {  # If $ProcessIsRunning was true, the extension used break
                # which should signal cancellation of all subsequent extensions.
                $spiToRemove += @(for (; $spi -lt $steppablePipelines.Count; $spi++) {
                    $steppablePipelines[$spi]
                })


                $InputObject # We will also output the inputObject in this case.
            }

            # Remove any steppable pipelines we need to remove.
            foreach ($tr in $spiToRemove) { $steppablePipelines.Remove($tr) }
        }     
    }

    end {
        foreach ($sp in $steppablePipelines) {
            $sp.End()
        }
    }
}
