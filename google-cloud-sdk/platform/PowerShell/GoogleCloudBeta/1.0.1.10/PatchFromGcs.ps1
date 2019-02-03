# Copyright 2015-2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License Version 2.0.
#
# Updates Cloud Tools for PowerShell module to the latest found in 
# Google Cloud Storage bucket g-cloudsharp-unsignedbinaries.

# Let a user manually select a Cloud SDK install path
param($installPath)
$installPath = $installPath -or $args[0]

# Find the Google Cloud SDK install path from the registry.
if (-not $installPath) {
    $hklmPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Google Cloud SDK"
    $hkcuPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Google Cloud SDK"
    if (Test-Path $hklmPath) {
        $installPath = Get-ItemPropertyValue $hklmPath InstallLocation
    } elseif (Test-Path $hkcuPath) {
        $installPath = Get-ItemPropertyValue $hkcuPath InstallLocation
    } else {
        Write-Error "Can not find Cloud SDK from the registry."
        return
    }
}
$installPath = $installPath -replace '"' # Registry values had quotes. This removes them.
Push-Location (Join-Path $installPath "google-cloud-sdk\platform\PowerShell")
$googlePowerShellPath = Resolve-Path "GoogleCloud"

if (-not (Test-Path $googlePowerShellPath)) {
    Write-Error "Can not find Cloud Tools for PowerShell. '$googlePowerShellPath' does not exist."
    return
}

$pathToOldCmdlets = "GoogleCloudPowerShell-unpatched-backup"
if (Test-Path $pathToOldCmdlets) {
    Remove-Item $pathToOldCmdlets -Recurse
}
Move-Item $googlePowerShellPath $pathToOldCmdlets
Import-Module "$pathToOldCmdlets/GoogleCloud.psd1"
$bucket = Get-GcsBucket g-cloudsharp-unsignedbinaries

# Find objects in the powershell directory, and select one most recently created.
$zipObject = Find-GcsObject $bucket -Prefix powershell | Sort TimeCreated -Descending | Select -First 1
$zipFileName = Split-Path $zipObject.Name -Leaf
Write-Verbose "Saving new file to $zipFileName"
Read-GcsObject $bucket $zipObject.Name -OutFile $zipFileName -Force

$zipPath = Resolve-Path $zipFileName
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, "$googlePowerShellPath\..")
Pop-Location

# SIG # Begin signature block
# MIIUEgYJKoZIhvcNAQcCoIIUAzCCE/8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB+4Oa3AC4hgLb+
# A3ddY1D8ndwDor1RPGlNiaelqNUxC6CCDtswggSZMIIDgaADAgECAg8WiPA5JV5j
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
# CisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEu6Y3C/Qo8R5epwzKXPgt1VG2R2
# C76q2Fbc7uSQYL8CMA0GCSqGSIb3DQEBAQUABIIBAHnIQC78Fm9LXttOCdieIKj2
# f6+gwjrKrHJfR6MDKME90iRC4/aCHmtyOz8GKRfv7Z0Bb6cTuwXA4DiKtYnqfbP3
# CKNcZDLCXHYT+J8p/1EdDLQe49rycp0AtDLW///Tf+LJH9cIqSYCRDyn/7f/jzY5
# l00FCpYv7KYcGTCrAOtbGzuyP2K16vakx3P4VYHW0lsGnrrbGNIyN4dJ6QIZiy5V
# ynEhX288GuWACVKkJYLYLrMKd68Gk8u6fRbZdBdkOHWFQWWfczNFRofzGsy2R7hW
# kXVN+w6acl6Fg2Hg4ks4rWwVdgvZvMQsQEbn6+j5w4FrTpx3BxRrk77d9Rh99pOh
# ggJDMIICPwYJKoZIhvcNAQkGMYICMDCCAiwCAQEwgakwgZUxCzAJBgNVBAYTAlVT
# MQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtlIENpdHkxHjAcBgNVBAoT
# FVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMYaHR0cDovL3d3dy51c2Vy
# dHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0LU9iamVjdAIPFojwOSVe
# Y45pFDkH5jMLMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
# MBwGCSqGSIb3DQEJBTEPFw0xODA5MTcyMjExMjJaMCMGCSqGSIb3DQEJBDEWBBRz
# 9sHvLXF3YpDRgluoz/z7vUXjmjANBgkqhkiG9w0BAQEFAASCAQAfVqh1xVZnrhxw
# i+MN2Q5L7mHKrM6UAbweOTMnv3g9L4YlFg8WLWdO0sJpizhlm5l472//4e2Bt6e+
# QInG5KMEEQfZ8hkyjzj/VW2a+wS/mqPc5DQX9bpM/0lNDkl8CJUWiG7fZGu7/zc3
# mYdCzOwAVwuGXmzvc2Z7LPsCZa1xzfJ9kAe9X/Rw9L/tqa9AmtFG0nkC4cdj2vY4
# RtQOxpaJqiPn/MHM+rQfmaEKMsjYDXMT9vVEDGBl++D9Ev/F7GlkaMl/ogzIGztk
# LIV6phpTWBddyzyqT5JyAPj7AQRkS3z/muLIkImfZzVh87rTdQMWcHAp8GWtuwHX
# 7yvgA7xS
# SIG # End signature block
