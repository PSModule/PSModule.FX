#Requires -Modules platyPS, PowerShellGet, PackageManagement

function Build-PSModule {
    <#
        .SYNOPSIS
        Builds a PowerShell module

        .DESCRIPTION
        Builds a PowerShell module

        .EXAMPLE
        Build-PSModule -Path 'src' -OutputPath 'outputs'

        Builds all modules in the 'src' folder and stores them in the 'outputs' folder

        .EXAMPLE
        Build-PSModule -Path 'src' -Name 'PSModule.FX' -OutputPath 'outputs'

        Builds the 'PSModule.FX' module in the 'src' folder and stores it in the 'outputs' folder.

        .NOTES
        #DECISION: Modules are default located under the '.\src' folder which is the root of the repo.
        #DECISION: Module name = the name of the folder under src. Inherited decision from PowerShell team.
        #DECISION: The module manifest file = name of the folder.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(

        # Name of the module to process.
        [Parameter()]
        [string] $Name = '*',

        # Path to the folder where the modules are located.
        [Parameter()]
        [string] $Path = 'src',

        # Path to the folder where the built modules are outputted.
        [Parameter()]
        [string] $OutputPath = 'outputs'
    )

    Write-Host '::group::Starting...'

    $modulesOutputFolderPath = Join-Path -Path $OutputPath 'modules'
    Write-Verbose "Creating module output folder [$modulesOutputFolderPath]"
    $modulesOutputFolder = New-Item -Path $modulesOutputFolderPath -ItemType Directory -Force
    Add-PSModulePath -Path $modulesOutputFolder

    $docsOutputFolderPath = Join-Path -Path $OutputPath 'docs'
    Write-Verbose "Creating docs output folder [$docsOutputFolderPath]"
    $docsOutputFolder = New-Item -Path $docsOutputFolderPath -ItemType Directory -Force

    $moduleFolders = Get-PSModuleFolders -Path $Path | Where-Object { $_.Name -like $Name }
    Write-Verbose "Found $($moduleFolders.Count) module(s)"
    $moduleFolders | ForEach-Object {
        Write-Verbose "[$($_.Name)]"
    }

    foreach ($moduleFolder in $moduleFolders) {
        Invoke-PSModuleBuild -ModuleFolderPath $moduleFolder.FullName -ModulesOutputFolder $modulesOutputFolder -DocsOutputFolder $docsOutputFolder
    }
}
