$uri = "https://raw.githubusercontent.com/cyberautomate/PubPowerShell/main/PSAffirmaitons/affirmations.json" 

# Testing Affirmations
Invoke-RestMethod -Uri $uri | Get-Random -Count 1