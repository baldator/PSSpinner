echo $PSScriptRoot
$ModulePath = ".\PSSpinner.psm1"
Import-Module $ModulePath -Force

Describe "Invoke-Spinner" {

    Context "Functionality" {
        
        It "Returns the value from the ScriptBlock" {
            $Result = Invoke-Spinner -Message "Testing Return" -ScriptBlock {
                Start-Sleep -Milliseconds 2000
                return "Success"
            }

            $Result | Should -Be "Success"
        }

        It "Can handle complex objects" {
            $Result = Invoke-Spinner -Message "Testing Objects" -ScriptBlock {
                return [PSCustomObject]@{ ID = 1; Name = "Test" }
            }

            $Result.ID | Should -Be 1
            $Result.Name | Should -Be "Test"
        }
    }

    Context "Error Handling" {
        
        It "Throws an error if the ScriptBlock fails" {
            {
                Invoke-Spinner -Message "Testing Error" -ScriptBlock { 
                    throw "Critical Failure" 
                }
            } | Should -Throw -ExpectedMessage "Critical Failure"
        }
    }
}