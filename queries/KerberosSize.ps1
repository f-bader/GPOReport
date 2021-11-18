
#region Kerberos Size
$CheckSettings = @{
    "Set maximum Kerberos SSPI context token buffer size" = @{
        "Key"       = "HKLM\System\CurrentControlSet\Control\Lsa\Kerberos\Parameters"
        "ValueName" = "MaxTokenSize"
    }
}
#endregion
