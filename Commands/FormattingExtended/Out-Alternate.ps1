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
    $NoPadding
    )

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

        $views = # Get the views and force them into an array
            @(foreach ($typeName in $PSTypeName) {
                foreach ($view in (Get-FormatData -TypeName $TypeName).FormatViewDefinition) {
                    $view
                }
            })
        
        # Now we walk over each view
        @(foreach ($view in $views) {
            # If we provided a -CurrentView, and this is it, skip.
            if ($CurrentView -and $view.Name -eq $CurrentView) { continue }
            # Determine the format type by getting the control and removing "Control" from the typename.
            $formatType = $view.Control.GetType().Name -replace 'Control$'

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
