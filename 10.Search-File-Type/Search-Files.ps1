<#
DESCRIPTION
This script will search a file structure for a specific file type and export the results to a CSV file. 
This can be used to search a user accessible file share for file types that you may have policies 
against storing on a file share. If you don’t have access to Enterprise tools like FSRM this is an 
easy way to provide similar functionality.
#>

#This is what Directory you want to search
$searchDir = "c:\files"

#This is what file or file type(s) you're searching for
$searchFile = "*.mp3"

#This is the location of your logfile of the results
$outputDir = "C:\scripts\files_$(get-date -f yyyy-MM-dd).csv"

$files = Get-ChildItem -Path $searchDir -Recurse -Filter $searchFile -EA silentlyContinue | 
Select-Object -Property Fullname, @{Name = "MegaBytes"; Expression = { "{0:F2}" -f ($_.Length / 1MB) } }, CreationTime, LastAccessTime | 
Sort-Object -Property MegaBytes -Descending

#The results output to a CSV file
$files | Export-Csv $outputDir -Append

Write-Host -foregroundcolor yellow "Search complete, results can be viewed here: $outputDir"

#Start excel and open the logfile of the results
Start-Process Excel -ArgumentList $outputDir