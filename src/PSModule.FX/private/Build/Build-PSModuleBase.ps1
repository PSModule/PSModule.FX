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

    $sourceFolder = Get-Item -Path $SourceFolderPath
    $outputFolder = Get-Item -Path $OutputFolderPath

    $moduleName = Split-Path -Path $SourceFolderPath -Leaf
    Write-Output "::group::[$moduleName] - Build base"

    $ignorePaths = @(
        'init',
        'private',
        'public',
        "$moduleName.psd1",
        "$moduleName.psm1"
    )
    Write-Verbose "Copying files from [$SourceFolderPath] to [$OutputFolderPath]"
    $ignorePaths | ForEach-Object {
        Write-Verbose "Ignoring path [$_]" -Verbose
    }

    $filePaths = New-Object System.Collections.Generic.List[string]
    $filePaths += Get-ChildItem -Path $sourceFolder.FullName -Directory -Exclude $ignorePaths | Get-ChildItem -Recurse -File | Select-Object -ExpandProperty FullName
    $filePaths += Get-ChildItem -Path $sourceFolder.FullName -File -Exclude $ignorePaths | Select-Object -ExpandProperty FullName
    $filePaths = $filePaths | Sort-Object
    $filePaths | ForEach-Object {
        $sourceFilePath = $_
        $destinationFilePath = $_ -replace ($sourceFolder.FullName), ($outputFolder.FullName)
        Copy-Item -Path $sourceFilePath -Destination $destinationFilePath -Force -Verbose
    }
    Write-Output '::endgroup::'

    Write-Output "::group::[$moduleName] - Build base - Result"
    (Get-ChildItem -Path $OutputFolderPath -Recurse -Force).FullName | Sort-Object
    Write-Output '::endgroup::'
}
