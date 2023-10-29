﻿function Build-PSModuleDocumentation {
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
    New-MarkdownHelp -Module $moduleName -OutputFolder $OutputFolderPath -Force -Verbose
    Write-Output '::endgroup::'

    Write-Output "::group::[$moduleName] - Build documentation - Result"
    Get-ChildItem -Path $OutputFolderPath -Recurse -Force -Include '*.md' | ForEach-Object {
        Write-Output "::debug::[$moduleName] - [$_] - [$(Get-FileHash -Path $_.FullName -Algorithm SHA256)]"
    }
    Write-Output '::endgroup::'
}
