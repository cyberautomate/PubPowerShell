Function ConvertTo-PDF {
    <#
DESCRIPTION
Convert 1 or many files to PDFs
PARAMETER filePath
-filePath: The path to the folder that contains all your text files
PARAMETER dllPath
-dllPath: The Path to the iTextSharp.DLL file
EXAMPLE
ConverTTo-PDF -filePath 'C:\help' -filetype 'txt' -dllPath 'C:\itextsharp.dll'
REQUIREMENTS
- iTextSharp 5.5.10 .NET Library
- You may have to Set execution policy to less restrictive policy
LINK
iTextSharp .NET library: https://github.com/itext/itextsharp/releases/tag/5.5.11
#>

    Param (
        [Parameter(
            Mandatory = $True,
            HelpMessage = 'Add the path you want to save help to EX. c:\help'
        )][string]$filePath,
    
        [Parameter(
            Mandatory = $True, HelpMessage = 'What file type to convert'
        )][string]$filetype,

        [Parameter(
            Mandatory = $True, HelpMessage = 'path to the itextsharp.dll file EX. c:\itextsharp.dll'
        )][string]$dllPath
    )

    Begin {
        Try {
            Add-Type -Path $dllPath -ErrorAction Stop
        }
        Catch {
            Throw "Could not load iTextSharp DLL from $($dllPath).`nPlease check that the dll is located at that path."
        }
    }

    Process {
        $txtFiles = Get-ChildItem -Path $filePath -Recurse -Filter "*.$filetype"

        ForEach ($txtFile in $txtFiles) {
            $path = "$($txtFile.DirectoryName)\$($txtFile.BaseName).pdf"
            $doc = New-Object -TypeName iTextSharp.text.Document
            $fileStream = New-Object -TypeName IO.FileStream -ArgumentList ($path, [System.IO.FileMode]::Create)
            [iTextSharp.text.pdf.PdfWriter]::GetInstance($doc, $filestream)
            [iTextSharp.text.FontFactory]::RegisterDirectories()

            $paragraph = New-Object -TypeName iTextSharp.text.Paragraph
            $paragraph.add(( Get-Content -Path $($txtFile.FullName) |
                    ForEach-Object {
                        "$_`n"
                    })) | Out-Null
            $doc.open()
            $doc.add($paragraph) | Out-Null
            $doc.close()
        }
    }
}