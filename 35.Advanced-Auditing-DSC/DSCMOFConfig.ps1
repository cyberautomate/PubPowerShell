# 5. Create the client MOFs
# https://github.com/PowerShell/AuditPolicyDsc

Configuration AuditPolicyCsv {
    param (
        [String] $NodeName = 'SVR'
    )    
    Import-DscResource -ModuleName AuditPolicyDsc

    Node $NodeName {
        AuditPolicyCsv auditPolicy {
            IsSingleInstance = 'Yes'
            CsvPath          = "C:\audit.csv"
        }
    }
}

#
AuditPolicyCsv

#
New-DscChecksum -path '.\AuditPolicyCSV\SVR.mof'