function Build-PSModuleBase {
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
    Write-Output "::group::[$moduleName] - Build base"

    $ignorePaths = @(
        'init',
        'private',
        'public',
        "$moduleName.psd1"
    )
    Write-Verbose "Copying files from [$SourceFolderPath] to [$OutputFolderPath]"
    $ignorePaths | ForEach-Object {
        Write-Verbose "Ignoring path [$_]"
    }

    Copy-Item -Path "$moduleFolder/*" -Destination $OutputFolderPath -Recurse -Verbose
    Write-Output '::endgroup::'

    "::group::[$moduleName] - Build base - Result"
    (Get-ChildItem -Path $OutputFolderPath -Recurse -Force).FullName | Sort-Object
    Write-Output '::endgroup::'
}
