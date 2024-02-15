# PSPrintful

A PowerShell wrapper for [Printful.com](https://www.printful.com) API

### Required Dependencies

1. You will need a [Printful](https://www.printful.com) API key from https://developers.printful.com/

   - My API key is set for the Account Access Level (I can access all stores)
   - I set the scopes to view / manage everything, you can minimize the scope for only actions you want users of the key to execute.

2. This module also requires the use of the PowerShell Secrets management module to maintain the Printful API key. The Secrets Management Module will be installed as a dependency. If you have never used the Secrets Management Module start [here](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/get-started/using-secretstore?view=ps-modules), it's pretty straight forward.

3. You will need to create a secret for your Prinful API key named "Key".
   - Create the Secrets Vault.
     `Register-SecretVault -ModuleName Microsoft.PowerShell.SecretStore -Name printful -DefaultVault`
   - Create the Secret
     `Set-Secret -Name Key -Secret XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`
