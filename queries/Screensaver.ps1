
#region Screensaver
$CheckSettings = @{
    "Number of seconds to wait to enable the screen saver" = @{
        "Key"       = "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop"
        "ValueName" = "ScreenSaveTimeOut"
    }
    "Password protect the screen saver"                    = @{
        "Key"       = "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop"
        "ValueName" = "ScreenSaverIsSecure"
    }
}
#endregion
