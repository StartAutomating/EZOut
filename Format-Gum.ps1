function Format-Gum {
[CmdletBinding(PositionalBinding=$false)]
[Management.Automation.Cmdlet("Format", "Object")]
param(
<#
The Command in Gum.
|CommandName|Description|
|-|-|
|choose|Choose an option from a list of choices|
|confirm|Ask a user to confirm an action|
|file|Pick a file from a folder|
|filter|Filter items from a list|
|format|Format a string using a template|
|input|Prompt for some input|
|join|Join text vertically or horizontally|
|pager|Scroll through a file|
|spin|Display spinner while running a command|
|style|Apply coloring, borders, spacing to text|
|table|Render a table of data|
|write|Prompt for long-form text|
#>
[Parameter(Mandatory,Position=0)]
[ValidateSet('choose','confirm','file','filter','format','input','join','pager','spin','style','table','write')]
[String]
$Command,
# The input object.
[Parameter(ValueFromPipeline)]
[Management.Automation.PSObject]
$InputObject,
# Any additional arguments
[Parameter(ValueFromRemainingArguments)]
[String[]]
$GumArgumentList,
# Show context-sensitive  
[ComponentModel.DefaultBindingProperty('help')]
[Management.Automation.SwitchParameter]
$Help,
# Print the  number
[ComponentModel.DefaultBindingProperty('version')]
[Management.Automation.SwitchParameter]
$Version,
# Maintain the order of the selected options
[ComponentModel.DefaultBindingProperty('ordered')]
[Management.Automation.SwitchParameter]
$Ordered,
#  of the list ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('height')]
[Management.Automation.PSObject]
$Height,
# "               Prefix to show on item that corresponds to the
[ComponentModel.DefaultBindingProperty('cursor')]
[Management.Automation.PSObject]
$Cursor,
#  value ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header')]
[Management.Automation.PSObject]
$Header,
# "        Prefix to show on the cursor item (hidden if
[ComponentModel.DefaultBindingProperty('cursor-prefix')]
[Management.Automation.PSObject]
$CursorPrefix,
# "      Prefix to show on selected items (hidden if
[ComponentModel.DefaultBindingProperty('selected-prefix')]
[Management.Automation.PSObject]
$SelectedPrefix,
# "
[ComponentModel.DefaultBindingProperty('unselected-prefix')]
[Management.Automation.PSObject]
$UnselectedPrefix,
# Options that should start as  
[ComponentModel.DefaultBindingProperty('selected')]
[Management.Automation.PSObject]
$Selected,
# Maximum number of options to pick
[ComponentModel.DefaultBindingProperty('limit')]
[Management.Automation.PSObject]
$Limit,
# Pick unlimited number of options (ignores limit)
[ComponentModel.DefaultBindingProperty('no-limit')]
[Management.Automation.SwitchParameter]
$NoLimit,
# Background Color
[ComponentModel.DefaultBindingProperty('cursor.background')]
[Management.Automation.PSObject]
$CursorBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('cursor.foreground')]
[Management.Automation.PSObject]
$CursorForeground,
# Border Style ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('cursor.border')]
[Management.Automation.PSObject]
$CursorBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('cursor.border-background')]
[Management.Automation.PSObject]
$CursorBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('cursor.border-foreground')]
[Management.Automation.PSObject]
$CursorBorderForeground,
# Text Alignment ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('cursor.align')]
[Management.Automation.PSObject]
$CursorAlign,
# Text height ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('cursor.height')]
[Management.Automation.PSObject]
$CursorHeight,
# Text width ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('cursor.width')]
[Management.Automation.PSObject]
$CursorWidth,
# 0"            Text margin ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('cursor.margin')]
[Management.Automation.PSObject]
$CursorMargin,
# 0"           Text padding ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('cursor.padding')]
[Management.Automation.PSObject]
$CursorPadding,
# Bold text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('cursor.bold')]
[Management.Automation.SwitchParameter]
$CursorBold,
# Faint text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('cursor.faint')]
[Management.Automation.SwitchParameter]
$CursorFaint,
# Italicize text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('cursor.italic')]
[Management.Automation.SwitchParameter]
$CursorItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('cursor.strikethrough')]
[Management.Automation.SwitchParameter]
$CursorStrikethrough,
# Underline text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('cursor.underline')]
[Management.Automation.SwitchParameter]
$CursorUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('header.background')]
[Management.Automation.PSObject]
$HeaderBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('header.foreground')]
[Management.Automation.PSObject]
$HeaderForeground,
# Border Style ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header.border')]
[Management.Automation.PSObject]
$HeaderBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('header.border-background')]
[Management.Automation.PSObject]
$HeaderBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('header.border-foreground')]
[Management.Automation.PSObject]
$HeaderBorderForeground,
# Text Alignment ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header.align')]
[Management.Automation.PSObject]
$HeaderAlign,
# Text height ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header.height')]
[Management.Automation.PSObject]
$HeaderHeight,
# Text width ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header.width')]
[Management.Automation.PSObject]
$HeaderWidth,
# 0"            Text margin ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header.margin')]
[Management.Automation.PSObject]
$HeaderMargin,
# 0"           Text padding ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header.padding')]
[Management.Automation.PSObject]
$HeaderPadding,
# Bold text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header.bold')]
[Management.Automation.SwitchParameter]
$HeaderBold,
# Faint text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header.faint')]
[Management.Automation.SwitchParameter]
$HeaderFaint,
# Italicize text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header.italic')]
[Management.Automation.SwitchParameter]
$HeaderItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('header.strikethrough')]
[Management.Automation.SwitchParameter]
$HeaderStrikethrough,
# Underline text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('header.underline')]
[Management.Automation.SwitchParameter]
$HeaderUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('item.background')]
[Management.Automation.PSObject]
$ItemBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('item.foreground')]
[Management.Automation.PSObject]
$ItemForeground,
# Border Style ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('item.border')]
[Management.Automation.PSObject]
$ItemBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('item.border-background')]
[Management.Automation.PSObject]
$ItemBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('item.border-foreground')]
[Management.Automation.PSObject]
$ItemBorderForeground,
# Text Alignment ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('item.align')]
[Management.Automation.PSObject]
$ItemAlign,
# Text height ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('item.height')]
[Management.Automation.PSObject]
$ItemHeight,
# Text width ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('item.width')]
[Management.Automation.PSObject]
$ItemWidth,
# 0"              Text margin ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('item.margin')]
[Management.Automation.PSObject]
$ItemMargin,
# 0"             Text padding ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('item.padding')]
[Management.Automation.PSObject]
$ItemPadding,
# Bold text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('item.bold')]
[Management.Automation.SwitchParameter]
$ItemBold,
# Faint text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('item.faint')]
[Management.Automation.SwitchParameter]
$ItemFaint,
# Italicize text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('item.italic')]
[Management.Automation.SwitchParameter]
$ItemItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('item.strikethrough')]
[Management.Automation.SwitchParameter]
$ItemStrikethrough,
# Underline text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('item.underline')]
[Management.Automation.SwitchParameter]
$ItemUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('selected.background')]
[Management.Automation.PSObject]
$SelectedBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('selected.foreground')]
[Management.Automation.PSObject]
$SelectedForeground,
# Border Style ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('selected.border')]
[Management.Automation.PSObject]
$SelectedBorder,
[ComponentModel.DefaultBindingProperty('selected.border-background')]
[Management.Automation.PSObject]
$SelectedBorderBackground,
[ComponentModel.DefaultBindingProperty('selected.border-foreground')]
[Management.Automation.PSObject]
$SelectedBorderForeground,
# Text Alignment ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('selected.align')]
[Management.Automation.PSObject]
$SelectedAlign,
# Text height ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('selected.height')]
[Management.Automation.PSObject]
$SelectedHeight,
# Text width ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('selected.width')]
[Management.Automation.PSObject]
$SelectedWidth,
# 0"          Text margin ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('selected.margin')]
[Management.Automation.PSObject]
$SelectedMargin,
# 0"         Text padding ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('selected.padding')]
[Management.Automation.PSObject]
$SelectedPadding,
# Bold text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('selected.bold')]
[Management.Automation.SwitchParameter]
$SelectedBold,
# Faint text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('selected.faint')]
[Management.Automation.SwitchParameter]
$SelectedFaint,
# Italicize text ($GUM_CHOOSE_ 
[ComponentModel.DefaultBindingProperty('selected.italic')]
[Management.Automation.SwitchParameter]
$SelectedItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('selected.strikethrough')]
[Management.Automation.SwitchParameter]
$SelectedStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('selected.underline')]
[Management.Automation.SwitchParameter]
$SelectedUnderline,
# The title of the  action
[ComponentModel.DefaultBindingProperty('affirmative')]
[Management.Automation.PSObject]
$Affirmative,
# The title of the  action
[ComponentModel.DefaultBindingProperty('negative')]
[Management.Automation.PSObject]
$Negative,
#  confirmation action
[ComponentModel.DefaultBindingProperty('default')]
[Management.Automation.SwitchParameter]
$Default,
#  for confirmation ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('timeout')]
[Management.Automation.PSObject]
$Timeout,
# Background Color
[ComponentModel.DefaultBindingProperty('prompt.background')]
[Management.Automation.PSObject]
$PromptBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('prompt.foreground')]
[Management.Automation.PSObject]
$PromptForeground,
# Border Style ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('prompt.border')]
[Management.Automation.PSObject]
$PromptBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('prompt.border-background')]
[Management.Automation.PSObject]
$PromptBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('prompt.border-foreground')]
[Management.Automation.PSObject]
$PromptBorderForeground,
# Text Alignment ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('prompt.align')]
[Management.Automation.PSObject]
$PromptAlign,
# Text height ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('prompt.height')]
[Management.Automation.PSObject]
$PromptHeight,
# Text width ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('prompt.width')]
[Management.Automation.PSObject]
$PromptWidth,
# 0 0 0"        Text margin ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('prompt.margin')]
[Management.Automation.PSObject]
$PromptMargin,
# 0"           Text padding ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('prompt.padding')]
[Management.Automation.PSObject]
$PromptPadding,
# Bold text ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('prompt.bold')]
[Management.Automation.SwitchParameter]
$PromptBold,
# Faint text ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('prompt.faint')]
[Management.Automation.SwitchParameter]
$PromptFaint,
# Italicize text ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('prompt.italic')]
[Management.Automation.SwitchParameter]
$PromptItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('prompt.strikethrough')]
[Management.Automation.SwitchParameter]
$PromptStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('prompt.underline')]
[Management.Automation.SwitchParameter]
$PromptUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('unselected.background')]
[Management.Automation.PSObject]
$UnselectedBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('unselected.foreground')]
[Management.Automation.PSObject]
$UnselectedForeground,
# Border Style ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('unselected.border')]
[Management.Automation.PSObject]
$UnselectedBorder,
[ComponentModel.DefaultBindingProperty('unselected.border-background')]
[Management.Automation.PSObject]
$UnselectedBorderBackground,
[ComponentModel.DefaultBindingProperty('unselected.border-foreground')]
[Management.Automation.PSObject]
$UnselectedBorderForeground,
# Text Alignment
[ComponentModel.DefaultBindingProperty('unselected.align')]
[Management.Automation.PSObject]
$UnselectedAlign,
# Text height ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('unselected.height')]
[Management.Automation.PSObject]
$UnselectedHeight,
# Text width ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('unselected.width')]
[Management.Automation.PSObject]
$UnselectedWidth,
# 1"        Text margin ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('unselected.margin')]
[Management.Automation.PSObject]
$UnselectedMargin,
# 3"       Text padding
[ComponentModel.DefaultBindingProperty('unselected.padding')]
[Management.Automation.PSObject]
$UnselectedPadding,
# Bold text ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('unselected.bold')]
[Management.Automation.SwitchParameter]
$UnselectedBold,
# Faint text ($GUM_CONFIRM_ 
[ComponentModel.DefaultBindingProperty('unselected.faint')]
[Management.Automation.SwitchParameter]
$UnselectedFaint,
# Italicize text
[ComponentModel.DefaultBindingProperty('unselected.italic')]
[Management.Automation.SwitchParameter]
$UnselectedItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('unselected.strikethrough')]
[Management.Automation.SwitchParameter]
$UnselectedStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('unselected.underline')]
[Management.Automation.SwitchParameter]
$UnselectedUnderline,
# Show hidden and 'dot' files ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('all')]
[Management.Automation.SwitchParameter]
$All,
# Allow  selection ($GUM_ 
[ComponentModel.DefaultBindingProperty('file')]
[Management.Automation.SwitchParameter]
$File,
# Allow directories selection ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('directory')]
[Management.Automation.SwitchParameter]
$Directory,
# Background Color
[ComponentModel.DefaultBindingProperty('symlink.background')]
[Management.Automation.PSObject]
$SymlinkBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('symlink.foreground')]
[Management.Automation.PSObject]
$SymlinkForeground,
# Border Style ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('symlink.border')]
[Management.Automation.PSObject]
$SymlinkBorder,
[ComponentModel.DefaultBindingProperty('symlink.border-background')]
[Management.Automation.PSObject]
$SymlinkBorderBackground,
[ComponentModel.DefaultBindingProperty('symlink.border-foreground')]
[Management.Automation.PSObject]
$SymlinkBorderForeground,
# Text Alignment ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('symlink.align')]
[Management.Automation.PSObject]
$SymlinkAlign,
# Text height ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('symlink.height')]
[Management.Automation.PSObject]
$SymlinkHeight,
# Text width ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('symlink.width')]
[Management.Automation.PSObject]
$SymlinkWidth,
# 0"           Text margin ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('symlink.margin')]
[Management.Automation.PSObject]
$SymlinkMargin,
# 0"          Text padding ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('symlink.padding')]
[Management.Automation.PSObject]
$SymlinkPadding,
# Bold text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('symlink.bold')]
[Management.Automation.SwitchParameter]
$SymlinkBold,
# Faint text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('symlink.faint')]
[Management.Automation.SwitchParameter]
$SymlinkFaint,
# Italicize text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('symlink.italic')]
[Management.Automation.SwitchParameter]
$SymlinkItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('symlink.strikethrough')]
[Management.Automation.SwitchParameter]
$SymlinkStrikethrough,
# Underline text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('symlink.underline')]
[Management.Automation.SwitchParameter]
$SymlinkUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('directory.background')]
[Management.Automation.PSObject]
$DirectoryBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('directory.foreground')]
[Management.Automation.PSObject]
$DirectoryForeground,
# Border Style ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('directory.border')]
[Management.Automation.PSObject]
$DirectoryBorder,
[ComponentModel.DefaultBindingProperty('directory.border-background')]
[Management.Automation.PSObject]
$DirectoryBorderBackground,
[ComponentModel.DefaultBindingProperty('directory.border-foreground')]
[Management.Automation.PSObject]
$DirectoryBorderForeground,
# Text Alignment ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('directory.align')]
[Management.Automation.PSObject]
$DirectoryAlign,
# Text height ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('directory.height')]
[Management.Automation.PSObject]
$DirectoryHeight,
# Text width ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('directory.width')]
[Management.Automation.PSObject]
$DirectoryWidth,
# 0"         Text margin ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('directory.margin')]
[Management.Automation.PSObject]
$DirectoryMargin,
# 0"        Text padding ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('directory.padding')]
[Management.Automation.PSObject]
$DirectoryPadding,
# Bold text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('directory.bold')]
[Management.Automation.SwitchParameter]
$DirectoryBold,
# Faint text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('directory.faint')]
[Management.Automation.SwitchParameter]
$DirectoryFaint,
# Italicize text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('directory.italic')]
[Management.Automation.SwitchParameter]
$DirectoryItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('directory.strikethrough')]
[Management.Automation.SwitchParameter]
$DirectoryStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('directory.underline')]
[Management.Automation.SwitchParameter]
$DirectoryUnderline,
# Background Color ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.background')]
[Management.Automation.PSObject]
$FileBackground,
# Foreground Color ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.foreground')]
[Management.Automation.PSObject]
$FileForeground,
# Border Style ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.border')]
[Management.Automation.PSObject]
$FileBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('file.border-background')]
[Management.Automation.PSObject]
$FileBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('file.border-foreground')]
[Management.Automation.PSObject]
$FileBorderForeground,
# Text Alignment ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.align')]
[Management.Automation.PSObject]
$FileAlign,
# Text height ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.height')]
[Management.Automation.PSObject]
$FileHeight,
# Text width ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.width')]
[Management.Automation.PSObject]
$FileWidth,
# 0"              Text margin ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.margin')]
[Management.Automation.PSObject]
$FileMargin,
# 0"             Text padding ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.padding')]
[Management.Automation.PSObject]
$FilePadding,
# Bold text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.bold')]
[Management.Automation.SwitchParameter]
$FileBold,
# Faint text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.faint')]
[Management.Automation.SwitchParameter]
$FileFaint,
# Italicize text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.italic')]
[Management.Automation.SwitchParameter]
$FileItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('file.strikethrough')]
[Management.Automation.SwitchParameter]
$FileStrikethrough,
# Underline text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('file.underline')]
[Management.Automation.SwitchParameter]
$FileUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('permissions.background')]
[Management.Automation.PSObject]
$PermissionsBackground,
[ComponentModel.DefaultBindingProperty('permissions.foreground')]
[Management.Automation.PSObject]
$PermissionsForeground,
# Border Style ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('permissions.border')]
[Management.Automation.PSObject]
$PermissionsBorder,
[ComponentModel.DefaultBindingProperty('permissions.border-background')]
[Management.Automation.PSObject]
$PermissionsBorderBackground,
[ComponentModel.DefaultBindingProperty('permissions.border-foreground')]
[Management.Automation.PSObject]
$PermissionsBorderForeground,
# Text Alignment ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('permissions.align')]
[Management.Automation.PSObject]
$PermissionsAlign,
# Text height ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('permissions.height')]
[Management.Automation.PSObject]
$PermissionsHeight,
# Text width ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('permissions.width')]
[Management.Automation.PSObject]
$PermissionsWidth,
# 0"       Text margin ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('permissions.margin')]
[Management.Automation.PSObject]
$PermissionsMargin,
# 0"      Text padding ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('permissions.padding')]
[Management.Automation.PSObject]
$PermissionsPadding,
# Bold text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('permissions.bold')]
[Management.Automation.SwitchParameter]
$PermissionsBold,
# Faint text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('permissions.faint')]
[Management.Automation.SwitchParameter]
$PermissionsFaint,
# Italicize text ($GUM_FILE_ 
[ComponentModel.DefaultBindingProperty('permissions.italic')]
[Management.Automation.SwitchParameter]
$PermissionsItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('permissions.strikethrough')]
[Management.Automation.SwitchParameter]
$PermissionsStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('permissions.underline')]
[Management.Automation.SwitchParameter]
$PermissionsUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('file-size.background')]
[Management.Automation.PSObject]
$FileSizeBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('file-size.foreground')]
[Management.Automation.PSObject]
$FileSizeForeground,
# Border Style ($GUM_FILE_FILE_SIZE_BORDER)
[ComponentModel.DefaultBindingProperty('file-size.border')]
[Management.Automation.PSObject]
$FileSizeBorder,
[ComponentModel.DefaultBindingProperty('file-size.border-background')]
[Management.Automation.PSObject]
$FileSizeBorderBackground,
[ComponentModel.DefaultBindingProperty('file-size.border-foreground')]
[Management.Automation.PSObject]
$FileSizeBorderForeground,
# Text Alignment ($GUM_FILE_FILE_SIZE_ALIGN)
[ComponentModel.DefaultBindingProperty('file-size.align')]
[Management.Automation.PSObject]
$FileSizeAlign,
# Text height ($GUM_FILE_FILE_SIZE_HEIGHT)
[ComponentModel.DefaultBindingProperty('file-size.height')]
[Management.Automation.PSObject]
$FileSizeHeight,
# Text width ($GUM_FILE_FILE_SIZE_WIDTH)
[ComponentModel.DefaultBindingProperty('file-size.width')]
[Management.Automation.PSObject]
$FileSizeWidth,
# 0"         Text margin ($GUM_FILE_FILE_SIZE_MARGIN)
[ComponentModel.DefaultBindingProperty('file-size.margin')]
[Management.Automation.PSObject]
$FileSizeMargin,
# 0"        Text padding ($GUM_FILE_FILE_SIZE_PADDING)
[ComponentModel.DefaultBindingProperty('file-size.padding')]
[Management.Automation.PSObject]
$FileSizePadding,
# Bold text ($GUM_FILE_FILE_SIZE_BOLD)
[ComponentModel.DefaultBindingProperty('file-size.bold')]
[Management.Automation.SwitchParameter]
$FileSizeBold,
# Faint text ($GUM_FILE_FILE_SIZE_FAINT)
[ComponentModel.DefaultBindingProperty('file-size.faint')]
[Management.Automation.SwitchParameter]
$FileSizeFaint,
# Italicize text ($GUM_FILE_FILE_SIZE_ITALIC)
[ComponentModel.DefaultBindingProperty('file-size.italic')]
[Management.Automation.SwitchParameter]
$FileSizeItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('file-size.strikethrough')]
[Management.Automation.SwitchParameter]
$FileSizeStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('file-size.underline')]
[Management.Automation.SwitchParameter]
$FileSizeUnderline,
# Character for selection
[ComponentModel.DefaultBindingProperty('indicator')]
[Management.Automation.PSObject]
$Indicator,
#  value ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('placeholder')]
[Management.Automation.PSObject]
$Placeholder,
# "                 to display ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('prompt')]
[Management.Automation.PSObject]
$Prompt,
# Input  ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('width')]
[Management.Automation.PSObject]
$Width,
# Initial filter  ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('value')]
[Management.Automation.PSObject]
$Value,
# Display from the bottom of the screen
[ComponentModel.DefaultBindingProperty('reverse')]
[Management.Automation.SwitchParameter]
$Reverse,
# Background Color
[ComponentModel.DefaultBindingProperty('indicator.background')]
[Management.Automation.PSObject]
$IndicatorBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('indicator.foreground')]
[Management.Automation.PSObject]
$IndicatorForeground,
# Border Style ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('indicator.border')]
[Management.Automation.PSObject]
$IndicatorBorder,
[ComponentModel.DefaultBindingProperty('indicator.border-background')]
[Management.Automation.PSObject]
$IndicatorBorderBackground,
[ComponentModel.DefaultBindingProperty('indicator.border-foreground')]
[Management.Automation.PSObject]
$IndicatorBorderForeground,
# Text Alignment ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('indicator.align')]
[Management.Automation.PSObject]
$IndicatorAlign,
# Text height ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('indicator.height')]
[Management.Automation.PSObject]
$IndicatorHeight,
# Text width ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('indicator.width')]
[Management.Automation.PSObject]
$IndicatorWidth,
# 0"         Text margin ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('indicator.margin')]
[Management.Automation.PSObject]
$IndicatorMargin,
# 0"        Text padding ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('indicator.padding')]
[Management.Automation.PSObject]
$IndicatorPadding,
# Bold text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('indicator.bold')]
[Management.Automation.SwitchParameter]
$IndicatorBold,
# Faint text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('indicator.faint')]
[Management.Automation.SwitchParameter]
$IndicatorFaint,
# Italicize text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('indicator.italic')]
[Management.Automation.SwitchParameter]
$IndicatorItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('indicator.strikethrough')]
[Management.Automation.SwitchParameter]
$IndicatorStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('indicator.underline')]
[Management.Automation.SwitchParameter]
$IndicatorUnderline,
[ComponentModel.DefaultBindingProperty('selected-indicator.background')]
[Management.Automation.PSObject]
$SelectedIndicatorBackground,
[ComponentModel.DefaultBindingProperty('selected-indicator.foreground')]
[Management.Automation.PSObject]
$SelectedIndicatorForeground,
[ComponentModel.DefaultBindingProperty('selected-indicator.border')]
[Management.Automation.PSObject]
$SelectedIndicatorBorder,
[ComponentModel.DefaultBindingProperty('selected-indicator.border-background')]
[Management.Automation.PSObject]
$SelectedIndicatorBorderBackground,
[ComponentModel.DefaultBindingProperty('selected-indicator.border-foreground')]
[Management.Automation.PSObject]
$SelectedIndicatorBorderForeground,
[ComponentModel.DefaultBindingProperty('selected-indicator.align')]
[Management.Automation.PSObject]
$SelectedIndicatorAlign,
# Text height
[ComponentModel.DefaultBindingProperty('selected-indicator.height')]
[Management.Automation.PSObject]
$SelectedIndicatorHeight,
# Text width
[ComponentModel.DefaultBindingProperty('selected-indicator.width')]
[Management.Automation.PSObject]
$SelectedIndicatorWidth,
# 0"
[ComponentModel.DefaultBindingProperty('selected-indicator.margin')]
[Management.Automation.PSObject]
$SelectedIndicatorMargin,
# 0"
[ComponentModel.DefaultBindingProperty('selected-indicator.padding')]
[Management.Automation.PSObject]
$SelectedIndicatorPadding,
# Bold text ($GUM_FILTER_SELECTED_PREFIX_BOLD)
[ComponentModel.DefaultBindingProperty('selected-indicator.bold')]
[Management.Automation.SwitchParameter]
$SelectedIndicatorBold,
# Faint text
[ComponentModel.DefaultBindingProperty('selected-indicator.faint')]
[Management.Automation.SwitchParameter]
$SelectedIndicatorFaint,
# Italicize text
[ComponentModel.DefaultBindingProperty('selected-indicator.italic')]
[Management.Automation.SwitchParameter]
$SelectedIndicatorItalic,
[ComponentModel.DefaultBindingProperty('selected-indicator.strikethrough')]
[Management.Automation.SwitchParameter]
$SelectedIndicatorStrikethrough,
[ComponentModel.DefaultBindingProperty('selected-indicator.underline')]
[Management.Automation.SwitchParameter]
$SelectedIndicatorUnderline,
[ComponentModel.DefaultBindingProperty('unselected-prefix.background')]
[Management.Automation.PSObject]
$UnselectedPrefixBackground,
[ComponentModel.DefaultBindingProperty('unselected-prefix.foreground')]
[Management.Automation.PSObject]
$UnselectedPrefixForeground,
[ComponentModel.DefaultBindingProperty('unselected-prefix.border')]
[Management.Automation.PSObject]
$UnselectedPrefixBorder,
[ComponentModel.DefaultBindingProperty('unselected-prefix.border-background')]
[Management.Automation.PSObject]
$UnselectedPrefixBorderBackground,
[ComponentModel.DefaultBindingProperty('unselected-prefix.border-foreground')]
[Management.Automation.PSObject]
$UnselectedPrefixBorderForeground,
[ComponentModel.DefaultBindingProperty('unselected-prefix.align')]
[Management.Automation.PSObject]
$UnselectedPrefixAlign,
# Text height
[ComponentModel.DefaultBindingProperty('unselected-prefix.height')]
[Management.Automation.PSObject]
$UnselectedPrefixHeight,
# Text width
[ComponentModel.DefaultBindingProperty('unselected-prefix.width')]
[Management.Automation.PSObject]
$UnselectedPrefixWidth,
# 0"
[ComponentModel.DefaultBindingProperty('unselected-prefix.margin')]
[Management.Automation.PSObject]
$UnselectedPrefixMargin,
# 0"
[ComponentModel.DefaultBindingProperty('unselected-prefix.padding')]
[Management.Automation.PSObject]
$UnselectedPrefixPadding,
# Bold text
[ComponentModel.DefaultBindingProperty('unselected-prefix.bold')]
[Management.Automation.SwitchParameter]
$UnselectedPrefixBold,
# Faint text
[ComponentModel.DefaultBindingProperty('unselected-prefix.faint')]
[Management.Automation.SwitchParameter]
$UnselectedPrefixFaint,
# Italicize text
[ComponentModel.DefaultBindingProperty('unselected-prefix.italic')]
[Management.Automation.SwitchParameter]
$UnselectedPrefixItalic,
[ComponentModel.DefaultBindingProperty('unselected-prefix.strikethrough')]
[Management.Automation.SwitchParameter]
$UnselectedPrefixStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('unselected-prefix.underline')]
[Management.Automation.SwitchParameter]
$UnselectedPrefixUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('text.background')]
[Management.Automation.PSObject]
$TextBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('text.foreground')]
[Management.Automation.PSObject]
$TextForeground,
# Border Style ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('text.border')]
[Management.Automation.PSObject]
$TextBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('text.border-background')]
[Management.Automation.PSObject]
$TextBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('text.border-foreground')]
[Management.Automation.PSObject]
$TextBorderForeground,
#  ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('text.align')]
[Management.Automation.PSObject]
$TextAlign,
#  ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('text.height')]
[Management.Automation.PSObject]
$TextHeight,
#  ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('text.width')]
[Management.Automation.PSObject]
$TextWidth,
# 0"               ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('text.margin')]
[Management.Automation.PSObject]
$TextMargin,
# 0"              ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('text.padding')]
[Management.Automation.PSObject]
$TextPadding,
# Bold text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('text.bold')]
[Management.Automation.SwitchParameter]
$TextBold,
# Faint text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('text.faint')]
[Management.Automation.SwitchParameter]
$TextFaint,
# Italicize text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('text.italic')]
[Management.Automation.SwitchParameter]
$TextItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('text.strikethrough')]
[Management.Automation.SwitchParameter]
$TextStrikethrough,
# Underline text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('text.underline')]
[Management.Automation.SwitchParameter]
$TextUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('match.background')]
[Management.Automation.PSObject]
$MatchBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('match.foreground')]
[Management.Automation.PSObject]
$MatchForeground,
# Border Style ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('match.border')]
[Management.Automation.PSObject]
$MatchBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('match.border-background')]
[Management.Automation.PSObject]
$MatchBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('match.border-foreground')]
[Management.Automation.PSObject]
$MatchBorderForeground,
# Text Alignment ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('match.align')]
[Management.Automation.PSObject]
$MatchAlign,
# Text height ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('match.height')]
[Management.Automation.PSObject]
$MatchHeight,
# Text width ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('match.width')]
[Management.Automation.PSObject]
$MatchWidth,
# 0"             Text margin ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('match.margin')]
[Management.Automation.PSObject]
$MatchMargin,
# 0"            Text padding ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('match.padding')]
[Management.Automation.PSObject]
$MatchPadding,
# Bold text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('match.bold')]
[Management.Automation.SwitchParameter]
$MatchBold,
# Faint text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('match.faint')]
[Management.Automation.SwitchParameter]
$MatchFaint,
# Italicize text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('match.italic')]
[Management.Automation.SwitchParameter]
$MatchItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('match.strikethrough')]
[Management.Automation.SwitchParameter]
$MatchStrikethrough,
# Underline text ($GUM_FILTER_ 
[ComponentModel.DefaultBindingProperty('match.underline')]
[Management.Automation.SwitchParameter]
$MatchUnderline,
# Glamour  to use for markdown formatting
[ComponentModel.DefaultBindingProperty('theme')]
[Management.Automation.PSObject]
$Theme,
# Programming  to parse code
[ComponentModel.DefaultBindingProperty('language')]
[Management.Automation.PSObject]
$Language,
# Format to use (markdown,template,code,emoji)
[ComponentModel.DefaultBindingProperty('type')]
[Management.Automation.PSObject]
$Type,
# Maximum value length (0 for no limit)
[ComponentModel.DefaultBindingProperty('char-limit')]
[Management.Automation.PSObject]
$CharLimit,
# Mask input characters
[ComponentModel.DefaultBindingProperty('password')]
[Management.Automation.SwitchParameter]
$Password,
# Text  
[ComponentModel.DefaultBindingProperty('align')]
[Management.Automation.PSObject]
$Align,
# Join (potentially multi-line) strings  
[ComponentModel.DefaultBindingProperty('horizontal')]
[Management.Automation.SwitchParameter]
$Horizontal,
# Join (potentially multi-line) strings  
[ComponentModel.DefaultBindingProperty('vertical')]
[Management.Automation.SwitchParameter]
$Vertical,
# Show line numbers
[ComponentModel.DefaultBindingProperty('show-line-numbers')]
[Management.Automation.SwitchParameter]
$ShowLineNumbers,
# Soft wrap lines
[ComponentModel.DefaultBindingProperty('soft-wrap')]
[Management.Automation.SwitchParameter]
$SoftWrap,
#  Color ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('background')]
[Management.Automation.PSObject]
$Background,
#  Color ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('foreground')]
[Management.Automation.PSObject]
$Foreground,
#  Style ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('border')]
[Management.Automation.PSObject]
$Border,
# Border Background Color
[ComponentModel.DefaultBindingProperty('border-background')]
[Management.Automation.PSObject]
$BorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('border-foreground')]
[Management.Automation.PSObject]
$BorderForeground,
# 0"                 Text  ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('margin')]
[Management.Automation.PSObject]
$Margin,
# 1"                Text  ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('padding')]
[Management.Automation.PSObject]
$Padding,
#  text ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('bold')]
[Management.Automation.SwitchParameter]
$Bold,
#  text ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('faint')]
[Management.Automation.SwitchParameter]
$Faint,
#  text ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('italic')]
[Management.Automation.SwitchParameter]
$Italic,
#  text ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('strikethrough')]
[Management.Automation.SwitchParameter]
$Strikethrough,
#  text ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('underline')]
[Management.Automation.SwitchParameter]
$Underline,
# Background Color ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.background')]
[Management.Automation.PSObject]
$HelpBackground,
# Foreground Color ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.foreground')]
[Management.Automation.PSObject]
$HelpForeground,
# Border Style ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.border')]
[Management.Automation.PSObject]
$HelpBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('help.border-background')]
[Management.Automation.PSObject]
$HelpBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('help.border-foreground')]
[Management.Automation.PSObject]
$HelpBorderForeground,
# Text Alignment ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.align')]
[Management.Automation.PSObject]
$HelpAlign,
# Text height ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.height')]
[Management.Automation.PSObject]
$HelpHeight,
# Text width ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.width')]
[Management.Automation.PSObject]
$HelpWidth,
# 0"            Text margin ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.margin')]
[Management.Automation.PSObject]
$HelpMargin,
# 0"           Text padding ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.padding')]
[Management.Automation.PSObject]
$HelpPadding,
# Bold text ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.bold')]
[Management.Automation.SwitchParameter]
$HelpBold,
# Faint text ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.faint')]
[Management.Automation.SwitchParameter]
$HelpFaint,
# Italicize text ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.italic')]
[Management.Automation.SwitchParameter]
$HelpItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('help.strikethrough')]
[Management.Automation.SwitchParameter]
$HelpStrikethrough,
# Underline text ($GUM_PAGER_ 
[ComponentModel.DefaultBindingProperty('help.underline')]
[Management.Automation.SwitchParameter]
$HelpUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('line-number.background')]
[Management.Automation.PSObject]
$LineNumberBackground,
[ComponentModel.DefaultBindingProperty('line-number.foreground')]
[Management.Automation.PSObject]
$LineNumberForeground,
# Border Style ($GUM_PAGER_LINE_NUMBER_BORDER)
[ComponentModel.DefaultBindingProperty('line-number.border')]
[Management.Automation.PSObject]
$LineNumberBorder,
[ComponentModel.DefaultBindingProperty('line-number.border-background')]
[Management.Automation.PSObject]
$LineNumberBorderBackground,
[ComponentModel.DefaultBindingProperty('line-number.border-foreground')]
[Management.Automation.PSObject]
$LineNumberBorderForeground,
# Text Alignment ($GUM_PAGER_LINE_NUMBER_ALIGN)
[ComponentModel.DefaultBindingProperty('line-number.align')]
[Management.Automation.PSObject]
$LineNumberAlign,
# Text height ($GUM_PAGER_LINE_NUMBER_HEIGHT)
[ComponentModel.DefaultBindingProperty('line-number.height')]
[Management.Automation.PSObject]
$LineNumberHeight,
# Text width ($GUM_PAGER_LINE_NUMBER_WIDTH)
[ComponentModel.DefaultBindingProperty('line-number.width')]
[Management.Automation.PSObject]
$LineNumberWidth,
# 0"     Text margin ($GUM_PAGER_LINE_NUMBER_MARGIN)
[ComponentModel.DefaultBindingProperty('line-number.margin')]
[Management.Automation.PSObject]
$LineNumberMargin,
# 0"    Text padding ($GUM_PAGER_LINE_NUMBER_PADDING)
[ComponentModel.DefaultBindingProperty('line-number.padding')]
[Management.Automation.PSObject]
$LineNumberPadding,
# Bold text ($GUM_PAGER_LINE_NUMBER_BOLD)
[ComponentModel.DefaultBindingProperty('line-number.bold')]
[Management.Automation.SwitchParameter]
$LineNumberBold,
# Faint text ($GUM_PAGER_LINE_NUMBER_FAINT)
[ComponentModel.DefaultBindingProperty('line-number.faint')]
[Management.Automation.SwitchParameter]
$LineNumberFaint,
# Italicize text ($GUM_PAGER_LINE_NUMBER_ITALIC)
[ComponentModel.DefaultBindingProperty('line-number.italic')]
[Management.Automation.SwitchParameter]
$LineNumberItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('line-number.strikethrough')]
[Management.Automation.SwitchParameter]
$LineNumberStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('line-number.underline')]
[Management.Automation.SwitchParameter]
$LineNumberUnderline,
# Show output of command ($GUM_SPIN_SHOW_OUTPUT)
[ComponentModel.DefaultBindingProperty('show-output')]
[Management.Automation.SwitchParameter]
$ShowOutput,
#  type ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner')]
[Management.Automation.PSObject]
$Spinner,
# Text to display to user while spinning
[ComponentModel.DefaultBindingProperty('title')]
[Management.Automation.PSObject]
$Title,
# Background Color
[ComponentModel.DefaultBindingProperty('spinner.background')]
[Management.Automation.PSObject]
$SpinnerBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('spinner.foreground')]
[Management.Automation.PSObject]
$SpinnerForeground,
# Border Style ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner.border')]
[Management.Automation.PSObject]
$SpinnerBorder,
[ComponentModel.DefaultBindingProperty('spinner.border-background')]
[Management.Automation.PSObject]
$SpinnerBorderBackground,
[ComponentModel.DefaultBindingProperty('spinner.border-foreground')]
[Management.Automation.PSObject]
$SpinnerBorderForeground,
# Text Alignment ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner.align')]
[Management.Automation.PSObject]
$SpinnerAlign,
# Text height ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner.height')]
[Management.Automation.PSObject]
$SpinnerHeight,
# Text width ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner.width')]
[Management.Automation.PSObject]
$SpinnerWidth,
# 0"          Text margin ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner.margin')]
[Management.Automation.PSObject]
$SpinnerMargin,
# 0"         Text padding ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner.padding')]
[Management.Automation.PSObject]
$SpinnerPadding,
# Bold text ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner.bold')]
[Management.Automation.SwitchParameter]
$SpinnerBold,
# Faint text ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner.faint')]
[Management.Automation.SwitchParameter]
$SpinnerFaint,
# Italicize text ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner.italic')]
[Management.Automation.SwitchParameter]
$SpinnerItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('spinner.strikethrough')]
[Management.Automation.SwitchParameter]
$SpinnerStrikethrough,
# Underline text ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('spinner.underline')]
[Management.Automation.SwitchParameter]
$SpinnerUnderline,
# Background Color ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.background')]
[Management.Automation.PSObject]
$TitleBackground,
# Foreground Color ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.foreground')]
[Management.Automation.PSObject]
$TitleForeground,
# Border Style ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.border')]
[Management.Automation.PSObject]
$TitleBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('title.border-background')]
[Management.Automation.PSObject]
$TitleBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('title.border-foreground')]
[Management.Automation.PSObject]
$TitleBorderForeground,
# Text Alignment ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.align')]
[Management.Automation.PSObject]
$TitleAlign,
# Text height ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.height')]
[Management.Automation.PSObject]
$TitleHeight,
# Text width ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.width')]
[Management.Automation.PSObject]
$TitleWidth,
# 0"            Text margin ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.margin')]
[Management.Automation.PSObject]
$TitleMargin,
# 0"           Text padding ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.padding')]
[Management.Automation.PSObject]
$TitlePadding,
# Bold text ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.bold')]
[Management.Automation.SwitchParameter]
$TitleBold,
# Faint text ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.faint')]
[Management.Automation.SwitchParameter]
$TitleFaint,
# Italicize text ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.italic')]
[Management.Automation.SwitchParameter]
$TitleItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('title.strikethrough')]
[Management.Automation.SwitchParameter]
$TitleStrikethrough,
# Underline text ($GUM_SPIN_ 
[ComponentModel.DefaultBindingProperty('title.underline')]
[Management.Automation.SwitchParameter]
$TitleUnderline,
# Row  
[ComponentModel.DefaultBindingProperty('separator')]
[Management.Automation.PSObject]
$Separator,
# Column names
[ComponentModel.DefaultBindingProperty('columns')]
[Management.Automation.PSObject]
$Columns,
# Column  
[ComponentModel.DefaultBindingProperty('widths')]
[Management.Automation.PSObject]
$Widths,
# Background Color ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.background')]
[Management.Automation.PSObject]
$CellBackground,
# Foreground Color ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.foreground')]
[Management.Automation.PSObject]
$CellForeground,
# Border Style ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.border')]
[Management.Automation.PSObject]
$CellBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('cell.border-background')]
[Management.Automation.PSObject]
$CellBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('cell.border-foreground')]
[Management.Automation.PSObject]
$CellBorderForeground,
# Text Alignment ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.align')]
[Management.Automation.PSObject]
$CellAlign,
# Text height ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.height')]
[Management.Automation.PSObject]
$CellHeight,
# Text width ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.width')]
[Management.Automation.PSObject]
$CellWidth,
# 0"              Text margin ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.margin')]
[Management.Automation.PSObject]
$CellMargin,
# 0"             Text padding ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.padding')]
[Management.Automation.PSObject]
$CellPadding,
# Bold text ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.bold')]
[Management.Automation.SwitchParameter]
$CellBold,
# Faint text ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.faint')]
[Management.Automation.SwitchParameter]
$CellFaint,
# Italicize text ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.italic')]
[Management.Automation.SwitchParameter]
$CellItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('cell.strikethrough')]
[Management.Automation.SwitchParameter]
$CellStrikethrough,
# Underline text ($GUM_TABLE_ 
[ComponentModel.DefaultBindingProperty('cell.underline')]
[Management.Automation.SwitchParameter]
$CellUnderline,
# Show cursor line ($GUM_WRITE_SHOW_CURSOR_LINE)
[ComponentModel.DefaultBindingProperty('show-cursor-line')]
[Management.Automation.SwitchParameter]
$ShowCursorLine,
# Background Color ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.background')]
[Management.Automation.PSObject]
$BaseBackground,
# Foreground Color ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.foreground')]
[Management.Automation.PSObject]
$BaseForeground,
# Border Style ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.border')]
[Management.Automation.PSObject]
$BaseBorder,
# Border Background Color
[ComponentModel.DefaultBindingProperty('base.border-background')]
[Management.Automation.PSObject]
$BaseBorderBackground,
# Border Foreground Color
[ComponentModel.DefaultBindingProperty('base.border-foreground')]
[Management.Automation.PSObject]
$BaseBorderForeground,
# Text Alignment ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.align')]
[Management.Automation.PSObject]
$BaseAlign,
# Text height ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.height')]
[Management.Automation.PSObject]
$BaseHeight,
# Text width ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.width')]
[Management.Automation.PSObject]
$BaseWidth,
# 0"              Text margin ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.margin')]
[Management.Automation.PSObject]
$BaseMargin,
# 0"             Text padding ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.padding')]
[Management.Automation.PSObject]
$BasePadding,
# Bold text ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.bold')]
[Management.Automation.SwitchParameter]
$BaseBold,
# Faint text ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.faint')]
[Management.Automation.SwitchParameter]
$BaseFaint,
# Italicize text ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.italic')]
[Management.Automation.SwitchParameter]
$BaseItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('base.strikethrough')]
[Management.Automation.SwitchParameter]
$BaseStrikethrough,
# Underline text ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('base.underline')]
[Management.Automation.SwitchParameter]
$BaseUnderline,
[ComponentModel.DefaultBindingProperty('cursor-line-number.background')]
[Management.Automation.PSObject]
$CursorLineNumberBackground,
[ComponentModel.DefaultBindingProperty('cursor-line-number.foreground')]
[Management.Automation.PSObject]
$CursorLineNumberForeground,
[ComponentModel.DefaultBindingProperty('cursor-line-number.border')]
[Management.Automation.PSObject]
$CursorLineNumberBorder,
[ComponentModel.DefaultBindingProperty('cursor-line-number.border-background')]
[Management.Automation.PSObject]
$CursorLineNumberBorderBackground,
[ComponentModel.DefaultBindingProperty('cursor-line-number.border-foreground')]
[Management.Automation.PSObject]
$CursorLineNumberBorderForeground,
[ComponentModel.DefaultBindingProperty('cursor-line-number.align')]
[Management.Automation.PSObject]
$CursorLineNumberAlign,
# Text height
[ComponentModel.DefaultBindingProperty('cursor-line-number.height')]
[Management.Automation.PSObject]
$CursorLineNumberHeight,
# Text width
[ComponentModel.DefaultBindingProperty('cursor-line-number.width')]
[Management.Automation.PSObject]
$CursorLineNumberWidth,
# 0"
[ComponentModel.DefaultBindingProperty('cursor-line-number.margin')]
[Management.Automation.PSObject]
$CursorLineNumberMargin,
# 0"
[ComponentModel.DefaultBindingProperty('cursor-line-number.padding')]
[Management.Automation.PSObject]
$CursorLineNumberPadding,
# Bold text
[ComponentModel.DefaultBindingProperty('cursor-line-number.bold')]
[Management.Automation.SwitchParameter]
$CursorLineNumberBold,
# Faint text
[ComponentModel.DefaultBindingProperty('cursor-line-number.faint')]
[Management.Automation.SwitchParameter]
$CursorLineNumberFaint,
# Italicize text
[ComponentModel.DefaultBindingProperty('cursor-line-number.italic')]
[Management.Automation.SwitchParameter]
$CursorLineNumberItalic,
[ComponentModel.DefaultBindingProperty('cursor-line-number.strikethrough')]
[Management.Automation.SwitchParameter]
$CursorLineNumberStrikethrough,
[ComponentModel.DefaultBindingProperty('cursor-line-number.underline')]
[Management.Automation.SwitchParameter]
$CursorLineNumberUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('cursor-line.background')]
[Management.Automation.PSObject]
$CursorLineBackground,
# Foreground Color
[ComponentModel.DefaultBindingProperty('cursor-line.foreground')]
[Management.Automation.PSObject]
$CursorLineForeground,
# Border Style ($GUM_WRITE_CURSOR_LINE_BORDER)
[ComponentModel.DefaultBindingProperty('cursor-line.border')]
[Management.Automation.PSObject]
$CursorLineBorder,
[ComponentModel.DefaultBindingProperty('cursor-line.border-background')]
[Management.Automation.PSObject]
$CursorLineBorderBackground,
[ComponentModel.DefaultBindingProperty('cursor-line.border-foreground')]
[Management.Automation.PSObject]
$CursorLineBorderForeground,
# Text Alignment ($GUM_WRITE_CURSOR_LINE_ALIGN)
[ComponentModel.DefaultBindingProperty('cursor-line.align')]
[Management.Automation.PSObject]
$CursorLineAlign,
# Text height ($GUM_WRITE_CURSOR_LINE_HEIGHT)
[ComponentModel.DefaultBindingProperty('cursor-line.height')]
[Management.Automation.PSObject]
$CursorLineHeight,
# Text width ($GUM_WRITE_CURSOR_LINE_WIDTH)
[ComponentModel.DefaultBindingProperty('cursor-line.width')]
[Management.Automation.PSObject]
$CursorLineWidth,
# 0"       Text margin ($GUM_WRITE_CURSOR_LINE_MARGIN)
[ComponentModel.DefaultBindingProperty('cursor-line.margin')]
[Management.Automation.PSObject]
$CursorLineMargin,
# 0"      Text padding ($GUM_WRITE_CURSOR_LINE_PADDING)
[ComponentModel.DefaultBindingProperty('cursor-line.padding')]
[Management.Automation.PSObject]
$CursorLinePadding,
# Bold text ($GUM_WRITE_CURSOR_LINE_BOLD)
[ComponentModel.DefaultBindingProperty('cursor-line.bold')]
[Management.Automation.SwitchParameter]
$CursorLineBold,
# Faint text ($GUM_WRITE_CURSOR_LINE_FAINT)
[ComponentModel.DefaultBindingProperty('cursor-line.faint')]
[Management.Automation.SwitchParameter]
$CursorLineFaint,
# Italicize text
[ComponentModel.DefaultBindingProperty('cursor-line.italic')]
[Management.Automation.SwitchParameter]
$CursorLineItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('cursor-line.strikethrough')]
[Management.Automation.SwitchParameter]
$CursorLineStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('cursor-line.underline')]
[Management.Automation.SwitchParameter]
$CursorLineUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('end-of-buffer.background')]
[Management.Automation.PSObject]
$EndOfBufferBackground,
[ComponentModel.DefaultBindingProperty('end-of-buffer.foreground')]
[Management.Automation.PSObject]
$EndOfBufferForeground,
# Border Style
[ComponentModel.DefaultBindingProperty('end-of-buffer.border')]
[Management.Automation.PSObject]
$EndOfBufferBorder,
[ComponentModel.DefaultBindingProperty('end-of-buffer.border-background')]
[Management.Automation.PSObject]
$EndOfBufferBorderBackground,
[ComponentModel.DefaultBindingProperty('end-of-buffer.border-foreground')]
[Management.Automation.PSObject]
$EndOfBufferBorderForeground,
# Text Alignment
[ComponentModel.DefaultBindingProperty('end-of-buffer.align')]
[Management.Automation.PSObject]
$EndOfBufferAlign,
# Text height ($GUM_WRITE_END_OF_BUFFER_HEIGHT)
[ComponentModel.DefaultBindingProperty('end-of-buffer.height')]
[Management.Automation.PSObject]
$EndOfBufferHeight,
# Text width ($GUM_WRITE_END_OF_BUFFER_WIDTH)
[ComponentModel.DefaultBindingProperty('end-of-buffer.width')]
[Management.Automation.PSObject]
$EndOfBufferWidth,
# 0"     Text margin ($GUM_WRITE_END_OF_BUFFER_MARGIN)
[ComponentModel.DefaultBindingProperty('end-of-buffer.margin')]
[Management.Automation.PSObject]
$EndOfBufferMargin,
# 0"    Text padding
[ComponentModel.DefaultBindingProperty('end-of-buffer.padding')]
[Management.Automation.PSObject]
$EndOfBufferPadding,
# Bold text ($GUM_WRITE_END_OF_BUFFER_BOLD)
[ComponentModel.DefaultBindingProperty('end-of-buffer.bold')]
[Management.Automation.SwitchParameter]
$EndOfBufferBold,
# Faint text ($GUM_WRITE_END_OF_BUFFER_FAINT)
[ComponentModel.DefaultBindingProperty('end-of-buffer.faint')]
[Management.Automation.SwitchParameter]
$EndOfBufferFaint,
# Italicize text
[ComponentModel.DefaultBindingProperty('end-of-buffer.italic')]
[Management.Automation.SwitchParameter]
$EndOfBufferItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('end-of-buffer.strikethrough')]
[Management.Automation.SwitchParameter]
$EndOfBufferStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('end-of-buffer.underline')]
[Management.Automation.SwitchParameter]
$EndOfBufferUnderline,
# Background Color
[ComponentModel.DefaultBindingProperty('placeholder.background')]
[Management.Automation.PSObject]
$PlaceholderBackground,
[ComponentModel.DefaultBindingProperty('placeholder.foreground')]
[Management.Automation.PSObject]
$PlaceholderForeground,
# Border Style ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('placeholder.border')]
[Management.Automation.PSObject]
$PlaceholderBorder,
[ComponentModel.DefaultBindingProperty('placeholder.border-background')]
[Management.Automation.PSObject]
$PlaceholderBorderBackground,
[ComponentModel.DefaultBindingProperty('placeholder.border-foreground')]
[Management.Automation.PSObject]
$PlaceholderBorderForeground,
# Text Alignment ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('placeholder.align')]
[Management.Automation.PSObject]
$PlaceholderAlign,
# Text height ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('placeholder.height')]
[Management.Automation.PSObject]
$PlaceholderHeight,
# Text width ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('placeholder.width')]
[Management.Automation.PSObject]
$PlaceholderWidth,
# 0"       Text margin ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('placeholder.margin')]
[Management.Automation.PSObject]
$PlaceholderMargin,
# 0"      Text padding ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('placeholder.padding')]
[Management.Automation.PSObject]
$PlaceholderPadding,
# Bold text ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('placeholder.bold')]
[Management.Automation.SwitchParameter]
$PlaceholderBold,
# Faint text ($GUM_WRITE_ 
[ComponentModel.DefaultBindingProperty('placeholder.faint')]
[Management.Automation.SwitchParameter]
$PlaceholderFaint,
# Italicize text
[ComponentModel.DefaultBindingProperty('placeholder.italic')]
[Management.Automation.SwitchParameter]
$PlaceholderItalic,
# Strikethrough text
[ComponentModel.DefaultBindingProperty('placeholder.strikethrough')]
[Management.Automation.SwitchParameter]
$PlaceholderStrikethrough,
# Underline text
[ComponentModel.DefaultBindingProperty('placeholder.underline')]
[Management.Automation.SwitchParameter]
$PlaceholderUnderline
)
begin {
    $accumulateInput = [Collections.Queue]::new()
}
process {
    if ($inputObject) {
        $accumulateInput.Enqueue($inputObject)
    }
}
end {
    $gumCmd = $ExecutionContext.SessionState.InvokeCommand.GetCommand('gum', 'Application')
    if (-not $gumCmd) {
        Write-Error "Gum not installed"
        return
    }
    $myCmd = $MyInvocation.MyCommand
    $myParameters = [Ordered]@{} + $PSBoundParameters
    $gumArgs = @(
    :nextParameter foreach ($parameterKV in $MyInvocation.MyCommand.Parameters.GetEnumerator()) {
        if (-not $myParameters.Contains($parameterKV.Key)) {
            continue
        }
        foreach ($attr in $parameterKV.Value.Attributes) {
            if ($attr -is [ComponentModel.DefaultBindingPropertyAttribute]) {
                "--$($attr.Name)"
                if ($myParameters[$parameterKV.Key] -isnot [switch]) {
                    $myParameters[$parameterKV.Key]
                }
                continue nextParameter
            }
        }
    })
    $allGumArgs = @() + $gumArgs + $gumArgumentList
    Write-Verbose "Calling gum with $allGumArgs"
    if ($accumulateInput.Count) {
        $MustConvert = $false
        $filteredInput = @(
        foreach ($inputObject in $accumulateInput) {
            if (-not $inputObject.GetType) { continue } 
            if ($inputObject -is [string] -or $inputObject.IsPrimitive) {
                $inputObject
            } else {
                $MustConvert = $true
                $inputObject
            }
        })
        if ($MustConvert) {
            $filteredInput | ConvertTo-Csv | & $gumCmd $Command @allGumArgs
        }
        else {
            $filteredInput | & $gumCmd $Command @allGumArgs
        }
    } else {
        & $gumCmd $Command @allGumArgs
    }
}
} 

