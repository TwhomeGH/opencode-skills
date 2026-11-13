@echo off
rem Wrapper so the inspector can be run from cmd.exe without PowerShell syntax.
rem Usage: aft-bash.cmd list | show <taskId> [-Tail N] | watch <taskId>
setlocal
set "SCRIPT=%~dp0aft-bash.ps1"
where pwsh >nul 2>nul
if %errorlevel%==0 (
    pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
) else (
    powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
)
