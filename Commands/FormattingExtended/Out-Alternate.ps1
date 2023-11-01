function Out-Alternate
{
    <#
    .SYNOPSIS
        Outputs alternate views
    .DESCRIPTION
        Outputs alternate views of an object or typename.
        
        While it is possible to display multiple views of an object in PowerShell, it's not as straightforward to see what those views are.
        
        Out-Alternate solves this problem, and is embeddable within a format file.
    .EXAMPLE
        Out-Alternate -TypeName "System.Diagnostics.Process"
    #>
    [Management.Automation.Cmdlet("Format", "Object")]
    param(
    # An input object.  If this is provided, it will infer the typenames
    [Parameter(ValueFromPipeline)]
    [PSObject]
    $InputObject,
    
    # The typename of the alternate.
    # If this is not provided, it can be inferred from the `-InputObject`.
    [Alias('TypeName')]
    [string[]]
    $PSTypeName,

    # The name of the current view.
    # If this is provided, it will not be displayed as an alternate.
    [string]
    $CurrentView,

    # A prefix to each view.
    [string]
    $Prefix = "",

    # A suffix to each view.
    [string]
    $Suffix,

    # If set, will not padd the space between the name of the format control and the -View parameter
    [switch]
    $NoPadding,

    # The name of one or more modules.
    # If provided, will provide the -PS1XMLPath of each module's .ExportedFormatFiles
    [string[]]
    $ModuleName,

    # The path to one or more .ps1xml files.
    # If these are provided (or inferred thru -ModuleName), will look for alternates in PS1XML.
    [string[]]
    $PS1XMLPath
    )
    
    begin {
        if (-not $script:AlternateViewCache) {
            $script:AlternateViewCache = @{}
        } 
    }

    process {
        # If no typename was provided
        if (-not $PSTypeName) {
            # and the input object has one
            if ($InputObject.pstypenames) {
                # use the input's PSTypeNames
                $PSTypeName = $InputObject.pstypenames
            }
        }

        # If we have no PSTypename, return.
        if (-not $PSTypeName) { return }

        if (-not $script:AlternateViewCache["$PSTypeName"]) {
            if ($ModuleName -and -not $PS1XMLPath) {                
                $PS1XMLPath = (Get-Module $ModuleName).ExportedFormatFiles
            }
                
            $script:AlternateViewCache["$PSTypeName"] =  # Get the views and force them into an array
                @(if ($PS1XMLPath) {
                    foreach ($ps1xml in $PS1XMLPath) {
                        if (-not $ps1xml) { continue }
                        Select-Xml -Path $ps1xml -XPath //TypeName |
                            & { process {
                                if ($_.Node.InnerText -and 
                                    $_.Node.InnerText.Trim() -notin $PSTypeName
                                ) {
                                    return
                                }
                                $_.Node.ParentNode.ParentNode
                            } }                    
                    }
                } else {
                    foreach ($typeName in $PSTypeName) {
                        foreach ($view in (Get-FormatData -TypeName $TypeName).FormatViewDefinition) {
                            $view
                        }
                    }
                })
        }

        $views = $script:AlternateViewCache["$PSTypeName"]

        # Now we walk over each view
        @(foreach ($view in $views) {
            # If we provided a -CurrentView, and this is it, skip.
            if ($CurrentView -and $view.Name -eq $CurrentView) { continue }
            # Determine the format type
            $formatType = if ($view.Control) {
                # by getting the control and removing "Control" from the typename (if using Get-FormatData).
                $view.Control.GetType().Name -replace 'Control$'
            } else {
                foreach ($potentialType in 'Table', 'List', 'Wide', 'Custom') {
                    if ($view."${potentialType}Control") {
                        $potentialType;break
                    }
                }
            }

            if (-not $formatType) { continue }
            

            # By default, we pad space (for aesthetic reasons).
            if (-not $NoPadding) { # If `-NoPadding` was passed, we won't pad space.
                # Otherwise, always pad to 6.
                # (the length of 'Custom', the longest of the potential format types)
                $formatType = $formatType.PadRight(6, ' ')
            }
            # Now output the name of the format command and it's view.
            "Format-$formatType -View '$($view.Name -replace "'", "''")'"
        }) -join [Environment]::NewLine
    }    
}
