Configuration SecurePullServerSQLDBgMSA {
    Param (
        [ValidateNotNullOrEmpty()]
        [ string ] $NodeName = 'localhost',

        [ValidateNotNullOrEmpty()]
        [ string ] $Thumbprint = " $( Throw "Provide a valid certificate thumbprint to continue" ) ",

        [ValidateNotNullOrEmpty()]
        [ string ] $Guid = " $( Throw "Provide a valid GUID to continue" ) "
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    Node $NodeName
    {

        LocalConfigurationManager {
            ActionAfterReboot    = 'ContinueConfiguration'
            ConfigurationMode    = 'ApplyandAutoCorrect'
            RebootNodeIfNeeded   = $false
            AllowModuleOverwrite = $true
            CertificateID        = $ThumbPrint
        }

        # https://docs.microsoft.com/en-us/powershell/dsc/pull-server/secureserver
        # The next series of settings disable SSL and enable TLS, for environments where that is required by policy.
        Registry TLS1_2ServerEnabled {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
            ValueName = 'Enabled'
            ValueData = 1
            ValueType = 'Dword'
        } # end resource

        Registry TLS1_2ServerDisabledByDefault {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
            ValueName = 'DisabledByDefault'
            ValueData = 0
            ValueType = 'Dword'
        } # end resource

        Registry TLS1_2ClientEnabled {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            ValueName = 'Enabled'
            ValueData = 1
            ValueType = 'Dword'
        } # end resource

        Registry TLS1_2ClientDisabledByDefault {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            ValueName = 'DisabledByDefault'
            ValueData = 0
            ValueType = 'Dword'
        } # end resource

        Registry SSL2ServerDisabled {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server'
            ValueName = 'Enabled'
            ValueData = 0
            ValueType = 'Dword'
        }

        Windowsfeature DSCServiceFeature {
            Ensure = 'Present'
            Name   = 'DSC-Service'
        }

        $pw = Read-Host "Enter Password" -AsSecureString
        $un = "DSC\SQLDSC$"
        [PSCredential] $cred = New-Object System.Management.Automation.PSCredential($un, $pw)

        xWebAppPool DSCPool {
            Ensure       = 'Present'
            Name         = 'DSCPool'
            identityType = 'SpecificUser'
            Credential   = $cred
            startMode    = 'OnDemand'
            State        = 'Started'
            DependsOn    = '[WindowsFeature]DSCServiceFeature'
        }

        xDscWebService SecureWebPullServer {
            Ensure                       = 'Present'
            EndpointName                 = 'PSDSCPullServer'
            Port                         = 443
            PhysicalPath                 = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint        = $Thumbprint
            ModulePath                   = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath            = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                        = 'Started'
            RegistrationKeyPath          = "$env:PROGRAMFILES\WindowsPowerShell\DscService"
            AcceptSelfSignedCertificates = $false
            UseSecurityBestPractices     = $true
            ApplicationPoolName          = 'DSCPool'
            SqlProvider                  = $true
            SqlConnectionString          = 'Provider=MSOLEDBSQL;Server=SVR19-2.dsc.local;Database=dsc;Trusted_Connection=yes;Initial Catalog=master;Encrypt=yes;'
            DependsOn                    = '[xWebAppPool]DSCPool'
        }

        File RegistrationKeyFile {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $Guid
            DependsOn       = '[xDscWebService]SecureWebPullServer'
        }

        # Stop the default website
        xWebsite StopDefaultSite {
            Ensure       = 'Present'
            Name         = 'Default Web Site'
            State        = 'Stopped'
            PhysicalPath = 'C:\inetpub\wwwroot'
            DependsOn    = '[xDscWebService]SecureWebPullServer'
        } # end resource

    }
}

$cd = @{
    AllNodes = @(
        @{
            NodeName                    = 'localhost'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
        }
    )
}


# Get the certificate thumbprint. This code assumes you gave your certificate a friendly name of DSCPullServerCert, change if needed.
$Thumbprint = Get-ChildItem Cert:\LocalMachine\My |
Where-Object { $_.FriendlyName -eq 'DSCPullServerCert' } |
Select-Object -ExpandProperty Thumbprint

# Create new GUID for Reg Key
$Guid = (New-guid).guid

# Execute the DSC configuration to create the mof and meta.mof.
SecurePullServerSQLDBgMSA -ConfigurationData $cd -Thumbprint $Thumbprint -Guid $Guid -OutputPath C:\DSC\Pull -Verbose

# Set the LCM on the Pull server via the meta.mof.
Set-DscLocalConfigurationManager -Path C:\DSC\Pull -ComputerName 'localhost' -Verbose -Force

# Build the Pull Server via the mof.
Start-DscConfiguration -Path C:\DSC\Pull -ComputerName 'localhost' -Wait -Force -Verbose