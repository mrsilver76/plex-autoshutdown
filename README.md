# Plex Autoshudown

*A simple script which, when executed, will check that no-one is using Plex before shutting down the server it is running on.*

This script is useful for people who have no requirement to run their Plex server 24/7 and have periods of time where no-one is using their server (eg. the early hours of the morning). In addition, the script will not "fight" with someone who manually turns on the Plex server and then doesn't stream anything for a period of time. This period of time is configurable.

There are two scripts, one for Windows uses and one for Linux users. There is no script (yet) for people running MacOS – although submissions are welcome.

## Licence

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any and all copyright interest in the software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to https://unlicense.org


## Known issues

- The Plex API will often incorrectly report that content is being streamed for several minutes after it has been stopped. There is no workaround for this.
- If you do not provide a valid Plex token then the script will always report that nothing is being streamed.

## Configuration instructions

To configure the script, open it up in your preferred text editor. For Windows, we recommend Notepad. For Linux we recommend nano.

There are two things in the code you can easily change:

### MIN_UPTIME

This is the minimum amount of time (in seconds) that a server must have been running (the “uptime”) before the script will work. The default (and recommended) value is `7200` which equates to 2 hours.

Using `7200` as an example, if you turn back on your Plex server at (say) 1am, then it will not attempt to turn the server back off again until 3am, even if you stop using it at 1:30am.

### PLEX_TOKEN

The script uses the Plex API in order to determine whether or not anything is streaming. To do this, it needs a token to use for authentication. There are instructions on how to find the token for your Plex server at https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/

You should modify this line to include your token (capitalisation is important). If you do not or you provide the wrong token then the script will always report that something is streaming.

> :warning: You should never share your Plex token with anyone else.

## Running instructions

To run the script, you can either double-click on it or run it from the command line. If you are using Linux then you will probably need to make the script executable with `chmod +x plex-autoshutdown.sh`.

To run on your Plex server, you will need to set up the script to run multiple times over the night. This is to ensure that if the shutdown is blocked because something is being streamed, then it will try again at a later time.

## Installation instructions (Windows)

You need to set up a scheduled task to run the script. These instructions assume that you want to turn your server off from between midnight and 6am.

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

You need to set up a cron to run this task. These instructions assume that you want to turn your server off from between midnight and 5:45am.

- Type `crontab -e`
- Add the following line to the bottom of the crontab file: `0,15,30,45 0-5 * * * /path/to/plex-autoshutdown.sh >/dev/null`
- Make sure you change `/path/to/plex-autoshutdown.sh` to the correct full path and location.
- Save the file.

As the script outputs messages, this will be emailed to you. The use of `>/dev/null` ensures that this does not happen.

## Configuring automatic power on

Most modern computer BIOS’ allow you to configure a computer to power on at a specific time. You will need to Google the brand of your computer/motherboard to find out how to access the BIOS. If it usually through pressing one of the F keys on power up.

Whilst you are configuring this, we recommend you enable the “automatically power on after power loss” option.

## Questions/problems?

Please raise a ticket.

## Want to make an improvement?

Pull requests are accepted provided:

1. They are offered under the unlicence (https://unlicense.org)
2. The feature/change is well documented and easy to understand.
3. The feature/change has sensible defaults.
4. The feature/change will be useful to the majority of users (we're trying to avoid having 1001 niche features)
5. The feature/change has been implemented (where possible) in both Windows and Linux.

We encourage people to use the same variable names in scripts to make documenting the options easier.
