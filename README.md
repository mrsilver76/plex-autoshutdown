# Plex Autoshutdown

*A simple script which will check that no-one is using Plex before shutting down the server it is running on.*

This script is useful for people who have no requirement to run their Plex server 24/7 and have periods of time where no-one is using their server (eg. the early hours of the morning).

**There are two scripts, one for Windows uses and one for Linux users.** The Linux one may work with macOS, but I have no way of verifying. I'm happy to take a submission/fix from someone who owns one. 

## Features

Despite being small, these scripts have some useful features:

1. Easy to set up, there is (literally) only one option that you *must* configure.
2. Will not shut down a machine if there are active Plex streams.
3. Will not force a machine to shut down for a (configurable) period of time after power up. This ensures that you can override the script by manually powering on your server and it won't promptly shut it down again.

## Download

1. Download the latest version from https://github.com/mrsilver76/plex-autoshutdown/releases
2. Unzip the file. On Windows, you can double-click the file. On Linux you should use the `unzip` command, which may need to be installed.
3. Use the file ending in `.bat` for Windows and the file ending `.sh` for Linux.

## Configuration instructions

To configure the script, open it up in your preferred text editor.

For Windows, I recommend [Notepad++](https://notepad-plus-plus.org/) but Notepad will do. For Linux, I recommend [nano](https://www.nano-editor.org/) which usually comes preinstalled with most distributions.

There are two things in the code you can easily change:

### MIN_UPTIME

This is the minimum amount of time (in seconds) that a server must have been running (the “uptime”) before the script will work. The default (and recommended) value is `7200` which equates to 2 hours.

Using `7200` as an example, if you turn back on your Plex server at (say) 1am, then it will not attempt to turn the server back off again until 3am, even if you stop using it at 1:30am.

> :warning: If you set this value too low, then your server may turn off very quickly after you have turned it back on.

### PLEX_TOKEN

The script uses the Plex API in order to determine whether or not anything is streaming. To do this, it needs a token to use for authentication. There are instructions on how to find the token for your Plex server at https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/

You should modify this line to include your token (capitalisation is important). If you provide an invalid token then the script will always report that something is streaming. The token in the code (`abcd1234efgh5678`) is invalid and will not work.

> :warning: You should never share your Plex token with anyone else.

## Running instructions

To run the script, you can either double-click on it or run it from the command line. If you are using Linux then you will probably need to make the script executable with `chmod +x plex-autoshutdown.sh`.

To run on your Plex server, you will need to set up the script to run multiple times over the night. This is to ensure that if the shutdown is blocked because something is being streamed, then it will try again at a later time.

## Installation instructions (Windows)

These instructions assume that you want to turn your server off from between midnight and 6am and that you will check the server status every 15 minutes.

> :warning: If you check the server status too frequently then there is a higher chance that the server will power off whilst you are picking something else to play.

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

## Installation instructions (Linux)

These instructions assume that you want to turn your server off from between midnight and 5:45am and that you will check the server status every 15 minutes.

> :warning: If you check the server status too frequently then there is a higher chance that the server will power off whilst you are picking something else to play.

You need to set up a cron to run this task:

- Type `crontab -e`
- Add the following line to the bottom of the crontab file: `0,15,30,45 0-5 * * * /path/to/plex-autoshutdown.sh >/dev/null`
- Make sure you change `/path/to/plex-autoshutdown.sh` to the correct full path and location.
- Save the file.

As the script outputs messages, this will be emailed to you. The use of `>/dev/null` ensures that this does not happen but you can also redirect it to a file if you wish.

## Configuring automatic power on

Most modern computer BIOS’ allow you to configure a computer to power on at a specific time. You will need to Google the brand of your computer/motherboard to find out how to access the BIOS. If it usually through pressing one of the F keys on power up.

Whilst you are configuring this, I recommend you also enable the “automatically power on after power loss” option. This means that if you have a power cut then the server will automatically boot again when power is restored.

## Known issues

- The Plex API will often incorrectly report that content is being streamed for several minutes after it has been stopped. There is no workaround for this.
- There is no validation of the Plex token. If you've supplied one that doesn't work then the script will incorrectly report that something is being streamed and your server will never shut down.

## Questions/problems?

Please raise an issue at https://github.com/mrsilver76/plex-autoshutdown/issues.

## Future improvements

Possible future improvements can be found at https://github.com/mrsilver76/plex-autoshutdown/labels/enhancement. Unless there is significant interest, it's doubtful I'll implement many of them as the script in its current form suits me just fine.

Pull requests are accepted, provided the capability will be useful to the majority of users. This is to avoid having 101 niche features and stop the script being something easy to set up and configure.

## Version history

### 1.0 (19th October 2024)
- Initial release.
