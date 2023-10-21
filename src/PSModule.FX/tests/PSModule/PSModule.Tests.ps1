[CmdLetBinding()]
Param(
    [Parameter(Mandatory)]
    [string] $Path
)

Describe 'Module design tests' {
    It 'File name and function name should match' {

        $scriptFiles = @()

        Get-ChildItem -Path $Path -Filter '*.ps1' -Recurse -File | ForEach-Object {
            $fileContent = Get-Content -Path $_.FullName -Raw
            if ($fileContent -match '(?:function|filter)\s+([a-zA-Z][a-zA-Z0-9-]*)') {
                $functionName = $matches[1]
                $fileName = $_.BaseName
                if ($functionName -ne $fileName) {
                    $scriptFiles += @{
                        fileName     = $fileName
                        filePath     = $_.FullName.Replace($Path, '').Trim('\').Trim('/')
                        functionName = $functionName
                    }
                }
            }
        }

        $issues = @('')
        $issues += $scriptFiles | ForEach-Object {
            "$filePath` contains: [$functionName]. Change file name or function/filter name so they match."
        }
        $issues -join [Environment]::NewLine | Should -BeNullOrEmpty -Because "the script files should be called the same as the function they contain"
    }

    # It 'Script file should only contain max one function or filter' {}
}
