function Pop-TypeData
{
    <#
    .Synopsis
        Removes Type information from the current session.
    .Description
        Pop-TypeData command removes dynamically created type data from the current session.
    .Link
        Push-TypeData
    #>
    [CmdletBinding(DefaultParameterSetName="ByModuleName")]
    param(
    # The name of the Type module.  If there is only one type name,then
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
        foreach ($kv in @($TypeModules.GetEnumerator())) {
            if ($psCmdlet.ParameterSetName -eq "ByModuleName") {
                if ($kv.Key -eq $ModuleName) {
                    Remove-Module $kv.Key
                    $null = $TypeModules.Remove($kv.Key)
                }
            }
        }
    }
}
