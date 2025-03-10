# Allow Unsigned Extensions

This repository contains an AppleScript and a launch daemon plist file to automate enabling Safari's Developer Settings. The script ensures that both the "Show features for web developers" (on the Advanced tab) and the "Allow unsigned extensions" (on the Developer tab) checkboxes are enabled in Safari's settings.

## Contents

- `AllowUnsignedExtensions.applescript` - The AppleScript file that automates Safari's settings.
- `lt.tumenas.allowunsignedextensions.plist` - The launch daemon configuration file.
- `.gitignore` - Git ignore file to prevent committing macOS, log, temp, editor-specific, and compiled AppleScript files.
- `README.md` - This documentation.
- `LICENSE` - The license file for this project.

## Prerequisites

- macOS (tested on macOS Sequoia)
- Safari installed
- Accessibility permissions enabled for the script/application

## Features

- **Dynamic Delays:**  
  The script dynamically waits for UI elements to appear using customizable timeout logic (`timeoutSeconds`), rather than fixed delays.

- **Automatic Log Cleanup:**  
  Log files are stored in `/tmp` and include:
  - `/tmp/AllowUnsignedExtensions.log`
  - `/tmp/AllowUnsignedExtensions.error.log`
  - `/tmp/AllowUnsignedExtensions.output.log`
  
  The script automatically deletes any of these log files that are older than a customizable retention period (`logRetentionDays`).

- **Robust UI Automation:**  
  The script navigates to the Advanced tab to enable the "Show features for web developers" checkbox (if not already enabled) and then switches to the Developer tab to enable the "Allow unsigned extensions" checkbox. Alternative search logic has been implemented to improve resilience against changes in Safari's UI.

- **Enhanced Error Handling & Notifications:**  
  Critical failures now trigger user notifications in addition to logging. This helps in immediately alerting the user if a key UI element is not found.

- **Daemon Auto-Restart:**  
  The plist file includes a `KeepAlive` key so that if the daemon fails, launchd will attempt to restart it automatically.

## Customizable Variables

- **`timeoutSeconds`**:  
  The maximum time (in seconds) to wait for each UI element to appear.

- **`logRetentionDays`**:  
  The number of days to retain log files before they are automatically deleted.

## Usage

1. **AppleScript Setup:**
   - Open `AllowUnsignedExtensions.applescript` in Script Editor.
   - Save it as an application (e.g., `AllowUnsignedExtensions.app`).
   - Ensure the application has the required accessibility permissions.

2. **Launch Daemon Setup:**
   - Edit the plist file (`lt.tumenas.allowunsignedextensions.plist`) to replace `your-username` in the `ProgramArguments` path with your actual username.
   - Place the plist in the appropriate directory:
     - For system-wide daemons: `/Library/LaunchDaemons/`
     - For user agents: `~/Library/LaunchAgents/`
   - Load the daemon using:

     ```bash
     sudo launchctl load /Library/LaunchDaemons/lt.tumenas.allowunsignedextensions.plist
     ```

   - The daemon will automatically trigger the AppleScript when Safari is launched.

## Logging

- The AppleScript logs actions and errors to `/tmp/AllowUnsignedExtensions.log`.
- The launch daemon logs standard error to `/tmp/AllowUnsignedExtensions.error.log` and standard output to `/tmp/AllowUnsignedExtensions.output.log`.
- Logs older than the specified retention period (`logRetentionDays`) are automatically deleted.

## Troubleshooting

- **Accessibility Permissions:**  
  If the script fails to run, ensure that the application has been granted Accessibility permissions in System Settings > Accessibility.

- **UI Element Not Found:**  
  If you receive an error dialog stating that a UI element (e.g., "Settings" menu item, Advanced or Developer tab, or one of the checkboxes) was not found within the timeout period, try increasing `timeoutSeconds` in the AppleScript.

- **Hardcoded Username:**  
  If the daemon does not start correctly, ensure that you have replaced the `your-username` placeholder in the plist file with your actual username. This is crucial because launchd does not support environment variable expansion.

- **Daemon Restart Failures:**  
  If the daemon fails repeatedly, check the log files (`/tmp/AllowUnsignedExtensions.error.log` and `/tmp/AllowUnsignedExtensions.output.log`) for detailed error messages. These logs will help identify if a UI change or another issue is preventing the script from running successfully.

## Version History

- **v1.0.0** (2025-03-10):  
  - Initial release with dynamic UI waits, customizable log cleanup (including error and output logs), alternative UI element search logic, enhanced error notifications, and daemon auto-restart.

## License

This project is licensed under the terms specified in the `LICENSE` file.
