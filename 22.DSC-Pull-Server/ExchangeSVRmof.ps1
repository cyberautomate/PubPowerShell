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
ExchangeService -Computername EXCH

# Create a Checksum for the file listed above
New-DscChecksum ".\exchangeservice\exch.mof"