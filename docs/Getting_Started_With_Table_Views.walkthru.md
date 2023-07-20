# Getting Started with EasyOuput
#.Video http://www.youtube.com/watch?v=aSY88XBTjrg

# One of the simple ways you can use Write-FormatView and the rest of this module is to improve your 
# interaction with pieces of data that you normally use in PowerShell, but find difficult to read.

# By using Write-FormatView, you can create a new look and feel for a type in PowerShell.

# A great example is the WMI class Win32_VideoController.  By default, no view is defined, so
# when you run

Get-WmiObject Win32_VideoController

# You get every property that exists on the video controller class, which is, well, a lot.
# One simple way to improve the experience is to make it a limited number of properties.

# To do this, we need to find out the type name.  You can see the type name at the top of
# the output of Get-Member
Get-WmiObject Win32_VideoController | 
    Get-Member

# Since everything is an object in PowerShell, we can pick out just the typename property from
# the result of Get-Member, and use this in the rest of the examples.  
# This trick will work for any single type of object that comes out of any command.
$typeName = 
    Get-WmiObject Win32_VideoController | 
        Get-Member |
        Select-Object -ExpandProperty TypeName -Unique

# The first way we can try improving the look and feel is to display a fixed set of properties.
# I'm interested in discovering the name, the ram, and the resolution.  To write a piece of format XML
# that can be used to display just these few properties, we just need to write this one line:
Write-FormatView -TypeName $typeName -Property Name, AdapterRAM, VideoModeDescription


# When this command is run, a bunch of text is outputted.  This text can be used as part of a larger 
# format.ps1xml file you write, or you can join this and other views into a file with Out-FormatData.
# If pipe Out-FormatData into Add-FormatData, you can dynamically add views to the output of anything
# in PowerShell.
Write-FormatView -TypeName $typeName -Property Name, AdapterRAM, VideoModeDescription |
    Out-FormatData |
    Add-FormatData
    
# Now let's see how it looks
Get-WmiObject Win32_VideoController
        
# As we continue, we'll be able to make this much nicer and richer.

# First, let's do the easy thing, and AutoSize the whole table.  
# This can be done to any table view with the -AutoSize switch
Write-FormatView -TypeName $typeName -Property Name, AdapterRAM, VideoModeDescription -AutoSize |
    Out-FormatData |
    Add-FormatData

# Let's see the difference
Get-WmiObject Win32_VideoController

# A better approach might be to use columns of a fixed width.  Let's try this:
Write-FormatView -TypeName $typeName -Property Name, AdapterRAM, VideoModeDescription -Width 30,15,40 |
    Out-FormatData |
    Add-FormatData

# Let's see the difference
Get-WmiObject Win32_VideoController

# That's much easier to read, but we can still do better.  I can't help but notice that
# AdapterRAM sounds kind of less like what I want to think of the property, which is Memory.

# Renaming the property is pretty easy a hashtable is used to describe
# the items that will be renamed.  The key is the new name, and the value is
# the old name.  The -Property parameter will contain the display names of
# each of the properties, including the new name
Write-FormatView -TypeName $typeName -Property Name, Memory, Mode -Width 30,15,40 -RenamedProperty @{
    "Mode" = "VideoModeDescription"
    "Memory" = "AdapterRAM"
} | 
    Out-FormatData |
    Add-FormatData
    
# Let's see the difference    
Get-WmiObject Win32_VideoController

# One of the really nifty things about PowerShell is the fact that you can represent disk space
# and memory in familiar terms, like mb, kb, gb.  Since WMI returns this information to us in 
# the less readable (but more precise) form of bytes, let's see how we can use the -VirtualProperty
# parameter of Write-FormatView to show the memory in megabytes

# VirtualProperty is a hashtable like RenamedProperty.  
# The key in -VirtualProperty is the display name of the property, and
# the value has to be a PowerShell script block { }
# This Script Block is pretty simple, it just takes the current value ($_), divides it by megabytes,
# and then adds the text 'mb' to the end.
Write-FormatView -TypeName $typeName -Property Name, Memory, Mode -Width 30,15,40 -VirtualProperty @{
    "Memory" = {
        "$($_.AdapterRAM / 1mb) mb"
    }
} -RenamedProperty @{
    "Mode" = "VideoModeDescription"
}| 
    Out-FormatData |
    Add-FormatData
    
# Let's see the difference
Get-WmiObject Win32_VideoController
