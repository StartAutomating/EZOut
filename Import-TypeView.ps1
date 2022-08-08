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
    $FilePath,

    # If set, will generate an identical typeview for the deserialized form of each typename.
    [switch]$Deserialized
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
                    # Files in subdirectories become the methods / properties used by a directory sharing that typename.
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
            # Apply them to each member first (so that it happens in time),
            foreach ($k in @($membersByType.Keys)) {
                if ($k -ne '*') {
                    $membersByType[$k] += $membersByType['*']
                }
            }
            $membersByType.Remove('*') # then remove it (so we don't do it twice).
        }

        foreach ($mt in $membersByType.GetEnumerator() | Sort-Object Key) {    # Walk thru the members by type
            $WriteTypeViewSplat = @{                         # and create a hashtable to splat.
                TypeName = $mt.Key
                Deserialized = $Deserialized
            }
            # Then, sort the values by name and by if it comes from this directory.
            $sortedValues = $mt.Value | Sort-Object Name, { $_.Directory.Name -ne $mt.Key }

            <#

            At a high level, what we're about to do so is turn a bunch of files into
            a bunch of input for Write-TypeView.

            By default .ps1s will become methods.
            .ps1 files that start with get_ or set_ become properties.
            .ps1 files that start with += become events.

            All other files will become noteproperties.

            Starting a file with . will hide the property.

            It should be noted that hidden ScriptMethods are not "private" Methods
            (though neither are C# private Methods, if you use Reflection).

            #>

            $aliasFileNames = 'Alias','Aliases','AliasProperty', '.Alias','.Aliases','.AliasProperty'
            $typeNameFileNames = 'TypeName','TypeNames','PSTypeName', 'PSTypeNames', 
                '.TypeName', '.TypeNames','.PSTypeName', '.PSTypeNames'
            $defaultDisplayFileName = 'DefaultDisplay','.DefaultDisplay'
            $scriptMethods = [Ordered]@{}
            $eventGenerators = [Ordered]@{}
            $eventNames = @()
            $scriptPropertyGet = [Ordered]@{}
            $scriptPropertySet = [Ordered]@{}
            $propertySets = [Ordered]@{}
            $aliasProperty = [Ordered]@{}
            $noteProperty = [Ordered]@{}
            $hideProperty = [Collections.Generic.List[string]]::new()
            foreach ($item in $sortedValues) {
                $itemName =
                    $item.Name.Substring(0, $item.Name.Length - $item.Extension.Length)

                # If it's a .ps1, it will become a method, property, or event.
                if ($item.Extension -eq '.ps1') {
                    $isScript = $true
                    $scriptBlock = # We'll want the script block.
                        $ExecutionContext.SessionState.InvokeCommand.GetCommand(
                            $item.Fullname, 'ExternalScript'
                        ).ScriptBlock
                } else {
                    $isScript = $false
                }

                if (-not $isScript -and $itemName -eq $item.Directory.Name) {
                    # If it's a data file that shares the name of the directory
                    # treat it as a "Default" value, and hide the property.
                    $itemName = 'Default'
                    $hideProperty += $itemName
                } elseif ($itemName.StartsWith('.')) {
                    # If the file starts with a ., hide the property.
                    $itemName = $itemName.TrimStart('.')
                    $hideProperty += $itemName -replace '^(?>get|set)_'
                }



                if ($isScript -and                         # If the file is a script
                    $itemName -match '(?<GetSet>get|set)_' # and it starts with get_ or set_
                    )
                {
                    $propertyName = $itemName.Substring(4) # it's a property.
                    # If it's a get, store it along with the other gets
                    if ($matches.GetSet -eq 'get' -and -not $scriptPropertyGet.Contains($propertyName)) {
                        $scriptPropertyGet[$propertyName] = $scriptBlock

                    }
                    # Otherwise, store it with the sets.
                    elseif (-not $scriptPropertySet.Contains($propertyName))
                    {
                        if ($scriptPropertySet.Contains($propertyName)) {
                            continue
                        }
                        $scriptPropertySet[$propertyName] = $scriptBlock
                    }
                }
                elseif ($isScript -and         # If this is a script and it's an event
                    ($itemName -match '^@' -or # (prefaced with @ -or ending with .event.ps1)
                     $itemName -match '\.event\.ps1$'
                    )
                ) {
                    $eventName = $itemName.Substring(2)

                    $eventGenerators[$eventName] = $scriptBlock # store it for later.
                }
                elseif ($isScript) # Otherwise, if it's a script, it's a method.
                {
                    $methodName =$itemName
                    if ($scriptMethods.Contains($methodName)) {
                        continue
                    }
                    $scriptMethods[$methodName] = $scriptBlock
                }
                else
                {
                    # If it's not a method, it's a data file.
                    # Most of these will become properties.
                    $fileText = [IO.File]::ReadAllText($item.FullName)
                    # If the file was a structure all PowerShell engines can read, we'll load it.
                    # Currently, .clixml, .json, .psd1, .txt, and .xml are supported.
                    if ($item.Extension -in '.txt','.psd1', '.xml','.json','.clixml' -and
                        $scriptPropertyGet[$itemName])
                    {
                        # Of course if we've already given this a .ps1, we'd prefer that and will move onto the next.
                        continue
                    }
                    # Let's take a look at the extension to figure out what we do.
                    switch ($item.Extension)
                    {
                        #region .txt Files
                        .txt {

                            if ($defaultDisplayFileName -contains $itemName) # If it's a default display file
                            {
                                # Use each line of the file text as the name of a property to display
                                $WriteTypeViewSplat.DefaultDisplay =
                                    $fileText -split '(?>\r\n|\n)' -ne ''
                            }
                            if ($typeNameFileNames -contains $itemName) {
                                $WriteTypeViewSplat.TypeName =
                                    $fileText -split '(?>\r\n|\n)' -ne ''
                            }
                            elseif ($itemName -like '*.propertySet') { # If it's a property set file (.propertyset.txt)
                                $propertySets[$itemName -replace '\.propertySet$'] = # Create a property set with the file name.
                                    $fileText -split '(?>\r\n|\n)' -ne '' # Each line will be treated as a name of a property.
                            }
                            elseif ($itemName -match '^@') {
                                $eventNames += $itemName.Substring(1)
                            }
                            elseif ($itemName -match '\.event\.txt') {
                                $eventNames += $itemName -replace '\.event$'
                            }
                            elseif (-not $noteProperty.Contains($itemName)) # Otherwise, it's a simple string noteproperty
                            {
                                $noteProperty[$itemName] = $fileText
                            }

                        }
                        #endregion .txt Files
                        #region .psd1 Files
                        .psd1 {
                            # If it's a .psd1
                            # we load it in a data block
                            # Load it in a data block
                            $dataScriptBlock = [ScriptBlock]::Create(@"
data { $([ScriptBlock]::Create($fileText)) }
"@)
                            if ($aliasFileNames -contains $itemName) # If it's an Alias file
                            {
                                # we load it now
                                $aliasProperty = (& $dataScriptBlock) -as [Collections.IDictionary]
                            } else {
                                # otherwise, we load it in a ScriptProperty
                                $scriptPropertyGet[$itemName] = $dataScriptBlock
                            }
                        }
                        #endregion .psd1 Files
                        #region XML files
                        .xml {
                            # Xml content is cached inline in a ScriptProperty and returned casted to [xml]
                            $scriptPropertyGet[$itemName] = [ScriptBlock]::Create(@"
[xml]@'
$fileText
'@
"@)
                        }
                        #endregion XML files
                        #region JSON files
                        .json {
                            # Json files are piped to ConvertFrom-Json
                            $scriptPropertyGet[$itemName] = [ScriptBlock]::Create(@"
@'
$fileText
'@ | ConvertFrom-Json
"@)

                        }
                        #endregion JSON files
                        #region CliXML files
                            # Clixml files are embedded into a ScriptProperty and Deserialized.
                        .clixml {
                            $scriptPropertyGet[$itemName] = [ScriptBlock]::Create(@"
[Management.Automation.PSSerializer]::Deserialize(@'
$fileText
'@)
"@)
                        }
                        #endregion CliXML files
                        default {
                            # If we have no clue what kind of file it is, the only good way we can handle it as a byte[]
                            # This is tricky because we are creating a .types.ps1xml file,
                            # which is XML and big enough already.


                            # So we compress it.
                            $fileBytes =                   # Read all the bytes
                                [IO.File]::ReadAllBytes($item.FullName)
                            $ms = [IO.MemoryStream]::new() # Create a new memory stream
                            $gzipStream =                  # Create a gzip stream
                                [IO.Compression.GZipStream]::new($ms, [Io.Compression.CompressionMode]"Compress")
                            $null =                        # Write the file bytes to the stream
                                $gzipStream.Write($fileBytes, 0, $fileBytes.Length)
                            $null = $gzipStream.Close()    # close the stream.  This was the easy part.
                            $itemName = $item.Name
                            if ($itemName.StartsWith('.')) {
                                $itemName = $itemName.TrimStart('.')
                                $hideProperty += $itemName
                            }
                            if (-not $scriptPropertyGet.Contains($itemName)) {
                                # The hard part is dynamically creating the unpacker.
                                # The get script will need to do the above steps in reverse, and read the bytes back
                                $scriptPropertyGet[$itemName] = [ScriptBlock]::Create(@"

`$stream =
    [IO.Compression.GZipStream]::new(
        [IO.MemoryStream]::new(
            [Convert]::FromBase64String(@'
$(
# We do this by embedding the byte[] inside a Heredoc in Base64
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
            if ($propertySets.Count) {
                $WriteTypeViewSplat.PropertySet = $propertySets
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

            if ($eventGenerators.Count) {
                $WriteTypeViewSplat.EventGenerator = $eventGenerators
            }

            if ($eventNames) {
                $WriteTypeViewSplat.EventName = $eventNames
            }

            if ($WriteTypeViewSplat.Count -gt 1) {
                $WriteTypeViewSplat.HideProperty = $hideProperty
                Write-TypeView @WriteTypeViewSplat
            }
        }

        $null = $null
    }
}
