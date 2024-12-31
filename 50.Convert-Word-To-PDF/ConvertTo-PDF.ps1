function ConvertTo-PDF {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $sourceFolder,

        [Parameter(Mandatory = $true)]
        [string] $outputFile
    )

    # Create a new Word COM object
    try {
        $word = New-Object -ComObject Word.Application
        $word.Visible = $false # Set to $true if you want to see the process

        # Create a new document for the merged content
        $mergedDoc = $word.Documents.Add()

        # Get all .txt files in the folder
        $txtFiles = Get-ChildItem -Path $sourceFolder -Filter "*.txt"

        # If no txt files to process stop and close word
        if ($txtFiles.Count -eq 0) {
            Write-Verbose "No text files found in the folder: $sourceFolder"
            $mergedDoc.Close()
            $word.Quit()
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
            exit 1
        }

        foreach ($file in $txtFiles) {
            Write-Verbose "Processing file: $($file.FullName)"

            # Check if the file is empty
            if ((Get-Item $file.FullName).Length -eq 0) {
                Write-Warning "Skipping empty file: $($file.FullName)"
                continue
            }

            # Read the content of the .txt file
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop

            # Insert the content into the Word document
            $selection = $word.Selection
            #$selection.TypeText("Content from file: $($file.Name)`n")
            $selection.TypeText($content)
            # Add a page break between files
            $selection.InsertBreak(7)

            # Save the merged document as a PDF
            # 17 corresponds to the PDF format
            $mergedDoc.SaveAs2([ref]"$outputFile\$($file.BaseName)", [ref]17)
            Write-Verbose "Merged document saved as PDF to: $outputFile\$($file.BaseName)"
        }

        # Properly close the merged document
        # Explicitly specify no saving changes
        $mergedDoc.Close([ref]$false)

        # Quit the Word application
        $word.Quit()

        # Release COM objects
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null

        Write-Verbose "All text files have been merged successfully."
    }
    catch {
        "ERROR: $_"
    }
}
