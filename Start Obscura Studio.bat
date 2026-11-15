@echo off
rem Opens Obscura Studio in its own window, like a desktop app.
rem Uses Microsoft Edge or Google Chrome, which are already on this computer. No internet connection is needed.
setlocal EnableDelayedExpansion
set "APP=%~dp0obscura-studio.html"
set "URL=file:///%APP:\=/%"
set "URL=!URL: =%%20!"

set "BROWSER="
set "B1=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
set "B2=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
set "B3=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
set "B4=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
set "B5=%LocalAppData%\Google\Chrome\Application\chrome.exe"
if exist "%B5%" set "BROWSER=%B5%"
if exist "%B4%" set "BROWSER=%B4%"
if exist "%B3%" set "BROWSER=%B3%"
if exist "%B2%" set "BROWSER=%B2%"
if exist "%B1%" set "BROWSER=%B1%"

if not defined BROWSER goto fallback
start "" "%BROWSER%" --app="%URL%" --window-size=1500,950
exit /b

:fallback
rem No Edge or Chrome found: open in the default browser instead.
start "" "%APP%"
