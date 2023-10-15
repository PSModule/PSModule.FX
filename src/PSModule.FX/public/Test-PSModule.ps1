#Requires -Modules Pester, PSScriptAnalyzer

function Test-PSModule {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Path to the folder where the built modules are outputted.
        [Parameter()]
        [string] $OutputPath = 'outputs'
    )

    Write-Output "::group::Starting..."

    $moduleFolders = Get-PSModuleFolders -Path $OutputPath
    Write-Verbose "Found $($moduleFolders.Count) module(s)"
    $moduleFolders | ForEach-Object {
        Write-Verbose "[$($_.Name)]"
    }

    foreach ($moduleFolder in $moduleFolders) {
        Invoke-PSModuleTest -ModuleFolderPath $moduleFolder.FullName
    }

}
