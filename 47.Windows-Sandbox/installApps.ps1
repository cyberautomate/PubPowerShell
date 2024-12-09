
$progressPreference = 'silentlyContinue'
Install-PackageProvider -Name NuGet -Force -Verbose #| Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force #-Repository PSGallery #| Out-Null
Repair-WinGetPackageManager

#Install PowerShell
winget install 'Microsoft.PowerShell' --source winget --accept-package-agreements --accept-source-agreements

#Install VSCode
winget install 'Microsoft.VisualStudioCode' --source winget

#Install Git
winget install 'Git.Git' --source winget

#Install Github Desktop
winget install 'GitHub.GitHubDesktop' --source winget

#Install Windows Terminal
winget install 'Microsoft.WindowsTerminal' --source winget

Start-Sleep -Seconds 5

# Update the $env:Path to the current session
$userpath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$env:Path = $userpath + ";" + $machinePath

#Install PowerShell VSCode Extension
code --install-extension C:\Sandbox\ms-vscode.PowerShell-2024.5.0.vsix
