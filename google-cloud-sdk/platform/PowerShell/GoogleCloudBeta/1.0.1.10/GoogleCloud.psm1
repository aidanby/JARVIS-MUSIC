$script:GCloudModule = $ExecutionContext.SessionState.Module
$script:GCloudModulePath = $script:GCloudModule.ModuleBase
$script:GCloudSdkLicense = @"
The Google Cloud SDK and its source code are licensed under Apache
License v. 2.0 (the "License"), unless otherwise specified by an alternate
license file.

You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Note that if you use the Cloud SDK with any Google Cloud Platform products,
your use is additionally going to be governed by the license agreement or
terms of service, as applicable, of the underlying Google Cloud Platform
product with which you are using the Cloud SDK. For example, if you are
using the Cloud SDK with Google App Engine, your use would additionally be
governed by the Google App Engine Terms of Service.

This also means that if you were to create works that call Google APIs, you
would still need to agree to the terms of service (usually, Google's
Developer Terms of Service at https://developers.google.com/terms) for those
APIs separately, as this code does not grant you any special rights to use
the services.

We collect anonymized usage data and anonymized stacktraces when crashes are encountered;
additional information is available at <https://cloud.google.com/sdk/usage-statistics>.

You may opt out of this collection at any time in the future by running the following command:
 gcloud config set disable_usage_reporting true

By installing the Cloud SDK, you accept the terms of the license.

"@
$script:gCloudInitWarning = "You will have to restart the shell and/or run 'gcloud init' " +
    "(if you haven't run it after installing the SDK) before the module can be used."
$script:installingSdkActivity = "Installing Google Cloud SDK"

# This function returns true if we are running PowerShell on Windows.
function IsWindows() {
    if ($PSVersionTable.PSEdition -ne "Core") {
        return $true
    }

    if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
        [System.Runtime.InteropServices.OSPlatform]::Windows)) {
        return $true
    }

    return $false
}

# Check and install Google Cloud SDK if it is not present. To install it non-interactively,
# set GCLOUD_SDK_INSTALLATION_NO_PROMPT to $true.
function Install-GCloudSdk {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param()

    $gCloudSDK = Get-Command gcloud -ErrorAction SilentlyContinue

    if ($null -ne $gCloudSDK) {
        return
    }

    Write-Host "Google Cloud SDK is not found in PATH. The SDK is required to run the module."
    $noPrompt = $env:GCLOUD_SDK_INSTALLATION_NO_PROMPT -eq $true -or $args -match "-?quiet"

    $query = "Do you want to install Google Cloud SDK? If you want to force the installation without prompt," +
             " set `$env:GCLOUD_SDK_INSTALLATION_NO_PROMPT to true or add '-quiet' to Import-Module -ArgumentList."
    $caption = "Installing Google Cloud SDK"

    $uiQuery = "Do you want to use the interactive installer? Select no to install silently on the command line."
    $uiCaption = "Installing Google Cloud SDK interactively"

    if ($PSCmdlet.ShouldProcess("Google Cloud SDK", "Install")) {
        if ($noPrompt) {
            Install-GCloudSdkSilently
        }
        else {
            if ($PSCmdlet.ShouldContinue($query, $caption)) {
                if ($PSCmdlet.ShouldContinue($uiQuery, $uiCaption)) {
                    Install-GCloudSdkInteractively
                }
                else {
                    Install-GCloudSdkSilently
                    gcloud init
                }
            }
        }
    }
}

function Install-GCloudSdkInteractively() {
    if (IsWindows) {
        $cloudSdkInstaller = "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
        $installerLocation = Join-Path $env:TMP "$([System.IO.Path]::GetRandomFileName()).exe"

        Write-Progress -Activity $installingSdkActivity `
                        -Status "Downloading interactive installer to $installerLocation."

        # Set this to hide the progress bar from Invoke-WebRequest, which is not very useful.
        $ProgressPreference = "SilentlyContinue"
        Invoke-WebRequest -Uri $cloudSdkInstaller -OutFile $installerLocation
        $ProgressPreference = "Continue"

        Write-Progress -Activity $installingSdkActivity `
                        -Status "Launching interactive installer. Blocking until installation is complete."
        Start-Process $installerLocation -Wait
        Write-Progress -Activity $installingSdkActivity -Completed
    }
    else {
        curl https://sdk.cloud.google.com | bash
    }
    Write-Warning $gCloudInitWarning
}

function Install-GCloudSdkSilently() {
    Write-Host $GCloudSdkLicense

    if (-not (IsWindows)) {
        curl https://sdk.cloud.google.com | bash -s -- --disable-prompts
        $cloudBinPath = "$HOME\google-cloud-sdk\bin"
        $envPath = [System.Environment]::GetEnvironmentVariable("PATH")
        if (-not $envPath.Contains($cloudBinPath)) {
            [System.Environment]::SetEnvironmentVariable("PATH", "$($envPath):$cloudBinPath")
        }
        return
    }

    # We use this method of installation instead of the installer because the installer does all the installation
    # in the background so we can't determine when it's done.
    $cloudSdkUri = "https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip"
    $zipFileLocation = Join-Path $env:TMP ([System.IO.Path]::GetRandomFileName())
    $extractedFolder = Join-Path $env:TMP ([System.IO.Path]::GetRandomFileName())
    $installationPath = "$env:LOCALAPPDATA\Google\Cloud SDK"

    Write-Progress -Activity $installingSdkActivity `
                   -Status "Downloading latest version of Cloud SDK to $zipFileLocation."

    # Set this to hide the progress bar from Invoke-WebRequest, which is not very useful.
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest -Uri $cloudSdkUri -OutFile $zipFileLocation
    $ProgressPreference = "Continue"

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    # This will extract it to a folder $env:APPDATA\google-cloud-sdk.
    Write-Progress -Activity $installingSdkActivity `
                   -Status "Extracting Google Cloud SDK to '$extractedFolder' ..."
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFileLocation, $extractedFolder)

    if (-not (Test-Path $installationPath)) {
        md $installationPath | Out-Null
    }
    Write-Progress -Activity $installingSdkActivity `
                   -Status "Moving Google Cloud SDK to '$installationPath' ..."
    Copy-Item "$extractedFolder\google-cloud-sdk" $installationPath -Recurse -Force

    # Set this to true to disable prompts.
    $env:CLOUDSDK_CORE_DISABLE_PROMPTS = $true
    Write-Progress -Activity $installingSdkActivity `
                   -Status "Running installation script ..."
    & "$installationPath\google-cloud-sdk\install.bat" --quiet 2>$null

    $cloudBinPath = "$installationPath\google-cloud-sdk\bin"
    $envPath = [System.Environment]::GetEnvironmentVariable("Path")
    if (-not $envPath.Contains($cloudBinPath)) {
        [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$cloudBinPath")
    }

    # We need to set this to false so user can run gcloud init after if they want.
    $env:CLOUDSDK_CORE_DISABLE_PROMPTS = $false

    Write-Progress -Activity $installingSdkActivity -Completed
}

Install-GCloudSdk

# Import either .NET Core or .NET Full version of the module based on
# the edition of PowerShell.
if ($PSVersionTable.PSEdition -eq "Core") {
    Import-Module "$script:GCloudModulePath\coreclr\Google.PowerShell.dll"
}
else {
    Import-Module "$script:GCloudModulePath\fullclr\Google.PowerShell.dll"
}

function gs:() {
    <#
    .SYNOPSIS
    Changes the directory to the Google Cloud Storage drive.
    .DESCRIPTION
    This function changes the directory to the Google Cloud Storage drive.
    It can be called before the Google Cloud PowerShell module is imported.
    #>
    cd gs:
}

# SIG # Begin signature block
# MIIUEgYJKoZIhvcNAQcCoIIUAzCCE/8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCx4dX8Q8E5JhPW
# bKrLZD9mpDByyeKJzYs5i5adQdTQpqCCDtswggSZMIIDgaADAgECAg8WiPA5JV5j
# jmkUOQfmMwswDQYJKoZIhvcNAQEFBQAwgZUxCzAJBgNVBAYTAlVTMQswCQYDVQQI
# EwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtlIENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
# VFJVU1QgTmV0d29yazEhMB8GA1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29t
# MR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0LU9iamVjdDAeFw0xNTEyMzEwMDAwMDBa
# Fw0xOTA3MDkxODQwMzZaMIGEMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRl
# ciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8g
# Q0EgTGltaXRlZDEqMCgGA1UEAxMhQ09NT0RPIFNIQS0xIFRpbWUgU3RhbXBpbmcg
# U2lnbmVyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6ek939c3CMke
# OLJSU0JtIvGxxAYEa579gnRQQ33GoLsfTvkCcSax70PYg4xI/OcPl3qa65zepqMO
# OxxEGHWOeKUXaf5JGKTiu1xO/o4qVHpQ8NX2zJHnmXnX3nmU15Yz/g6DviK/YxYs
# o90oG689q+qX0vG/BBDnPUhF/R9oZcF/WZlpwCIxDGJup1xlASGwY8QiGCfu5vzS
# AD1HLqi4hlZdBNwTFyVuHN9EDxXNt9ulV3ZCbwBogpnS48He8IuUV0zsCJAiIc4i
# K5gMQuZCk5SYk+/9Btk/vFubVDwgse5q1kd6xauA6TCa3vGkP1VNCgk0inUp0mmt
# lw9Qv/jKCQIDAQABo4H0MIHxMB8GA1UdIwQYMBaAFNrtZHQUnBQ8q92Zqb1bKE2L
# PMnYMB0GA1UdDgQWBBSOay0za/Qzp5OzE5ql4Ar3EjVqiDAOBgNVHQ8BAf8EBAMC
# BsAwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8E
# OzA5MDegNaAzhjFodHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVROLVVTRVJGaXJz
# dC1PYmplY3QuY3JsMDUGCCsGAQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDov
# L29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQUFAAOCAQEAujMkQECMfNtY
# n7NgmLL1wDH+6x9uUPYK4OTmga0mh6Lf/bPa9HPzAPspG4kbFT7ba1KTK8SsOYHX
# PGdXmjk24CgImuM5T5uJCX97xWF/WYkyJQpqrho+8KInqLbDuIf3FgRIQT1c2Oyf
# TSAxBNlloe3NaQdTFj3dNgIKiOtA5QYwC7gWS9zvvFUJ/8Y+Ei52s9zOQu/5dlfh
# twoFQJhYml1xFpNxjGWB6m/ziff7c62057/Zjm+qC08l87jh1d11mGiB+KrA0YDC
# xMQ5icH2yZ5s13T52Zf4T8KaCs1ej/gZ6eCln8TwkiHmLXklySL5w/A6hFetOhb0
# Y5QQHV3QxjCCBN0wggPFoAMCAQICECqcIayqpjo8WKe5MivulI0wDQYJKoZIhvcN
# AQELBQAwfzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0
# aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMTAwLgYDVQQDEydT
# eW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBDb2RlIFNpZ25pbmcgQ0EwHhcNMTUxMjE2
# MDAwMDAwWhcNMTgxMjE2MjM1OTU5WjBkMQswCQYDVQQGEwJVUzETMBEGA1UECAwK
# Q2FsaWZvcm5pYTEWMBQGA1UEBwwNTW91bnRhaW4gVmlldzETMBEGA1UECgwKR29v
# Z2xlIEluYzETMBEGA1UEAwwKR29vZ2xlIEluYzCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAMQNgsRBKSjl/Qw/pccOZr2lxIuziqyEA5+ELjjfBrFO/TNg
# WDg23SLP3/FQH0fxVQXBgQHnKD7/X4kSCerfqhdJLHGrSNGdLvRR4APg9xZsewwi
# dW1+H0nEQyiIQdxs7RMqA5nrYhT5NSZuEiwD4veBuRoFZwZ8phpb7SAV5S2D3o42
# +h4IQRwaSJ+28cMvAhNLp8q67xxYb47TDxSkCytduvRaow1kNKWK149NImZNpK7h
# +c3GWObGEXcy37rfOUiK0SfXM3eoyeRe7foSz/P9+u6rgIYTNOtafm9sG+7YS7LM
# d5iHrMr1u2RvSR5bkWNQH2MtgydzB58rFvR7cSkCAwEAAaOCAW4wggFqMAkGA1Ud
# EwQCMAAwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMGYGA1Ud
# IARfMF0wWwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcCARYXaHR0cHM6Ly9kLnN5
# bWNiLmNvbS9jcHMwJQYIKwYBBQUHAgIwGRoXaHR0cHM6Ly9kLnN5bWNiLmNvbS9y
# cGEwHwYDVR0jBBgwFoAUljtT8Hkzl699g+8uK8zKt4YecmYwKwYDVR0fBCQwIjAg
# oB6gHIYaaHR0cDovL3N2LnN5bWNiLmNvbS9zdi5jcmwwVwYIKwYBBQUHAQEESzBJ
# MB8GCCsGAQUFBzABhhNodHRwOi8vc3Yuc3ltY2QuY29tMCYGCCsGAQUFBzAChhpo
# dHRwOi8vc3Yuc3ltY2IuY29tL3N2LmNydDARBglghkgBhvhCAQEEBAMCBBAwFgYK
# KwYBBAGCNwIBGwQIMAYBAQABAf8wDQYJKoZIhvcNAQELBQADggEBACPnk5Ov26hN
# r69U6NgmlYDNI5Fw7QtbsenY3R5AN3iXGO2f5YRnhQZQtfGr5oNaF3tRvn8Yxkde
# K6r0oB81PgWfQ0D3n9H04acC847Jcf4YN0hC1+Q2cxCS1NjZHMQmWBhntiQiaWMC
# 90lRa3X2tH1W/yz0iPdnbwiG84sLMAJ/bZLZTr2Z93t0hgzLua0sv0R5qACCnGL0
# qhHf0r/w4ZIoEZC7XjOIhpZN3Quvw2ehlS1EMsb697iAwU44vh+2hPfxITFnSaif
# inUH3zs6w+pyzUB/p9p8yS58qQzxXVyCQmK5SZSPcOalwF8X+0A2wTqJYwMcP2ag
# PY+hTE5crL8wggVZMIIEQaADAgECAhA9eNf5dklgsmF99PAeyoYqMA0GCSqGSIb3
# DQEBCwUAMIHKMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4x
# HzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOjA4BgNVBAsTMShjKSAy
# MDA2IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkxRTBD
# BgNVBAMTPFZlcmlTaWduIENsYXNzIDMgUHVibGljIFByaW1hcnkgQ2VydGlmaWNh
# dGlvbiBBdXRob3JpdHkgLSBHNTAeFw0xMzEyMTAwMDAwMDBaFw0yMzEyMDkyMzU5
# NTlaMH8xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlv
# bjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3lt
# YW50ZWMgQ2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl4MeABavLLHSCMTXaJNRYB5x9uJHtNtYTSNi
# arS/WhtR96MNGHdou9g2qy8hUNqe8+dfJ04LwpfICXCTqdpcDU6kDZGgtOwUzpFy
# VC7Oo9tE6VIbP0E8ykrkqsDoOatTzCHQzM9/m+bCzFhqghXuPTbPHMWXBySO8Xu+
# MS09bty1mUKfS2GVXxxw7hd924vlYYl4x2gbrxF4GpiuxFVHU9mzMtahDkZAxZeS
# itFTp5lbhTVX0+qTYmEgCscwdyQRTWKDtrp7aIIx7mXK3/nVjbI13Iwrb2pyXGCE
# nPIMlF7AVlIASMzT+KV93i/XE+Q4qITVRrgThsIbnepaON2b2wIDAQABo4IBgzCC
# AX8wLwYIKwYBBQUHAQEEIzAhMB8GCCsGAQUFBzABhhNodHRwOi8vczIuc3ltY2Iu
# Y29tMBIGA1UdEwEB/wQIMAYBAf8CAQAwbAYDVR0gBGUwYzBhBgtghkgBhvhFAQcX
# AzBSMCYGCCsGAQUFBwIBFhpodHRwOi8vd3d3LnN5bWF1dGguY29tL2NwczAoBggr
# BgEFBQcCAjAcGhpodHRwOi8vd3d3LnN5bWF1dGguY29tL3JwYTAwBgNVHR8EKTAn
# MCWgI6Ahhh9odHRwOi8vczEuc3ltY2IuY29tL3BjYTMtZzUuY3JsMB0GA1UdJQQW
# MBQGCCsGAQUFBwMCBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMCAQYwKQYDVR0RBCIw
# IKQeMBwxGjAYBgNVBAMTEVN5bWFudGVjUEtJLTEtNTY3MB0GA1UdDgQWBBSWO1Pw
# eTOXr32D7y4rzMq3hh5yZjAfBgNVHSMEGDAWgBR/02Wnwt3su/AwCfNDOfoCrzMx
# MzANBgkqhkiG9w0BAQsFAAOCAQEAE4UaHmmpN/egvaSvfh1hU/6djF4MpnUeeBcj
# 3f3sGgNVOftxlcdlWqeOMNJEWmHbcG/aIQXCLnO6SfHRk/5dyc1eA+CJnj90Htf3
# OIup1s+7NS8zWKiSVtHITTuC5nmEFvwosLFH8x2iPu6H2aZ/pFalP62ELinefLyo
# qqM9BAHqupOiDlAiKRdMh+Q6EV/WpCWJmwVrL7TJAUwnewusGQUioGAVP9rJ+01M
# j/tyZ3f9J5THujUOiEn+jf0or0oSvQ2zlwXeRAwV+jYrA9zBUAHxoRFdFOXivSdL
# VL4rhF4PpsN0BQrvl8OJIrEfd/O9zUPU8UypP7WLhK9k8tAUITGCBI0wggSJAgEB
# MIGTMH8xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlv
# bjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3lt
# YW50ZWMgQ2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBAhAqnCGsqqY6PFin
# uTIr7pSNMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKEC
# gAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwG
# CisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIDBpum9GOXKdrKCMQWG0eleAP6Vx
# MUZjV85glYPUSyfZMA0GCSqGSIb3DQEBAQUABIIBAKtIH0sPGmMNO8C+eX3EcxaW
# R4pnXbIeZZN8GhhCGLmWa8fcDtBiVEDGp8IUprgtuNvdeFFiiwMtUAn7WYhD+FxF
# AVnqaj0b01p7f0JNm0V0r0oUgVbWbE7qd3r4s1Sqx7o7to0RCR2oDKAlVvVItGME
# 2w19Z44XJqDAe01f5vvMD3pfxG0ldrYtdVKKUsz15IEuf+2O2gSWt4ABNnaSeOv8
# bkNvwmnmLW3cFj6DCdm62/oZ0+PWx56gKD7nR3ZA09ASv9QKRCaPWfGDdOEVZy2N
# 3M6YQsCkdRzWZBP8Vkyy4zcLpCeUgr5BB5XHBRpfOs6gUTkBv8G9Qem6vTTWfqCh
# ggJDMIICPwYJKoZIhvcNAQkGMYICMDCCAiwCAQEwgakwgZUxCzAJBgNVBAYTAlVT
# MQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtlIENpdHkxHjAcBgNVBAoT
# FVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMYaHR0cDovL3d3dy51c2Vy
# dHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0LU9iamVjdAIPFojwOSVe
# Y45pFDkH5jMLMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
# MBwGCSqGSIb3DQEJBTEPFw0xODA5MTcyMjExMTRaMCMGCSqGSIb3DQEJBDEWBBSO
# HrSF70OY4j9tDVGwdQcAxrggYTANBgkqhkiG9w0BAQEFAASCAQBQIDOeN294+3dh
# 7lrTZCki87ne4bAm0DNmoBb5wUw1k/hKCYcvD+uI+/cUBc83fkPpHrSndw8mlFmA
# oRfOQBbIXi79/emzOiiVgNqGgm8r5IE6oO5AhNtitKLLs9fUS4N6o0HDs3tGWf79
# LxYOs1jdZ+WkxM9EAvm1vzqiZKbNo0myv9qbU5nPGWqeQxt0KLGNlykrHuNWFAxa
# YNRxuVdPJZd/EllrnL2s0s1FuJwXdG8SFTa2XCqHqy5i20XzOAS9WKLQw7yRuF6v
# qCpHcywUDAJ0591Loi57dEsWw84ha3Mnbf89gKnvZ7kOT2Of64am2Ybku2g1l1HL
# 9/D26D6Z
# SIG # End signature block
