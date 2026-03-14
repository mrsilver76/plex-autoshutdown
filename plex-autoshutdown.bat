@echo off
setlocal enabledelayedexpansion

rem Plex Autoshutdown (for Windows)
rem Version 1.3 (released 14th March 2025)
rem https://github.com/mrsilver76/plex-autoshutdown
rem
rem A simple script which, when executed, will check that no-one is using Plex
rem before shutting down the server it is running on.
rem
rem Please see the README for details on how to configure and run.

rem ----- Licence ----------------------------------------------------------

rem This is free and unencumbered software released into the public domain.
rem
rem Anyone is free to copy, modify, publish, use, compile, sell, or distribute
rem this software, either in source code form or as a compiled binary, for any
rem purpose, commercial or non-commercial, and by any means.
rem
rem In jurisdictions that recognize copyright laws, the author or authors of
rem this software dedicate any and all copyright interest in the software to
rem the public domain. We make this dedication for the benefit of the public
rem at large and to the detriment of our heirs and successors. We intend this
rem dedication to be an overt act of relinquishment in perpetuity of all present
rem and future rights to this software under copyright law.
rem
rem THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
rem IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
rem FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
rem AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
rem ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
rem WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
rem
rem For more information, please refer to https://unlicense.org

rem ----- Basic configuration settings -----------------------------------
rem
rem Only one setting (your PLEX_TOKEN) is required to get this script running.
rem You can leave everything else as-is and the script will work perfectly fine.

rem PLEX_TOKEN
rem The API token required for this script to be able to access Plex.
rem Do not share your token with anyone. For details on how to find this, see
rem https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/

set PLEX_TOKEN=abcd1234efgh5678

rem ----- Advanced configuration settings --------------------------------
rem
rem You do not have to change any of these settings. The script works fine
rem with the defaults. These options are only for fine-tuning behaviour.

rem MIN_UPTIME
rem The minimum amount of time (in seconds) the server needs to be running
rem before this script will run. If the server is manually powered on after
rem it has been shut down then this will prevent it from being shut down again
rem for that period of time. The recommended value is 7200 = 2 hours.

set MIN_UPTIME=7200

rem BLOCKING_PROCESSES
rem A semi-colon (;) separated list of processes that will block shutdown
rem if they are running. This is useful for delaying shutdown until certain
rem tasks (either Plex related or not) finish. For example we include
rem "Plex Transcoder.exe" here to ensure that the server isn’t incorrectly
rem shut down while Plex is transcoding - even if the Plex API reports no
rem activity.

set BLOCKING_PROCESSES=Plex Transcoder.exe

rem BLOCKING_ADDRESSES
rem A semi-colon (;) separated list of devices that will block shutdown if
rem they are active. Each entry can be an IP address or hostname
rem (e.g. "192.168.0.20;SAMSUNGTV") and devices on this list are assumed to
rem be in use if they respond to a network ping. If you want to use
rem IP addresses then it is recommended to configure your router to
rem assign a static (same) IP address to the device to stop it changing.

set BLOCKING_ADDRESSES=

rem ----- End of configuration settings. Code starts here ----------------

set VERSION=1.3
set DO_SHUTDOWN=true

rem Parse arguments looking for test mode defined

set "TEST_MODE=false"
for %%A in (%*) do (
	if "%%A"=="-t" set "TEST_MODE=true"
	if "%%A"=="--test" set "TEST_MODE=true"
	if "%%A"=="/t" set "TEST_MODE=true"
	if "%%A"=="/test" set "TEST_MODE=true"
)

rem Display starting up message

if "%TEST_MODE%"=="true" (
	call :Log Plex Autoshutdown v%VERSION% starting ^(test mode^)...
) else (
	call :Log Plex Autoshutdown v%VERSION% starting...
)

rem Check if the Plex token has been set correctly

if "%PLEX_TOKEN%"=="" (
    call :Log Error: Plex token is not set
    exit /b 1
) else if "%PLEX_TOKEN%"=="abcd1234efgh5678" (
    call :Log Error: Plex token is set to the default placeholder
    exit /b 1
)

rem Check if Plex is running and contactable

curl -s -o "%TEMP%\plex-autoshutdown.tmp" -w "%%{http_code}" --connect-timeout 3 "http://127.0.0.1:32400/status/sessions?X-Plex-Token=%PLEX_TOKEN%" > "%TEMP%\plex_http_code.tmp"
set /p HTTP_CODE=<"%TEMP%\plex_http_code.tmp"
del "%TEMP%\plex_http_code.tmp"

rem Plex not running or unreachable

if "%HTTP_CODE%"=="000" (
    call :Log Error: Plex is not running or not reachable
    del /f "%TEMP%\plex-autoshutdown.tmp"
    exit /b 1
)

REM Plex running but the token is invalid

if "%HTTP_CODE%"=="401" (
    call :Log Error: Plex is running but the token is invalid
    del /f "%TEMP%\plex-autoshutdown.tmp"
    exit /b 1
)

rem Plex responded with a HTTP code that wasn't 200 (success)

if not "%HTTP_CODE%"=="200" (
    call :Log Error: Plex responded with HTTP %HTTP_CODE%
    del /f "%TEMP%\plex-autoshutdown.tmp"
    exit /b 1
)

rem Something responded, but it doesn't look like Plex

findstr /c:"<MediaContainer" "%TEMP%\plex-autoshutdown.tmp" >nul
if errorlevel 1 (
    call :Log Error: Response does not appear to be Plex
    del /f "%TEMP%\plex-autoshutdown.tmp"
    exit /b 1
)

rem Get the uptime and check it's not less than the configured amount

set uptime_seconds=

for /f %%i in ('powershell.exe -NoProfile -NonInteractive -Command "[int]((New-TimeSpan -Start (Get-CimInstance Win32_OperatingSystem).LastBootUpTime -End (Get-Date)).TotalSeconds)"') do (
    set uptime_seconds=%%i
)

if %uptime_seconds% LSS %MIN_UPTIME% (
	call :Log Uptime is %uptime_seconds% seconds, which is less than %MIN_UPTIME%
    set DO_SHUTDOWN=false
)

rem Check if Plex has any active streams

curl -s "http://127.0.0.1:32400/status/sessions?X-Plex-Token=%PLEX_TOKEN%" -o "%TEMP%\plex-autoshutdown.tmp" >NUL
find /I "MediaContainer size=""0"">" "%TEMP%\plex-autoshutdown.tmp" >NUL
if %errorlevel%==1 (
    call :Log Plex is streaming content
	set DO_SHUTDOWN=false
)

rem Check if Plex is downloading

curl -s "http://127.0.0.1:32400/activities?X-Plex-Token=%PLEX_TOKEN%" -o "%TEMP%\plex-autoshutdown.tmp" >NUL
find /I "type=""media.download""" "%TEMP%\plex-autoshutdown.tmp" >NUL
if %errorlevel%==0 (
    call :Log Plex is downloading content
	set DO_SHUTDOWN=false
) 

rem Check if Plex is transcoding

find /I "type=""media.offline.transcode""" "%TEMP%\plex-autoshutdown.tmp" >NUL
if %errorlevel%==0 (
	call :Log Plex is transcoding content
	set DO_SHUTDOWN=false
)

rem Check if Plex is streaming or recording live TV

find /I "type=""grabber.grab""" "%TEMP%\plex-autoshutdown.tmp" >NUL
if %errorlevel%==0 (
	call :Log Plex is streaming or recording live TV
	set DO_SHUTDOWN=false
)

rem Clean up

del /f "%TEMP%\plex-autoshutdown.tmp"

rem Check if any processes are running that would block shutdown

if defined BLOCKING_PROCESSES (
    for %%P in (%BLOCKING_PROCESSES%) do (
        set PROC_NAME=%%P
        set PROC_NAME=!PROC_NAME:;=!
        tasklist /FI "IMAGENAME eq !PROC_NAME!" 2>NUL | find /I "!PROC_NAME!" >NUL
        if !errorlevel!==0 (
            call :Log Found process running: !PROC_NAME!
            set DO_SHUTDOWN=false
        )
    )
)

rem Check if any local addresses are in use that would block shutdown
rem
rem Note: Early versions also checked the ARP cache, but dynamic entries can
rem remain in both Windows and Linux for hours after a device powers off.
rem In testing, a TV turned off 5 hours earlier was still listed in the ARP
rem cache, making this method unreliable for detecting active devices.

if defined BLOCKING_ADDRESSES (
    for %%T in (%BLOCKING_ADDRESSES%) do (
 
        rem Ping the address/hostname to see if device is online

        ping -n 1 -w 2000 %%T | find "TTL=" >NUL
        if !errorlevel! EQU 0 (
            call :Log Found active device at %%T
            set DO_SHUTDOWN=false
        )
    )
)

rem Shut down the server

if "%DO_SHUTDOWN%"=="false" (
    call :Log Autoshutdown finished ^(shutdown blocked^)
    exit /b 1
)

if "%TEST_MODE%"=="true" (
	call :Log Shutdown would happen now ^(blocked by test mode^)
) else (
	call :Log Shutting down now...
	shutdown /s /t 0
)
exit /b 0

rem Log
rem Echos text to stdout prefixed with the date and time, ideal for
rem sending to a text log for monitoring and debugging purposes
:Log
for /f "delims=" %%I in ('powershell -NoProfile -NonInteractive -Command "Get-Date -Format \"yyyy-MM-dd HH:mm:ss\" "') do set "TS=%%I"
echo [%TS%] %*
goto :eof