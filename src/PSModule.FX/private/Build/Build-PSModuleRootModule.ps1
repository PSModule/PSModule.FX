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

    # RE-create the moduleName.psm1 file
    # concat all the files, and add Export-ModuleMembers at the end with modules.
    $moduleOutputfolder = Join-Path -Path $OutputFolderPath -ChildPath $moduleName
    $rootModuleFile = New-Item -Path $moduleOutputfolder -Name "$moduleName.psm1" -Force

    # Add content to the root module file in the following order:
    # 1. Load data files from Data folder
    # 2. Init
    # 3. Private
    # 4. Public
    # 5  *.ps1 on module root
    # 6. Export-ModuleMember

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


    $subFolders = Get-ChildItem -Path $SourceFolderPath -Directory -Force | Where-Object -Property Name -In $folderProcessingOrder
    foreach ($subFolder in $subFolders) {
        Add-ContentFromItem -Path $subFolder.FullName -RootModuleFilePath $rootModuleFile.FullName -RootPath $SourceFolderPath
    }

    $files = $SourceFolderPath | Get-ChildItem -File -Force -Filter '*.ps1'
    foreach ($file in $files) {
        $relativePath = $file.FullName.Replace($SourceFolderPath, '').TrimStart($pathSeparator)
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

    $functionsToExport = Get-PSModuleFunctionsToExport -SourceFolderPath $SourceFolderPath
    $functionsToExport = $($functionsToExport -join "','")

    $cmdletsToExport = Get-PSModuleCmdletsToExport -SourceFolderPath $SourceFolderPath
    $cmdletsToExport = $($cmdletsToExport -join "','")

    $variablesToExport = Get-PSModuleVariablesToExport -SourceFolderPath $SourceFolderPath
    $variablesToExport = $($variablesToExport -join "','")

    $aliasesToExport = Get-PSModuleAliasesToExport -SourceFolderPath $SourceFolderPath
    $aliasesToExport = $($aliasesToExport -join "','")

    Add-Content -Path $rootModuleFile -Value "Export-ModuleMember -Function '$functionsToExport' -Cmdlet '$cmdletsToExport' -Variable '$variablesToExport' -Alias '$aliasesToExport'"
    Write-Output '::endgroup::'

    Write-Verbose 'Invoke-Formatter on manifest file'
    $AllContent = Get-Content -Path $rootModuleFile.FullName -Raw
    $settings = (Join-Path -Path $PSScriptRoot -ChildPath 'tests' 'PSScriptAnalyzer' 'PSScriptAnalyzer.Tests.psd1')
    Invoke-Formatter -ScriptDefinition $AllContent -Settings $settings |
        Out-File -FilePath $rootModuleFile.FullName -Encoding utf8BOM -Force

    Write-Output "::group::[$moduleName] - Build root module - Result"
    Show-FileContent -Path $rootModuleFile
    Write-Output '::endgroup::'
}
