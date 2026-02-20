@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PSSpinner.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.4'

    # ID used to uniquely identify this module
    GUID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'

    # Author of this module
    Author = 'Baldator'
    
    # Copyright statement for this module
    Copyright = 'MIT Licence.'

    # Description of the functionality provided by this module
    Description = 'A PowerShell module that provides an ora-like terminal spinner.'

    # Functions to export from this module
    FunctionsToExport = @('Invoke-Spinner')

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Minimum PowerShell version
    PowerShellVersion = '5.1'

    # Explicitly list files to include in the module package
    FileList = @(
        'PSSpinner.psd1',
        'PSSpinner.psm1',
        'Public/Invoke-Spinner.ps1',
    )

    PrivateData = @{

        PSData = @{

            Tags = @('Spinner', 'Progress', 'Animation', 'Terminal', 'UX')
            LicenseUri = 'https://opensource.org/licenses/MIT'

            ProjectUri = 'https://github.com/Baldator/PSSpinner'
            ReleaseNotes = 'Added timeout functionality to Invoke-Spinner. If the ScriptBlock does not complete within the specified timeout, the spinner will stop and a TimeoutException will be thrown.'

    }




}
