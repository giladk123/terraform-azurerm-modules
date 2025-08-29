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
  -Force:$true `
  -SafeModeAdministratorPassword (ConvertTo-SecureString $safe_mode_password -AsPlainText -Force)

Start-Sleep -Seconds 30

if ($create_user -and $user_username -and $user_password) {
  Import-Module ActiveDirectory
  $securePass = ConvertTo-SecureString $user_password -AsPlainText -Force
  $cn = "CN=$user_username,$user_ou_dn,DC=" + ($domain_fqdn -split '\.' -join ',DC=')
  New-ADUser -Name $user_username -SamAccountName $user_username -UserPrincipalName "$user_username@$domain_fqdn" `
    -GivenName $user_given_name -Surname $user_surname -Enabled $true -AccountPassword $securePass -Path $cn
}


