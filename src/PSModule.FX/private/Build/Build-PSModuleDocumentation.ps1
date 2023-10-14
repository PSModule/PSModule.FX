function Build-PSModuleDocumentation {
    [CmdletBinding()]
    param(
        # Path to the folder where the module source code is located.
        [Parameter(Mandatory)]
        [string] $ModuleFolderPath,

        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $OutputFolderPath
    )

    $moduleName = Split-Path -Path $ModuleFolderPath -Leaf
    Write-Output "::group::[$moduleName] - Build documentation"

    Write-Output "::group::[$moduleName] - Resolving modules"
    Resolve-ModuleDependencies -Path $outputManifestPath
    Write-Output '::endgroup::'

    Write-Verbose "Importing module"
    Import-Module $moduleOutputFolderPath
    Write-Output "::group::[$($task -join '] - [')] - Generate help"

    Write-Verbose "[$($task -join '] - [')] - [Help] - List loaded modules"
    $availableModules = Get-Module -Verbose:$false
    $availableModules
    Write-Output '::endgroup::'

    Write-Verbose "[$($task -join '] - [')] - [Help] - Building help"
    if ($moduleName -in $availableModules) {
        New-MarkdownHelp -Module $moduleName -OutputFolder ".\outputs\docs\$moduleName" -Force
    } else {
        Write-Warning "[$($task -join '] - [')] - [Help] - Module [$moduleName] not found"
    }
    Write-Output '::endgroup::'

}
