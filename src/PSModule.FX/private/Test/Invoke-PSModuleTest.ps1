function Invoke-PSModuleTest {
    param(
        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModuleFolderPath
    )

    $moduleName = Split-Path -Path $ModuleFolderPath -Leaf

    Write-Output "::group::[$moduleName]"
    Write-Verbose "ModuleFolderPath - [$ModuleFolderPath]"

    Write-Output "::group::[$moduleName] - Invoke-ScriptAnalyzer"
    $moduleFolder = Get-Item -Path $ModuleFolderPath
    Invoke-PSSATest -ModuleFolder $moduleFolder -Verbose:$false
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
