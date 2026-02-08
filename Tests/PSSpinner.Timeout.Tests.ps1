echo $PSScriptRoot
$ModulePath = ".\PSSpinner.psm1"
Import-Module $ModulePath -Force

Describe "Invoke-Spinner - Timeout behavior" {

    It "Completes when ScriptBlock finishes before timeout" {
        $Result = Invoke-Spinner -Message "Quick" -TimeoutSeconds 2 -ScriptBlock {
            Start-Sleep -Milliseconds 200
            return "Done"
        }

        $Result | Should -Be "Done"
    }

    It "Throws a TimeoutException when the timeout elapses" {
        {
            Invoke-Spinner -Message "Slow" -TimeoutSeconds 1 -ScriptBlock {
                Start-Sleep -Seconds 2
                return "TooLate"
            }
        } | Should -Throw -ExceptionType System.TimeoutException
    }
}
