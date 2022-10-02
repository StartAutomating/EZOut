
Write-TypeView
--------------
### Synopsis
Writes extended type view information

---
### Description

PowerShell has a robust, extensible types system.  With Write-TypeView, you can easily add extended type information to any type.
This can include:
    The default set of properties to display (-DefaultDisplay)
    Sets of properties to display (-PropertySet)
    Serialization Depth (-SerializationDepth)
    Virtual methods or properties to add onto the type (-ScriptMethod, -ScriptProperty and -NoteProperty)
    Method or property aliasing (-AliasProperty)

---
### Related Links
* [Out-TypeView](Out-TypeView.md)



* [Add-TypeView](Add-TypeView.md)



---
### Parameters
#### **TypeName**

The name of the type.
Multiple type names will all have the same methods, properties, events, etc.



> **Type**: ```[String[]]```

> **Required**: true

> **Position**: 1

> **PipelineInput**:true (ByPropertyName)



---
#### **ScriptMethod**

A collection of virtual method names and the script blocks that will be used to run the virtual method.



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **ScriptProperty**

A Collection of virtual property names and the script blocks that will be used to get the property values.



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **NoteProperty**

A collection of fixed property values.



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **AliasProperty**

A collection of property aliases



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **EventGenerator**

A collection of scripts that may create events.
These will become ScriptMethods.
* Send_NameOfEvent will call the generator and optionally send an event.  Arguments will may be passed along to the event.
* Register_NameOfEvent({}) will call Register-EngineEvent to register an event handler
* Unregister_NameOfEvent([[PSEventSubscriber]) will call Unregister-EngineEvent to remove the handler.



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **EventName**

A list of event names.
These will become ScriptMethods.
* Send_NameOfEvent will call the generator and optionally send an event.  Arguments will be sent as event and message data.
* Register_NameOfEvent({}) will call Register-EngineEvent to register an event handler
* Unregister_NameOfEvent([[PSEventSubscriber]) will call Unregister-EngineEvent to remove the handler.



> **Type**: ```[String[]]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **DefaultDisplay**

The default display.
If only one propertry is used, this will set the default display property.
If more than one property is used, this will set the default display member set.



> **Type**: ```[String[]]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **IdProperty**

The ID property



> **Type**: ```[String]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **SerializationDepth**

The serialization depth.  If the type is deserialized, this is the depth of subpropeties
that will be stored.  For instance, a serialization depth of 3 would storage an object, it's
subproperties, and those objects' subproperties.  You can use the serialization depth
to minimize the overhead of moving objects back and forth across the remoting boundary,
or to ensure that you capture the correct information.



> **Type**: ```[Int32]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Reserializer**

The reserializer type used for recreating a deserialized type.
If none is provided, consider using -Deserialized



> **Type**: ```[Type]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **PropertySet**

Property sets define default views for an object.  A property set can be used with Select-Object
to display just that set of properties.



> **Type**: ```[IDictionary]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **HideProperty**

Will hide any properties in the list from a display



> **Type**: ```[String[]]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
#### **Deserialized**

If set, will generate an identical typeview for the deserialized form of each typename.



> **Type**: ```[Switch]```

> **Required**: false

> **Position**: named

> **PipelineInput**:false



---
### Outputs
* [String](https://learn.microsoft.com/en-us/dotnet/api/System.String)




---
### Syntax
```PowerShell
Write-TypeView [-TypeName] <String[]> [-ScriptMethod <IDictionary>] [-ScriptProperty <IDictionary>] [-NoteProperty <IDictionary>] [-AliasProperty <IDictionary>] [-EventGenerator <IDictionary>] [-EventName <String[]>] [-DefaultDisplay <String[]>] [-IdProperty <String>] [-SerializationDepth <Int32>] [-Reserializer <Type>] [-PropertySet <IDictionary>] [-HideProperty <String[]>] [-Deserialized] [<CommonParameters>]
```
---


