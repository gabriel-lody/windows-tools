# Windows Tools

A collection of PowerShell scripts designed to automate Windows system tasks and fix common annoyances. These utilities are built for power users who want their system to behave more intelligently without manual intervention.

---

## Drive Clean

A PowerShell script that reclaims space on secondary drives by removing Windows system clutter.

### The Problem

Windows treats every drive as a system drive, creating unnecessary system folders that waste space:
- **Recycle Bin** (`$RECYCLE.BIN`) - Stores deleted files on every drive
- **System Volume Information** - Contains restore points and shadow copies

On secondary drives used purely for data storage, these folders serve no purpose and can consume gigabytes of valuable space.

### What This Script Does

`drive-clean.ps1` cleans these system folders from a specified drive:

1. **Disables System Restore** on the drive to prevent future space waste
2. **Removes Recycle Bin** folder completely
3. **Removes System Volume Information** folder and all its contents (restore points, shadow copies)

The script is designed to run automatically via Windows Task Scheduler. Operations are logged to the Windows Event Viewer (Application log, source: "DriveClean") so you can track what was removed.

**Note:** Windows will recreate `System Volume Information` with minimal content (~20KB) after deletion. This is normal NTFS behavior and cannot be prevented, but the folder will no longer grow with restore points.

### Setup (Task Scheduler)

1. **Open Task Scheduler**
   - Press `Win + R`, type `taskschd.msc`, press Enter

2. **Create a New Task**
   - Click "Create Task" (not "Create Basic Task")
   - Name: `Clean Drive D`
   - **Important:** Under "When running the task, use the following user account:", change from your username to `SYSTEM`
   - Check "Run with highest privileges"
   - Configure for: Windows 10/11

3. **Triggers Tab**
   - Click "New..."
   - Begin the task: Select **"On an event"**
   - Log: Select **"Security"**
   - Source: **Microsoft-Windows-Security-Auditing**
   - Event ID: **4634**
   - Click OK

4. **Actions Tab**
   - Click "New..."
   - Action: `Start a program`
   - Program/script: `powershell.exe`
   - Add arguments: `-NoProfile -ExecutionPolicy Bypass -File "C:\path\to\drive-clean.ps1"`
   - Replace `C:\path\to\` with the actual path to your script
   - Click OK twice to save the task

#### Checking the Logs

1. Open Event Viewer (`Win + R`, type `eventvwr.msc`, press Enter)
2. Navigate to: **Windows Logs → Application**
3. Filter by source: **DriveClean**
4. Look for:
   - Event ID 1002 (Information): System Restore disabled
   - Event ID 1000 (Information): Successful folder removal
   - Event ID 1001 (Warning): Failed to remove folder
   - Event ID 1003 (Warning): Failed to disable System Restore

### Requirements

- Windows 10 or later
- Administrator privileges
- PowerShell 5.1 or later (included in Windows 10/11)

### Important Notes

- **Not for manual execution** - This script is designed to run automatically via Task Scheduler, not to be executed manually
- **SYSTEM account required** - The task must run under the SYSTEM account (not your user account) to have sufficient privileges to remove these protected system folders
- **Data safety** - This script only removes system folders, not your personal files
- **System Restore disabled** - The script permanently disables System Restore on the target drive to prevent space waste
- **NTFS limitation** - Windows will recreate `System Volume Information` with minimal content (~20KB) after deletion. This is normal NTFS behavior and the folder will not grow since System Restore is disabled

### License

Free to use and modify.
