##############################################################
# Merges all the PDF files for each Module in to 1 PDF file per
# module called Help_<moduleName>.pdf in $filepath
##############################################################

$folders = Get-ChildItem -Path $filePath -Directory
$ErrorActionPreference = 'silentlycontinue'
foreach ($folder in $folders) {
    $pdfs = Get-ChildItem -Path $folder.fullname -recurse -Filter '*.pdf'

    [void] [System.Reflection.Assembly]::LoadFrom(
        [System.IO.Path]::Combine($filePath, $dllPath)
    )
    $output = [System.IO.Path]::Combine($filePath, "Help_$($folder[0].Name).pdf")
    $fileStream = New-Object -TypeName System.IO.FileStream -ArgumentList ($output, [System.IO.FileMode]::OpenOrCreate)
    $document = New-Object -TypeName iTextSharp.text.Document
    $pdfCopy = New-Object -TypeName iTextSharp.text.pdf.PdfCopy -ArgumentList ($document, $fileStream)
    $document.Open()
    
    foreach ($pdf in $pdfs) {
        $reader = New-Object -TypeName iTextSharp.text.pdf.PdfReader -ArgumentList ($pdf.FullName)
        $pdfCopy.AddDocument($reader)
        $reader.Dispose()
    }
    $pdfCopy.Dispose()
    $document.Dispose()
    $fileStream.Dispose()
}