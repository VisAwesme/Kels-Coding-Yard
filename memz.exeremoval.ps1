########################################################################################################################
################################################## MEMZ.EXE DESTORYER ##################################################
########################################################################################################################
##################################################### MADE BY DRKEL ####################################################
########################################################################################################################
<#
.NOTES
This is still a very heavy work-in-progress.
Please note, any commented parts of the script are either... more dangerous parts of it, or possibly broken.-
Please read any following comments to them.
.IMPORTANT
Please do NOT run this on your main system, this is not going to save your precious windows 11 system (i hate windows for the life of me)-
if you downloaded MEMZ.exe on your main system.
Make sure your VM is secure and run a AntiVirus on your main after downloading MEMZ.exe (if your using a TRIAGE VM your fine,-
-and if your using LINUX your also fine, as EXE fies dont work on linux.(Unless you use wine, but how stupid can you be??))
.INSTRUCTIONS
First, please for all that is holy. RUN THIS ON A VM.
Second, once in the VM or TRIAGE VM. Made a text file and name it "kill.ps1" (DO NOT NAME IT ANYTHING CONTAINING THE WORD "MEMZ" OR "MEMEZ" THE PS1 WILL DELETE ITSELF)-
- then copy and paste this whole script in there, before attempting to run, run this in powershell... (line under)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Third, go onto github (https://github.com/Dfmaaa/MEMZ-virus), and download that on your VM.
Fourth, run MEMZ.exe (duh).
Fifth, most important right click on "kill.ps1" or whatever you named it, and click "Run in PowerShell".-
You can also just copy this whole script and paste it in a powershell as admin.
And finally, pray that this will work.
Also a small reminder, do NOT try and manually kill MEMZ.exe via task manager, doing so will brick the VM (rely on this PS1 to kill it).

#>

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

# Common files for where viruses are mostly planted.
$paths = @(
    "$env:USERPROFILE\Downloads\memz*.exe",
    "$env:USERPROFILE\Downloads\memez*.exe",
    "$env:USERPROFILE\Desktop\memz*.exe",
    "$env:USERPROFILE\Desktop\memez*.exe",
    "C:\Windows\System32\memz.exe",   # Exact file name; no wildcards
    "C:\Windows\System32\memez.exe" # Exact file name; no wildcards (Add a comma at the end if you uncomment the danger zone.)
   #--!DANGER ZONE!--#
   # Uncomment these for a possibly dangerous file removal.
   #"C:\Windows\System32\memz*.exe",
   #"C:\Windows\System32\memez*.exe"
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
    Write-Error "Run this script as Administrator. Exiting." -ForegroundColor Red
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
        Write-Warning "Some processes still running—aggressive removal may have failed for a few." -ForegroundColor Red
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
            Write-Warning "Failed to aggressively delete file: $path" -ForegroundColor Red
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
                Write-Warning "Failed to remove scheduled task $($task.TaskName) aggressively: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "No scheduled tasks found for memz variants." -ForegroundColor Green
    }
} catch {
    Write-Warning "Error retrieving scheduled tasks: $_" -ForegroundColor Red
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
                        Write-Warning "Failed to remove registry entry '$entry': $_" -ForegroundColor Red
                    }
                }
            }
        } else {
            Write-Host "No registry entries found in $regPath for memz variants." -ForegroundColor Green
        }
    } catch {
        Write-Warning "Error accessing registry path $regPath: $_" -ForegroundColor Red
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
    Write-Warning "Failed to list or delete shadow copies: $_" -ForegroundColor Red
}

Write-Host "Aggressive malware removal complete. Get fucked MEMZ.exe. >:3c" -ForegroundColor Cyan

pause
########################################################################################################################
##################################################### END OF SCRIPT ##################################################
########################################################################################################################
################################################## MEMZ.EXE DESTORYER ##################################################
########################################################################################################################
##################################################### MADE BY DRKEL ####################################################
########################################################################################################################
