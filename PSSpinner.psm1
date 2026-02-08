# Get public functions
$Public = @(Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -ErrorAction SilentlyContinue)

# Dot source the files
foreach ($Import in $Public) {
    try {
        . $Import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($Import.Name): $_"
    }
}

# Get private functions
$Private = @(Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue)

# Dot source the files
foreach ($Import in $Private) {
    try {
        . $Import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($Import.Name): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName