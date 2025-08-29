param(
  [string]$domain_fqdn,
  [string]$netbios_name,
  [string]$safe_mode_password,
  [string]$site_name,
  [bool]$create_user,
  [string]$user_username,
  [string]$user_password,
  [string]$user_ou_dn,
  [string]$user_given_name,
  [string]$user_surname
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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


