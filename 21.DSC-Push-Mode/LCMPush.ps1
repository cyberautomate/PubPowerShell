# Get all the DSC CMDLets
Get-Command -Noun dsc*

# Get Available Resources
# Refer to powershellgallery.com for additional resources
Get-DscResource

# What can we configure for each resource
Get-DscResource File | Select -ExpandProperty Properties

# Step 1
# Generate a LCM Config for target node
# Target Node LCM Configuration
Configuration LCMConfig {
    # Parameters
    Param([string[]]$ComputerName = "localhost")
    # Target Node
    Node $ComputerName {
        # LCM Resource
        LocalConfigurationManager {
            ConfigurationMode              = "ApplyAndAutoCorrect"
            ConfigurationModeFrequencyMins = 30
        }
    }
}

# Generate MOF File
LCMConfig -ComputerName EXCH

# Check LCM Settings on target node
Get-DscLocalConfigurationManager -CimSession EXCH 

# Apply the LCMConfig for each Target Node
Set-DscLocalConfigurationManager -Path LCMConfig

# Check the LCM Config again
# Notice the CoConfigurationModeFrequencyMins value changed to 30
Get-DscLocalConfigurationManager -CimSession EXCH