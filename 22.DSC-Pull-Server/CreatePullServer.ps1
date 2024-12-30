# Step 1 Install xPSDesiredStateConfiguration
Install-Module -Name xPSDesiredStateConfiguration

# Step 2
# Create the Pull Server. 

Configuration CreatePullServer {
    param (
        [string[]]$ComputerName = 'localhost'
    )

    Import-DSCResource -ModuleName xPSDesiredStateConfiguration
    Import-DSCResource –ModuleName PSDesiredStateConfiguration

    Node $ComputerName {
        WindowsFeature DSCServiceFeature {
            Ensure = "Present"
            Name   = "DSC-Service"
        }

        xDscWebService PSDSCPullServer {
            Ensure                   = "Present"
            UseSecurityBestPractices = 0
            EndpointName             = "PSDSCPullServer"
            Port                     = 8080
            PhysicalPath             = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbPrint    = "AllowUnencryptedTraffic"
            ModulePath               = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath        = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                    = "Started"
            DependsOn                = "[WindowsFeature]DSCServiceFeature"
        }

    }

}

#Creates the .mof file
CreatePullServer

# Apply the Pull Server configuration to the Pull Server
Start-DscConfiguration .\CreatePullServer -Wait