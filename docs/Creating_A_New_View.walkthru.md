# The next view we can improve with Write-FormatView is how devices look
# A way to get the devices on the operating system is:

Get-WmiObject Win32_PnPEntity
       
# In earlier examples, we saw how to create a quick table view.  Let's do that for
# Win32_PnpEntity.

# To start out with, let's get the typename.
$typeName = 
    Get-WmiObject Win32_PnPEntity | 
        Get-Member |
        Select-Object TypeName -Unique
        
$typeName |
    Write-FormatView -Property Name, Status, Manufacturer, DeviceID -AutoSize |
    Out-FormatData |
    Add-FormatData            

# Let's see the difference
Get-WmiObject Win32_PnpEntity

# That's much better, but the Manufacturer information is repeated a lot, and it
# takes up a lot of space on the screen.  If we're careful about the order the data
# goes in, we can improve the appearance of the output by using the -GroupByProperty parameter.

$typeName |
    Write-FormatView -Property Name, Status, DeviceID -AutoSize -GroupByProperty Manufacturer |
    Out-FormatData |
    Add-FormatData            


# Let's see the difference
Get-WmiObject Win32_PnpEntity |
    Sort-Object Manufacturer

# It's very important to sort before you pipe into grouped views.        
# GroupBy will add a header to all items from the object pipeline that have the same property.
# Whenever a new value for that property is encountered, a new header will be added.  This means
# that if you output a bunch of objects by a grouping that comes out of order, you will see
# a lot of groups.  Let's the difference by showing the same data without sorting.        
Get-WmiObject Win32_PnpEntity
                                
# It looks much, much better sorted
Get-WmiObject Win32_PnpEntity |
    Sort-Object Manufacturer
    
# The only unfortunate thing about this view is that both the deviceID and the name are
# very long.  It would be better to show them in a list instead.  Luckily, Write-FormatView
# has the -AsList switch, which does just that.        
$typeName |
    Write-FormatView -Property Name, Status, DeviceID -GroupByProperty Manufacturer -AsList |
    Out-FormatData |
    Add-FormatData            
                                
# Let's see the difference
Get-WmiObject Win32_PnpEntity |
    Sort-Object Manufacturer
