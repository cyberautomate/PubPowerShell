# Run on the target node
[DSCLocalConfigurationManager()]
Configuration LCMConfig {
    Node SVR {
        Settings {
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RefreshMode       = 'Pull'
        }

        ConfigurationRepositoryWeb PullServer {
            ServerURL               = 'https://10.0.10.1:8080/PsDscPullserver.svc'
            AllowUnsecureConnection = $false
            RegistrationKey         = 'ab5f4916-a937-4f99-ae72-8b9db3dd8a60'
            ConfigurationNames      = @('SVR')
        }

        ResourceRepositoryWeb PullServerModules {
            ServerURL               = 'https://10.0.10.1:8080/PsDscPullserver.svc'
            AllowUnsecureConnection = $false
            RegistrationKey         = 'ab5f4916-a937-4f99-ae72-8b9db3dd8a60'
        }
    }
}

LCMConfig

Set-DscLocalConfigurationManager -ComputerName $env:COMPUTERNAME -Path '.\LCMConfig' -Verbose

Get-DSCLocalConfigurationManager

# This will show you the location of the CSV file that configuration is using
Get-DscConfiguration