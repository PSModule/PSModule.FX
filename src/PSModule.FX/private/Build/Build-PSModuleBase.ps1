function Build-PSModuleBase {
    [CmdletBinding()]
    param(
        # Path to the folder where the module source code is located.
        [Parameter(Mandatory)]
        [string] $ModuleFolderPath,

        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModuleOutputFolderPath
    )

    $moduleName = Split-Path -Path $ModuleFolderPath -Leaf
    Write-Output "::group::[$moduleName] - Build base"

    $ignorePaths = @(
        'init',
        'private',
        'public',
        "$moduleName.psd1"
    )
    Write-Verbose "Copying files from [$ModuleFolderPath] to [$OutputFolderPath]"
    $ignorePaths | ForEach-Object {
        Write-Verbose "Ignoring path [$_]"
    }

    Copy-Item -Destination $ModuleOutputFolderPath -Recurse -Verbose

    Copy-Item -Path "$moduleFolder/*" -Destination $OutputFolderPath -Recurse -Verbose

    (Get-ChildItem -Path $outputsFolder -Recurse -Force).FullName | Sort-Object
    Write-Output '::endgroup::'
}
