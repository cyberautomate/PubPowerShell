# Your Configuration
Configuration ExchangeService {

    # Parameters
    # Accepts a string value computername or defaults to localhost
    Param([string[]]$ComputerName = "localhost")

    # Target Node
    Node $ComputerName {

        # Service Resource
        # Ensure a service is started
        Service MSExchangeTransport {
            Name  = 'MSExchangeTransport'
            State = 'Running'
        }
    }
}

# Generate the .MOF files
ExchangeService -ComputerName EXCH

# MOF files are created in whatever directory you're in in the PS Console
# 1 MOF file per target node

# Apply the configuration
Start-DscConfiguration -path ExchangeService -Wait -Verbose -Force

# View Deployed Configurations
Get-DscConfiguration -CimSession EXCH

#Testing Config (detect drift)
Test-DscConfiguration -CimSession EXCH