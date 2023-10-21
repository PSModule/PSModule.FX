[CmdLetBinding()]
Param(
    [Parameter(Mandatory)]
    [string] $Path,

    [Parameter(Mandatory)]
    [string] $SettingsFilePath
)

BeforeDiscovery {
    $rules = Get-ScriptAnalyzerRule | Sort-Object -Property Severity -Verbose:$false | ConvertTo-Json | ConvertFrom-Json -AsHashtable
    Write-Warning "Discovered [$($rules.Count)] rules"
    $relativeSettingsFilePath = $SettingsFilePath.Replace($PSScriptRoot, '').Trim('\').Trim('/')
}

Describe "PSScriptAnalyzer tests using settings file [$relativeSettingsFilePath]" {
    BeforeAll {
        $testResults = Invoke-ScriptAnalyzer -Path $Path -Settings $SettingsFilePath -Recurse -Verbose:$false
        Write-Warning "Found [$($testResults.Count)] issues"
    }

    It '<CommonName> (<RuleName>)' -ForEach $rules {
        param ($RuleName)

        $issues = @('')
        $issues += $testResults | Where-Object -Property RuleName -EQ $RuleName | ForEach-Object {
            $relativePath = $_.ScriptPath.Replace($Path, '').Trim('\').Trim('/')
            "$relativePath`:L$($_.Line):C$($_.Column): $($_.Message)"
        }
        $issues -join [Environment]::NewLine | Should -BeNullOrEmpty
    }
}
