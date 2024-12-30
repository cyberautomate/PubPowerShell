
# Basic Syntax example
Get-Service | Where-Object Status -eq Running

# Advanced Syntax example
Get-Service | Where-Object { $PSItem.Status -eq 'Running' -and $PSItem.StartType -eq 'Automatic' }
# Same as above
Get-Service | Where-Object { $_.Status -eq 'Running' -and $_.StartType -eq 'Automatic' }