configuration DisableFirewall {
    param ()
    Import-DscResource –ModuleName 'NetworkingDsc'

    Node localhost
    {
        FirewallProfile DisableFirewall
        {
            Name    = 'Domain'
            Enabled = 'True'
        }
    }
}

# **NOTE:** The code above is the actual node configuration, everything below is used to create and stage the mof files

# Set the output path
$outputPath = 'C:\DSC\Node_Configs'

# Generate the MOF
DisableFirewall -outputPath $outputPath

# Generate the Checksum for the MOF
New-DscChecksum -Path $outputPath -OutPath $outputPath -Verbose

# Move Config to Configurations folder on Pull Server
# $session = New-PSSession SVR19
$source = "$outputPath\*"
$Dest = 'C:\Program Files\WindowsPowerShell\DscService\Configuration'

Copy-Item -Path $Source -Destination $Dest -Recurse -Force -Verbose

# Package and Publish the NetworkingDsc Module 
$ModuleList = @("NetworkingDsc")
Publish-DscModuleAndMof -Source C:\DSC -ModuleNameList $ModuleList -Force