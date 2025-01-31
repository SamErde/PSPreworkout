@{
    #________________________________________
    #IncludeDefaultRules
    IncludeDefaultRules = $true
    #________________________________________

    #Severity
    #Specify Severity when you want to limit generated diagnostic records to a specific subset: [ Error | Warning | Information ]
    Severity            = @('Error', 'Warning')
    #________________________________________

    #CustomRulePath
    #Specify CustomRulePath when you have a large set of custom rules you'd like to reference
    #CustomRulePath = "Module\InjectionHunter\1.0.0\InjectionHunter.psd1"
    #________________________________________

    #IncludeRules
    #Specify IncludeRules when you only want to run specific subset of rules instead of the default rule set.
    #IncludeRules = @('PSShouldProcess',
    #                 'PSUseApprovedVerbs')
    #________________________________________

    #ExcludeRules
    #Specify ExcludeRules when you want to exclude a certain rule from the the default set of rules.
    ExcludeRules        = @(
        #'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseSingularNouns',
        'PSShouldProcess'
    )
    #________________________________________

    #Rules
    #Here you can specify customizations for particular rules. Several examples are included below:
    Rules               = @{
        PSUseCompatibleCmdlets = @{
            compatibility = @('core-6.1.0-windows', 'desktop-5.1-windows')
        }
        PSUseCompatibleSyntax  = @{
            Enable         = $true
            TargetVersions = @(
                '5.1',
                '7.2'
            )
        }
    }
}
