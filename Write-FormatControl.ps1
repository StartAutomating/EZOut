function Write-FormatControl
{
    <#
    .Synopsis
        Writes the Format XML for a Control
    .Description
        Writes the .format.ps1xml for a custom control.  Custom Controls can be reused throughout the formatting file.
    .Example
        
    .Link
        Write-FormatCustomView
    #>
    param(
    # The name of the control
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [String]$Name,

    <#
    
    The script block used to fill in the contents of a custom control.
    
    
    The script block can either be an arbitrary script, which will be run, 
    or it can contain a series of Write-FormatViewExpression commands.
    
    If the ScriptBlock contains Write-FormatViewExpression, 
    code in between Write-FormatViewExpression will not be included in the formatter
    #>
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('ScriptBlock', 'DefaultAction')]
    [ScriptBlock]$Action
    )

    process {
        $Splat = $PSBoundParameters | 
            & ${?@} -Command Write-FormatCustomView
        $Splat.AsControl = $true        
        $splat | & ${.@}        
    }
}
