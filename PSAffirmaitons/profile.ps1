$uri = "https://raw.githubusercontent.com/signalwarrant/Powershell/master/PSAffirmaitons/affirmations.json" 

# Testing Affirmations
Invoke-RestMethod -Uri $uri | Get-Random -Count 1