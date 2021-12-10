# GPOReport
A PowerShell function to search for specific group policy settings in all GPOs in a large enterprise environment

## How to use

### Dot Source function

```powershell
. .\Get-SettingsFromGPO.ps1
```

### Define a settings query hashtable

```powershell
$CheckSettings = @{
    "Unique setting name for the report. Choose something you can remember, like the display name of the setting" = @{
        # Key = The path to the registry key
        "Key"       = "HKLM\SOFTWARE\Policies\Microsoft\PassportForWork"
        # ValueName = The name of the registry value 
        "ValueName" = "Enabled"
    }
}
```

### Query your domain

```powershell
#region Query one domain
Get-SettingsFromGPO -Domain "your.dom.ain" -CheckSetting $CheckSettings
#endregion

#region Query multiple domains and save to file
$Domains = @(
    "your.dom1.ain",
    "your.dom2.ain"
)
# Export data as JSON
$Report = $Domains | Get-SettingsFromGPO -CheckSetting $CheckSettings
$Report | ConvertTo-Json | Out-File -FilePath "C:\Temp\GPOs.json" -Encoding UTF8
#endregion
```

### Queries

Need inspiration? You can find a bunch of queries [here](./queries/). Please feel free to provide your queries as a pull request to this repository.

* [Kerberos Ticket Size](./queries/KerberosSize.ps1)
* [LAN Manager authentication level](./queries/LANManager.ps1)
* [Windows Hello for Business](./queries/WHfB.ps1)
* [Screensaver](./queries/Screensaver.ps1)
