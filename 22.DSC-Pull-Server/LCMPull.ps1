Configuration LCMPullConfig 
{ 
    LocalConfigurationManager { 
        ConfigurationID                = "EXCH";
        RefreshMode                    = "PULL";
        DownloadManagerName            = "WebDownloadManager";
        RebootNodeIfNeeded             = $true;
        RefreshFrequencyMins           = 30;
        ConfigurationModeFrequencyMins = 30; 
        ConfigurationMode              = "ApplyAndAutoCorrect";
        DownloadManagerCustomData      = @{
            ServerUrl               = "http://SCCM:8080/PSDSCPullServer/PSDSCPullServer.svc"; 
            AllowUnsecureConnection = “TRUE”
        }
    } 
} 

# Create the .mof meta file for the target node
LCMPullConfig

# We're turning on Pull Mode on the Target
Set-DSCLocalConfigurationManager -Computer localhost -Path ./LCMPullConfig -Verbose