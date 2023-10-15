[CmdLetBinding()]
Param(
    [Parameter(Mandatory)]
    [string] $Path
)

# Get all PSScript Analyzer Rules and save them in an array
$rules = Get-ScriptAnalyzerRule

# Create an array of the types of rules
$Severities = @('Information', 'Warning', 'Error')

foreach ($Severity in $Severities) {
    Describe "Testing PSSA $Severity Rules" -Tag $Severity {
        It '<CommonName> (<RuleName>)' -ForEach ($rules | Where-Object Severity -EQ $Severity) {
            param ($RuleName)
            #Test all scripts for the given rule and if there is a problem display this problem in a nice an reabable format in the debug message and let the test fail
            Invoke-ScriptAnalyzer -Path $Path -IncludeRule $RuleName -Recurse |
                ForEach-Object {
                    "$($_.ScriptName):L$($_.Line): $($_.Message)"
                } | Should -BeNullOrEmpty
        }
    }
}
