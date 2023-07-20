# The PowerShell Types system has a lot of really underused capabilities.  One particularily interesting one is PropertySets.
# A Property Set is a named view of a type's data, which will only pick up those properties.  
# You use them with Select-Object.  A built in one is the PSConfiguration view on the output of Get-Process
Get-Process | Select-Object PSConfiguration

# You can see all of the PropertySets built into PowerShell with the Get-PropertySet command from EZOut
Get-PropertySet

# To create new ones, you can use the command ConvertTo-TypePropertySet.  You pipe in a Select-Object result to this command
# in order to create a result set.  This small pipeline creates a property set for file times.
Get-ChildItem | 
            Select-Object Name, LastWriteTime, CreationTime |
            ConvertTo-TypePropertySet -Name FileTimes
            
# To dynamically add it, pipe it into Out-TypeData and Add-TypeData
Get-ChildItem | 
            Select-Object Name, LastWriteTime, CreationTime |
            ConvertTo-TypePropertySet -Name FileTimes | 
            Out-TypeData |
            Add-TypeData

# Now we can ask for the FileTimes property set when we use Select-Object
Get-ChildItem | 
    Select-Object filetimes
