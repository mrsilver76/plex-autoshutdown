#!/bin/bash

# Plex Autoshutdown (for Linux)
# Version 1.3 (released 14th March 2025)
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

# ----- Basic configuration settings -----------------------------------
#
# Only one setting (your PLEX_TOKEN) is required to get this script running.
# You can leave everything else as-is and the script will work perfectly fine.

# PLEX_TOKEN
# The API token required for this script to be able to access Plex.
# Do not share your token with anyone. For details on how to find this, see
# https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/

PLEX_TOKEN="abcd1234efgh5678"

# ----- Advanced configuration settings --------------------------------
#
# You do not have to change any of these settings. The script works fine
# with the defaults. These options are only for fine-tuning behaviour.

# MIN_UPTIME
# The minimum amount of time (in seconds) the server needs to be running
# before this script will run. If the server is manually powered on after
# it has been shut down then this will prevent it from being shut down again
# for that period of time. The recommended value is 7200 = 2 hours.

MIN_UPTIME=7200

# BLOCKING_PROCESSES
# A semi-colon (;) separated list of processes that will block shutdown
# if they are running. This is useful for delaying shutdown until certain
# tasks (either Plex related or not) finish. For example we include
# "Plex Transcoder" here to ensure that the server isn’t incorrectly
# shut down while Plex is transcoding - even if the Plex API reports no
# activity.

BLOCKING_PROCESSES="Plex Transcoder"

# BLOCKING_ADDRESSES
# A semi-colon (;) separated list of devices that will block shutdown if
# they are active. Each entry can be an IP address or hostname
# (e.g. "192.168.0.20;SAMSUNGTV") and devices on this list are assumed to
# be in use if they respond to a network ping. If you want to use
# IP addresses then it is recommended to configure your router to
# assign a static (same) IP address to the device to stop it changing.

BLOCKING_ADDRESSES=""

# ----- End of configuration settings. Code starts here ----------------

VERSION="1.3"
DO_SHUTDOWN=true

# Log
# Echos text to stdout prefixed with the date and time, ideal for
# sending to a text log for monitoring and debugging purposes
Log() {
    TS=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TS] $*"
}

# Parse arguments looking for test mode defined

TEST_MODE=false
for arg in "$@"; do
	lower_arg="${arg,,}"
	case "$lower_arg" in
		-t|--test|/t|/test)
			TEST_MODE=true
			;;
	esac
done

# Display starting up message

if [ "$TEST_MODE" = true ]; then
    Log "Plex Autoshutdown v$VERSION starting (test mode)..."
else
    Log "Plex Autoshutdown v$VERSION starting..."
fi

# Check if the Plex token has been set correctly

if [ -z "$PLEX_TOKEN" ]; then
    Log "Error: Plex token is not set"
    exit 1
elif [ "$PLEX_TOKEN" = "abcd1234efgh5678" ]; then
    Log "Error: Plex token is set to the default placeholder"
    exit 1
fi

# Check if Plex is running and contactable

rm -f "/tmp/plex-autoshutdown.tmp"
HTTP_CODE=$(curl -s -o "/tmp/plex-autoshutdown.tmp" -w "%{http_code}" --connect-timeout 3 "http://127.0.0.1:32400/status/sessions?X-Plex-Token=$PLEX_TOKEN")

# Plex not running or unreachable

if [ "$HTTP_CODE" = "000" ]; then
    Log "Error: Plex is not running or not reachable"
    rm -f "/tmp/plex-autoshutdown.tmp"
    exit 1
fi

# Plex running but the token is invalid

if [ "$HTTP_CODE" = "401" ]; then
    Log "Error: Plex is running but the token is invalid"
    rm -f "/tmp/plex-autoshutdown.tmp"
    exit 1
fi

# Plex responded with a HTTP code that wasn't 200 (success)

if [ "$HTTP_CODE" != "200" ]; then
    Log "Error: Plex responded with HTTP $HTTP_CODE"
    rm -f "/tmp/plex-autoshutdown.tmp"
    exit 1
fi

# Something responded, but it doesn't look like Plex

if ! grep -q "<MediaContainer" "/tmp/plex-autoshutdown.tmp"; then
    Log "Error: Response does not appear to be Plex"
    rm -f "/tmp/plex-autoshutdown.tmp"
    exit 1
fi

# Get the uptime and check it's not less than the configured amount

uptime_seconds=$(awk '{print int($1)}' /proc/uptime)

if (( uptime_seconds < MIN_UPTIME )); then
    Log "Uptime is $uptime_seconds seconds, which is less than $MIN_UPTIME"
    DO_SHUTDOWN=false
fi

# Check if Plex has any active streams

if ! grep -q 'MediaContainer size="0">' "/tmp/plex-autoshutdown.tmp"; then
    Log "Plex is streaming content"
    DO_SHUTDOWN=false
fi

# Check if Plex is downloading

curl -s "http://127.0.0.1:32400/activities?X-Plex-Token=$PLEX_TOKEN" -o "/tmp/plex-autoshutdown.tmp"
if grep -q 'type="media.download"' "/tmp/plex-autoshutdown.tmp"; then
    Log "Plex is downloading content"
    DO_SHUTDOWN=false
fi

# Check if Plex is transcoding

if grep -q 'type="media.offline.transcode"' "/tmp/plex-autoshutdown.tmp"; then
    Log "Plex is transcoding content"
    DO_SHUTDOWN=false
fi

# Check if Plex is streaming or recording live TV

if grep -q 'type="grabber.grab"' "/tmp/plex-autoshutdown.tmp"; then
    Log "Plex is streaming or recording live TV"
    DO_SHUTDOWN=false
fi

# Clean up

rm -f "/tmp/plex-autoshutdown.tmp"

# Check if any processes are running that would block shutdown

if [[ -n "$BLOCKING_PROCESSES" ]]; then
    IFS=';' read -ra PROC_ARRAY <<< "$BLOCKING_PROCESSES"
    for PROC_NAME in "${PROC_ARRAY[@]}"; do

        # Skip empty strings
        [[ -z "$PROC_NAME" ]] && continue

        if ps -ef | grep -i "$PROC_NAME" | grep -v grep >/dev/null; then
            Log "Found process running: $PROC_NAME"
            DO_SHUTDOWN=false
        fi
    done
fi

# Check if any local addresses are in use that would block shutdown
#
# Note: Early versions also checked the ARP cache, but dynamic entries can
# remain in both Windows and Linux for hours after a device powers off.
# In testing, a TV turned off 5 hours earlier was still listed in the ARP
# cache, making this method unreliable for detecting active devices.

# Only run if BLOCKING_ADDRESSES is defined
if [[ -n "$BLOCKING_ADDRESSES" ]]; then
    IFS=';' read -ra ADDR_ARRAY <<< "$BLOCKING_ADDRESSES"

    # Loop over each address/hostname
    for TARGET in "${ADDR_ARRAY[@]}"; do

        # Ping the address/hostname to see if device is online

        if ping -c 1 -W 2 "$TARGET" &>/dev/null; then
            Log "Found active device at $TARGET"
            DO_SHUTDOWN=false
        fi

    done
fi

# Shut down the server

if [ $DO_SHUTDOWN = false ]; then
    Log "Autoshutdown finished (shutdown blocked)"
    exit 1
fi

if [ "$TEST_MODE" = true ]; then
    Log "Shutdown would happen now (blocked by test mode)"
else
    Log "Shutting down now..."
    sudo shutdown -h now
fi

exit 0