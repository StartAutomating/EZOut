if (-not $this.'.Message') {
    Add-Member -InputObject $this NoteProperty '.Message' 'Hello World' -Force
}
$this.'.Message'
