#!/bin/bash

# Plex Autoshutdown (for Linux)
# Version 1.0 (released 19 October 2024)
# https://github.com/mrsilver76/plex-autoshutdown
#
# A simple script which, when executed, will check that no-one is using Plex
# before shutting down the server it is running on.
#
# Please see the README for details on how to configure and run.

# ----- Licence ----------------------------------------------------------

# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or distribute
# this software, either in source code form or as a compiled binary, for any
# purpose, commercial or non-commercial, and by any means.
#
# In jurisdictions that recognize copyright laws, the author or authors of
# this software dedicate any and all copyright interest in the software to
# the public domain. We make this dedication for the benefit of the public
# at large and to the detriment of our heirs and successors. We intend this
# dedication to be an overt act of relinquishment in perpetuity of all present
# and future rights to this software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to https://unlicense.org

# ----- Configuration settings -------------------------------------------

# MIN_UPTIME
# The minimum amount of time (in seconds) the server needs to be running
# before this script will run. If the server is manually powered on after
# it has been shut down then this will prevent it from being shut down again
# for that period of time. The recommended value is 7200 = 2 hours.

MIN_UPTIME=7200

# PLEX_TOKEN
# The API token required for this script to be able to access Plex.
# Do not share your token with anyone. For details on how to find this, see
# https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/

PLEX_TOKEN=abcd1234efgh5678

# ----- End of configuration settings. Code starts here ------------------

readonly MIN_UPTIME
readonly PLEX_TOKEN

# Get the uptime in seconds

uptime_seconds=$(awk '{print int($1)}' /proc/uptime)

if ((uptime_seconds < MIN_UPTIME)); then
	echo Script terminated. Uptime is $uptime_seconds seconds, which is less than $MIN_UPTIME.
	exit 1
fi

# Check if Plex has any active streams

if ! curl -s "http://127.0.0.1:32400/status/sessions?X-Plex-Token=$PLEX_TOKEN" | grep -i "MediaContainer size=\"0\">" >/dev/null; then
	echo Script terminated. Plex is streaming.
	exit 1
fi

# Shut down the server

echo Shutting down now...
sudo shutdown -h now
exit 0