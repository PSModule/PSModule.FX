#Requires -Modules Pester, PSScriptAnalyzer

function Test-PSModule {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Name of the module to process.
        [Parameter()]
        [string] $Name = '*',

        # Path to the folder where the built modules are outputted.
        [Parameter()]
        [string] $OutputPath = 'outputs'
    )

    Write-Output '::group::Starting...'

    $moduleFolders = Get-PSModuleFolders -Path $OutputPath | Where-Object { $_.Name -like $Name }
    Write-Verbose "Found $($moduleFolders.Count) module(s)"
    $moduleFolders | ForEach-Object {
        Write-Verbose "[$($_.Name)]"
    }

    foreach ($moduleFolder in $moduleFolders) {
        Invoke-PSModuleTest -ModuleFolderPath $moduleFolder.FullName
    }
}
