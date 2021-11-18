function Get-SettingsFromGPO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $CheckSetting,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$Domain,

        [switch]$NoGPLink
    )
    begin {
        #region Functions
        function Get-IniContent ($filePath) {
            # Source: https://blogs.technet.microsoft.com/heyscriptingguy/2011/08/20/use-powershell-to-work-with-any-ini-file/
            $ini = @{}
            switch -regex -file $FilePath {
                "^\[(.+)\]" {
                    # Section
                    $section = $matches[1]
                    $ini[$section] = @{}
                    $CommentCount = 0
                }
                "^(;.*)$" {
                    # Comment
                    $value = $matches[1]
                    $CommentCount = $CommentCount + 1
                    $name = "Comment" + $CommentCount
                    $ini[$section][$name] = $value
                }
                "(.+?)\s*=(.*)" {
                    # Key
                    $name, $value = $matches[1..2]
                    $ini[$section][$name] = $value
                }
            }
            return $ini
        }

        function Convert-InfRegValueToObject ($Value) {
            $RegData = $Value -split ","
            if ($RegData.Count -ne 2) {
                throw "Cannot convert $Value to PSObject"
            }
            # 1 – REG_SZ, 2 – REG_EXPAND_SZ, 3 – REG_BINARY, 4 – REG_DWORD, 7 – REG_MULTI_SZ
            $Type = switch ($RegData[0]) {
                1 { "REG_SZ" }
                2 { "REG_EXPAND_SZ" }
                3 { "REG_BINARY" }
                4 { "REG_DWORD" }
                5 { "REG_MULTI_SZ" }
                Default { "Unknown " }
            }
            Return [pscustomobject]@{
                Value = $RegData[1]
                Type  = $Type
            }
        }
    }

    process {
        $AllGPOs = Get-GPO -All -Domain $Domain -ErrorAction Stop
        foreach ($GPO in $AllGPOs) {
            # Also check "Machine\microsoft\windows nt\SecEdit\GptTmpl.inf" the policy
            $FilePath = "\\$($GPO.DomainName)\SYSVOL\$($GPO.DomainName)\Policies\{$($GPO.Id)}\Machine\microsoft\windows nt\SecEdit\GptTmpl.inf"
            foreach ( $setting in $CheckSettings.Keys ) {

                #region Check with Get-GPRegistryValue
                Write-Verbose "[$($GPO.DomainName)][$($GPO.DisplayName)]::[$($CheckSettings[$setting].Key)]::Policy::[$($CheckSettings[$setting].ValueName)]"
                $GPValue = Get-GPRegistryValue -Name $GPO.DisplayName -Key $CheckSettings[$setting].Key -ValueName $CheckSettings[$setting].ValueName -Domain $GPO.DomainName -ErrorAction SilentlyContinue
                #endregion

                #region Check in GptTmpl.inf
                if ( [string]::IsNullOrWhiteSpace($GPValue) -and (Test-Path $FilePath -ErrorAction SilentlyContinue) ) {
                    Write-Verbose "[$($GPO.DomainName)][$($GPO.DisplayName)]::No GPO value found, try GptTmpl.inf method"
                    $InfContent = Get-IniContent $FilePath
                    # Change HKLM to MACHINE because MSFT and add the ValueName
                    $InfKeyValue = ($CheckSettings[$setting].Key -replace 'HKLM', 'MACHINE') + '\' + $CheckSettings[$setting].ValueName
                    Write-Verbose "[$($GPO.DomainName)][$($GPO.DisplayName)]::INF::$InfKeyValue"
                    # Check if the key exists
                    if ( $InfKeyValue -in $InfContent['Registry Values'].Keys ) {
                        # Get current value
                        $InfValue = $InfContent['Registry Values'][$InfKeyValue]
                        # Check if string is empty
                        if (-not [string]::IsNullOrWhiteSpace($InfValue) ) {
                            # Convert numeric value to PSObject
                            $GPValue = Convert-InfRegValueToObject $InfValue
                        }
                    }
                }
                #endregion

                #region Check with Get-GPPrefRegistryValue
                if ( [string]::IsNullOrWhiteSpace($GPValue) ) {
                    Write-Verbose "[$($GPO.DomainName)][$($GPO.DisplayName)]::[$($CheckSettings[$setting].Key)]::RegistryValue::[$($CheckSettings[$setting].ValueName)]"
                    $GPValue = Get-GPPrefRegistryValue -Name $GPO.DisplayName -Context Computer -Key $CheckSettings[$setting].Key -ValueName $CheckSettings[$setting].ValueName -Domain $GPO.DomainName -ErrorAction SilentlyContinue
                }
                #endregion
                if ($GPValue) {
                    if ($PSBoundParameters.ContainsKey('NoGPLink')) {
                        $Links = ""
                    } else {
                        #region Get GPO Link
                        # but only if it was not done already for the last setting
                        if ( $GPOReport.GPO.Name -ne $GPO.DisplayName ) {
                            [xml]$GPOReport = $GPO | Get-GPOReport -ReportType XML -Domain $Domain
                            $Links = $GPOReport.GPO.LinksTo
                        }
                        #endregion
                    }
                    [pscustomobject]@{
                        DomainName  = $GPO.DomainName
                        GPO         = $GPO.DisplayName
                        GPOLinks    = $Links
                        Setting     = $setting
                        ValueName   = $CheckSettings[$setting].ValueName
                        Hive        = $CheckSettings[$setting].Key
                        WmiFilter   = "$($GPO.WmiFilter)"
                        PolicyState = $GPValue.PolicyState
                        Value       = $GPValue.Value
                        Type        = $GPValue.Type
                        Path        = $GPO.Path
                    }
                }
            }
        }
    }

    end {}
}
