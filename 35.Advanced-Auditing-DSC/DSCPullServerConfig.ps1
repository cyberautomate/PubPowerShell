# 4. Configure the Pull Server
Configuration DscPullServer {
    param (
        [string[]]$NodeName = 'localhost',

        [ValidateNotNullOrEmpty()]
        [string] $certificateThumbPrint,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $RegistrationKey
    )

    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration

    Node $NodeName
    {
        WindowsFeature DSCServiceFeature {
            Ensure = 'Present'
            Name   = 'DSC-Service'
        }

        xDscWebService PSDSCPullServer {
            Ensure                   = 'present'
            EndpointName             = 'PSDSCPullServer'
            Port                     = 8080
            PhysicalPath             = "$env:SystemDrive\inetpub\PSDSCPullServer\"
            CertificateThumbPrint    = $certificateThumbPrint
            # This is where the packaged modules needed by client go
            ModulePath               = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            # Client .MOF and Checksum files go here
            ConfigurationPath        = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                    = 'Started'
            DependsOn                = '[WindowsFeature]DSCServiceFeature'
            UseSecurityBestPractices = $true
        }
        
        File RegistrationKeyFile {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $RegistrationKey
        }
    }
}

$guid = [guid]::newGuid()

$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.FriendlyName -eq 'PSDSCPullServerCert' }

DscPullServer -certificateThumbPrint $cert.Thumbprint -RegistrationKey $guid -OutputPath $env:HOMEDRIVE\dsc

Start-DscConfiguration -Path $env:HOMEDRIVE\dsc -Wait -Verbose

# Server URL, copy and paster the Server URL into a web browser
# You should get some XML output if everything is working ok.
# https://YourServerNameHere:8080/PSDSCPullServer.svc/