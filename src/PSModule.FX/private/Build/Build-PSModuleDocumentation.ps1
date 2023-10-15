function Build-PSModuleDocumentation {
    [CmdletBinding()]
    param(
        # Path to the folder where the module source code is located.
        [Parameter(Mandatory)]
        [string] $SourceFolderPath,

        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $OutputFolderPath
    )

    $moduleName = Split-Path -Path $SourceFolderPath -Leaf
    Write-Output "::group::[$moduleName] - Build documentation"

    $manifestFile = Get-PSModuleManifest -SourceFolderPath $SourceFolderPath -As FileInfo -Verbose:$false
    Resolve-PSModuleDependencies -ManifestFilePath $manifestFile

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
