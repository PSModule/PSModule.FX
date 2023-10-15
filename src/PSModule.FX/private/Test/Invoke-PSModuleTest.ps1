function Invoke-PSModuleTest {
    param(
        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModuleFolderPath
    )

    $moduleName = Split-Path -Path $ModuleFolderPath -Leaf

    Write-Output "::group::[$moduleName]"
    Write-Verbose "ModuleFolderPath - [$ModuleFolderPath]"

    $moduleFolder = Get-Item -Path $ModuleFolderPath

    Write-Output "::group::[$moduleName] - Invoke-ScriptAnalyzer"
    Invoke-Pester -Path .\PSSA.Tests.ps1 -Script @{ ModulePath = $moduleFolder.FullName }



    Write-Verbose "SearchFolder (to look for PS files):" -Verbose
    Write-Verbose "$($SearchFolder)" -Verbose

    $pesterCommand = Get-Command Invoke-Pester

    Write-Verbose "Testing with PowerShell $($PSVersionTable.PSVersion.ToString())" -Verbose
    Write-Verbose "Testing with Pester $($pesterCommand.version)" -Verbose

    $container = New-PesterContainer -Path (Join-Path $PSScriptRoot "tests")

    $container.Data = @{
        SearchFolder = $SearchFolder
    }
    $pesterFunctionParams = New-PesterConfiguration
    $pesterFunctionParams.Run.PassThru = $true
    $pesterFunctionParams.Run.Container = $container

    if ($PSBoundParameters.OutputResults.IsPresent) {

        # Producing test results when running in a pipeline
        $pesterFunctionParams.TestResult.Enabled = $true
        $pesterFunctionParams.TestResult.OutputPath = "pssa.testresults.xml"
    }

    $pesterResults = Invoke-Pester -Configuration $pesterFunctionParams
    if ($pesterResults.FailedCount -gt 0) {
        $pesterResults
    }














    Write-Output "::endgroup::"

    Write-Verbose "[$moduleName] - Done"
}

# <#
# Run tests from ".\tests\$moduleName.Tests.ps1"
# # Import the module using Import-Module $moduleManifestFilePath,
# # Do not not just add the outputted module file to the PATH of the runner (current context is enough) $env:PATH += ";.\outputs\$moduleName" as the import-module will actually test that the module is importable.
# #>

# <#
# Run tests from ".\tests\$moduleName.Tests.ps1"
# #>

# <#
# Test-ModuleManifest -Path $Path
# #>
