function Add-ContentFromItem {
    param(
        [string] $Path,
        [string] $RootModuleFilePath,
        [string] $RootPath
    )
    $relativeFolderPath = $Path.Replace($RootPath, '').TrimStart($pathSeparator)

    Add-Content -Path $RootModuleFilePath -Value @"
#region - From $relativeFolderPath
Write-Verbose "[`$scriptName] - [$relativeFolderPath] - Processing folder"

"@

    $subFolders = $Path | Get-ChildItem -Directory -Force | Sort-Object -Property Name
    foreach ($subFolder in $subFolders) {
        Add-ContentFromItem -Path $subFolder.FullName -RootModuleFilePath $RootModuleFilePath -RootPath $RootPath
    }

    $files = $Path | Get-ChildItem -File -Force -Filter '*.ps1' | Sort-Object -Property FullName
    foreach ($file in $files) {
        $relativeFilePath = $file.FullName.Replace($RootPath, '').TrimStart($pathSeparator)
        Add-Content -Path $RootModuleFilePath -Value @"
#region - From $relativeFilePath
Write-Verbose "[`$scriptName] - [$relativeFilePath] - Importing"

"@
        Get-Content -Path $file.FullName | Add-Content -Path $RootModuleFilePath
        Add-Content -Path $RootModuleFilePath -Value @"

Write-Verbose "[`$scriptName] - [$relativeFilePath] - Done"
#endregion - From $relativeFilePath
"@
    }
    Add-Content -Path $RootModuleFilePath -Value @"

Write-Verbose "[`$scriptName] - [$relativeFolderPath] - Done"
#endregion - From $relativeFolderPath

"@
}
