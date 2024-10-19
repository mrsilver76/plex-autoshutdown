@echo off
setlocal enabledelayedexpansion

rem Plex Autoshutdown (for Windows)
rem Version 1.0 (released 19 October 2024)
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

rem ----- Configuration settings -------------------------------------------

rem MIN_UPTIME
rem The minimum amount of time (in seconds) the server needs to be running
rem before this script will run. If the server is manually powered on after
rem it has been shut down then this will prevent it from being shut down again
rem for that period of time. The recommended value is 7200 = 2 hours.

set MIN_UPTIME=7200

rem PLEX_TOKEN
rem The API token required for this script to be able to access Plex.
rem Do not share your token with anyone. For details on how to find this, see
rem https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/

set PLEX_TOKEN=abcd1234efgh5678

rem ----- End of configuration settings. Code starts here ------------------

rem Get the uptime

Set uptime_seconds=

(for /F "tokens=1,* delims==" %%v in (
    'wmic path Win32_PerfFormattedData_PerfOS_System get SystemUptime /format:list ^| findstr "[0-9]"'
) do (
    Set uptime_seconds=%%w
))

if %uptime_seconds% LSS %MIN_UPTIME% (
	echo Script terminated. Uptime is %uptime_seconds% seconds, which is less than %MIN_UPTIME%.
	exit /b
)

rem Check if Plex has any active streams

curl -s "http://192.168.0.3:32400/status/sessions?X-Plex-Token=%PLEX_TOKEN%" | find /I "MediaContainer size=""0"">" >NUL
if errorlevel 1 (
	echo Script terminated. Plex is streaming.
	exit /b
)

rem Shut down the server

echo Shutting down now...
shutdown /s /f