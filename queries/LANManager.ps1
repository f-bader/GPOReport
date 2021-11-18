#region LAN Manager authentication level
$CheckSettings = @{
    "Network security: LAN Manager authentication level" = @{
        "Key"       = "HKLM\System\CurrentControlSet\Control\Lsa"
        "ValueName" = "LmCompatibilityLevel"
    }
}
#endregion
