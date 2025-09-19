# This log writer function is meant to be included in a script
#
# Variable definition
#
# Use the script name as the base for the logfile name, add a timestamp to it.
[string]$ScriptName = $MyInvocation.MyCommand.Name.Replace(".ps1", "")
[string]$Script:LogfileName = ($ScriptName + "_{0:yyyyMMdd-HHmmss}.log" -f [DateTime]::Now)

# Set the log path to the script root directory
[System.IO.DirectoryInfo]$Script:LogPath = $PSScriptRoot

# Combine the log path and logfile name to create the full path of the logfile
[System.IO.FileInfo]$script:LogFileFullPath = Join-Path -Path $Script:LogPath -ChildPath $Script:LogfileName

# Set start and stop messages for the logfile
[string]$Script:LogFileStart = "Logging started"
[string]$Script:LogFileStop = "Logging stopped"

# Set logging variables to control the initial logging behavior
$Script:LoggingEnabled = $true
$Script:FileLoggingEnabled = $false

function Write-LogFile
{
    # Logging function, used for progress and error logging
    # Uses the globally (script scoped) configured variables 'LogFileFullPath' to identify the logfile, 'LoggingEnabled' to enable/disable logging
    # and 'FileLoggingEnabled' to enable/disable file based logging
    #
    [CmdLetBinding()]

    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [System.Management.Automation.ErrorRecord]$ErrorInfo = $null
    )

    # Prefix the string to write with the current Date and Time, add error message if present...
    if ($ErrorInfo)
    {
        $logLine = "{0:dd.MM.yyyy H:mm:ss} : ERROR : {1} The error is: {2}" -f [DateTime]::Now, $Message, $ErrorInfo.Exception.Message
    }

    Else
    {
        $logLine = "{0:dd.MM.yyyy H:mm:ss} : INFO : {1}" -f [DateTime]::Now, $Message
    }

    # If logging is enabled...
    if ($Script:LoggingEnabled)
    {
        # If file based logging is enabled, write to the logfile
        if ($Script:FileLoggingEnabled)
        {
            # Create the Script:LogfileFullPath and folder structure if it doesn't exist
            if (-not (Test-Path $script:LogFileFullPath -PathType Leaf))
            {
                New-Item -ItemType File -Path $script:LogFileFullPath -Force -Confirm:$false -WhatIf:$false | Out-Null
                Add-Content -Value "Logging started." -Path $script:LogFileFullPath -Encoding UTF8 -WhatIf:$false -Confirm:$false
            }

            # Write to Script:LogfileFullPath
            Add-Content -Value $logLine -Path $script:LogFileFullPath -Encoding UTF8 -WhatIf:$false -Confirm:$false
            Write-Verbose $logLine
        }

        # If file based logging is not enabled, Output the log line to the console
        else
        {
            # If an errorinfo was given, format the output in red
            If ($ErrorInfo)
            {
                Write-Host -ForegroundColor Red -Object $logLine
            }

            Else
            {
                Write-Host -Object $logLine
            }

        }
    }
}
