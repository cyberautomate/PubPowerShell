# Enable Remoting to an Azure VM
Enable-PSRemoting

# Make sure to set the Public IP address to static or make sure you track the change of the public IP

# Create Network Security Group Rule to allow winrm

# Create a Selfsigned cert on the Azure VM
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName PC1.mydomain.local
Export-Certificate -Cert $Cert -FilePath '<filepath>\exch.cer'

# Create a firewall rule inside the Azure VM
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force
New-NetFirewallRule -DisplayName 'WinRM HTTPS-In' -Name 'WinRM HTTPS-In' -Profile Any -LocalPort 5986 -Protocol TCP

# Install the Cert on the client

# Run this on the remote client
$cred = Get-Credential
Enter-PSSession -ConnectionUri https://xx.xx.xx.xx:5986 -Credential $cred -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck) -Authentication Negotiate