@echo off
rem ===========================================================================
rem  Install cc (this project's restored Claude Code CLI) on Windows.
rem
rem  Just double-click this file. It runs scripts\install.ps1, which installs
rem  dependencies, builds dist\cli.js, and puts a "cc" command on your PATH.
rem
rem  From a terminal you can also pass:
rem      scripts\install.cmd --no-deps --no-build --no-path
rem ===========================================================================
setlocal

rem Pause at the end only when this window was opened by a double-click.
set "CC_PAUSE=0"
echo %cmdcmdline% | find /i "%~nx0" >nul 2>nul && set "CC_PAUSE=1"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set "CC_RC=%ERRORLEVEL%"

if "%CC_PAUSE%"=="1" pause
endlocal & exit /b %CC_RC%
