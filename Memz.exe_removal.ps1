# kill.ps1
#.REMINDER-NEEDED
# For this script to run, run this in powershell as a admin! 
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
<#
.CREDITS (and the usual stupid humor...)
If you reuse or remake this script, credit DrKel or visawesme. And if you steal it and claim it as yours, expect a DMCA notice (or at least some serious side-eye).
Horrible code written by Dr. Kel, who loves VoTV so much they started pretending to be Kel (NOT THE KEL FROM OMORI, THE ONE FROM VOICES OF THE VOID).
-- Yeah, I’m not okay.
This script is not responsible for any damage to your system, your sanity, or your cat’s trust in you.
If you experience issues, please contact your local IT department, or better yet, a therapist.
Seriously, don’t run this on your main machine unless you’re ready for the game "Will it boot tomorrow?"
-[--]---[--]---ACTUAL CODE BEGINS HERE---[--]---[--]-
.DANGER
Very dangerous script—this could potentially cause more damage than MEMZ itself.
If you're running this in VMware or VirtualBox, remember: VM escapes are a thing.
.Use Triage if you have a lifetime to spare, but don’t be surprised if your account gets an 8-hour review delay.
.SUPERDUPERIMPORTANT
This script is intended for highly controlled environments (e.g., a triage VM or a random computer found under a table).
It forcefully terminates processes, deletes files, and removes persistence mechanisms associated with MEMZ.exe and its variants.
.IMPORTANT
Before running, set the execution policy:
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
(Side note: don’t blame me if this turns your computer into a toaster.)
.SYNOPSIS
Forcefully terminates all processes matching MEMZ variants, removes persistence mechanisms, and aggressively strips process privileges.
.DESCRIPTION
This script hunts for processes with names like MEMZ.exe, memez.exe, etc. It uses background jobs to kill them, attempts to remove all persistence (scheduled tasks, registry entries, and shadow copies), and calls a custom .NET function to strip privileges from those processes.
.NOTES
Run this script as Administrator.
WARNING: This script is like a wrecking ball—you might lose files and system stability you didn’t know you loved.
#>
#.REMINDER-NEEDED
# For this script to run, run this in powershell as a admin! 
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# ----- Configuration Section -----
# Define primary process name variants (wildcards used for matching)
$processNames = @(
    "memz.exe",       # Standard process name
    "memez.exe",      # Common typo
    "MEMZ*.exe",      # Variations (case-insensitive)
    "memz*.exe",      # Variations
    "memez*.exe",     # Variations
    "MEMEZ*.exe",     # Extra variation
    "memz.exe*",      # Processes starting with memz.exe
    "memez.exe*",     # Processes starting with memez.exe
    "memz.exe 32*"    # Variations including "32" (e.g., 32-bit)
)

# Additional variants to target using wildcards
$additionalProcessNames = @(
    "memz*.com", "memez*.com",
    "memz*.bat", "memez*.bat",
    "memz*.cmd", "memez*.cmd",
    "memz*.scr", "memez*.scr",
    "memz*.pif", "memez*.pif",
    "memz*.dll", "memez*.dll",
    "memz*.sys", "memez*.sys",
    "memz*.vbs", "memez*.vbs",
    "memz*.js",  "memez*.js",
    "memz*.jse", "memez*.jse",
    "memz*.wsf", "memez*.wsf",
    "memz*.wsh", "memez*.wsh",
    "memz*.ps1", "memez*.ps1",
    "memz*.psm1", "memez*.psm1",
    "memz*.psd1", "memez*.psd1",
    "memz*.hta", "memez*.hta"
)
$processNames += $additionalProcessNames

# Define common file paths for memz.exe/memez.exe.
$paths = @(
    "$env:USERPROFILE\Downloads\memz.exe",
    "$env:USERPROFILE\Downloads\memez.exe",
    "$env:USERPROFILE\Desktop\memz.exe",
    "$env:USERPROFILE\Desktop\memez.exe",
    "C:\Windows\System32\memz.exe",   # Exact file name; no wildcards
    "C:\Windows\System32\memez.exe"    # Exact file name; no wildcards
)

# ----- Helper Function: Remove-ProcessPermissions -----
function Remove-ProcessPermissions {
    param(
        [int]$ProcessId
    )
    Write-Host "Aggressively removing privileges from process ID $ProcessId..." -ForegroundColor Magenta
    try {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class ProcessPrivileges {
    public const uint TOKEN_ADJUST_PRIVILEGES = 0x0020;
    public const uint TOKEN_QUERY = 0x0008;
    public const uint PROCESS_QUERY_INFORMATION = 0x0400;
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool OpenProcessToken(IntPtr ProcessHandle, uint DesiredAccess, out IntPtr TokenHandle);
    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(uint processAccess, bool bInheritHandle, int processId);
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool AdjustTokenPrivileges(IntPtr TokenHandle, bool DisableAllPrivileges, ref TOKEN_PRIVILEGES NewState, uint BufferLength, IntPtr PreviousState, IntPtr ReturnLength);
    [StructLayout(LayoutKind.Sequential)]
    public struct LUID {
        public uint LowPart;
        public int HighPart;
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct LUID_AND_ATTRIBUTES {
        public LUID Luid;
        public uint Attributes;
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct TOKEN_PRIVILEGES {
        public uint PrivilegeCount;
        public LUID_AND_ATTRIBUTES Privileges;
    }
}
"@
        # Open target process handle
        $processHandle = [ProcessPrivileges]::OpenProcess([ProcessPrivileges]::PROCESS_QUERY_INFORMATION, $false, $ProcessId)
        if ($processHandle -eq [IntPtr]::Zero) {
            Write-Output "Failed to open process handle for PID $ProcessId"
            return
        }
        $tokenHandle = [IntPtr]::Zero
        $result = [ProcessPrivileges]::OpenProcessToken($processHandle, [ProcessPrivileges]::TOKEN_ADJUST_PRIVILEGES -bor [ProcessPrivileges]::TOKEN_QUERY, [ref]$tokenHandle)
        if (-not $result) {
            Write-Output "Failed to open process token for PID $ProcessId"
            return
        }
        # Disable all privileges for this process token
        $tp = New-Object ProcessPrivileges+TOKEN_PRIVILEGES
        $tp.PrivilegeCount = 1
        $tp.Privileges = New-Object ProcessPrivileges+LUID_AND_ATTRIBUTES
        $tp.Privileges.Attributes = 0  # Remove privilege
        $adjusted = [ProcessPrivileges]::AdjustTokenPrivileges($tokenHandle, $true, [ref]$tp, 0, [IntPtr]::Zero, [IntPtr]::Zero)
        if ($adjusted) {
            Write-Output "Privileges aggressively removed from PID $ProcessId"
        } else {
            Write-Output "Failed to adjust token privileges for PID $ProcessId"
        }
    } catch {
        Write-Output "Exception while removing privileges from PID $ProcessId: $_"
    }
}

# ----- Main Execution Section -----
# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Run this script as Administrator. Exiting."
    exit 1
}

$jobs = @()
Write-Host "Aggressively searching for malicious processes..." -ForegroundColor Cyan

foreach ($name in $processNames) {
    try {
        $procs = Get-Process -Name $name -ErrorAction SilentlyContinue
    } catch {
        $procs = $null
    }
    if ($procs) {
        foreach ($proc in $procs) {
            Write-Host "Targeting $($proc.Name) (PID: $($proc.Id)) aggressively." -ForegroundColor Yellow
            # Forcefully remove privileges from process
            Remove-ProcessPermissions -ProcessId $proc.Id
            $job = Start-Job -ScriptBlock {
                param($pid)
                try {
                    # Kill child processes first
                    $childProcs = Get-CimInstance Win32_Process -Filter "ParentProcessId=$pid" -ErrorAction SilentlyContinue
                    foreach ($child in $childProcs) {
                        Stop-Process -Id $child.ProcessId -Force -ErrorAction Stop
                        Write-Output "Aggressively killed child PID $($child.ProcessId)"
                    }
                    # Kill parent process
                    Stop-Process -Id $pid -Force -ErrorAction Stop
                    Write-Output "Aggressively killed PID $pid"
                } catch {
                    Write-Output "Failed to aggressively kill PID $pid: $_"
                }
            } -ArgumentList $proc.Id
            $jobs += $job
        }
    } else {
        Write-Host "No malicious processes found matching: $name" -ForegroundColor Green
    }
}

if ($jobs.Count -gt 0) {
    Write-Host "Waiting for all aggressive kill jobs to complete..." -ForegroundColor Cyan
    Wait-Job -Job $jobs
    foreach ($job in $jobs) {
        Receive-Job -Job $job
    }
    $remaining = @()
    foreach ($name in $processNames) {
        $remaining += Get-Process -Name $name -ErrorAction SilentlyContinue
    }
    if ($remaining.Count -eq 0) {
        Write-Host "All memz-related processes have been aggressively terminated." -ForegroundColor Green
    } else {
        Write-Warning "Some processes still running—aggressive removal may have failed for a few."
    }
} else {
    Write-Host "No malicious processes were found to terminate." -ForegroundColor Green
}

# Delete the files corresponding to MEMZ variants
foreach ($path in $paths) {
    if (Test-Path $path) {
        try {
            Remove-Item -Path $path -Force
            Write-Host "Aggressively deleted file: $path" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to aggressively delete file: $path"
        }
    }
}

# ----- Additional Persistence Removal -----
Write-Host "Aggressively checking for persistence mechanisms..." -ForegroundColor Cyan

# Remove Scheduled Tasks related to memz
try {
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*memz*" -or $_.TaskName -like "*memez*" }
    if ($tasks) {
        foreach ($task in $tasks) {
            Write-Host "Aggressively removing scheduled task: $($task.TaskName)" -ForegroundColor Yellow
            try {
                Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction Stop
                Write-Host "Scheduled task $($task.TaskName) removed aggressively." -ForegroundColor Green
            } catch {
                Write-Warning "Failed to remove scheduled task $($task.TaskName) aggressively: $_"
            }
        }
    } else {
        Write-Host "No scheduled tasks found for memz variants." -ForegroundColor Green
    }
} catch {
    Write-Warning "Error retrieving scheduled tasks: $_"
}

# Remove Registry Run entries for memz (both HKCU and HKLM)
$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($regPath in $registryPaths) {
    try {
        $props = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
        if ($props) {
            $propNames = ($props | Get-Member -MemberType NoteProperty).Name
            foreach ($entry in $propNames) {
                if ($entry -match "(?i)memz|memez") {
                    Write-Host "Aggressively removing registry entry '$entry' from $regPath" -ForegroundColor Yellow
                    try {
                        Remove-ItemProperty -Path $regPath -Name $entry -ErrorAction Stop
                        Write-Host "Registry entry '$entry' removed aggressively." -ForegroundColor Green
                    } catch {
                        Write-Warning "Failed to remove registry entry '$entry': $_"
                    }
                }
            }
        } else {
            Write-Host "No registry entries found in $regPath for memz variants." -ForegroundColor Green
        }
    } catch {
        Write-Warning "Error accessing registry path $regPath: $_"
    }
}

# Immediately delete all Volume Shadow Copies (aggressive mode)
try {
    $shadowCopies = vssadmin list shadows
    if ($shadowCopies) {
        Write-Host "Shadow copies detected. Aggressively deleting them now! (Data loss guaranteed)" -ForegroundColor Red
        vssadmin delete shadows /all /quiet
    } else {
        Write-Host "No shadow copies found." -ForegroundColor Green
    }
} catch {
    Write-Warning "Failed to list or delete shadow copies: $_"
}

Write-Host "Aggressive malware removal complete. Get fucked MEMZ.exe. >:3c" -ForegroundColor Cyan

<#
End of aggressive removal script.
Remember: This script is experimental and destructive. Use only in a secure, isolated environment.
#>
