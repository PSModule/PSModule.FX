#Requires -Modules Pester, PSScriptAnalyzer

function Test-PSModule {
    <#
        .SYNOPSIS
        Test a module.

        .DESCRIPTION
        Test a module using Pester and PSScriptAnalyzer.
        Runs both custom tests defined in a module's tests folder and the default tests.

        .EXAMPLE
        Test-PSModule -Name 'PSModule.FX' -Path 'outputs'
    #>
    [OutputType([int])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Name of the module to process.
        [Parameter()]
        [string] $Name = '*',

        # Path to the folder where the built modules are outputted.
        [Parameter()]
        [string] $Path
    )

    Write-Output '::group::Starting...'

    $moduleFolders = Get-PSModuleFolders -Path $Path | Where-Object { $_.Name -like $Name }
    Write-Verbose "Found $($moduleFolders.Count) module(s)"
    $moduleFolders | ForEach-Object {
        Write-Verbose "[$($_.Name)]"
    }
    Write-Output '::endgroup::'
    
    $failedTests = 0
    foreach ($moduleFolder in $moduleFolders) {
        try {
            $failedTests += Invoke-PSModuleTest -ModuleFolderPath $moduleFolder.FullName
        } catch {
            Write-Error "[$($moduleFolder.Name)] - $($_.Exception.Message)"
        }
    }
    $failedTests
}
