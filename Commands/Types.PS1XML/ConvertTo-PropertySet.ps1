function ConvertTo-PropertySet
{
    <#
    .Synopsis
        Converts Select-Object results to a property set
    .Description
        Converts Select-Object results to a named property set
        Named property sets can be requested from a property
    .Example
        Get-ChildItem |
            Select-Object Name, LastWriteTime, LastModifiedTime, CreationTime |
            ConvertTo-TypePropertySet -Name FileTimes |
            Out-TypeData |
            Add-TypeData

        Get-ChildItem |
            Select-Object filetimes
    .Link
        Out-TypeData
    .Link
        Add-TypeData
    #>
    [OutputType([string])]
    [Alias('ConvertTo-TypePropertySet')]
    param(
    # The output from Select-Object
    [ValidateScript({
        if ($_.pstypenames[0] -notlike "Selected.*") {
            throw "Must pipe in the result of a select-object"
        }
        return $true
    })]
    [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
    $SelectedObject,

    # The name of the selection set to create
    [Parameter(Mandatory=$true,Position=0)]
    $Name
    )

    begin {
        $list = New-Object Collections.ArrayList
    }

    process {
        $null = $list.Add($SelectedObject)
    }

    end {
        $groupedByType = $list | Group-Object { $_.pstypenames[0] } -AsHashTable

        foreach ($kv in $groupedByType.GetEnumerator()) {
            $shortTypeName = $kv.Key.Substring("Selected.".Length)
            $values = $kv.Value | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            Write-TypeView -TypeName $shortTypeName -PropertySet @{
                $Name = $values
            }
        }
    }
}