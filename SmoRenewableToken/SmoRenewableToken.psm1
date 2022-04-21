$PublicScriptPath = Join-Path $PSScriptRoot "Public"

$Scripts = @(Get-ChildItem $PublicScriptPath -Recurse -Include *.ps1)

foreach ($Script in $Scripts) {
    . $Script
}