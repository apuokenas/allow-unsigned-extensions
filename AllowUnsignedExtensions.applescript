-- AllowUnsignedExtensions.applescript
--
-- Author: Apuokenas
-- Version: 1.0.1
-- Last Updated: 2025-03-11
--
-- This AppleScript enables Safari's Developer Settings by ensuring the 
-- "Show features for web developers" checkbox is checked on the Advanced tab,
-- and then it enables the "Allow unsigned extensions" checkbox on the Developer tab.
--
-- Usage:
-- - In Script Editor, export the AppleScript as an application (AllowUnsignedExtensions.app).
-- - Save the script application in the /Applications location.
-- - Ensure Safari and AllowUnsignedExtensions.app has accessibility permissions (System Settings > Privacy & Security > Accessibility).
-- - Save the accompanying lt.tumenas.enableunsignedextensions.plist file in ~/Library/LaunchAgents/.
-- - Register the launch agent permanently to auto-load it on each Safari launch: `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/lt.tumenas.allowunsignedextensions.plist`

--------------------------------------------------------------------------------
-- Configurable Variables
--------------------------------------------------------------------------------
set timeoutSeconds to 10 -- Maximum time (in seconds) to wait for UI elements
set logRetentionDays to 30 -- Number of days to retain log files

--------------------------------------------------------------------------------
-- Log Cleanup: Delete log files older than the specified number of days
--------------------------------------------------------------------------------
-- The find command searches in /tmp for any file with a name starting with "AllowUnsignedExtensions"
-- and ending with ".log", and deletes those older than logRetentionDays.
do shell script "find /tmp -name 'AllowUnsignedExtensions*.log' -mtime +" & (logRetentionDays as string) & " -delete"

--------------------------------------------------------------------------------
-- Utility: Append messages to a log file
--------------------------------------------------------------------------------
on logMessage(messageText)
    do shell script "echo " & quoted form of (messageText & return) & " >> /tmp/AllowUnsignedExtensions.log"
end logMessage

--------------------------------------------------------------------------------
-- Utility: Attempt to find a checkbox by name using alternative search logic
--------------------------------------------------------------------------------
on findCheckboxInWindow(winRef, checkboxName)
    tell application "System Events"
        -- First, try the default hierarchy
        try
            set chk to checkbox checkboxName of group 1 of group 1 of winRef
            if chk exists then return chk
        end try
        -- If not found, iterate over all groups in the window
        try
            set allGroups to every group of winRef
            repeat with g in allGroups
                try
                    set chk to checkbox checkboxName of g
                    if chk exists then return chk
                end try
            end repeat
        end try
        return missing value
    end tell
end findCheckboxInWindow

--------------------------------------------------------------------------------
-- Utility: Wait for a UI element to appear with dynamic delay
--------------------------------------------------------------------------------
on waitForElement(testBlock)
    set elapsedTime to 0
    repeat until testBlock() or elapsedTime > timeoutSeconds
        delay 0.5
        set elapsedTime to elapsedTime + 0.5
    end repeat
    return (elapsedTime ² timeoutSeconds)
end waitForElement

--------------------------------------------------------------------------------
-- Display error dialog and log message, then exit
--------------------------------------------------------------------------------
on handleCriticalFailure(errorMessage)
    logMessage(errorMessage)
    display dialog errorMessage buttons {"OK"} default button "OK"
    error errorMessage
end handleCriticalFailure

--------------------------------------------------------------------------------
-- Check for Accessibility permissions
--------------------------------------------------------------------------------
tell application "System Events"
    if not (UI elements enabled) then
        handleCriticalFailure("Accessibility permissions are not enabled. Please enable them in System Settings > Privacy & Security > Accessibility.")
    end if
end tell

--------------------------------------------------------------------------------
-- Activate Safari
--------------------------------------------------------------------------------
tell application "Safari" to activate

tell application "System Events"
    tell process "Safari"
        -- Wait for the Settings menu item with timeout
        if not (waitForElement(function() exists (menu item "Settings..." of menu "Safari" of menu bar 1) end function) ) then
            handleCriticalFailure("Settings menu item not found within timeout.")
        else
            logMessage("Settings menu item found.")
            click menu item "Settings..." of menu "Safari" of menu bar 1
        end if

        -- Wait for the Settings window to appear dynamically
        if not (waitForElement(function() exists window 1 end function)) then
            handleCriticalFailure("Settings window did not appear within timeout.")
        else
            logMessage("Settings window appeared.")
        end if

        -- Wait for the Advanced tab button to appear dynamically
        if not (waitForElement(function() exists (button "Advanced" of toolbar 1 of window 1) end function)) then
            handleCriticalFailure("Advanced tab button not found within timeout.")
        else
            logMessage("Advanced tab button appeared.")
            click button "Advanced" of toolbar 1 of window 1
        end if

        -- Wait for the "Show features for web developers" checkbox on the Advanced tab
        if not (waitForElement(function() (findCheckboxInWindow(window 1, "Show features for web developers")) ­ missing value end function)) then
            handleCriticalFailure("Checkbox 'Show features for web developers' not found on Advanced tab within timeout.")
        else
            logMessage("Checkbox 'Show features for web developers' appeared on Advanced tab.")
        end if

        -- Enable "Show features for web developers" if not already enabled
        set devFeaturesCheckbox to findCheckboxInWindow(window 1, "Show features for web developers")
        if devFeaturesCheckbox is missing value then
            handleCriticalFailure("Could not locate 'Show features for web developers' checkbox.")
        else if not (value of devFeaturesCheckbox as boolean) then
            click devFeaturesCheckbox
            logMessage("Enabled 'Show features for web developers'.")
            -- Wait for the Developer tab to become available after enabling
            if not (waitForElement(function() exists (button "Developer" of toolbar 1 of window 1) end function)) then
                handleCriticalFailure("Developer tab did not appear after enabling advanced features.")
            else
                logMessage("Developer tab appeared after enabling advanced features.")
            end if
        else
            logMessage("'Show features for web developers' already enabled.")
        end if

        -- Wait for the Developer tab button to appear dynamically
        if not (waitForElement(function() exists (button "Developer" of toolbar 1 of window 1) end function)) then
            handleCriticalFailure("Developer tab button not found within timeout.")
        else
            logMessage("Developer tab button appeared.")
            click button "Developer" of toolbar 1 of window 1
        end if

        -- Wait for the "Allow unsigned extensions" checkbox on the Developer tab
        if not (waitForElement(function() (findCheckboxInWindow(window 1, "Allow unsigned extensions")) ­ missing value end function)) then
            handleCriticalFailure("Checkbox 'Allow unsigned extensions' not found on Developer tab within timeout.")
        else
            logMessage("Checkbox 'Allow unsigned extensions' appeared on Developer tab.")
        end if

        -- Enable the "Allow unsigned extensions" checkbox if not already enabled
        set unsignedCheckbox to findCheckboxInWindow(window 1, "Allow unsigned extensions")
        if unsignedCheckbox is missing value then
            handleCriticalFailure("Could not locate 'Allow unsigned extensions' checkbox.")
        else if not (value of unsignedCheckbox as boolean) then
            click unsignedCheckbox
            logMessage("Enabled 'Allow unsigned extensions'.")
        else
            logMessage("'Allow unsigned extensions' already enabled.")
        end if
    end tell
end tell
