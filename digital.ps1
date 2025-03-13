# Remove digital.v if it exists
if (Test-Path "digital.v") {
    Remove-Item "digital.v"
}

# Write PoliLobinho.v to digital.v using ASCII encoding (no BOM)
Get-Content "PoliLobinho.v" | Set-Content "digital.v" -Encoding ascii

# Append content from all other .v files (excluding PoliLobinho.v and digital.v)
$files = Get-ChildItem -Filter "*.v" | Where-Object {
    $_.Name -notin "PoliLobinho.v", "digital.v"
}

foreach ($file in $files) {
    Get-Content $file.FullName | Add-Content "digital.v" -Encoding ascii
}