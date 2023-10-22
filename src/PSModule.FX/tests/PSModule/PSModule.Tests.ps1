[CmdLetBinding()]
Param(
    [Parameter(Mandatory)]
    [string] $Path
)

# These tests are for the whole module and its parts. The scope of these tests are on the src folder and the specific module folder within it.
Context 'Module design tests' {
    Describe 'Script files' {
        It 'Script file name and function/filter name should match' {

            $scriptFiles = @()

            Get-ChildItem -Path $Path -Filter '*.ps1' -Recurse -File | ForEach-Object {
                $fileContent = Get-Content -Path $_.FullName -Raw
                if ($fileContent -match '^(?:function|filter)\s+([a-zA-Z][a-zA-Z0-9-]*)') {
                    $functionName = $matches[1]
                    $fileName = $_.BaseName
                    $scriptFiles += @{
                        fileName     = $fileName
                        filePath     = $_.FullName.Replace($Path, '').Trim('\').Trim('/')
                        functionName = $functionName
                    }
                }
            }

            $issues = @('')
            $issues += $scriptFiles | Where-Object { $_.filename -ne $_.functionName } | ForEach-Object {
                " - $($_.filePath): Function/filter name [$($_.functionName)]. Change file name or function/filter name so they match."
            }
            $issues -join [Environment]::NewLine | Should -BeNullOrEmpty -Because 'the script files should be called the same as the function they contain'
        }

        # It 'Script file should only contain max one function or filter' {}

        # It 'has tests for the section of functions' {} # Look for the folder name in tests called the same as section/folder name of functions

    }

    Describe 'Function/filder design' {
        # It 'has synopsis for all functions' {}
        # It 'has description for all functions' {}
        # It 'has examples for all functions' {}
        # It 'has output documentation for all functions' {}
        # It 'has [CmdletBinding()] attribute' {}
        # It 'has [OutputType()] attribute' {}
    }

    Describe 'Parameter design' {
        # It 'has parameter description for all functions' {}
        # It 'has parameter validation for all functions' {}
        # It 'parameters have [Parameters()] attribute' {}
    }

}
