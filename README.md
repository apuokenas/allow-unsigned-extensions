# Allow Unsigned Extensions

This repository contains an AppleScript and a launch agent's XML [property list](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/UnderstandXMLPlist/UnderstandXMLPlist.html) (plist) file to automate enabling Safari's Developer Settings. The script ensures that both the "Show features for web developers" (on the Advanced tab) and the "Allow unsigned extensions" (on the Developer tab) checkboxes are enabled in Safari's settings.

## Why This Project Exists?

Some Safari extensions come unsigned (such as [ImprovedTube](https://github.com/code-charity/youtube)) when their developers were not willing to pay Apple a [99 USD/year](https://developer.apple.com/programs/whats-included/#:~:text=The%20Apple%C2%A0Developer%20Program%20is%2099%20USD%20per%20membership%20year) subscription fee, so such extensions have to be allowed every time Safari quits and opens. The same applies when you are [building and running a Safari extension](https://developer.apple.com/documentation/safariservices/building-a-safari-app-extension) by delivering it inside a macOS app for you or any other user to run it so the Safari extension immediately becomes available in this web browser.

Suppose you are not part of the Apple Developer Program or have not yet configured a developer identity for your existing Xcode project. In that case, your Safari web extension would not be signed with a development certificate. [Safari ignores unsigned extensions by default](https://developer.apple.com/documentation/safariservices/running-your-safari-web-extension#Configure-Safari-in-macOS-to-run-unsigned-extensions) for security purposes, so your extension would not appear in Safari Extensions preferences.

To develop or to load an extension without a certificate, each time you launch Safari, you need to tell it to load unsigned extensions using the Develop menu.

If you are using Safari 17 or later, click the Developer tab in Safari Settings and select the "Allow unsigned extensions" option. The Allow Unsigned Extensions setting [resets](https://developer.apple.com/documentation/safariservices/building-a-safari-app-extension#:~:text=The%20Allow%20Unsigned%20Extensions%20setting%20resets%20when%20a%20user%20quits%20Safari%2C%20so%20you%20need%20to%20set%20it%20again%20the%20next%20time%20you%20launch%20Safari.) when a user quits Safari, so you must set it again the next time you launch Safari.

I created this project to solve such a nagging issue of constantly re-enabling the "Allow unsigned extensions" option again the next time you launch Safari. However, you must still enter your password and click OK to allow unsigned extensions. At least you do not need to re-enable the unsigned extension by selecting its checkbox on the Extensions tab of the Safari Settings window.

## Contents

- [`.gitignore`](https://github.com/apuokenas/allow-unsigned-extensions/blob/master/.gitignore) - Git ignore file to prevent committing macOS, log, temp, editor-specific, and compiled AppleScript files.
- [`AllowUnsignedExtensions.applescript`](https://github.com/apuokenas/allow-unsigned-extensions/blob/master/AllowUnsignedExtensions.applescript) - The AppleScript file that automates Safari's settings.
- [`LICENSE`](https://github.com/apuokenas/allow-unsigned-extensions/blob/master/LICENSE) - The license file for this project.
- [`README.md`](https://github.com/apuokenas/allow-unsigned-extensions/blob/master/README.md) - This documentation.
- [`lt.tumenas.allowunsignedextensions.plist`](https://github.com/apuokenas/allow-unsigned-extensions/blob/master/lt.tumenas.allowunsignedextensions.plist) - The launch agent configuration file.

## Prerequisites

- macOS (tested on macOS Sequoia 15.3.1)
- Safari 17+ installed (tested on Safari 18.3)
- Accessibility permissions enabled for the `Safari.app` and `AllowUnsignedExtensions.app` (System Settings > Privacy & Security > Accessibility)

## Customizable Variables

- **`timeoutSeconds`**:  
  The maximum time (in seconds) to wait for each UI element to appear.

- **`logRetentionDays`**:  
  The number of days to retain log files before they are automatically deleted.

## Features

- **Dynamic Delays:**  
  The script dynamically waits for UI elements to appear using customizable timeout logic (`timeoutSeconds`) rather than fixed delays.

- **Automatic Log Cleanup:**  
  Log files are stored in `/tmp` and include:
  - `/tmp/AllowUnsignedExtensions.log`
  - `/tmp/AllowUnsignedExtensions.error.log`
  - `/tmp/AllowUnsignedExtensions.output.log`
  
  The script automatically deletes any of these log files older than a customizable retention period (`logRetentionDays`).

- **Robust UI Automation:**  
  The script navigates to the Advanced tab to enable the "Show features for web developers" checkbox (if not already enabled) and then switches to the Developer tab to enable the "Allow unsigned extensions" checkbox. Alternative search logic has been implemented to improve resilience against changes in Safari's UI.

- **Enhanced Error Handling & Notifications:**  
  Critical failures trigger user notifications in addition to logging. This helps immediately alert the user if a key UI element is not found.

- **Launch Agent Auto-Restart:**  
  The plist file includes a `KeepAlive` key so that if the launch agent fails, launchd will attempt to restart it automatically.

## Usage

1. **AppleScript Setup:**
   - Open `AllowUnsignedExtensions.applescript` in Script Editor.
   - Export it as an application (`AllowUnsignedExtensions.app`).
   - Save `AllowUnsignedExtensions.app` in the `~/Applications/` directory.
   - Ensure the application has the required accessibility permissions (System Settings > Privacy & Security > Accessibility).

2. **Launch Agent Setup:**
   - Edit the plist file (`lt.tumenas.allowunsignedextensions.plist`) to replace `your-username` in the `ProgramArguments` path with your actual username.
   - Place the plist in the appropriate directory for user agents: `~/Library/LaunchAgents/` (as we are dealing with the application that runs under the current user's context and does not require root privileges)
   - Load the launch agent (register it permanently) using:

     ```bash
     sudo launchctl bootstrap ~/Library/LaunchAgents/lt.tumenas.allowunsignedextensions.plist
     ```

   - Run this to unload the launch agent (needed in exceptional cases only, such as when updating the agent configuration or removing the agent, when trying to isolate the agent-related issue, or when temporarily disabling the agent to perform some maintenance):

     ```bash
     sudo launchctl bootout ~/Library/LaunchAgents/lt.tumenas.allowunsignedextensions.plist
     ```

   - The launch agent will automatically trigger the AppleScript when Safari is launched.

## Logging

- The AppleScript logs actions and errors to `/tmp/AllowUnsignedExtensions.log`.
- The launch agent logs standard errors to `/tmp/AllowUnsignedExtensions.error.log` and standard output to `/tmp/AllowUnsignedExtensions.output.log`.
- Logs older than the specified retention period (`logRetentionDays`) are automatically deleted.
- macOS generally removes temporary files in `/tmp` that haven't been accessed for around 3 days, although the exact timing can vary, and the system also clears `/tmp` on reboot.

## Troubleshooting

- **Accessibility Permissions:**  
  If the script fails to run, ensure that the application has been granted Accessibility permissions in System Settings > Privacy & Security > Accessibility.

- **UI Element Not Found:**  
  If you receive an error dialog stating that a UI element (e.g., "Settings" menu item, Advanced or Developer tab, or one of the checkboxes) was not found within the timeout period, try increasing `timeoutSeconds` in the AppleScript.

- **Hardcoded Username:**  
  If the launch agent does not start correctly, ensure that you have replaced the `your-username` placeholder in the plist file with your actual username. This is crucial because launchd does not support environment variable expansion.

- **Launch Agent Restart Failures:**  
  If the launch agent fails repeatedly, check the log files (`/tmp/AllowUnsignedExtensions.error.log` and `/tmp/AllowUnsignedExtensions.output.log`) for detailed error messages. These logs will help identify if a UI change or another issue is preventing the script from running successfully.

## Version History

- **v1.0.1** (2025-03-11):  
  - Fix documentation style and typos.
- **v1.0.0** (2025-03-10):  
  - Initial release with dynamic UI waits, customizable log cleanup (including error and output logs), alternative UI element search logic, enhanced error notifications, and launch agent auto-restart.

## License

This project is licensed under the terms specified in the `LICENSE` file.
