# Plex Autoshutdown

<p><img src="https://img.shields.io/badge/Windows-supported-0078D6?logo=windows&logoColor=white" alt="Windows"> <img src="https://img.shields.io/badge/Linux-supported-FCC624?logo=linux&logoColor=black" alt="Linux"> <img src="https://img.shields.io/badge/License-Unlicense-000000?logo=unlicense&logoColor=white" alt="Unlicense"></p>

*A simple script which will check that no-one is using Plex before shutting down the server it is running on.*

This script is useful for people who have no requirement to run their Plex server 24/7 and have periods of time where no-one is using their server (eg. the early hours of the morning).

**There are two scripts, one for Windows uses and one for Linux users.** The Linux one may work with macOS, but I have no way of verifying. I'm happy to take a submission/fix from someone who owns one. 

## 🧰 Features

Despite being small, these scripts have some useful features:

* 🖥️ Works on Windows and Linux (and possibly macOS)
* ⚙️ Easy to set up, there is only one option that you _**must**_ configure.
* 🎬 Will not shut down a machine if there are active Plex streams (audio or video).
* 📥 Will not shut down a machine if there are active Plex downloads.
* 📺 Will not shut down a machine if live TV is being watched or recorded.
* 🧩 Will not shut down a machine if certain processes (Plex related or not) are running.
* 🏠 Will not shutdown a machine if certain devices are active on the network (e.g. a television).
* ⏳ Will not force a machine to shut down for a (configurable) period of time after power up.
* 🧪 Test mode to verify the logic without accidentally powering off your machine.

## 📦 Download

1. Get the latest version from https://github.com/mrsilver76/plex-autoshutdown/releases. Windows users should download the zip file, Linux users should download the tar.gz file.
3. Decompress the file. On Windows, you can double-click the file. On Linux you should use the `gunzip` command.
4. Use the file ending in `.bat` for Windows and the file ending `.sh` for Linux.

## ⚙️ Configuration

To configure the script, open it up in your preferred text editor. For Windows, Notepad will do. For Linux, I recommend [nano](https://www.nano-editor.org/) which usually comes preinstalled with most distributions.

### Basic configuration options

Only one setting is required to get this script running. You can leave everything else as-is and the script will work perfectly fine.

- **`PLEX_TOKEN`**  
  The script uses the Plex API in order to determine whether or not anything is streaming. To do this, it needs a token to use for authentication. Plex provides instructions on how to find the token for your Plex server [here](https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/). 

  You should modify this line to include your token (capitalisation is important). If you provide an invalid token then the script will display an error and stop. The default token in the code (`abcd1234efgh5678`) is invalid and will never work.

> [!CAUTION]
> You should never share your Plex token with anyone else.

### Advanced configuration options

You do not have to edit any of these settings. The script works fine with the defaults and these options are only for fine-tuning behaviour.

- **`MIN_UPTIME`**  
  This is the minimum amount of time (in seconds) that a server must have been running (the “uptime”) before the script will work. The default (and recommended) value is `7200` which equates to 2 hours.

  Using `7200` as an example, if you turn back on your Plex server at (say) 1am, then it will not attempt to turn the server back off again until 3am, even if you stop using it at 1:30am.

> [!IMPORTANT]
> If you set this value too low, then your server may turn off very quickly after you have turned it back on.

- **`BLOCKING_PROCESSES`**  
  A semi-colon (`;`) separated list of processes that will block shutdown if they are running. This is useful for delaying shutdown until certain tasks (either Plex related or not) finish. The default code includes `Plex Transcoder` here to ensure that the server isn’t incorrectly shut down while Plex is transcoding - even if the Plex API reports no activity.

- **`BLOCKING_ADDRESSES`**  
  A semi-colon (`;`) separated list of devices that will block shutdown if they are active. Each entry can be an IP address or hostname (e.g. `192.168.0.20;SAMSUNG-TV`) and devices on this list are assumed to be in use if they respond to [ping](https://www.lifewire.com/ping-command-2618099) or appear in [ARP](https://en.wikipedia.org/wiki/Address_Resolution_Protocol). If you want to use IP addresses then it is recommended to configure your router to assign a static (same) IP address to the device to stop it changing.

## ▶️ Running the script

The script must be placed and run on your Plex server (the same machine Plex is installed on) to correctly detect streams, downloads and other activity. 

On Linux, you will need to make it executable first by using `chmod +x plex-autoshutdown.sh`.

Before enabling automatic shutdown, run the script in test mode from the command line to confirm that everything is working correctly. When test mode is enabled, the script performs all checks and reports what it would do. Even if a condition would normally block a shutdown, the script will continue running so you can see the full set of results. _**It will never actually shut down your server in this mode!**_

To use test mode, append any of `/t`, `/test`, `-t`, or `--test` to the command line, irrespective of your operating system:

- Windows: `plex-autoshutdown.bat /test`
- Linux: `plex-autoshutdown.sh -t`

Once you've confirmed that the script works as expected, you need to configure your operating system to run the script multiple times over the night. This is to ensure that if the shutdown is blocked because something is being streamed or downloaded, then it will try again at a later time.

## 🪟 Automatic scheduling (Windows)

These instructions assume that you want to turn your server off from between midnight and 6am and that you will check the server status every 15 minutes.

> [!IMPORTANT]
> If you check the server status too frequently then there is a higher chance that the server will power off whilst you are picking something else to play.

You need to set up a scheduled task to run the script:

- Click on “Start”, type “Task” and select “Task Scheduler”.
- Click on “Create Task”.
- Set the Name to: “Plex Autoshutdown”.
- Set the Description to: “Automatically shut down this machine if Plex is not running”.
- If you run Plex without logging a user in, then you will need to enable “Run whether user is logged in or not”.
- Click on the “Trigger” tab.
- Click on “New”.
- Set Begin the Task to: On a schedule.
- Set Settings to Daily, Start at 00:00, Recur every 1 day.
- Click on “OK”.
- Set “Repeat Task” to “every 15 minutes” for a duration of “6 hours” (you’ll need to type this in as the drop-down won’t have it)
- Set “Enabled” to ticked.
- Click on “Actions”.
- Click on “New”.
- Set “Action” to “Start a program”.
- Set Program/Script to the name and location of the script. Use the “Browse” button to locate it.
- Click on “OK”.
- Click on “Conditions”.
- Ensure that “Wake the computer to run this task” is turned off.
- Click on “OK”.

## 🐧 Automatic scheduling (Linux)

These instructions assume that you want to turn your server off from between midnight and 5:45am and that you will check the server status every 15 minutes.

> [!IMPORTANT]
> If you check the server status too frequently then there is a higher chance that the server will power off whilst you are picking something else to play.

You need to set up a cron to run this task:

- Type `crontab -e`
- Add the following line to the bottom of the crontab file: `0,15,30,45 0-5 * * * /path/to/plex-autoshutdown.sh >/dev/null`
- Make sure you change `/path/to/plex-autoshutdown.sh` to the correct full path and location.
- Save the file.

As the script outputs messages, this will be emailed to you. The use of `>/dev/null` ensures that this does not happen but you can also redirect it to a file if you wish.

## 🔌 Automatic power on

Once you have the script set up to shut down your machine, you also need some way to start it back up again in the morning.

The easiest way is to change your BIOS settings to power on the machine at a specific time. To access the BIOS, you will usually need to press a key such as <kbd>Del</kbd>, <kbd>F1</kbd>, <kbd>F2</kbd>, <kbd>F10</kbd> or <kbd>Esc</kbd> immediately after powering on. If you’re unsure which key to use for your computer or motherboard, check the manufacturer’s instructions or search online.

You can usually find the power-on scheduling option in your BIOS under a "Power" or "Advanced" menu, often called something like "Resume by RTC Alarm", "Wake on RTC", or "Wake on Alarm". If you don’t see it, check any "Power Management" or "ACPI" sections. 

> [!TIP]
> Whilst you are configuring this, I recommend you also enable the “automatically power on after power loss” option. This means that if you have a power cut then the server will automatically boot again when power is restored.


## 📝 Logging

The script outputs information to the terminal or console, showing whether any streams, downloads, live TV, blocking processes, or devices were detected, and what decisions the script made. This information can be useful for review or debugging. **Most of the time you won't need this output**, which is why the instructions either do nothing with it (on Windows) or redirect it to `/dev/null` (on Linux).

If you do decide you need to review the output (e.g. to troubleshoot an issue), you can redirect the output to a file by appending a redirect to the end of the command:

- Windows: `plex-autoshutdown.bat > "C:\path\to\logs\autoshutdown.log" 2>&1`
- Linux: `./plex-autoshutdown.sh > /path/to/logs/autoshutdown.log 2>&1`

If you intend to keep this redirect in place indefinitely then, over time, the log file will grow very large. To prevent this, you can use a simple rotation script that runs daily to archive old logs and keep only recent entries. The following code should be called once a day (for example, on start up), assumes that you write out to `autoshutdown.log` and will maintain up to 7 days of history.

**Windows** (save as `rotate-autoshutdown.bat`)
```batch
@echo off

set "LOG_DIR=C:\path\to\logs"
set "LOG_FILE=%LOG_DIR%\autoshutdown.log"

rem Delete the oldest log
del "%LOG_DIR%\autoshutdown-7.log" 2>nul

rem Shift logs up by one
for /l %%i in (6,-1,1) do (
    ren "%LOG_DIR%\autoshutdown-%%i.log" "autoshutdown-%%~ni%%i+.log" 2>nul
)

rem Move today's log to autoshutdown-1.log
move "%LOG_FILE%" "%LOG_DIR%\autoshutdown-1.log" 2>nul
```

**Linux** (save as `rotate-autoshutdown.sh`)
```bash
#!/bin/bash

LOG_DIR="/path/to/logs"
LOG_FILE="$LOG_DIR/autoshutdown.log"

# Delete the oldest log
rm -f "$LOG_DIR/autoshutdown-7.log"

# Shift logs up by one
for i in 6 5 4 3 2 1; do
    mv "$LOG_DIR/autoshutdown-$i.log" "$LOG_DIR/autoshutdown-$((i+1)).log" 2>/dev/null
done

# Move today's log to autoshutdown-1.log
mv "$LOG_FILE" "$LOG_DIR/autoshutdown-1.log" 2>/dev/null
```


This approach keeps your logs manageable while preserving recent history for troubleshooting. You can schedule these scripts using Task Scheduler on Windows or cron on Linux.

## ⚠️ Known issues

- The Plex API may continue reporting that content is being streamed for several minutes after playback stops. There is no workaround for this.
- The Plex API may fail to report active transcoding. To prevent shutdown during transcoding, the `Plex Transcoder` entry in `BLOCKING_PROCESSES` acts as an effective workaround.
- The script will not work if "Secured connections" is set to "Required" within Plex.

## 🛟 Questions/problems?

Please raise an issue at https://github.com/mrsilver76/plex-autoshutdown/issues.

## 💡 Future development: open but unplanned

This script currently meets the needs it was designed for, and no major new features are planned at this time. However, the project remains open to community suggestions and improvements. If you have ideas or see ways to enhance the tool, please feel free to submit a [feature request](https://github.com/mrsilver76/plex-autoshutdown/issues).

Some other improvements I'm thinking about, but won't implement unless there is demand, are:

- **Support for secured connections.** This would enable the script to work even if "Secured connections" is set to "Required" within the Plex server.
- **Report number of streams rather than just checking for 0.** Instead of only detecting whether there are zero streams, report how many active streams are running so you can decide based on count thresholds. 
- **Output to logs instead of screen.** Add or improve logging so that script output goes to log files rather than just the console, useful for monitoring and debugging. 
- **Sleep option, instead of power down.** Provide an option to put the machine into sleep/standby rather than fully powering it down when no active streams are detected. 
- **Test command line option.** Add a “dry-run” or “test” command line flag that will simulate the shutdown check without executing the shutdown, for validation purposes. 

## 📝 Attribution
- Plex is a registered trademark of Plex, Inc. This tool is not affiliated with or endorsed by Plex, Inc.
- With thanks to [https://www.plexopedia.com/plex-media-server/api/](https://www.plexopedia.com/plex-media-server/api/) for Plex API documentation.

## 🕰️ Version history

### 1.3 (xx March 2026)
- Added connectivity tests to check if Plex is running and the supplied token is valid.
- Improved the formatting of the output to make troubleshooting easier.
- Added support for blocking shutdown if certain processes are running.
- Added support for blocking shutdown if certain devices are on the network (e.g. a television).
- Added a test mode to enable verification of the logic without shutting down the server.
- Updated the documentation.

### 1.2 (28th March 2025)
- Added support for blocking shutdown if live TV is being recorded or viewed.
- Error messages now differentiate between transcoding and downloading when reporting why a shutdown is being blocked.
- Fixed a bug where the temporary file wasn't always removed after the script finishes.

### 1.1 (3rd November 2024)
- Added support for blocking shutdown if content is being transcoded or downloaded.
- Swapped the configuration variables so that the mandatory one is at the top.
- Cleaned up the documentation.

### 1.0 (19th October 2024)
- Initial release.
