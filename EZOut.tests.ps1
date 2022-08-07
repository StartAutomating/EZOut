[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="Using for Testing")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="Using for Testing")]
param()
describe 'EZOut' {
    it 'Can write formatting with Write-FormatView' {
        Write-FormatView -TypeName foo -Property bar |
            should -Belike *<View>*<TypeName>foo</TypeName>*<PropertyName>bar</PropertyName>*</View>*
    }
    it 'Can write types with Write-TypeView' {
        Write-TypeView -TypeName foo -DefaultDisplay bar |
            should -Belike *<Type>*<Name>foo</Name>*<ReferencedProperties>*bar*</ReferencedProperties>*
    }
    it 'Gives you a way to build formatting and types (with Write-EZFormatFile)' {
        Write-EZFormatFile |
            should -Belike '#requires -Module EZOut*Out-FormatData*Out-TypeData*'

        Write-EZFormatFile -Format { Write-FormatView -TypeName t -Property n} -Type { Write-TypeView -TypeName t -ScriptProperty @{n={[Random]::new().Next() }}} |
            should -Belike '#requires -Module EZOut*Out-FormatData*Out-TypeData*'
    }
    it 'Can Get-FormatFile to see loaded formatting' {
        $formatFiles = @(Get-FormatFile |
            Select-Object -ExpandProperty Name

        Get-FormatFile -OnlyFromModule |
            Select-Object -ExpandProperty Name

        Get-FormatFile -OnlyBuiltIn |
            Select-Object -ExpandProperty Name

        if (-not $PSVersionTable.Platform) {
        Get-FormatFile -FromSnapins |
            Select-Object -ExpandProperty Name
        }
        )
        if ($formatFiles) {
            $formatFiles | should -Belike *.ps1xml
        }
    }

    it 'Can Find-FormatView' {
        Find-FormatView -TypeName System.Diagnostics.Process

        Find-FormatView -TypeName System.IO.FileInfo
    }
}

describe 'Write-FormatView' {
    it 'Can add a -VirtualProperty' {
        $tn = "type$(Get-random)"

        Write-FormatView -TypeName $tn -VirtualProperty @{foo={'bar'}} -Property foo |
            Out-FormatData |
            Add-FormatData


        [PSCustomObject]@{PSTypeName=$tn;n=1} | Out-String | should -Belike *foo*bar*
        Clear-FormatData
    }
    it 'Can add an -AliasProperty' {
        $tn = "type$(Get-random)"
        Write-FormatView -TypeName $tn -AliasProperty @{N2='n'} -Property n2 |
            Out-FormatData |
            Add-FormatData

        [PSCustomObject]@{PSTypeName=$tn;n=1} | Out-String | should -Belike *n2*1*
    }
    it 'Can format a property' {
        $tn = "type$(Get-random)"
        Write-FormatView -TypeName $tn -FormatProperty @{N='{0}%'} -Property n |
            Out-FormatData |
            Add-FormatData

        [PSCustomObject]@{PSTypeName=$tn;n=1} | Out-String | should -Belike *n*1%*
    }
    it 'Can run an -Action' {
        $tn = "type$(Get-Random)"

        Write-FormatView -TypeName $tn -Action { "foobar" } |
            Out-FormatData |
            Add-FormatData

        New-Object PSObject -Property @{PSTypeName=$tn;n=1} | Out-String | should -Belike *foobar*

        Clear-FormatData

        New-Object PSObject -Property @{PSTypeName=$tn;n=1} | Out-String | should -Belike *n*1*
    }

    it 'Can make a list view if you pass -AsList' {
        Write-FormatView -TypeName foobar -Property foo, bar -AsList | should -Belike '*<ListControl>*'
    }

    it 'Can -GroupByProperty' {
        $fvXml = [xml](Write-FormatView -TypeName foobar -Property foo -GroupByProperty Name)
        $fvXml.View.GroupBy.PropertyName | should -Be Name
    }

    it 'Can -GroupByScript' {
        $fvXml = [xml](Write-FormatView -TypeName foobar -Property foo -GroupByScript {($_.N % 2) -as [bool]} -GroupLabel 'IsOdd')
        $fvXml.View.GroupBy.Label | should -Be IsOdd
        $fvXml.View.GroupBy.ScriptBlock | should -Belike '*$_.n*%*2*'
    }

    it 'Can use a custom control to render the group' {
        $fvXml = [xml](Write-FormatView -TypeName foobar -Property foo -GroupByProperty prop -GroupAction CustomControl)
        $fvXml.View.GroupBy.CustomControlName | should -Be CustomControl
    }

    it 'Can create custom controls' {
        $fvXml = [xml](Write-FormatView -Action { 'hi' } -AsControl -Name CustomControl -TypeName t)
        $fvXml.Control.Name | should -Be CustomControl
    }

    it 'Can use a -TypeName as a SelectionSetName if -IsSelectionSet is passed' {
        $fvXml =[xml](Write-FormatView -TypeName FileSystemTypes -IsSelectionSet -Property a)
        $fvXml.View.ViewSelectedBy.SelectionSet | should -Be FileSystemTypes
    }

    it 'Will pass parameters down to Write-FormatTableView or Write-FormatListView' {
        $ft = Write-FormatView -Property Drink, Price -AlignProperty @{
            Drink = 'Center'
            Price= 'Center'
        } -FormatProperty @{
            Price = '{0:c}'
        } -Width 40, 40 -TypeName MenuItem
        $ftXml = [xml]$ft
        $ftXml.View.TableControl.TableHeaders.TableColumnHeader[0].Alignment | should -Be center
    }

    it 'Can -ColorProperty' {
        Write-FormatView -TypeName ColorN -Property N -ColorProperty @{N={if ($_.N % 2) { "#ff0000"} else {"#0f0"} }}
    }

    it 'Can -ConditionalProperty if using -AsList' {
        Write-FormatView -TypeName ConditionN -Property N -ConditionalProperty @{N={$_.N%2}} -AsList
    }

    it 'Can write any old XML' {
        $fv = Write-FormatView -FormatXML @'
<SelectionSets>
        <SelectionSet>
            <Name>FileSystemTypes</Name>
            <Types>
                <TypeName>System.IO.DirectoryInfo</TypeName>
                <TypeName>System.IO.FileInfo</TypeName>
            </Types>
        </SelectionSet>
    </SelectionSets>
'@ -TypeName FileSystemTypes
        $fvXml = [xml]$fv
        $fvXml.selectionSets.SelectionSet.Name | should -Be FileSystemTypes
    }

    context 'Fault Tolerance' {
        it 'Will not let you send strings as -VirtualProperty values' {
            { Write-FormatView -Property foo -VirtualProperty @{foo='baz'} } | should -Throw
        }
        it 'Will not let you -RenameProperty to anything but strings' {
            { Write-FormatView -Property foo -RenameProperty @{foo=2} } | should -Throw
        }
        it 'Will not let you -FormatProperty with a non-string value' {
            { Write-FormatView -Property foo -FormatProperty @{foo=2} } | should -Throw
        }
        it 'Will not let you pass non-string keys to -ColorProperty' {
            { Write-FormatView -Property foo -ColorProperty @{2=2} } | should -Throw
        }
        it 'Will not let you create a view -AsControl without a -Name' {
            { Write-FormatView -TypeName t -Action { 'hi' } -AsControl -ErrorAction Stop } | should -Throw
        }
        it 'Will not let you pass bad alignments into -AlignProperty' {
            { Write-FormatView -AlignProperty @{k='blah'} -TypeName t} | should -Throw
        }
        it 'Will not let you pass literals into -ConditionalProperty' {
            { Write-FormatView -AsList -TypeName t -ConditionalProperty @{foo='bar' }} | should -Throw
        }
    }
}

describe "Write-FormatTableView" {
    it "Can set the -Width of each -Property.  Setting a negative width will make the column right-aligned" {
        $ft = Write-FormatTableView -Property verb, noun, description -Width 20, -40
        $ftXml = [xml]$ft
        $ftXml.TableControl.TableHeaders.TableColumnHeader[0].Width | should -Be 20
        $ftXml.TableControl.TableHeaders.TableColumnHeader[1].Width | should -Be 40
        $ftXml.TableControl.TableHeaders.TableColumnHeader[1].Alignment | should -Be right
    }

    it 'Can control the column alignment' {
        $ft = Write-FormatTableView -Property Drink, Price -AlignProperty @{
            Drink = 'Center'
            Price= 'Center'
        } -FormatProperty @{
            Price = '{0:c}'
        } -Width 40, 40
        $ftXml = [xml]$ft
        $ftXml.TableControl.TableHeaders.TableColumnHeader[0].Alignment | should -Be center

        Write-FormatView -TypeName MenuItem -FormatXML $ft |
            Out-FormatData|
            Add-FormatData

        [PSCustomObject]@{PSTypeName='MenuItem';Drink='Coffee';Price=2.99} | Out-String | should -Belike "*$('{0:C}' -f 2.99)*"
    }

    it 'Can conditionally -ColorRow.  The ScriptBlock must return a hex color or escape sequence.' {
        # This works by turning properties into virtual properties
        $ft = Write-FormatTableView -Property N -AutoSize -ColorRow {if ($_.N % 2) { "#ff0000"} else {"#0f0"} }
        $ftXml = [xml]$ft
        $ftXml.TableControl.TableRowEntries.TableRowEntry.TableColumnItems.TableColumnItem.ScriptBlock |
            should -Belike '*$_.N*'
    }

    it 'Can conditionally -ColorProperty.  The ScriptBlock must return a hex color or escape sequence.' {
        $ft = Write-FormatTableView -Property N -AutoSize -ColorProperty @{N={if ($_.N % 2) { "#ff0000"} else {"#0f0"} }}
        $ftXml = [xml]$ft
        $ftXml.TableControl.TableRowEntries.TableRowEntry.TableColumnItems.TableColumnItem.ScriptBlock |
            should -Belike '*$_.N*'
    }

    it 'Can -ColorProperty, even when the property is virtual or an alias' {
        $colorScript = {if ($_.N % 2) { "#ff0000"} else {"#0f0"} }
        $ft = Write-FormatTableView -Property N2, IsOdd -AliasProperty @{N2='N'} -ColorProperty @{N2=$colorScript;IsOdd=$colorScript} -VirtualProperty @{IsOdd={($_.N % 2) -as [bool]}}
        $ftXml = [xml]$ft
        $ftXml.TableControl.TableRowEntries.TableRowEntry.TableColumnItems.'#comment' | should -Belike '*conditionalColor:*'
    }

    it 'Can hide table headers' {
        $ft = Write-FormatTableView -HideHeader -Property N
        $ftXml = [xml]$ft
        $ftXml.TableControl.ChildNodes[0].Name | should -Be HideTableHeaders
    }

    it 'Can selectively display content, based off of a -ViewCondition' {
        [PSCustomObject]@{
            Property = 'Host', 'N'
            VirtualProperty = @{Host={'Normal'}}
        },[PSCustomObject]@{
            ViewCondition = { $host.Name -eq 'MySpecialHost'}
            ViewTypeName = 'HostAwareTable'
            VirtualProperty = @{Host={ "Special"}}
            Property = 'Host', 'N'
        } | Write-FormatTableView |
            Write-FormatView -FormatXML { $_ } -TypeName HostAwareTable |
            Out-FormatData |
            Add-FormatData

        @(foreach ($n in 1..5) {
            [PSCustomObject]@{PSTypeName='HostAwareTable';N=$n}
        }) |Out-String | should -Belike *normal*
    }

    it 'Can selectively display content, based off of a -ViewCondition with a -ViewSelectionSet' {
        [PSCustomObject]@{
            Property = 'Host', 'N'
            VirtualProperty = @{Host={'Normal'}}
        },[PSCustomObject]@{
            ViewCondition = { $host.Name -eq 'MySpecialHost'}
            ViewSelectionSet = 'HostAwareTable'
            VirtualProperty = @{Host={ "Special"}}
            Property = 'Host', 'N'
        } | Write-FormatTableView |
            Write-FormatView -FormatXML { $_ } -TypeName HostAwareTable |
            Out-FormatData |
            Add-FormatData

        @(foreach ($n in 1..5) {
            [PSCustomObject]@{PSTypeName='HostAwareTable';N=$n}
        }) |Out-String | should -Belike *normal*
    }

    context 'Fault Tolerance' {
        it 'Will not let you send strings as -VirtualProperty values' {
            { Write-FormatTableView -Property foo -VirtualProperty @{foo='baz'} } | should -Throw
        }
        it 'Will not let you -RenameProperty to anything but strings' {
            { Write-FormatTableView -Property foo -RenameProperty @{foo=2} } | should -Throw
        }
        it 'Will not let you -FormatProperty with a non-string value' {
            { Write-FormatTableView -Property foo -FormatProperty @{foo=2} } | should -Throw
        }
        it 'Will not let you pass non-string keys to -ColorProperty' {
            { Write-FormatTableView -Property foo -ColorProperty @{2=2} } | should -Throw
        }
        it 'Will not let you pass bad alignment into -AlignProperty' {
            { Write-FormatTableView -AlignProperty @{k='blah'} } | should -Throw
        }
    }
}

describe "Write-FormatListView" {
    it "Can be written directly with Write-FormatListView" {
        Write-FormatListView -Property foo,bar | should -Belike "*<ListControl>*<PropertyName>foo</PropertyName>*<PropertyName>bar</PropertyName>*"
    }

    it 'Can -FormatProperty' {
        $ft =
            Write-FormatListView -Property Drink, Price -FormatProperty @{
                Price = '{0:c}'
            }
        Write-FormatView -TypeName MenuItem -FormatXML $ft |
            Out-FormatData|
            Add-FormatData

        [PSCustomObject]@{PSTypeName='MenuItem';Drink='Coffee';Price=2.99} | Out-String | should -Belike "*$('{0:C}' -f 2.99)*"
    }

    it 'Can display a -ConditionalProperty' {
        $ft =
            Write-FormatListView -Property N -ConditionalProperty @{
                N = { $_.n % 2 }
            }
        Write-FormatView -TypeName OddN -FormatXML $ft |
            Out-FormatData|
            Add-FormatData
        @(
        foreach ($n in 1..10) {
            [PSCustomObject]@{PSTypeName='OddN';N =$n}
        }
        ) | Out-String | should -Belike '*N*1*N*3*N*5*N*7*N*9*'
    }

    it 'Can conditionally -ColorProperty.  The ScriptBlock must return a hex color or escape sequence.' {
        $fl = Write-FormatListView -Property N -ColorProperty @{N={if ($_.N % 2) { "#ff0000"} else {"#0f0"} }}
        $flXml = [xml]$fl
        $flXml.ListControl.ListEntries.ListEntry.ListItems.'#comment' | should -Belike '*conditionalColor:*'
    }

    it 'Can -ColorProperty, even when the property is virtual or an alias' {
        $colorScript = {if ($_.N % 2) { "#ff0000"} else {"#0f0"} }
        $fl = Write-FormatListView -Property N2, IsOdd -AliasProperty @{N2='N'} -ColorProperty @{N2=$colorScript;IsOdd=$colorScript} -VirtualProperty @{IsOdd={($_.N % 2) -as [bool]}}
        $flXml = [xml]$fl
        $flXml.ListControl.ListEntries.ListEntry.ListItems.'#comment' | should -Belike '*conditionalColor:*'
    }

    it 'Can make an -AliasProperty' {
        $flXml = [xml](Write-FormatListView -Property a -AliasProperty @{a='b'})
        $flXml.listControl.ListEntries.ListEntry.ListItems.ListItem.Label | should -Be a
        $flXml.listControl.ListEntries.ListEntry.ListItems.ListItem.PropertyName | should -Be b
    }

    it 'Can make an -VirtualProperty' {
        $flXml = [xml](Write-FormatListView -Property a -VirtualProperty @{a={'b'}})
        $flXml.listControl.ListEntries.ListEntry.ListItems.ListItem.Label | should -Be a
        $flXml.listControl.ListEntries.ListEntry.ListItems.ListItem.ScriptBlock | should -Be "'b'"
    }

    it 'Can selectively display different properties, based off of a condition' {
        [PSCustomObject]@{
            Property = 'N','IsEven'
            VirtualProperty = @{
                IsEven = { -not ($_.N % 2) }
            }
        },[PSCustomObject]@{
            Property = 'N','IsOdd'
            ViewCondition = { $_.N % 2 }
            ViewTypeName = 'EvenOddN'
            VirtualProperty = @{
                IsOdd = { ($_.N % 2) -as [bool] }
            }
        } | Write-FormatListView |
            Write-FormatView -FormatXML { $_ } -TypeName EvenOddN |
            Out-FormatData |
            Add-FormatData

        [PSCustomObject]@{PSTypeName='EvenOddN';N=1}| Out-String | should -Belike "*n*:*1*IsOdd*:*true*"
        [PSCustomObject]@{PSTypeName='EvenOddN';N=2}| Out-String | should -Belike "*n*:*2*IsEven*:*true*"
    }

    it 'Can selectively display different properties, based off of a -ViewCondition with a -ViewSelectionSet' {
        @([PSCustomObject]@{
            Property = 'N','IsEven'
            VirtualProperty = @{
                IsEven = { -not ($_.N % 2) }
            }
        },[PSCustomObject]@{
            Property = 'N','IsOdd'
            ViewCondition = { $_.N % 2 }
            ViewSelectionSet = 'EvenOddNumbers'
            VirtualProperty = @{
                IsOdd = { ($_.N % 2) -as [bool] }
            }
        } | Write-FormatListView |
            Write-FormatView -FormatXML { $_ } -TypeName EvenOddN
        Write-FormatView -FormatXML @'
<SelectionSet>
    <Name>EvenOddNumbers</Name>
    <Types>
        <TypeName>EvenOddN</TypeName>
    </Types>
</SelectionSet>
'@ -TypeName na
        )|
            Out-FormatData |
            Add-FormatData

        [PSCustomObject]@{PSTypeName='EvenOddN';N=1}| Out-String | should -Belike "*n*:*1*IsOdd*:*true*"
        [PSCustomObject]@{PSTypeName='EvenOddN';N=2}| Out-String | should -Belike "*n*:*2*IsEven*:*true*"
    }

    context 'Fault Tolerance' {
        it 'Will not let you send strings as -VirtualProperty values' {
            { Write-FormatListView -Property foo -VirtualProperty @{foo='baz'} } | should -Throw
        }
        it 'Will not let you -RenameProperty to anything but strings' {
            { Write-FormatListView -Property foo -RenameProperty @{foo=2} } | should -Throw
        }
        it 'Will not let you -FormatProperty with a non-string value' {
            { Write-FormatListView -Property foo -FormatProperty @{foo=2} } | should -Throw
        }
        it 'Will not let you pass non-string keys to -ColorProperty' {
            { Write-FormatListView -Property foo -ColorProperty @{2=2} } | should -Throw
        }
        it 'Will not let you pass non-string values to -ConditionalProperty' {
            { Write-FormatListView -Property foo -ConditionalProperty @{2=2} } | should -Throw
        }

    }
}

describe "Write-FormatCustomView" {
    it "Can do anything in -Action" {
        $tn = "type$(Get-Random)"

        Write-FormatView -TypeName $tn -Action { "Hello $env:UserName, it's $([DateTime]::Now)" } |
            Out-FormatData |
            Add-FormatData

        New-Object PSObject -Property @{PSTypeName=$tn;n=1} | Out-String | should -Belike *hello*
    }

    it 'Can provide a parallel set of -VisibilityCondition' {
        $tn = "type$([Random]::new().next())"
        Write-FormatCustomView -Action { "This is $false and will not be shown" }, {"This is $true and will be shown" } -VisibilityCondition { $false }, { $true} |
            Write-FormatView -TypeName $tn -FormatXML {$_} |
            Out-FormatData |
            Add-FormatData

        [PSCustomObject]@{PSTypeName=$tn;n=1} | Out-String | should -Belike '*This is true*'
    }

    it "Will render an -Action that has only one token, which is a literal string, as <Text>" {
        $fv = Write-formatCustomview -Action { "foobar" }
        $fvXml = [xml]$fv
        $fvXml.CustomControl.CustomEntries.CustomEntry.CustomItem.Text | should -Be foobar
    }

    it "Will render an -Action that uses the mythical command Write-NewLine will become a <Newline/>" {
        $fv = Write-FormatCustomView -Action { Write-NewLine }
        $fvXml = [xml]$fv
        if (-not $fvXml.CustomControl.CustomEntries.CustomEntry.CustomItem.ChildNodes[0].Name -eq 'Newline') {
            throw "<NewLine/> Expected"
        }
    }

    it 'Can -Indent (though hosts seem not to honor this)' {
        $fvXml = [xml](Write-FormatCustomView -indent 4 -Action {"h" })
        $fvXml.CustomControl.CustomEntries.CustomEntry.CustomItem.Frame.LeftIndent | should -Be 4
    }

    it 'Can use -a -ViewCondition to branch (but input will have to be piped in)' {
        [PSCustomObject]@{
            ViewCondition = { $host.Name -eq 'MySuperSpecialHost'}
            ViewTypeName = 'HostAwareFormatter'
            Action = { "$($_.N) Special Host"}
        },[PSCustomObject]@{
            Action = { "$($_.N) Normal Host" }
        } | Write-FormatCustomView |
            Write-FormatView -FormatXML { $_ } -TypeName HostAwareFormatter |
            Out-FormatData |
            Add-FormatData


        [PSCustomObject]@{PSTypeName='HostAwareFormatter';N=1} | Out-String | should -Belike "*normal host*"
    }

    it 'Can use a -ViewCondition with a -ViewSelectionSet to match multiple typenames (piping is still required)' {
        [PSCustomObject]@{
            ViewCondition = { $host.Name -eq 'MySuperSpecialHost'}
            ViewSelectionSet = 'HostAwareFormatter'
            Action = { "$($_.N) Special Host"}
        },[PSCustomObject]@{
            Action = { "$($_.N) Normal Host" }
        } | Write-FormatCustomView |
            Write-FormatView -FormatXML { $_ } -TypeName HostAwareFormatter |
            Out-FormatData |
            Add-FormatData


        [PSCustomObject]@{PSTypeName='HostAwareFormatter';N=1} | Out-String | should -Belike "*normal host*"
    }

    it 'Can just run a command with no parameters in -Action' {
        $fvXml = [xml](Write-FormatCustomView -Action {Get-Command} )
        $fvXml.CustomControl.CustomEntries.CustomEntry.CustomItem.ExpressionBinding.ScriptBlock | should -Be 'Get-Command'
    }


    it "Will run Write-FormatCustomExpression" {
        $fv =
            Write-FormatCustomView -Action {
                Write-FormatViewExpression -ScriptBlock { "hello world"}
            }

        $fvXml = [xml]$fv
        $fvXml.CustomControl.CustomEntries.CustomEntry.CustomItem.ExpressionBinding.ScriptBlock |
            should -Belike '*"hello world"*'
    }
}

describe "Write-FormatViewExpression" {
    it 'Can render a -Property in a -ControlName, and -Enumerate the items' {
        $fv = Write-FormatViewExpression -ControlName MyCustomControl -Enumerate -Property Items
        $fvXml = [xml]$fv
        $fvXml.ExpressionBinding.PropertyName | should -Be Items
        $fvXml.ExpressionBinding.ChildNodes[1].Name |should -Be EnumerateCollection
        $fvXml.ExpressionBinding.CustomControlName | should -Be MyCustomControl
    }

    it 'Can render a -Property with a -FormatString' {
        $fvXml = [xml](Write-FormatViewExpression -FormatString '{0:C}' -Property Price)
        $fvXml.ExpressionBinding.PropertyName | should -Be Price
        $fvXml.ExpressionBinding.FormatString | should -Be '{0:C}'
    }
    it 'Can have a -ForegroundColor or -BackgroundColor (if ($Host.UI.SupportsVirtualTerminal))' {
        $fv =
            Write-FormatCustomView -Action {
                Write-FormatViewExpression -ScriptBlock { "hello world" } -ForegroundColor "#000" -BackgroundColor "#ffffff"
            }

        $fvXml = [xml]$fv

        $fvXml.CustomControl.CustomEntries.CustomEntry.CustomItem.ExpressionBinding[0].ScriptBlock |
            should -Belike '*Format-RichText*-ForegroundColor*#000*-BackgroundColor*#ffffff*'
    }

    it 'Will create a <NewLine> element when the -NewLine parameter is provided' {
        $fvxml = [xml](Write-FormatViewExpression -Newline)
        $fvxml.FirstChild.LocalName | should -Be 'Newline'
    }

    it 'Will create <Text> element when the -Text parameter is provided' {
        $fvxml = [xml](Write-FormatViewExpression -Text 'hello world')
        $fvxml.FirstChild.LocalName | should -Be 'Text'
        $fvxml.FirstChild.InnerText | should -Be 'Hello world'
    }

    it "Will call itself if the -ScriptBlock contains itself" {
        $fvXml = [xml](Write-FormatViewExpression -ScriptBlock { Write-FormatViewExpression -Property 'hi'  })
        $fvXml.ExpressionBinding.PropertyName | should -Be hi
    }
}


describe "Write-FormatTreeView" {
    it "Can make a tree view by using a recusive custom control" {
        $formatTree =
            Write-FormatTreeView -TypeName System.IO.FileInfo,
                System.IO.DirectoryInfo -Branch ([char]9500 + [char]9472 + [char]9472) -Property Name -HasChildren {
                if (-not $_.EnumerateFiles) { return $false }
                foreach ($f in $_.EnumerateFiles()) {$f;break}
            },
            {
                if (-not $_.EnumerateDirectories) { return $false }
                foreach ($f in $_.EnumerateDirectories()) {$f;break}
            } -Children {
                $_.EnumerateFiles()
            }, {
                foreach ($d in $_.EnumerateDirectories()) {
                    if ($d.Attributes -band 'Hidden') { continue }
                    $d
                }
            }

        $formatTree |
            Select-Xml /Control |
            Select-Object -ExpandProperty Node |
            Select-Object -ExpandProperty Name |
            should -Be 'System.IO.FileInfo/System.IO.DirectoryInfo.TreeNode'
    }

    it 'Can provide a -SelectionSet instead of a -TypeName' {
        $formatTree =
            Write-FormatTreeView -SelectionSet FileSystemTypes -Branch ([char]9500 + [char]9472 + [char]9472) -Property Name -HasChildren {
                if (-not $_.EnumerateFiles) { return $false }
                foreach ($f in $_.EnumerateFiles()) {$f;break}
            },
            {
                if (-not $_.EnumerateDirectories) { return $false }
                foreach ($f in $_.EnumerateDirectories()) {$f;break}
            } -Children {
                $_.EnumerateFiles()
            }, {
                foreach ($d in $_.EnumerateDirectories()) {
                    if ($d.Attributes -band 'Hidden') { continue }
                    $d
                }
            }

        $formatTree |
            Select-Xml /Control |
            Select-Object -ExpandProperty Node |
            Select-Object -ExpandProperty Name |
            should -Be 'FileSystemTypes.TreeNode'
    }

    it 'Can provide a custom -ControlName for the node control' {
        $formatTree =
            Write-FormatTreeView -TypeName System.IO.FileInfo,
                System.IO.DirectoryInfo -Branch ([char]9500 + [char]9472 + [char]9472) -Property Name -HasChildren {
                if (-not $_.EnumerateFiles) { return $false }
                foreach ($f in $_.EnumerateFiles()) {$f;break}
            },
            {
                if (-not $_.EnumerateDirectories) { return $false }
                foreach ($f in $_.EnumerateDirectories()) {$f;break}
            } -Children {
                $_.EnumerateFiles()
            }, {
                foreach ($d in $_.EnumerateDirectories()) {
                    if ($d.Attributes -band 'Hidden') { continue }
                    $d
                }
            } -ControlName FileTreeNode

        $formatTree |
            Select-Xml /Control |
            Select-Object -ExpandProperty Node |
            Select-Object -ExpandProperty Name |
            should -Be 'FileTreeNode'
    }

    it 'Can provide a -Separator between each -Property' {
        $formatTree =
            Write-FormatTreeView -TypeName System.IO.FileInfo,
                System.IO.DirectoryInfo -Branch ([char]9500 + [char]9472 + [char]9472) -Property Name, {$_.LastWriteTime.ToString()},@{If={$true};ScriptBlock={'hi'}} -Separator '-'  -HasChildren {
                if (-not $_.EnumerateFiles) { return $false }
                foreach ($f in $_.EnumerateFiles()) {$f;break}
            },
            {
                if (-not $_.EnumerateDirectories) { return $false }
                foreach ($f in $_.EnumerateDirectories()) {$f;break}
            } -Children {
                $_.EnumerateFiles()
            }, {
                foreach ($d in $_.EnumerateDirectories()) {
                    if ($d.Attributes -band 'Hidden') { continue }
                    $d
                }
            }

        $ftXml = [xml]$formatTree[0]
        $ftXml.Control.CustomControl.CustomEntries.CustomEntry.CustomItem.ExpressionBinding[1].PropertyName | should -Be Name
        $ftXml.Control.CustomControl.CustomEntries.CustomEntry.CustomItem.ExpressionBinding[2].ScriptBlock | should -Be '$_.LastWriteTime.ToString()'
        $ftXml.Control.CustomControl.CustomEntries.CustomEntry.CustomItem.ExpressionBinding[3].ScriptBlock | should -Be "'hi'"
    }

    it 'Can provide -EndBranch text' {
        $formatTree =
            Write-FormatTreeView -TypeName System.IO.FileInfo,
                System.IO.DirectoryInfo -Branch ([char]9500 + [char]9472 + [char]9472) -Property Name, {$_.LastWriteTime.ToString()},@{If={$true};ScriptBlock={'hi'}} -Separator '-'  -HasChildren {
                if (-not $_.EnumerateFiles) { return $false }
                foreach ($f in $_.EnumerateFiles()) {$f;break}
            },
            {
                if (-not $_.EnumerateDirectories) { return $false }
                foreach ($f in $_.EnumerateDirectories()) {$f;break}
            } -Children {
                $_.EnumerateFiles()
            }, {
                foreach ($d in $_.EnumerateDirectories()) {
                    if ($d.Attributes -band 'Hidden') { continue }
                    $d
                }
            } -EndBranch 'bye'
        $ftXml = [xml]$formatTree[0]
        @($ftXml.Control.CustomControl.CustomEntries.CustomEntry.CustomItem.Text)[-1] | should -Be "bye"
    }

    it 'Can provide an -EndBranchScript' {
        $formatTree =
            Write-FormatTreeView -TypeName System.IO.FileInfo,
                System.IO.DirectoryInfo -Branch ([char]9500 + [char]9472 + [char]9472) -Property Name, {$_.LastWriteTime.ToString()},@{If={$true};ScriptBlock={'hi'}} -Separator '-'  -HasChildren {
                if (-not $_.EnumerateFiles) { return $false }
                foreach ($f in $_.EnumerateFiles()) {$f;break}
            },
            {
                if (-not $_.EnumerateDirectories) { return $false }
                foreach ($f in $_.EnumerateDirectories()) {$f;break}
            } -Children {
                $_.EnumerateFiles()
            }, {
                foreach ($d in $_.EnumerateDirectories()) {
                    if ($d.Attributes -band 'Hidden') { continue }
                    $d
                }
            } -EndBranchScript {'bye'}
        $ftXml = [xml]$formatTree[0]
        @($ftXml.Control.CustomControl.CustomEntries.CustomEntry.CustomItem.ExpressionBinding)[-2].ScriptBlock | should -Be "'bye'"
    }

    it 'Can provide a custom -ChildNodeControl' {
        $formatTree =
            Write-FormatTreeView -TypeName System.IO.FileInfo,
                System.IO.DirectoryInfo -Branch ([char]9500 + [char]9472 + [char]9472) -Property Name -Separator '-'  -HasChildren {
                if (-not $_.EnumerateFiles) { return $false }
                foreach ($f in $_.EnumerateFiles()) {$f;break}
            },
            {
                if (-not $_.EnumerateDirectories) { return $false }
                foreach ($f in $_.EnumerateDirectories()) {$f;break}
            } -Children {
                $_.EnumerateFiles()
            }, {
                foreach ($d in $_.EnumerateDirectories()) {
                    if ($d.Attributes -band 'Hidden') { continue }
                    $d
                }
            } -ChildNodeControl FileNodeControl
        $ftXml = [xml]$formatTree[0]
        @($ftXml.Control.CustomControl.CustomEntries.CustomEntry.CustomItem.ExpressionBinding)[2].CustomControlName | should -Be FileNodeControl
        @($ftXml.Control.CustomControl.CustomEntries.CustomEntry.CustomItem.ExpressionBinding)[3].CustomControlName | should -Be FileNodeControl
    }

    it 'Can branch the view based off of -ViewTypeName, -ViewSelectionSet, and -ViewCondition' {
        $fv = [PSCustomObject]@{ViewTypeName=''},
        [PSCustomObject]@{
            ViewSelectionSet = 'bar'
        },
        [PSCustomObject]@{
            ViewTypeName = 't'
            ViewCondition = {$true}
        } | Write-FormatTreeView -TypeName t -Property name

        $fv | Out-FormatData | Add-FormatData
    }

    context 'Fault Tolerance' {
        it 'Will complain when passed an unrecognizable -Property' {
            { Write-FormatTreeView -TypeName t -Property 1 } | should -Throw
        }
        it 'Will complain when not passed a -TypeName, -SelectionSet, or -ControlName' {
            { Write-FormatTreeView -ErrorAction Stop } | should -Throw
        }
    }
}

describe "Write-FormatWideView" {
    it "You can make a wide view (if you want to, they truncate)" {
        Write-FormatWideView -Property foo -AutoSize | should -Belike '*<WideControl>*AutoSize*<PropertyName>foo*'
    }

    it 'Can override a property name with a -SCriptBlock (which will be truncated)' {
        Write-FormatWideView -ScriptBlock {'hi'} -ColumnCount 2 | should -Belike "*<WideControl>*<ColumnNumber>2</ColumnNumber>*<ScriptBlock>'hi'</ScriptBlock>*"
    }

    it 'Can use -a -ViewCondition to branch (but input will have to be piped in)' {
        [PSCustomObject]@{
            ScriptBlock = { "$($_.N) NormalHost" }
        },[PSCustomObject]@{
            ViewCondition = { $host.Name -eq 'MySpecialHost'}
            ViewTypeName = 'HostAwareFormatter'
            ScriptBlock = { "$($_.N) Special Host"}
        } | Write-FormatWideView |
            Write-FormatView -FormatXML { $_ } -TypeName HostAwareFormatter |
            Out-FormatData |
            Add-FormatData


        [PSCustomObject]@{PSTypeName='HostAwareFormatter';N=1} | Out-String | should -Belike "*normalhost*"

        Remove-FormatData -ModuleName HostAwareFormatter
    }

    it 'Can use a -ViewCondition with a -ViewSelectionSet to match multiple typenames (piping in is still required)' {
        [PSCustomObject]@{
            ScriptBlock = { "$($_.N) NormalHost" }
        },[PSCustomObject]@{
            ViewCondition = { $host.Name -eq 'MySpecialHost'}
            ViewSelectionSet = 'HostAwareFormatter'
            ScriptBlock = { "$($_.N) Special Host"}
        } | Write-FormatWideView |
            Write-FormatView -FormatXML { $_ } -TypeName HostAwareFormatter |
            Out-FormatData |
            Add-FormatData


        [PSCustomObject]@{PSTypeName='HostAwareFormatter';N=1} | Out-String | should -Belike "*normalhost*"

        Remove-FormatData -ModuleName HostAwareFormatter
    }
}



describe "EZOut can create selection sets" {
    it "Write-PropertySet can create a property set" {
        $propertySet =
            Write-PropertySet -typename System.IO.FileInfo -name filetimes -propertyName Name, LastAccessTime, CreationTime, LastWriteTime

        $propertySet = [xml]$propertySet

        $propertySet.SelectNodes("//PropertySet/Name").'#text' | should -Be filetimes
    }

    it "ConvertTo-PropertySet converts Select-Object output into a property set" {
        $propertySet =
            Get-ChildItem |
                Select-Object Name, LastAccessTime, CreationTime, LastWriteTime |
                ConvertTo-PropertySet -Name filetimes


        @($propertySet |
            Select-Xml -XPath "//PropertySet/Name" |
            ForEach-Object{$_.node.'#text'}) |
            Select-Object -Unique |
            should -Be filetimes
    }

    it 'ConvertTo-PropertySet will complain when passed input that does not come from Select-Object' {
        {Get-ChildItem | Select-Object -First 1 | ConvertTo-PropertySet -Name Test -ErrorAction Stop} |should -Throw
    }

    it 'Can Get Property Sets' {
        $propertySets= Get-PropertySet

        if ($propertySets) {
            $propertySetMemberNames = $propertySets|
                Get-Member -MemberType Properties |
                Select-Object -ExpandProperty Name

            if ($propertySetMemberNames) {
                if ($propertySetMemberNames -notcontains 'TypeName') {
                    throw "TypeName not found"
                }
                if ($propertySetMemberNames -notcontains 'PropertySet') {
                    throw "PropertySet not found"
                }
            }
        }
    }


}

describe 'Write-TypeView' {
    it 'Can add a -NoteProperty to any type' {
        $tn = "t$([Random]::new().Next())"
        Write-TypeView -TypeName $tn -NoteProperty @{foo='bar'} -HideProperty foo |
            Out-TypeData|
            Add-TypeData
        $o = [PSCustomObject]@{PSTypeName=$tn}
        $o.foo | should -Be bar

        Remove-TypeData -ModuleName $tn
    }

    it 'Can add an -AliasProperty' {
        $tn = "t$([Random]::new().Next())"
        Write-TypeView -TypeName $tn -AliasProperty @{
            mytypenames = 'pstypenames'
        } -HideProperty mytypenames | Out-TypeData | Add-TypeData
        ([PSCustomObject]@{PSTypeName=$tn}).mytypenames[0] | should -Be $tn
        Remove-TypeData -ModuleName $tn
    }

    it 'Can add a -ScriptMethod' {
        $tn = "t$([Random]::new().Next())"
        Write-TypeView -TypeName $tn -ScriptMethod @{
            GetTypeNames = {return $this.pstypenames}
        } | Out-TypeData | Add-TypeData
        ([PSCustomObject]@{PSTypeName=$tn}).GetTypeNames()[0] | should -Be $tn
    }

    it 'Can add an -EventName' {
        $scriptMethodXml = Write-TypeView -TypeName Stuff -EventName Happens |
            Select-Xml -Xpath //ScriptMethod |
            Select-Object -ExpandProperty Node

        $names = @($scriptMethodXml | ForEach-Object { $_.Name } | Sort-Object)

        $names[0] | Should -Be Register_Happens
        $names[1] | Should -Be Send_Happens
        $definitions = @($scriptMethodXml | ForEach-Object { $_.Script })
        $definitions[0] |
            Should -BeLike '*Register-EngineEvent*-SourceIdentifier $SourceIdentifier*'
        $definitions[1] |
            Should -BeLike '*New-Event*-SourceIdentifier*Stuff.Happens*'
    }



    it "Can get and set a -ScriptProperty" {
        $tn = "t$(Get-Random)"
        Write-TypeView -TypeName $tn -ScriptProperty @{
            foo = {
                "bar" # get
            }, {
                $global:set = $args # set
            }
        } -HideProperty foo |
            Out-TypeData |
            Add-TypeData

        $o = New-Object PSObject -Property @{PSTypeName=$tn}

        $o.foo | should -Be bar

        $o.foo = 'baz'
        $Global:set | should -Be baz
    }

    it 'Can make a read-only property' {
        $tn = "t$(Get-Random)"
        Write-TypeView -TypeName $tn -ScriptProperty @{
            foo = {
                "bar" # get
            }
        } -HideProperty foo |
            Out-TypeData |
            Add-TypeData
        $o = [PSCustomObject]@{PSTypeName=$tn}

        $o.foo | should -Be bar
        { $o.foo = 'baz' } | should -Throw

        Clear-TypeData
    }

    it 'Can change the -SerializationDepth (this is used in remoting)' {
        $tv = Write-TypeView -TypeName t -SerializationDepth 5
        $tvXml = [xml]$tv
        $tvXml.Type.Members.MemberSet.Members.NoteProperty.Value | should -Be 5
    }

    it 'Can specify a -Reserializer' {
        $tvXml = [xml](Write-TypeView -Reserializer ([Hashtable]) -TypeName t)
        $tvXml.Type.Members.MemberSet.Members.NoteProperty.Name | should -Be TargetTypeForDeserialization
        $tvXml.Type.Members.MemberSet.Members.NoteProperty.Value | should -Be hashtable
    }

    it 'Can specify -Deserialized (and get two type definitions for the price of one)' {
        $typenames =
        Write-TypeView -TypeName a -ScriptProperty @{b={"C"}} -Deserialized |
            Select-Xml -XPath /Type/Name |
            Select-Object -ExpandProperty Node |
            Select-Object -ExpandProperty '#Text'
        $typenames[0] | should -Be 'a'
        $typenames[1] | should -Be 'Deserialized.a'
    }

    context 'Fault Tolerance' {
        it 'Will only allow a [string] in -ScriptMethod keys' {
            { Write-TypeView -TypeName t -ScriptMethod @{2=1} } | should -Throw
        }
        it 'Will only allow a [ScriptBlock]s in-ScriptMethod values' {
            { Write-TypeView -TypeName t -ScriptMethod @{foo=1} } | should -Throw
        }
        it 'Will only allow a [string] in -ScriptProperty keys' {
            { Write-TypeView -TypeName t -ScriptProperty @{2=1} } | should -Throw
        }
        it 'Will only allow a [ScriptBlock]s in -ScriptProperty values' {
            { Write-TypeView -TypeName t -ScriptProperty @{foo=1} } | should -Throw
        }
        it 'Will only allow a [string] key in -AliasProperty' {
            { Write-TypeView -TypeName t -AliasProperty @{2=2}} | should -Throw
        }
        it 'Will allow no more than two [ScriptBlock] in a -ScriptProperty' {
            { Write-TypeView -TypeName t -ScriptProperty @{foo={'bar'},{'baz'},{'bing'} } }| should -Throw
        }
        it 'Will only allow a [string] key in -NoteProperty' {
            { Write-TypeView -TypeName t -NoteProperty @{2=2} } | should -Throw
        }

        it 'Will only allow a [string] key in -PropertySet' {
            { Write-TypeView -TypeName t -PropertySet @{1=2}} | should -Throw
        }
        it 'Will only allow a [string] or list value in -PropertySet' {
            { Write-TypeView -TypeName t -PropertySet @{"1"=2} } | should -Throw
        }
    }
}

describe 'Add-FormatData' {
    it 'Dynamically adds format data' {
        $tn = "type$(Get-Random)"

        Write-FormatView -TypeName $tn -Action { "Hello $env:UserName, it's $([DateTime]::Now)" } |
            Out-FormatData |
            Add-FormatData

        [PSCustomObject]@{PSTypeName=$tn;n=1} | Out-String | should -Belike *hello*
    }

    context 'Fault Tolerance' {
        it 'Will complain when passed bad XML' {
            { Add-FormatData -FormatXml "<blah/>" } | should -Throw
        }
        it 'Will create an automatic name when no TypeName is found' {
            Write-FormatView -AsControl -Action { "hi" } -Name control -TypeName t |
                Out-FormatData  |
                Add-FormatData -PassThru |
                Select-Object -ExpandProperty Name |
                should match 'FormatModule\d+'
        }
    }
}

describe 'Add-TypeData' {
    it 'Dynamically adds type data' {
        $tn = "t$([Random]::new().Next())"
        Write-TypeView -TypeName $tn -NoteProperty @{foo='bar'} |
            Out-TypeData|
            Add-TypeData -PassThru
        $o = [PSCustomObject]@{PSTypeName=$tn}
        $o.foo | should -Be bar
    }
    context 'Fault Tolerance' {
        it 'Will complain when passed bad XML' {
            { Add-TypeData -TypeXml '<blah />' } | should -Throw
        }
        it 'Will generate a module name when passed an empty <Type> (but will not load)' {
            { Add-TypeData -TypeXml '<Types><Type></Type></Types>' -ErrorAction Stop } | should -Throw
        }
    }
}


describe 'Out-FormatData' {
    it 'Combines one or more formatting into a single <Configuration>' {
        $fx = Write-FormatView -TypeName foo -Property bar |
            Out-FormatData
        $fxml = [xml]$fx
        $fxml.FirstChild.NextSibling.LocalName | should -Be '#comment'
        $fxml.FirstChild.NextSibling.NextSibling.LocalName | should -Be Configuration
    }

    it 'Can combine SelectionSets, Controls, and Views' {
        $fd = @(Write-FormatView -Action {
            Write-FormatViewExpress ion -If { $true } -ControlName MyControl -ScriptBlock { 1..10 } -Enumerate
        } -TypeName MyTypeName
        Write-FormatView -Action {$_ } -AsControl -Name MyControl -TypeName TN
        Write-FormatView -FormatXML '
            <SelectionSet>
                <Name>FileSystemTypes</Name>
                <Types>
                    <TypeName>System.IO.DirectoryInfo</TypeName>
                    <TypeName>System.IO.FileInfo</TypeName>
                </Types>
            </SelectionSet>' -TypeName TN
        ) | Out-FormatData
        ([xml]$fd).Configuration.ChildNodes.Count | should -Be 3
    }
    context 'Fault Tolerance' {
        it 'Will complain when passed bad XML' {
            { Out-FormatData -FormatXml '<blah/>'} | should -Throw
        }
    }
}

describe 'Out-TypeData' {
    it 'Combines one or more formatting into a single <Configuration>' {
        $tx = Write-TypeView -TypeName foo -DefaultDisplay bar |
            Out-TypeData
        $txml = [xml]$tx
        $txml.FirstChild.NextSibling.LocalName | should -Be '#Comment'
        $txml.FirstChild.NextSibling.NextSibling.LocalName | should -Be Types
    }
    context 'Fault Tolerance' {
        it 'Will complain when passed bad XML' {
            { Out-TypeData -TypeXml '<blah/>'} | should -Throw
        }
    }
}

describe 'Import-FormatView' {
    it 'Can import .format.ps1 and .view.ps1 files' {
        Get-Module EZOut |
            Split-Path |
            Join-Path -ChildPath Formatting |
            Get-Item |
            Import-FormatView
    }
    it 'Can import files with a relative path' {
        Get-Module EZOut |
            Split-Path |
            Join-Path -ChildPath Formatting |
            Push-Location

        Import-FormatView .\FileSystemTypes.format.xml
        Pop-Location
    }

    context 'Fault Tolerance' {
        it 'Will error if the file does not exist' {
            Get-Module EZOut |
                Split-Path |
                Join-Path -ChildPath Formatting |
                Push-Location

            { Import-FormatView .\ThisFileDoesNotExist.format.xml} | should -Throw
            Pop-Location
        }
    }
}

describe 'Import-TypeView' {
    it 'Can create type files out of directories' {
        $tmp =
            if ($env:PIPELINE_WORKSPACE) { $env:PIPELINE_WORKSPACE } 
            elseif ($env:TEMP) { "$env:TEMP" } 
            else { "/tmp" }
        $tmpDir = New-Item -ItemType Directory -Path (Join-Path $tmp "$(Get-Random)") 
        $testTypeDir = New-Item -ItemType Directory -Path (Join-Path $tmpDir.FullName "TestType$($tmpDir.Name)")
        Push-Location $testTypeDir.FullName
        Set-Content get_Foo.txt Foo
        Set-Content Alias.psd1 '@{Foo2="Foo"}'
        Set-Content DefaultDisplay.txt RandomNumber
        Set-Content get_RandomNumber.ps1 {Get-Random}
        Set-Content set_RandomNumber.ps1 {$args}
        Set-Content .HiddenProperty.txt Value
        Set-Content XmlProperty.xml '<Message language="en-us">hello</Message>'
        Set-Content DefaultDisplay.txt RandomNumber
        'Foo', 'RandomNumber' -join [Environment]::NewLine | 
            Set-Content Example.PropertySet.txt
        
        $typesXml = 
            [xml](Import-TypeView -FilePath $tmpDir.FullName | Out-TypeData)
        
        $typesXml | Add-TypeData
        $o = [PSCustomObject]@{PSTypeName=$testTypeDir.Name;N=1}
        $o.RandomNumber | Should -BeGreaterThan 1
        $o.HiddenProperty | Should -Be Value
        Pop-Location
        Remove-Item -Recurse -Force $tmpDir
        Clear-TypeData
    }
    context 'Fault Tolerance' {
        it 'Will error if the file does not exist' {
            Get-Module EZOut |
                Split-Path |
                Join-Path -ChildPath Formatting |
                Push-Location

            { Import-TypeView .\ThisFileDoesNotExist.types.xml -ErrorAction Stop } | should -Throw
            Pop-Location
        }
    }
}

describe 'Format-Object' {
    it 'Is an extensible format command' {
        "$(1,2,3 | Format-Object -NumberedList)" | Should -BeLike '*1.?1*2.?2*3.?3*'
        if ($host.UI.SupportsVirtualTerminal) {
            "$('red' | Format-Object -ForegroundColor "Red")" | Should -Match '\e.+Red'
        }
        "1","2","3" | Format-Object -YamlHeader | Should -BeLike '*- 1*- 2*- 3*'
        [PSCustomObject]@{a='b';c='d'} | Format-Object -MarkdownTable | Should -BeLike '*|a*|c*|*|b*|d*|'
        100 | Format-Object -HeatMapMax 100 -HeatMapHot 0xff0000 | Should -be '#ff0000'
    }
}

describe 'Format-YAML' {
    it 'Formats an object as YAML' {
        [Ordered]@{a=1;b=2.1;c='c';d=@{k='v'}} | Format-YAML | 
            Should -BeLike @'
*
a: 1
b: 2.1
c: c
d:
  k: v
'@
    }    
}