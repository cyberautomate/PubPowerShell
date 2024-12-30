# Code Source: http://duffney.io/Configure-HTTPS-DSC-PullServerPSv5
$inf = @"
[Version] 
Signature="`$Windows NT`$"
[NewRequest]
Subject = "CN=DC, OU=IT, O=Signalwarrant, L=Augusta, S=SE, C=US"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
FriendlyName = PSDSCPullServerCert
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0
"@

$infFile = "$env:HOMEDRIVE\temp\certrq.inf"
$requestFile = "$env:HOMEDRIVE\temp\request.req"
$CertFileOut = "$env:HOMEDRIVE\temp\certfile.cer"

mkdir $env:HOMEDRIVE\temp
$inf | Set-Content -Path $infFile

& certreq.exe -new "$infFile" "$requestFile"

# Make sure the DC matches everywhere
& certreq.exe -submit -config DC.signalwarrant.local\Signalwarrant-DC-CA -attrib 'CertificateTemplate:WebServer' "$requestFile" "$CertFileOut"

& certreq.exe -accept "$CertFileOut"

## Copy the certfile to any clients and install the Cert to Local Machine