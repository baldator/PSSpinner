function Invoke-Spinner {
    <#
    .SYNOPSIS
        Displays a CLI spinner while running a script block in the background.

    .DESCRIPTION
        Runs a ScriptBlock in a separate Runspace (thread) to allow the main thread
        to render a smooth animation. Returns the output of the ScriptBlock.

    .PARAMETER ScriptBlock
        The code to execute.

    .PARAMETER Message
        The text to display next to the spinner.

    .EXAMPLE
        $Result = Invoke-Spinner -Message "Downloading..." -ScriptBlock { Start-Sleep -Seconds 2; return "Done" }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [string]$Message = "Processing...",

        [Parameter(Mandatory = $false)]
        [int]$TimeoutSeconds = 0
    )

    # Spinner Frames (Braille dots for PSCore, ASCII for Windows PowerShell)
    $Frames = @([char]0x280B, [char]0x2819, [char]0x2839, [char]0x2838, [char]0x283C, [char]0x2834, [char]0x2826, [char]0x2827, [char]0x2807, [char]0x280F)
    $Interval = 80 # Milliseconds

    # Save original cursor state
    try {
        $OriginCursor = [Console]::CursorVisible
        [Console]::CursorVisible = $false
    }
    catch {
        # Keep going if host doesn't support cursor manipulation (e.g. some CI envs)
    }

    # Setup the background runspace
    $PowerShell = [PowerShell]::Create()
    $null = $PowerShell.AddScript($ScriptBlock)

    try {
        # Start the background task
        $AsyncResult = $PowerShell.BeginInvoke()

        # Start timeout stopwatch (if a timeout was provided)
        $TimedOut = $false
        if ($TimeoutSeconds -gt 0) { $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew() }

        # Animation Loop
        $FrameIndex = 0
        while (-not $AsyncResult.IsCompleted) {
            $CurrentFrame = $Frames[$FrameIndex % $Frames.Count]

            # \r returns to start of line. Write-Host handles color/formatting.
            Write-Host -NoNewline "`r$CurrentFrame $Message"

            Start-Sleep -Milliseconds $Interval
            $FrameIndex++

            # Check for timeout
            if ($TimeoutSeconds -gt 0 -and $Stopwatch.Elapsed.TotalSeconds -ge $TimeoutSeconds) {
                try { $PowerShell.Stop() } catch {}
                $TimedOut = $true
                break
            }
        }

        # End the task (if not timed out)
        if (-not $TimedOut) {
            $Output = $PowerShell.EndInvoke($AsyncResult)
        } else {
            try { $null = $PowerShell.EndInvoke($AsyncResult) } catch {}
        }

        # Check for timeout
        if ($TimedOut) {
            # Failure State for timeout
            Write-Host -NoNewline "`r"
            Write-Host -ForegroundColor Red -NoNewline ([char]0x2716 + " ")
            Write-Host "$Message"

            throw [System.TimeoutException]::new("Invoke-Spinner timed out after $TimeoutSeconds seconds")
        }

        # Check for errors in the background runspace
        if ($PowerShell.Streams.Error.Count -gt 0) {
            throw $PowerShell.Streams.Error[0]
        }

        # Success State
        Write-Host -NoNewline "`r"
        Write-Host -ForegroundColor Green -NoNewline ([char]0x2714 + " ")
        Write-Host "$Message"
        
        # Return the actual object from the scriptblock
        return $Output

    }
    catch {
        # Failure State
        Write-Host -NoNewline "`r"
        Write-Host -ForegroundColor Red -NoNewline ([char]0x2716 + " ")
        Write-Host "$Message"
        
        # Throw the inner exception if it exists, otherwise throw the current exception
        if ($_.Exception.InnerException) {
            throw $_.Exception.InnerException
        } else {
            throw $_
        }
    }
    finally {
        # Cleanup Resources
        $PowerShell.Dispose()
        try { [Console]::CursorVisible = $OriginCursor } catch {}
    }
}
