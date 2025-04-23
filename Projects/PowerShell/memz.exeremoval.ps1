########################################################################################################################
################################################## MEMZ.EXE DESTROYER ##################################################
########################################################################################################################
##################################################### MADE BY DRKEL ####################################################
########################################################################################################################
<#
.NOTES
This is still a very heavy work-in-progress.
Any commented parts of the script indicate either extra dangerous sections or areas that might be unstable.
Be sure to read the comments and use extreme caution.
.IMPORTANT
Do NOT run this on your main system. Use a secure VM (or TRIAGE VM) for safety.
Remember: if you downloaded MEMZ.exe on your main system, this script isn’t coming to your rescue!
Make sure your VM is secure and scan your main system with an antivirus afterward.
.INSTRUCTIONS
1. RUN THIS ON A VM.
2. Create a text file named "kill.ps1" (avoid the words "MEMZ" or "MEMEZ" in the filename).
3. Paste the entire script into the file.
4. In PowerShell, run:
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
5. Download the original MEMZ files from GitHub (https://github.com/Dfmaaa/MEMZ-virus) on your VM (Reminder- These github viruses may get removed, so reccomend searching for them).
6. Run MEMZ.exe.
7. Right-click on your "kill.ps1" file and choose "Run in PowerShell" (or run as Administrator in a PowerShell window).
8. Pray that this aggressive removal works as intended.
Also, a reminder: do NOT manually kill MEMZ.exe via Task Manager or you might brick your VM.
#>

# ----- Global Logging Setup -----
$LogFile = "$env:USERPROFILE\Desktop\memz_removal_log.txt"
if (Test-Path $LogFile) { Remove-Item $LogFile -Force }
function Write-Log {
    param(
        [string]$Message,
        [ConsoleColor]$Color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp - $Message"
    Write-Host $line -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $line
}

Write-Log "Starting aggressive MEMZ.exe removal script!" Cyan

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
# Additional variants to target using wildcards for file deletion
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

# Common file paths where the virus might be lurking.
$paths = @(
    "$env:USERPROFILE\Downloads\memz*.exe",
    "$env:USERPROFILE\Downloads\memez*.exe",
    "$env:USERPROFILE\Desktop\memz*.exe",
    "$env:USERPROFILE\Desktop\memez*.exe",
    "C:\Windows\System32\memz.exe",   # Exact file name; no wildcards
    "C:\Windows\System32\memez.exe"     # Exact file name; no wildcards
    # --!DANGER ZONE!--#
    # Uncomment the following lines ONLY if you fully understand the risks!
    # "C:\Windows\System32\memz*.exe",
    # "C:\Windows\System32\memez*.exe"
)

# ----- Helper Function: Remove-ProcessPermissions -----
function Remove-ProcessPermissions {
    param(
        [int]$ProcessId
    )
    Write-Log "Aggressively removing privileges from process ID $ProcessId..." Magenta
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
        $processHandle = [ProcessPrivileges]::OpenProcess([ProcessPrivileges]::PROCESS_QUERY_INFORMATION, $false, $ProcessId)
        if ($processHandle -eq [IntPtr]::Zero) {
            Write-Log "Failed to open process handle for PID $ProcessId" Yellow
            return
        }
        $tokenHandle = [IntPtr]::Zero
        $result = [ProcessPrivileges]::OpenProcessToken($processHandle, [ProcessPrivileges]::TOKEN_ADJUST_PRIVILEGES -bor [ProcessPrivileges]::TOKEN_QUERY, [ref]$tokenHandle)
        if (-not $result) {
            Write-Log "Failed to open process token for PID $ProcessId" Yellow
            return
        }
        # Disable all privileges for this process token
        $tp = New-Object ProcessPrivileges+TOKEN_PRIVILEGES
        $tp.PrivilegeCount = 1
        $tp.Privileges = New-Object ProcessPrivileges+LUID_AND_ATTRIBUTES
        $tp.Privileges.Attributes = 0  # Remove privilege
        $adjusted = [ProcessPrivileges]::AdjustTokenPrivileges($tokenHandle, $true, [ref]$tp, 0, [IntPtr]::Zero, [IntPtr]::Zero)
        if ($adjusted) {
            Write-Log "Privileges aggressively removed from PID $ProcessId" Green
        } else {
            Write-Log "Failed to adjust token privileges for PID $ProcessId" Yellow
        }
    } catch {
        Write-Log "Exception while removing privileges from PID $ProcessId: $_" Red
    }
}

# ----- Helper Function: Get-MaliciousProcesses -----
# Instead of relying on Get-Process with wildcards (which can be iffy due to the .exe suffix),
# this function filters all running processes by comparing the lower-case process names to our target patterns.
function Get-MaliciousProcesses {
    $processedPatterns = $processNames | ForEach-Object { ($_ -replace "\.exe", "").ToLower() }
    $targetProcesses = Get-Process | Where-Object {
        $procName = $_.Name.ToLower()
        foreach ($pattern in $processedPatterns) {
            if ($procName -like $pattern) { return $true }
        }
        return $false
    }
    return $targetProcesses
}

# ----- Main Execution Section -----
# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "Run this script as Administrator. Exiting." Red
    exit 1
}

# Aggressively hunt for malicious processes!
Write-Log "Aggressively searching for malicious processes..." Cyan
$jobs = @()
$maliciousProcs = Get-MaliciousProcesses
if ($maliciousProcs) {
    foreach ($proc in $maliciousProcs) {
        Write-Log "Targeting process $($proc.Name) (PID: $($proc.Id)) aggressively." Yellow
        # Remove privileges to weaken its defenses
        Remove-ProcessPermissions -ProcessId $proc.Id
        # Start a background job to kill the process and its child processes
        $job = Start-Job -ScriptBlock {
            param($pid)
            try {
                # Kill child processes first
                $childProcs = Get-CimInstance Win32_Process -Filter "ParentProcessId=$pid" -ErrorAction SilentlyContinue
                foreach ($child in $childProcs) {
                    Stop-Process -Id $child.ProcessId -Force -ErrorAction Stop
                    Write-Output "Aggressively killed child PID $($child.ProcessId)"
                }
                # Kill the parent process
                Stop-Process -Id $pid -Force -ErrorAction Stop
                Write-Output "Aggressively killed PID $pid"
            } catch {
                Write-Output "Failed to aggressively kill PID $pid: $_"
            }
        } -ArgumentList $proc.Id
        $jobs += $job
    }
} else {
    Write-Log "No malicious processes found matching our criteria." Green
}

if ($jobs.Count -gt 0) {
    Write-Log "Waiting for all aggressive kill jobs to complete..." Cyan
    Wait-Job -Job $jobs
    foreach ($job in $jobs) {
        Receive-Job -Job $job | ForEach-Object { Write-Log $_ Green }
    }
    $remainingProcs = Get-MaliciousProcesses
    if ($remainingProcs.Count -eq 0) {
        Write-Log "All memz-related processes have been aggressively terminated." Green
    } else {
        Write-Log "Some processes still running—aggressive removal may have failed for a few." Red
    }
} else {
    Write-Log "No malicious processes were found to terminate." Green
}

# ----- Delete Malicious Files -----
Write-Log "Aggressively deleting malicious files..." Cyan
foreach ($path in $paths) {
    if (Test-Path $path) {
        try {
            Remove-Item -Path $path -Force -Recurse
            Write-Log "Aggressively deleted file: $path" Green
        } catch {
            Write-Log "Failed to aggressively delete file: $path" Red
        }
    }
}

# ----- Additional Persistence Removal -----
Write-Log "Aggressively checking for persistence mechanisms..." Cyan

# Remove Scheduled Tasks related to memz
try {
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*memz*" -or $_.TaskName -like "*memez*" }
    if ($tasks) {
        foreach ($task in $tasks) {
            Write-Log "Aggressively removing scheduled task: $($task.TaskName)" Yellow
            try {
                Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction Stop
                Write-Log "Scheduled task $($task.TaskName) removed aggressively." Green
            } catch {
                Write-Log "Failed to remove scheduled task $($task.TaskName) aggressively: $_" Red
            }
        }
    } else {
        Write-Log "No scheduled tasks found for memz variants." Green
    }
} catch {
    Write-Log "Error retrieving scheduled tasks: $_" Red
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
                    Write-Log "Aggressively removing registry entry '$entry' from $regPath" Yellow
                    try {
                        Remove-ItemProperty -Path $regPath -Name $entry -ErrorAction Stop
                        Write-Log "Registry entry '$entry' removed aggressively." Green
                    } catch {
                        Write-Log "Failed to remove registry entry '$entry': $_" Red
                    }
                }
            }
        } else {
            Write-Log "No registry entries found in $regPath for memz variants." Green
        }
    } catch {
        Write-Log "Error accessing registry path $regPath: $_" Red
    }
}

# Immediately delete all Volume Shadow Copies (aggressive mode)
try {
    $shadowCopies = vssadmin list shadows
    if ($shadowCopies) {
        Write-Log "Shadow copies detected. Aggressively deleting them now! (Data loss guaranteed)" Red
        vssadmin delete shadows /all /quiet
    } else {
        Write-Log "No shadow copies found." Green
    }
} catch {
    Write-Log "Failed to list or delete shadow copies: $_" Red
}

# ----- Additional Aggressive Removal Types -----
# Disable Network Adapters
Write-Log "Disabling network adapters to prevent malware communication..." Cyan
try {
    Get-NetAdapter | ForEach-Object {
        Disable-NetAdapter -Name $_.Name -Confirm:$false -ErrorAction Stop
        Write-Log "Network adapter $($_.Name) disabled aggressively." Green
    }
} catch {
    Write-Log "Failed to disable network adapters: $_" Red
}

# Clear Temporary Files
Write-Log "Clearing temporary files..." Cyan
try {
    $tempPaths = @(
        "$env:TEMP\*",
        "$env:USERPROFILE\AppData\Local\Temp\*"
    )
    foreach ($tempPath in $tempPaths) {
        Remove-Item -Path $tempPath -Force -Recurse -ErrorAction Stop
        Write-Log "Temporary files in $tempPath cleared aggressively." Green
    }
} catch {
    Write-Log "Failed to clear temporary files: $_" Red
}

# Remove Startup Items related to memz
Write-Log "Aggressively removing startup items..." Cyan
$startupPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\*",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\*"
)
foreach ($startupPath in $startupPaths) {
    try {
        $props = Get-ItemProperty -Path $startupPath -ErrorAction SilentlyContinue
        if ($props) {
            $propNames = ($props | Get-Member -MemberType NoteProperty).Name
            foreach ($entry in $propNames) {
                if ($entry -match "(?i)memz|memez") {
                    Write-Log "Aggressively removing startup entry '$entry' from $startupPath" Yellow
                    try {
                        Remove-ItemProperty -Path $startupPath -Name $entry -ErrorAction Stop
                        Write-Log "Startup entry '$entry' removed aggressively." Green
                    } catch {
                        Write-Log "Failed to remove startup entry '$entry': $_" Red
                    }
                }
            }
        } else {
            Write-Log "No startup entries found in $startupPath for memz variants." Green
        }
    } catch {
        Write-Log "Error accessing startup path $startupPath: $_" Red
    }
}

# Additional aggressive deletion from common directories
$additionalPaths = @(
    "C:\Program Files\memz*",
    "C:\Program Files (x86)\memz*",
    "C:\ProgramData\memz*",
    "C:\Users\*\AppData\Local\memz*",
    "C:\Users\*\AppData\Roaming\memz*"
)
foreach ($additionalPath in $additionalPaths) {
    if (Test-Path $additionalPath) {
        try {
            Remove-Item -Path $additionalPath -Force -Recurse
            Write-Log "Aggressively deleted additional path: $additionalPath" Green
        } catch {
            Write-Log "Failed to aggressively delete additional path: $additionalPath" Red
        }
    }
}

# ----- End of Additional Aggressive Removal Types -----
Write-Log "Aggressive malware removal complete. Get fucked, MEMZ.exe. >:3c" Cyan

pause
########################################################################################################################
##################################################### END OF SCRIPT ##################################################
########################################################################################################################
################################################## MEMZ.EXE DESTROYER ##################################################
########################################################################################################################
##################################################### MADE BY DRKEL ####################################################
########################################################################################################################
