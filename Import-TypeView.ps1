function Import-TypeView
{
    <#
    .Synopsis
        Imports a Type View
    .Description
        Imports a Type View, defined in a external file .method or .property file
    .Link
        Write-TypeView
    .Example
        Import-TypeView .\Types
    #>
    param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('FullName')]
    [string[]]
    $FilePath
    )

    process {

        <#
        In order to make something like inheritance work,
        we want to be able to define properties and methods a few places:

        * In the -FilePath directory (these apply to all types)
        * In a directory (these apply to that a type sharing the name of the directory)
        * In any nested subdirectory (these should apply like inherited types)
        #>


        $membersByType = @{}
        foreach ($fp in $FilePath) {
            $filePathRoot = Get-Item -Path $fp
            $filesBeneathRoot = Get-ChildItem -Recurse -Path $fp -Force



            foreach ($fbr in $filesBeneathRoot) {
                if ($fbr -is [IO.DirectoryInfo]) { continue }
                if ($fbr.Directory.FullName -eq $filePathRoot.FullName) {
                    # Files directly beneath the root become methods / properties shared by all typenames
                    if (-not $membersByType['*']) {
                        $membersByType['*'] = @()
                    }
                    $membersByType['*'] += $fbr
                } else {
                    $subTypeNames = @($fbr.FullName.Substring(
                        $filePathRoot.FullName.Length
                    ).TrimStart(
                        [IO.Path]::DirectorySeparatorChar
                    ).Split([IO.Path]::DirectorySeparatorChar))

                    foreach ($subType in $subTypeNames) {
                        if ($subType -eq $subTypeNames[-1]) { continue }
                        if (-not $membersByType[$subType]) {
                            $membersByType[$subType] = @()
                        }
                        $membersByType[$subType] += $fbr
                    }
                }
            }



        }

        if ($membersByType['*']) # If any members applied to all types
        {
            foreach ($k in @($membersByType.Keys)) { # Apply them to each member
                if ($k -ne '*') {
                    $membersByType[$k] += $membersByType['*']
                }
            }
            $membersByType.Remove('*') # then remove it.
        }

        foreach ($mt in $membersByType.GetEnumerator()) { # Walk thru the members by type
            $WriteTypeViewSplat = @{TypeName = $mt.Key}   # and create a hashtable to splat.
            # Then, sort the values by name and by if it comes from this directory.
            $sortedValues = $mt.Value | Sort-Object Name, { $_.Directory.Name -ne $mt.Key }
            $aliasFileNames = 'Alias','Aliases','AliasProperty'
            $scriptMethods = [Ordered]@{}
            $scriptPropertyGet = [Ordered]@{}
            $scriptPropertySet = [Ordered]@{}
            $aliasProperty = [Ordered]@{}
            $noteProperty = [Ordered]@{}
            $hideProperty = [Collections.Generic.List[string]]::new()
            foreach ($item in $sortedValues) {
                $itemName =
                    $item.Name.Substring(0, $item.Name.Length - $item.Extension.Length)

                if ($item.Extension -eq '.ps1') {
                    $isScript = $true
                    $scriptBlock =
                        $ExecutionContext.SessionState.InvokeCommand.GetCommand(
                            $item.Fullname, 'ExternalScript'
                        ).ScriptBlock
                } else {
                    $isScript = $false
                }

                if (-not $isScript -and $itemName -eq $item.Directory.Name) {
                    $itemName = 'Default'
                    $hideProperty += $itemName
                } elseif ($itemName.StartsWith('.')) {
                    $itemName = $itemName.TrimStart('.')
                    $hideProperty += $itemName
                }

                if ($isScript -and $itemName -match '(?<GetSet>get|set)_')
                {
                    $propertyName = $itemName.Substring(4)
                    if ($matches.GetSet -eq 'get' -and -not $scriptPropertyGet.Contains($propertyName)) {
                        if ($scriptPropertyGet.Contains($propertyName)) {
                            continue
                        }
                        $scriptPropertyGet[$propertyName] = $scriptBlock

                    } elseif (-not $scriptPropertySet.Contains($propertyName)) {
                        if ($scriptPropertySet.Contains($propertyName)) {
                            continue
                        }
                        $scriptPropertySet[$propertyName] = $scriptBlock
                    }
                }
                elseif ($isScript)
                {
                    $methodName =$itemName
                    if ($scriptMethods.Contains($methodName)) {
                        continue
                    }
                    $scriptMethods[$methodName] = $scriptBlock
                }
                else
                {
                    $fileText = [IO.File]::ReadAllText($item.FullName)
                    if ($item.Extension -in '.psd1', '.xml','.json','.clixml' -and
                        $scriptPropertyGet[$itemName])
                    {
                        continue
                    }
                    switch ($item.Extension)
                    {
                        .txt {
                            if (-not $noteProperty.Contains($itemName)) {
                                $noteProperty[$itemName] = $fileText
                            }
                        }
                        .psd1 {
                            if ($aliasFileNames -contains $itemName) {
                                $dataScriptBlock = [ScriptBlock]::Create(@"
data { $([ScriptBlock]::Create($fileText)) }
"@)
                                $aliasProperty = (& $dataScriptBlock) -as [Collections.IDictionary]
                            } else {
                            
                            
                            $scriptPropertyGet[$itemName] = [ScriptBlock]::Create(@"
data { $fileText }
"@)
                            }
                        }
                        .xml {
                            $scriptPropertyGet[$itemName] = [ScriptBlock]::Create(@"
[xml]@'
$fileText
'@
"@)
                        }
                        .json {
                            $scriptPropertyGet[$itemName] = [ScriptBlock]::Create(@"
@'
$fileText
'@ | ConvertFrom-Json
"@)

                        }
                        .clixml {
                            $scriptPropertyGet[$itemName] = [ScriptBlock]::Create(@"
[Management.Automation.PSSerializer]::Deserialize(@'
$fileText
'@)
"@)
                        }
                        default {
                            $fileBytes = [IO.File]::ReadAllBytes($item.FullName)
                            $ms = [IO.MemoryStream]::new()
                            $gzipStream = [IO.Compression.GZipStream]::new($ms, [Io.Compression.CompressionMode]"Compress")
                            $null = $gzipStream.Write($fileBytes, 0, $fileBytes.Length)
                            $null = $gzipStream.Close()
                            $itemName = $item.Name
                            if ($itemName.StartsWith('.')) {
                                $itemName = $itemName.TrimStart('.')
                                $hideProperty += $itemName
                            }
                            if (-not $scriptPropertyGet.Contains($itemName)) {
                                $scriptPropertyGet[$itemName] = [ScriptBlock]::Create(@"

`$stream =
    [IO.Compression.GZipStream]::new(
        [IO.MemoryStream]::new(
            [Convert]::FromBase64String(@'
$(
[Convert]::ToBase64String($ms.ToArray(), "InsertLineBreaks")
)
'@)
        ),
        [IO.Compression.CompressionMode]'Decompress'
    );
"@ + @'

$BufferSize = 1kb
$buffer = [Byte[]]::new($BufferSize)
$bytes =
    do {
        $bytesRead= $stream.Read($buffer, 0, $BufferSize )
        $buffer[0..($bytesRead - 1)]
        if ($bytesRead -lt $BufferSize ) {
            break
        }
    } while ($bytesRead -eq $BufferSize )
$bytes -as [byte[]]
$stream.Close()
$stream.Dispose()
'@)

                            }
                        }
                    }
                }



            }

            if ($scriptMethods.Count) {
                $WriteTypeViewSplat.ScriptMethod = $scriptMethods
            }
            if ($aliasProperty.Count) {
                $WriteTypeViewSplat.AliasProperty = $aliasProperty
            }
            if ($scriptPropertyGet.Count -or $scriptPropertySet.Count) {
                $scriptProperties = [Ordered]@{}
                foreach ($k in $scriptPropertyGet.Keys) {
                    $scriptProperties[$k] = $scriptPropertyGet[$k]
                }
                foreach ($k in $scriptPropertySet.Keys) {
                    if (-not $scriptProperties[$k]) {
                        $scriptProperties[$k] = {}, $scriptPropertySet[$k]
                    } else {
                        $scriptProperties[$k] = $scriptProperties[$k], $scriptPropertySet[$k]
                    }
                }
                $WriteTypeViewSplat.ScriptProperty = $scriptProperties
            }

            if ($noteProperty.Count) {
                $WriteTypeViewSplat.NoteProperty = $noteProperty
            }

            if ($WriteTypeViewSplat.Count -gt 1) {
                $WriteTypeViewSplat.HideProperty = $hideProperty
                Write-TypeView @WriteTypeViewSplat
            }
        }

        $null = $null
    }
}
