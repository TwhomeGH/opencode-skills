<#
.SYNOPSIS
    Inspect AFT background bash tasks: list running tasks, show a snapshot, or
    follow stdout/stderr live.

.DESCRIPTION
    Read-only viewer for tasks recorded under
    %LOCALAPPDATA%\cortexkit\aft\<harness>\bash-tasks\<project>\<taskId>\.

    Modes
      list            Running tasks only (default).
      show <taskId>   Metadata, process tree, and the tail of stdout/stderr.
      watch <taskId>  Follow new stdout/stderr until the task stops running.

    <taskId> may be a unique prefix. The tool never kills or modifies a task.

.PARAMETER Mode
    list, show, or watch.

.PARAMETER TaskId
    Full task id (bash-...) or a unique prefix.

.PARAMETER Tail
    Lines of existing output shown by `show` (default 40).

.PARAMETER IntervalMs
    Poll interval for `watch` (default 1000).

.EXAMPLE
    .\aft-bash.ps1 list

.EXAMPLE
    .\aft-bash.ps1 show bash-f16feba141aff02e -Tail 20

.EXAMPLE
    .\aft-bash.ps1 watch bash-f16feba141aff02e
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('list', 'show', 'watch')]
    [string]$Mode = 'list',

    [Parameter(Position = 1)]
    [string]$TaskId,

    [int]$Tail = 40,

    [int]$IntervalMs = 1000
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$AnsiPattern = [regex]'\x1B\[[0-9;?]*[ -/]*[@-~]'

function Get-TaskSearchRoots {
    $roots = @()
    if ($env:AFT_STORAGE_DIR) {
        $roots += (Join-Path $env:AFT_STORAGE_DIR '*\bash-tasks')
    }
    if ($env:LOCALAPPDATA) {
        $roots += (Join-Path $env:LOCALAPPDATA 'cortexkit\aft\*\bash-tasks')
    }
    return $roots
}

function Get-Tasks {
    $tasks = New-Object System.Collections.Generic.List[object]
    foreach ($pattern in (Get-TaskSearchRoots)) {
        Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $tasksRoot = $_.FullName
            Get-ChildItem -Path $tasksRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $projectDir = $_.FullName
                Get-ChildItem -Path $projectDir -Directory -Filter 'bash-*' -ErrorAction SilentlyContinue | ForEach-Object {
                    $metaPath = Join-Path $_.FullName 'control\metadata.json'
                    if (-not (Test-Path $metaPath)) { return }
                    try {
                        $meta = Get-Content $metaPath -Raw -Encoding utf8 | ConvertFrom-Json
                    } catch {
                        return
                    }
                    $tasks.Add([pscustomobject]@{ Dir = $_.FullName; Meta = $meta })
                }
            }
        }
    }
    return $tasks
}

function Resolve-Task([string]$Id) {
    if (-not $Id) {
        throw "show/watch need a task id. Run 'list' to see running tasks."
    }
    $all = Get-Tasks
    $exact = $all | Where-Object { $_.Meta.task_id -eq $Id }
    if ($exact) { return $exact[0] }
    $matches = @($all | Where-Object { $_.Meta.task_id -like "$Id*" })
    if ($matches.Count -eq 1) { return $matches[0] }
    if ($matches.Count -gt 1) {
        throw "Task id prefix '$Id' is ambiguous: $($matches.Count) matches."
    }
    throw "Task '$Id' not found under AFT storage."
}

function Format-Duration([long]$Milliseconds) {
    $span = [TimeSpan]::FromMilliseconds($Milliseconds)
    if ($span.TotalHours -ge 1) { return ('{0:hh\:mm\:ss}' -f $span) }
    return ('{0:mm\:ss}' -f $span)
}

function Get-ElapsedMs($Meta) {
    if ($Meta.finished_at) { return [long]($Meta.finished_at - $Meta.started_at) }
    return [long]([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() - $Meta.started_at)
}

function Get-ProcessTree([int]$RootPid) {
    $all = Get-CimInstance Win32_Process
    $rows = New-Object System.Collections.Generic.List[object]
    function Walk([int]$Parent, [int]$Depth) {
        foreach ($child in ($all | Where-Object { $_.ParentProcessId -eq $Parent })) {
            $cpu = $null
            $proc = Get-Process -Id $child.ProcessId -ErrorAction SilentlyContinue
            if ($proc) { $cpu = [math]::Round($proc.CPU, 1) }
            $rows.Add([pscustomobject]@{
                Depth = $Depth
                Pid   = [int]$child.ProcessId
                Name  = $child.Name
                MemMB = [int]($child.WorkingSetSize / 1MB)
                CpuS  = $cpu
                Cmd   = $child.CommandLine
            })
            Walk ([int]$child.ProcessId) ($Depth + 1)
        }
    }
    $root = Get-CimInstance Win32_Process -Filter "ProcessId=$RootPid" -ErrorAction SilentlyContinue
    if ($root) {
        $rows.Add([pscustomobject]@{
            Depth = 0
            Pid   = [int]$root.ProcessId
            Name  = $root.Name
            MemMB = [int]($root.WorkingSetSize / 1MB)
            CpuS  = $null
            Cmd   = $root.CommandLine
        })
        Walk $RootPid 1
    }
    return $rows
}

function Write-Tree([int]$RootPid) {
    $rows = Get-ProcessTree $RootPid
    if (-not $rows) {
        Write-Output "  (process $RootPid is no longer running)"
        return
    }
    foreach ($row in $rows) {
        $indent = '  ' * $row.Depth
        $cpu = if ($null -ne $row.CpuS) { "$($row.CpuS)s" } else { '-' }
        Write-Output ("{0}{1} {2} mem={3}MB cpu={4}" -f $indent, $row.Pid, $row.Name, $row.MemMB, $cpu)
        if ($row.Depth -gt 0 -and $row.Cmd) {
            $snippet = $row.Cmd
            if ($snippet.Length -gt 110) { $snippet = $snippet.Substring(0, 110) + '...' }
            Write-Output ("{0}  {1}" -f $indent, $snippet)
        }
    }
}

function Get-Lines([string]$Path, [int]$Count) {
    if (-not (Test-Path $Path)) { return @() }
    $lines = Get-Content -Path $Path -Tail $Count -ErrorAction SilentlyContinue
    return @($lines | ForEach-Object { $AnsiPattern.Replace($_, '') })
}

function Show-Snapshot($Task, [int]$TailLines) {
    $m = $Task.Meta
    Write-Output ("task    : {0}" -f $m.task_id)
    Write-Output ("status  : {0}" -f $m.status)
    Write-Output ("session : {0}" -f $m.session_id)
    Write-Output ("elapsed : {0}" -f (Format-Duration (Get-ElapsedMs $m)))
    if ($m.finished_at) {
        Write-Output ("exit    : {0}" -f $m.exit_code)
    }
    Write-Output ("pid     : {0}" -f $m.child_pid)
    Write-Output ("workdir : {0}" -f $m.workdir)
    Write-Output ("command : {0}" -f (($m.command -split "`n")[0]))
    Write-Output ''
    Write-Output 'process tree'
    Write-Output '------------'
    Write-Tree ([int]$m.child_pid)
    Write-Output ''
    Write-Output ("stdout (last {0} lines)" -f $TailLines)
    Write-Output '-----------------------'
    $out = Get-Lines (Join-Path $Task.Dir 'io\stdout') $TailLines
    if ($out.Count -eq 0) { Write-Output '  (empty)' } else { $out | ForEach-Object { Write-Output $_ } }
    Write-Output ''
    Write-Output ("stderr (last {0} lines)" -f $TailLines)
    Write-Output '-----------------------'
    $err = Get-Lines (Join-Path $Task.Dir 'io\stderr') $TailLines
    if ($err.Count -eq 0) { Write-Output '  (empty)' } else { $err | ForEach-Object { Write-Output $_ } }
}

function Read-NewText([string]$Path, [ref]$Offset) {
    if (-not (Test-Path $Path)) { return '' }
    $stream = $null
    try {
        $stream = [System.IO.File]::Open($Path, 'Open', 'Read', 'ReadWrite')
        if ($Offset.Value -gt $stream.Length) { $Offset.Value = 0 }
        [void]$stream.Seek($Offset.Value, 'Begin')
        $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
        $text = $reader.ReadToEnd()
        $Offset.Value = $stream.Position
        return $text
    } catch {
        return ''
    } finally {
        if ($stream) { $stream.Dispose() }
    }
}

function Write-Prefixed([string]$Tag, [string]$Text) {
    if (-not $Text) { return }
    $Text = $AnsiPattern.Replace($Text, '')
    foreach ($line in ($Text -split "`r?`n")) {
        if ($line -ne '') { Write-Output ("[{0}] {1}" -f $Tag, $line) }
    }
}

function Watch-Task($Task, [int]$PollMs) {
    $stdout = Join-Path $Task.Dir 'io\stdout'
    $stderr = Join-Path $Task.Dir 'io\stderr'
    $metaPath = Join-Path $Task.Dir 'control\metadata.json'

    $offOut = 0L
    $offErr = 0L
    if (Test-Path $stdout) { $offOut = (Get-Item $stdout).Length }
    if (Test-Path $stderr) { $offErr = (Get-Item $stderr).Length }

    Write-Output ("watching {0} (Ctrl+C stops watching, not the task)" -f $Task.Meta.task_id)
    $lastStatus = [DateTime]::MinValue
    while ($true) {
        $meta = $null
        try { $meta = Get-Content $metaPath -Raw -Encoding utf8 | ConvertFrom-Json } catch { }
        if (-not $meta) { Write-Output 'metadata disappeared; task history was cleaned up.'; return }

        Write-Prefixed 'stdout' (Read-NewText $stdout ([ref]$offOut))
        Write-Prefixed 'stderr' (Read-NewText $stderr ([ref]$offErr))

        if (((Get-Date) - $lastStatus).TotalSeconds -ge 5) {
            $elapsed = Format-Duration (Get-ElapsedMs $meta)
            Write-Output ("[status] {0} elapsed={1} pid={2}" -f $meta.status, $elapsed, $meta.child_pid)
            $lastStatus = Get-Date
        }

        if ($meta.status -ne 'running') {
            Write-Output ("[done] status={0} exit={1} elapsed={2}" -f `
                $meta.status, $meta.exit_code, (Format-Duration (Get-ElapsedMs $meta)))
            return
        }
        Start-Sleep -Milliseconds $PollMs
    }
}

switch ($Mode) {
    'list' {
        $running = @(Get-Tasks | Where-Object { $_.Meta.status -eq 'running' } |
            Sort-Object { $_.Meta.started_at })
        if ($running.Count -eq 0) {
            Write-Output 'No running AFT bash tasks.'
            return
        }
        $rows = $running | ForEach-Object {
            $m = $_.Meta
            [pscustomobject]@{
                Task    = $m.task_id
                Pid     = $m.child_pid
                Elapsed = Format-Duration (Get-ElapsedMs $m)
                Session = $m.session_id
                Command = ($m.command -split "`n")[0]
            }
        }
        $rows | Format-Table -AutoSize -Wrap
    }
    'show' {
        Show-Snapshot (Resolve-Task $TaskId) $Tail
    }
    'watch' {
        Watch-Task (Resolve-Task $TaskId) $IntervalMs
    }
}
