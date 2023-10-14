function Get-ModuleFolders {
    <#
        .SYNOPSIS
        Get all folders where the content of the folder is a module file or manifest file.

        .DESCRIPTION
        Get all folders where the content of the folder is a module file or manifest file.
        Search is recursive.

        .EXAMPLE
        Get-ModuleFolders -Path 'src'

        Get all folders where the content of the folder is a module file or manifest file.
    #>
    [CmdletBinding()]
    param(
        # Path to the folder where the modules are located.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Path = 'src'
    )

    $moduleFolders = Get-ChildItem -Path $Path -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object {
        Get-ChildItem -Path $_.FullName -File -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -match '.*\.psm1|.*\.psd1'
        }
    }
    return $moduleFolders
}
