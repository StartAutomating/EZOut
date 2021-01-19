function Write-TypeView
{
    <#
    .Synopsis
        Writes extended type view information
    .Description
        PowerShell has a robust, extensible types system.  With Write-TypeView, you can easily add extended type information to any type.
        This can include:
            The default set of properties to display (-DefaultDisplay)
            Sets of properties to display (-PropertySet)
            Serialization Depth (-SerializationDepth)
            Virtual methods or properties to add onto the type (-ScriptMethod, -ScriptProperty and -NoteProperty)
            Method or property aliasing (-AliasProperty)
    .Link
        Out-TypeView
    .Link
        Add-TypeView
    #>
    [OutputType([string])]
    param(
    # The name of the type.
    # Multiple type names will all have the same methods, properties, events, etc.
    [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)]
    [String[]]
    $TypeName,

    # A collection of virtual method names and the script blocks that will be used to run the virtual method.
    [ValidateScript({
        if ($_.Keys | Where-Object {$_-isnot [string]}) {
            throw "Must provide the names of script methods"
        }
        if ($_.Values | Where-Object {$_ -isnot [ScriptBlock]}) {
            throw "Must provide script blocks to handle each method"
        }
        return $true
    })]
    [Collections.IDictionary]$ScriptMethod = @{},

    # A Collection of virtual property names and the script blocks that will be used to get the property values.
    [ValidateScript({
        $in = $_
        foreach ($kv in $in.GetEnumerator()) {
            if ($kv.Key -isnot [string]) {
                throw "Must provide the names of script properties"
            }
            if ($kv.Value.Count -gt 2) {
                throw "No more than two scripts can be provided"
            }
            foreach ($_ in $kv.Value) {
                if ($_ -isnot [ScriptBlock]) {
                    throw "Must provide script blocks to handle each property"
                }
            }
        }
        return $true
    })]
    [Collections.IDictionary]$ScriptProperty,

    # A collection of fixed property values.
    [ValidateScript({
        if ($_.Keys | Where-Object { $_-isnot [string] } ) {
            throw "Must provide the names of note properties"
        }
        return $true
    })]
    [Collections.IDictionary]$NoteProperty,

    # A collection of property aliases
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [string]) {
                throw "All keys and values in the property rename map must be strings"
            }
        }
        return $true
    })]
    [Collections.IDictionary]$AliasProperty,

    # A collection of scripts that may create events.
    # These will become ScriptMethods.
    # * Send_NameOfEvent will call the generator and optionally send an event.  Arguments will may be passed along to the event.
    # * Register_NameOfEvent({}) will call Register-EngineEvent to register an event handler
    # * Unregister_NameOfEvent([[PSEventSubscriber]) will call Unregister-EngineEvent to remove the handler.
    [ValidateScript({
        if ($_.Keys | Where-Object {$_-isnot [string]}) {
            throw "Must provide the names of events methods"
        }
        if ($_.Values | Where-Object {$_ -isnot [ScriptBlock] -and $_ -notlike '*New-Event*'}) {
            throw "Must provide script blocks for values, and each must contain New-Event"
        }
        return $true
    })]
    [Collections.IDictionary]$EventGenerator,

    # A list of event names.
    # These will become ScriptMethods.
    # * Send_NameOfEvent will call the generator and optionally send an event.  Arguments will be sent as event and message data.
    # * Register_NameOfEvent({}) will call Register-EngineEvent to register an event handler
    # * Unregister_NameOfEvent([[PSEventSubscriber]) will call Unregister-EngineEvent to remove the handler.
    [string[]]$EventName,

    # The default display.
    # If only one propertry is used, this will set the default display property.
    # If more than one property is used, this will set the default display member set.
    [string[]]$DefaultDisplay,

    # The ID property
    [string]$IdProperty,

    # The serialization depth.  If the type is deserialized, this is the depth of subpropeties
    # that will be stored.  For instance, a serialization depth of 3 would storage an object, it's
    # subproperties, and those objects' subproperties.  You can use the serialization depth
    # to minimize the overhead of moving objects back and forth across the remoting boundary,
    # or to ensure that you capture the correct information.
    [int]$SerializationDepth = 2,

    # The reserializer type used for recreating a deserialized type.
    # If none is provided, consider using -Deserialized
    [Type]$Reserializer,

    # Property sets define default views for an object.  A property set can be used with Select-Object
    # to display just that set of properties.
    [ValidateScript({
        if ($_.Keys | Where-Object {$_ -isnot [string] } ) {
            throw "Must provide the names of property sets"
        }
        if ($_.Values |
            Where-Object {$_ -isnot [string] -and  $_ -isnot [Object[]] -and $_ -isnot [string[]] }){
            throw "Must provide a name or list of names for each property set"
        }
        return $true
    })]
    [Collections.IDictionary]$PropertySet,

    # Will hide any properties in the list from a display
    [string[]]$HideProperty,

    # If set, will generate an identical typeview for the deserialized form of each typename.
    [switch]$Deserialized
    )

    begin {
        $RegisterMethod = {
            param(
            [Parameter(Mandatory)]
            [string]
            $SourceIdentifier
            )
            [ScriptBlock]::Create(@"
param([ScriptBlock]`$EventHandler, `$SourceIdentifier = '$SourceIdentifier')
Register-EngineEvent -SourceIdentifier `$SourceIdentifier -Action `$EventHandler
"@)
        }

        $UnregisterMethod =
            [ScriptBlock]::Create(@"
param(`$EventHandler)
if (`$Eventhandler -is [Management.Automation.PSEventSubscriber]) {
    `$Eventhandler | Unregister-Event
} elseif (`$eventHandler -is [string]) {
    Get-EventSubscriber -SourceIdentifier `$EventHandler -ErrorAction SilentlyContinue  | Unregister-Event
}  elseif (`$eventHandler -is [int]) {
    Get-EventSubscriber -SubscriptionID `$EventHandler -ErrorAction SilentlyContinue | Unregister-Event
} elseif (`$eventHandler -is [ScriptBlock]) {
    Get-EventSubscriber |
        Where-Object { (`$_.Action.Command -replace '\s') -eq (`$eventHandler -replace '\s')} | Unregister-Event
} else {
    throw "Handler must be a [PSEventSubscriber], [ScriptBlock], a [string] SourceIdentifier, or an [int]SubscriptionID"
}
"@)
    }

    process {
        if ($Deserialized -and $TypeName -notlike 'Deserialized.*') {
            $typeName =
                foreach ($tn in $TypeName) {
                    $tn, "Deserialized.$tn"
                }
        }


        # Before we get started, we want to turn the abstract idea of Events into ScriptMethods
        if ($EventGenerator) { # Event Generators come first
            foreach ($evtGen in $EventGenerator.GetEnumerator()) {
                $evt = $evtGen.Key.Substring(0,1).ToUpper() + $evtGen.Key.Substring(1)
                $sendMethodName = "Send_$evt"
                $registerMethodName = "Register_$evt"
                $UnregisterMethodName = "Unregister_$evt"
                if ($ScriptMethod[$sendMethodName] -or     # If we already have Send_,
                    $ScriptMethod[$registerMethodName] -or # Register_,
                    $ScriptMethod[$unregisterMethodName]   # Unregister_
                ) {
                    # the user wants it that way.
                    continue
                }
                $ScriptMethod[$sendMethodName]     = $evtGen.Value
                $ScriptMethod[$registerMethodName] =
                    & $RegisterMethod "$($TypeName -replace '^Deserialized\.').$($evtGen.Key)"
                $ScriptMethod[$UnregisterMethodName] =
                    & $UnregisterMethod "$($TypeName -replace '^Deserialized\.').$($evtGen.Key)"
            }
        }
        elseif ($EventName) {
            foreach ($evtName in $EventName) {
                $evt = $evtName.Substring(0,1).ToUpper() + $evtName.Substring(1)
                $sendMethodName = "Send_$evt"
                $registerMethodName = "Register_$evt"
                $UnregisterMethodName = "Unregister_$evt"
                if ($ScriptMethod[$sendMethodName] -or     # If we already have Send_,
                    $ScriptMethod[$registerMethodName] -or # Register_,
                    $ScriptMethod[$unregisterMethodName]   # Unregister_
                ) {
                    # the user wants it that way.
                    continue
                }
                $evtSourceId = "$($TypeName -replace '^Deserialized\.').$evt"
                $ScriptMethod[$sendMethodName]     = [ScriptBlock]::Create("
                    New-Event -SourceIdentifier '$evtSourceId' -Sender `$this -EventArguments `$args -MessageData `$args
                ")
                $ScriptMethod[$registerMethodName] = & $RegisterMethod $evtSourceId
                $ScriptMethod[$unregisterMethodName] = & $unRegisterMethod $evtSourceId
            }
        }

        foreach ($tn in $TypeName) {
            $memberSetXml = ""

            #region Construct PSStandardMembers
            if ($psBoundParameters.ContainsKey('SerializationDepth') -or
                $psBoundParameters.ContainsKey('IdProperty') -or
                $psBoundParameters.ContainsKey('DefaultDisplay') -or
                $psBoundParameters.ContainsKey('Reserializer')) {
                $defaultDisplayXml = if ($psBoundParameters.ContainsKey('DefaultDisplay')) {
    $referencedProperties = "<Name>" + ($defaultDisplay -join "</Name>
                            <Name>") + "</Name>"
    "                <PropertySet>
                        <Name>DefaultDisplayPropertySet</Name>
                        <ReferencedProperties>
                            $referencedProperties
                        </ReferencedProperties>
                    </PropertySet>
    "
                }
                $serializationDepthXml = if ($psBoundParameters.ContainsKey('SerializationDepth')) {
                    "
                    <NoteProperty>
                        <Name>SerializationDepth</Name>
                        <Value>$SerializationDepth</Value>
                    </NoteProperty>"
                } else {$null }

                $ReserializerXml = if ($psBoundParameters.ContainsKey('Reserializer'))  {
    "
                    <NoteProperty>
                        <Name>TargetTypeForDeserialization</Name>
                        <Value>$Reserializer</Value>
                    </NoteProperty>

    "
                } else { $null }

                $memberSetXml = "
                <MemberSet>
                    <Name>PSStandardMembers</Name>
                    <Members>
                        $defaultDisplayXml
                        $serializationDepthXml
                        $reserializerXml
                    </Members>
                </MemberSet>
                "
            }
            #endregion Construct PSStandardMembers

            #region PropertySetXml
            $propertySetXml  = if ($psBoundParameters.PropertySet) {
                foreach ($NameAndValue in $PropertySet.GetEnumerator() | Sort-Object Key) {
                    $referencedProperties = "<Name>" + ($NameAndValue.Value -join "</Name>
                        <Name>") + "</Name>"
                "<PropertySet>
                    <Name>$([Security.SecurityElement]::Escape($NameAndValue.Key))</Name>
                    <ReferencedProperties>
                        $referencedProperties
                    </ReferencedProperties>
                </PropertySet>"
                }
            } else {
                ""
            }
            #endregion



            #region Aliases
            $aliasPropertyXml = if ($psBoundParameters.AliasProperty) {
                foreach ($NameAndValue in $AliasProperty.GetEnumerator() | Sort-Object Key) {
                    $isHiddenChunk = if ($HideProperty -contains $NameAndValue.Key) {
                        'IsHidden="true"'
                    }
                    "
                <AliasProperty $isHiddenChunk>
                    <Name>$([Security.SecurityElement]::Escape($NameAndValue.Key))</Name>
                    <ReferencedMemberName>$([Security.SecurityElement]::Escape($NameAndValue.Value))</ReferencedMemberName>
                </AliasProperty>"
                }
            } else {
                ""
            }
            #endregion Aliases
            $NotePropertyXml = if ($psBoundParameters.NoteProperty) {
                foreach ($NameAndValue in $NoteProperty.GetEnumerator() | Sort-Object Key) {
                    $isHiddenChunk = if ($HideProperty -contains $NameAndValue.Key) {
                        'IsHidden="true"'
                    }
                    "
                <NoteProperty $isHiddenChunk>
                    <Name>$([Security.SecurityElement]::Escape($NameAndValue.Key))</Name>
                    <Value>$([Security.SecurityElement]::Escape($NameAndValue.Value))</Value>
                </NoteProperty>"
                }
            } else {
                ""
            }
            $scriptMethodXml = if ($ScriptMethod -and $ScriptMethod.Count) {
                foreach ($methodNameAndCode in $ScriptMethod.GetEnumerator() | Sort-Object Key) {                                "
                <ScriptMethod>
                    <Name>$($methodNameAndCode.Key)</Name>
                    <Script>
                        $([Security.SecurityElement]::Escape($methodNameAndCode.Value))
                    </Script>
                </ScriptMethod>"
                }
            } else {
                ""
            }

            #region Script Property
            $scriptPropertyXml = if ($psBoundParameters.ScriptProperty) {
                foreach ($propertyNameAndCode in $ScriptProperty.GetEnumerator() | Sort-Object Key) {
                    $isHiddenChunk = if ($HideProperty -contains $propertyNameAndCode.Key) {
                        'IsHidden="true"'
                    }
                    $getScript, $setScript = $propertyNameAndCode.Value
                    if ($getScript -and $setScript) {
                        "
                <ScriptProperty $isHiddenChunk>
                    <Name>$($propertyNameAndCode.Key)</Name>
                    <GetScriptBlock>
                        $([Security.SecurityElement]::Escape($getScript))
                    </GetScriptBlock>
                    <SetScriptBlock>
                        $([Security.SecurityElement]::Escape($setScript))
                    </SetScriptBlock>
                </ScriptProperty>"
                    } else {
                        "
                <ScriptProperty $isHiddenChunk>
                    <Name>$($propertyNameAndCode.Key)</Name>
                    <GetScriptBlock>
                        $([Security.SecurityElement]::Escape($propertyNameAndCode.Value))
                    </GetScriptBlock>
                </ScriptProperty>"
                    }
                }
            }

            $innerXml = @($memberSetXml) + $propertySetXml + $aliasPropertyXml + $codePropertyXml + $codeMethodXml + $scriptMethodXml + $scriptPropertyXml + $NotePropertyXml

            $innerXml = ($innerXml  | Where-Object {$_} ) -join ([Environment]::NewLine)
            "
        <Type>
            <Name>$tn</Name>
            <Members>
                $innerXml
            </Members>
        </Type>"
        }
    }

}
