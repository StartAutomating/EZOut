function Clear-FormatData
{
    <#
    .Synopsis
        Clears formatting to the current session.
    .Description
        The Clear-FormatData command removes the formatting data for the current session.
        The formatting data must have been added with Add-FormatData
    .Example
        Clear-FormatData
    .Link
        Push-FormatData
    .Link
        Pop-FormatData
    #>
    [OutputType([Nullable])]
    param()

    #region Clear module and reset data
    $FormatModules.Values | Where-Object{ $_ } | Remove-Module
    $Script:FormatModules = @{}
    #endregion Clear module and reset data
}
