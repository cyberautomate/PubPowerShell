# Source: https://tommymaynard.com/text-to-speech-in-powershell/
Function Convert-TextToSpeech {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$Text,
        [Parameter()]
        [ValidateSet(1,2,3,4,5,6,7,8,9,10)]
        [int]$SpeechSpeed = 3
    ) # End Param.
 
    Begin {
        Function ConvertTextToSpeech {
            [CmdletBinding()]Param (
                [Parameter()]$Text,
                [Parameter()]$SpeechSpeed
            ) # End Param.
            Add-Type -AssemblyName System.Speech
            $VoiceEngine = New-Object System.Speech.Synthesis.SpeechSynthesizer
            $VoiceEngine.Rate = $SpeechSpeed - 2
            $VoiceEngine.Speak($Text)
        } # End Function: ConvertTextToSpeech.
    } # End Begin.
 
    Process {
        $Session = New-PSSession -Name WinPSCompatSession -UseWindowsPowerShell
        Invoke-Command -Session $Session -ScriptBlock ${Function:ConvertTextToSpeech} -ArgumentList $Text,$SpeechSpeed
    } # End Process.
 
    End {
        Remove-PSSession -Name WinPSCompatSession
    } # End End.
}

$uri = "https://raw.githubusercontent.com/signalwarrant/Powershell/master/PSAffirmaitons/affirmations.json" 

# Testing Affirmations
$restContent = Invoke-RestMethod -Uri $uri 
$text = $restContent | Get-Random -Count 1
$text

Convert-TextToSpeech -text $text