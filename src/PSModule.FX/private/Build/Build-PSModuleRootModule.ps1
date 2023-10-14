function Build-PSModuleRootModule {
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
    Write-Output "::group::[$moduleName] - Build root module"

    $task.Add('Compress')
    Write-Output "::group::[$($task -join '] - [')]"
    Write-Verbose "[$($task -join '] - [')] - Processing"

    # RE-create the moduleName.psm1 file
    # concat all the files, and add Export-ModuleMembers at the end with modules.
    $rootModuleFile = New-Item -Path $moduleOutputFolderPath -Name $manifest.RootModule -Force

    # Add content to the root module file in the following order:
    # 1. Load data files from Data folder
    # 2. Init
    # 3. Classes
    # 4. Private
    # 5. Public
    # 6  *.ps1 on module root
    # 7. Export-ModuleMember


    Add-Content -Path $rootModuleFile.FullName -Value @'
[Cmdletbinding()]
param()

$scriptName = $MyInvocation.MyCommand.Name
Write-Verbose "[$scriptName] Importing subcomponents"

#region - Data import
Write-Verbose "[$scriptName] - [data] - Processing folder"
$dataFolder = (Join-Path $PSScriptRoot 'data')
Write-Verbose "[$scriptName] - [data] - [$dataFolder]"
Get-ChildItem -Path "$dataFolder" -Recurse -Force -Include '*.psd1' -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Verbose "[$scriptName] - [data] - [$($_.Name)] - Importing"
    New-Variable -Name $_.BaseName -Value (Import-PowerShellDataFile -Path $_.FullName) -Force
    Write-Verbose "[$scriptName] - [data] - [$($_.Name)] - Done"
}

Write-Verbose "[$scriptName] - [data] - Done"
#endregion - Data import

'@

    $folderProcessingOrder = @(
        'init',
        'private',
        'public'
    )
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

    $subFolders = Get-ChildItem -Path $moduleOutputFolderPath -Directory -Force | Where-Object -Property Name -In $folderProcessingOrder
    foreach ($subFolder in $subFolders) {
        Add-ContentFromItem -Path $subFolder.FullName -RootModuleFilePath $rootModuleFile.FullName -RootPath $moduleOutputFolderPath
        $subFolder | Remove-Item -Recurse -Force
    }

    $files = $moduleOutputFolderPath | Get-ChildItem -File -Force -Filter '*.ps1'
    foreach ($file in $files) {
        $relativePath = $file.FullName.Replace($moduleOutputFolderPath, '').TrimStart($pathSeparator)
        Add-Content -Path $rootModuleFile.FullName -Value @"
#region - From $relativePath
Write-Verbose "[`$scriptName] - [$relativePath] - Importing"

"@
        Get-Content -Path $file.FullName | Add-Content -Path $rootModuleFile.FullName

        Add-Content -Path $rootModuleFile.FullName -Value @"
Write-Verbose "[`$scriptName] - [$relativePath] - Done"
#endregion - From $relativePath

"@
        $file | Remove-Item -Force
    }

    $moduleFunctions = $($manifest.FunctionsToExport -join "','")
    $moduleCmdlets = $($manifest.CmdletsToExport -join "','")
    $moduleVariables = $($manifest.VariablesToExport -join "','")
    $moduleAlias = $($manifest.AliasesToExport -join "','")

    Add-Content -Path $rootModuleFile -Value "Export-ModuleMember -Function '$moduleFunctions' -Cmdlet '$moduleCmdlets' -Variable '$moduleVariables' -Alias '$moduleAlias'"

    Write-Output "::group::[$($task -join '] - [')] - Root Module"
    Get-Content -Path $rootModuleFile
    Write-Output '::endgroup::'


    Write-Output "::group::[$moduleName] - Output - RootModule"
    Get-Content -Path $outputManifestPath
    Write-Output '::endgroup::'
}
