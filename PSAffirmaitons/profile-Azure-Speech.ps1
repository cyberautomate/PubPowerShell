$apikey = Get-Content -Path "C:\Users\Dave\Documents\key.txt"
$uri = "https://raw.githubusercontent.com/signalwarrant/Powershell/master/PSAffirmaitons/affirmations.json"
$mp3File = 'C:\Users\Dave\Documents\affirm.mp3'
$voice = 'en-US-GuyNeural'
$region = 'eastus'

# Grab the Azure Cognitive services bearer token
Get-SpeechToken -Key $apikey -Region $region

# Testing Affirmations
$restContent = Invoke-RestMethod -Uri $uri | Get-Random -Count 1

# Show text on screen
$restContent

# Convert the text to speech
Convert-TextToSpeech -Voice $voice -Text $restContent -Path $mp3File

# Play the mp3
Add-Type -AssemblyName presentationCore
$mediaPlayer = New-Object system.windows.media.mediaplayer
$mediaPlayer.open($mp3File)
$mediaPlayer.Play()

# Clean up the mp3
Start-Sleep -Seconds 1
Remove-Item -Path $mp3File -Force