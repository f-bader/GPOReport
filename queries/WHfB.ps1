
#region Windows Hello for Business
$CheckSettings = @{
    "HKLM - Use Windows Hello for Business"                        = @{
        "Key"       = "HKLM\SOFTWARE\Policies\Microsoft\PassportForWork"
        "ValueName" = "Enabled"
    }
    "HKLM - Do not start Windows Hello provisioning after sign-in" = @{
        "Key"       = "HKLM\SOFTWARE\Policies\Microsoft\PassportForWork"
        "ValueName" = "DisablePostLogonProvisioning"
    }
    "HKCU - Use Windows Hello for Business"                        = @{
        "Key"       = "HKCU\SOFTWARE\Policies\Microsoft\PassportForWork"
        "ValueName" = "Enabled"
    }
    "HKCU - Do not start Windows Hello provisioning after sign-in" = @{
        "Key"       = "HKCU\SOFTWARE\Policies\Microsoft\PassportForWork"
        "ValueName" = "DisablePostLogonProvisioning"
    }
    "HKLM - Turn on convenience PIN sign-in"                       = @{
        "Key"       = "HKLM\SOFTWARE\Policies\Microsoft\Windows\System"
        "ValueName" = "AllowDomainPINLogon"
    }
}
#endregion
