gci $PSScriptRoot/private -Filter *.ps1 | % { . $_.FullName }

$publicfunction = @()
gci $PSScriptRoot/public | % { . $_.FullName; $publicfunction += $_.BaseName }

Export-ModuleMember -Function $publicfunction