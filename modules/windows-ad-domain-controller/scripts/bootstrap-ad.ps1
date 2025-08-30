$domain_fqdn      = "${domain_fqdn}"
$netbios_name     = "${netbios_name}"
$safe_mode_password = "${safe_mode_password}"
$site_name        = "${site_name}"
$create_user      = "${create_user}" -eq "true"
$user_username    = "${user_username}"
$user_password    = "${user_password}"
$user_ou_dn       = "${user_ou_dn}"
$user_given_name  = "${user_given_name}"
$user_surname     = "${user_surname}"

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($safe_mode_password)) {
  Write-Error "safe_mode_password is empty"
}

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment

Install-ADDSForest `
  -DomainName $domain_fqdn `
  -DomainNetbiosName $netbios_name `
  -CreateDnsDelegation:$false `
  -DatabasePath 'C:\Windows\NTDS' `
  -SysvolPath 'C:\Windows\SYSVOL' `
  -LogPath 'C:\Windows\NTDS' `
  -InstallDns:$true `
  -NoRebootOnCompletion:$true `
  -Force:$true `
  -SafeModeAdministratorPassword (ConvertTo-SecureString $safe_mode_password -AsPlainText -Force)

Start-Sleep -Seconds 10

if ($create_user -and $user_username -and $user_password) {
  $postScript = @"
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
function Wait-ADReady {
  param([int]$timeoutSeconds = 900)
  $elapsed = 0
  while ($elapsed -lt $timeoutSeconds) {
    try { Get-ADDomain | Out-Null; return }
    catch { Start-Sleep -Seconds 10; $elapsed += 10 }
  }
  throw 'Active Directory not ready after timeout.'
}
Wait-ADReady
$securePass = ConvertTo-SecureString '$user_password' -AsPlainText -Force
$containerPath = '$user_ou_dn' + ',DC=' + ('${domain_fqdn}' -split '\\.' -join ',DC=')
New-ADUser -Name '$user_username' -SamAccountName '$user_username' -UserPrincipalName '$user_username@${domain_fqdn}' `
  -GivenName '$user_given_name' -Surname '$user_surname' -Enabled $true -AccountPassword $securePass -Path $containerPath
"@
  $postPath = 'C:\\AzureData\\PostAD.ps1'
  $postScript | Out-File -FilePath $postPath -Encoding ASCII -Force
  New-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\RunOnce' -Name 'PostADSetup' -Value "PowerShell.exe -ExecutionPolicy Bypass -File $postPath" -PropertyType String -Force | Out-Null
}

# Queue a reboot in the background and return success so the extension doesn't fail on restart
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -WindowStyle Hidden -Command Start-Sleep -Seconds 5; Restart-Computer -Force" -WindowStyle Hidden | Out-Null
exit 0


