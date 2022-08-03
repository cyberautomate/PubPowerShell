Function Format-MerchReports {
  <#
  .SYNOPSIS
  Reformats and combines Merch by Amazon sales reports
  
  .DESCRIPTION
  1. Deletes the first 13 rows of each CSV in $csvPath
  2. Combines the data from all the files
  3. Adds column headers defined in $finalHeader
  4. Outputs the file to $csvPath as formatted-Merchreports.csv 
  
  .PARAMETER csvPath
  Specifies the file system path the folder containing 
  the Merch by Amazon reports.
  
  .INPUTS
  System.String. File path to the CSV Merch by Amazon reports.
  
  .OUTPUTS
  CSV file to $csvPath with filename formatted-Merchreports.csv
  
  .EXAMPLE
  Format-MerchReports -csvPath c:\mypath\
  
  .LINK
  
  #>

  [CmdletBinding()]
      Param([string]$csvPath = 'c:\Reports\')
          try
              {
                  $processedCSVs = $NULL
                  $csvs = Get-ChildItem -Path $csvPath -Filter *.csv
    
                  $header = 'Blank','Date','ASIN','Name','Category 1',
                      'Category 2','Category 3','Product Type','Transaction Type',
                      'Sales Price','Sales Price Currency Code','Units',
                      'Gross Earnings or Refunds'
    
                  $finalHeader = 'Date','ASIN','Name','Category 1',
                      'Category 2','Category 3','Product Type','Transaction Type',
                      'Sales Price','Sales Price Currency Code','Units',
                      'Gross Earnings or Refunds'
    
                  foreach ($csv in $csvs) {
                      $processedCSVs += Import-Csv -Path $csv -Delimiter ',' -Header $header | 
                          Select-Object -Skip 13 -Property $finalHeader
                  } 
  
                  $processedCSVs | Export-Csv -Path "$csvPath\formatted-Merchreports.csv" -NoTypeInformation    
              }
          catch
              {
                  "Error was $_"
                  $line = $_.InvocationInfo.ScriptLineNumber
                  "Error was in Line $line"
              }
}
