function Pop-FormatData
{
    <#
    .Synopsis
        Removes formatting from the current session.
    .Description
        Pop-FormatData command removes dynamically loaded formatting data from the current session.
    .Link
        Push-FormatData    
    #>
    [CmdletBinding(DefaultParameterSetName="ByModuleName")]
    param(
    # The name of the format module.  If there is only one type name,then
    # this is the name of the module.
    [Parameter(ParameterSetName='ByModuleName',
        Mandatory=$true,
        ValueFromPipeline=$true)]
    [String]
    $ModuleName
    )


    process {
        # Use @() to walk the hashtable first,
        # so we can modify it within the foreach
        foreach ($kv in @($FormatModules.GetEnumerator())) {
            if ($psCmdlet.ParameterSetName -eq "ByModuleName") {
                if ($kv.Key -eq $ModuleName) {
                    Remove-Module $kv.Key
                    $null = $FormatModules.Remove($kv.Key)
                }
            }
        }
    }
}
