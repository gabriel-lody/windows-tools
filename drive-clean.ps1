param([string]$DriveLetter = "D:")

# Check if drive is available
if (-not (Test-Path $DriveLetter)) {
    # Drive is not available, exit silently
    exit 0
}

$EventSource = "DriveClean"

# Create Event Source if it doesn't exist
if (-not [System.Diagnostics.EventLog]::SourceExists($EventSource)) {
    try {
        New-EventLog -LogName Application -Source $EventSource
    } catch {
        # If creation fails, use default source
        $EventSource = "Application"
    }
}

function Remove-DriveClutter {
    param([string]$Drive)

    # Disable System Restore on this drive first
    try {
        Disable-ComputerRestore -Drive $Drive -ErrorAction Stop
        Write-EventLog -LogName Application -Source $EventSource -EventId 1002 -EntryType Information -Message "Disabled System Restore on: $Drive"
    } catch {
        Write-EventLog -LogName Application -Source $EventSource -EventId 1003 -EntryType Warning -Message "Failed to disable System Restore on $Drive : $($_.Exception.Message)"
    }

    $paths = @(
        (Join-Path $Drive '$RECYCLE.BIN'),
        (Join-Path $Drive 'System Volume Information')
    )

    foreach ($path in $paths) {
        try {
            Remove-Item $path -Recurse -Force -ErrorAction Stop
            Write-EventLog -LogName Application -Source $EventSource -EventId 1000 -EntryType Information -Message "Successfully removed: $path"
        } catch {
            Write-EventLog -LogName Application -Source $EventSource -EventId 1001 -EntryType Warning -Message "Failed to remove $path : $($_.Exception.Message)"
        }
    }
}

Remove-DriveClutter -Drive $DriveLetter
