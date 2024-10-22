
# From <https://github.com/jschick04/PSProfile/blob/main/src/Microsoft.PowerShell_profile.ps1>
#region .Net Discoverability Functions

function Get-Type {
    <#
            .SYNOPSIS
            Get exported types in the current session

            .DESCRIPTION
            Get exported types in the current session

            .PARAMETER Module
            Filter on Module.  Accepts wildcard

            .PARAMETER Assembly
            Filter on Assembly.  Accepts wildcard

            .PARAMETER FullName
            Filter on FullName.  Accepts wildcard

            .PARAMETER Namespace
            Filter on Namespace.  Accepts wildcard

            .PARAMETER BaseType
            Filter on BaseType.  Accepts wildcard

            .PARAMETER IsEnum
            Filter on IsEnum.

            .EXAMPLE
            #List the full name of all Enums in the current session
            Get-Type -IsEnum $true | Select -ExpandProperty FullName | Sort -Unique

            .EXAMPLE
            #Connect to a web service and list all the exported types

            #Connect to the web service, give it a namespace we can search on
            $weather = New-WebServiceProxy -uri "http://www.webservicex.net/globalweather.asmx?wsdl" -Namespace GlobalWeather

            #Search for the namespace
            Get-Type -NameSpace GlobalWeather

            IsPublic IsSerial Name                                     BaseType
            -------- -------- ----                                     --------
            True     False    MyClass1ex_net_globalweather_asmx_wsdl   System.Object
            True     False    GlobalWeather                            System.Web.Services.Protocols.SoapHttpClientProtocol
            True     True     GetWeatherCompletedEventHandler          System.MulticastDelegate
            True     False    GetWeatherCompletedEventArgs             System.ComponentModel.AsyncCompletedEventArgs
            True     True     GetCitiesByCountryCompletedEventHandler  System.MulticastDelegate
            True     False    GetCitiesByCountryCompletedEventArgs     System.ComponentModel.AsyncCompletedEventArgs

            .EXAMPLE
            #List the arguments for a .NET type
            (Get-Type -FullName *PSCredential).GetConstructors()[0].GetPerameters()

            .FUNCTIONALITY
            Computers
    #>
    [CmdletBinding(HelpUri = 'https://raw.githubusercontent.com/SamErde/PSPreworkout/main/src/Help/')]
    param(
        [string]$Module = '*',
        [string]$Assembly = '*',
        [string]$FullName = '*',
        [string]$Namespace = '*',
        [string]$BaseType = '*',
        [switch]$IsEnum
    )

    #Build up the Where statement
    $WhereArray = @('$_.IsPublic')
    if ($Module -ne '*') { $WhereArray += '$_.Module -like $Module' }
    if ($Assembly -ne '*') { $WhereArray += '$_.Assembly -like $Assembly' }
    if ($FullName -ne '*') { $WhereArray += '$_.FullName -like $FullName' }
    if ($Namespace -ne '*') { $WhereArray += '$_.Namespace -like $Namespace' }
    if ($BaseType -ne '*') { $WhereArray += '$_.BaseType -like $BaseType' }
    #This clause is only evoked if IsEnum is passed in
    if ($PSBoundParameters.ContainsKey('IsEnum')) { $WhereArray += '$_.IsENum -like $IsENum' }

    #Give verbose output, convert where string to scriptblock
    $WhereString = $WhereArray -Join ' -and '
    $WhereBlock = [scriptblock]::Create( $WhereString )
    Write-Verbose "Where ScriptBlock: { $WhereString }"

    #Invoke the search!
    [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
        Write-Verbose "Getting types from $($_.FullName)"
        Try {
            $_.GetExportedTypes()
        } Catch {
            Write-Verbose "$($_.FullName) error getting Exported Types: $_"
            $null
        }

    } | Where-Object -FilterScript $WhereBlock
}

function Get-Constructor {
    <#
        .SYNOPSIS
            Displays the available constructor parameters for a given type

        .DESCRIPTION
            Displays the available constructor parameters for a given type

        .PARAMETER Type
            The type name to list out available contructors and parameters

        .PARAMETER AsObject
            Output the results as an object instead of a formatted table

        .EXAMPLE
            Get-Constructor -Type "adsi"

            DirectoryEntry Constructors
            ---------------------------

            System.String path
            System.String path, System.String username, System.String password
            System.String path, System.String username, System.String password, System.DirectoryServices.AuthenticationTypes aut...
            System.Object adsObject

            Description
            -----------
            Displays the output of the adsi contructors as a formatted table

        .EXAMPLE
            "adsisearcher" | Get-Constructor

            DirectorySearcher Constructors
            ------------------------------

            System.DirectoryServices.DirectoryEntry searchRoot
            System.DirectoryServices.DirectoryEntry searchRoot, System.String filter
            System.DirectoryServices.DirectoryEntry searchRoot, System.String filter, System.String[] propertiesToLoad
            System.String filter
            System.String filter, System.String[] propertiesToLoad
            System.String filter, System.String[] propertiesToLoad, System.DirectoryServices.SearchScope scope
            System.DirectoryServices.DirectoryEntry searchRoot, System.String filter, System.String[] propertiesToLoad, System.D...

            Description
            -----------
            Takes input from pipeline and displays the output of the adsi contructors as a formatted table

        .EXAMPLE
            "adsisearcher" | Get-Constructor -AsObject

            Type                                                        Parameters
            ----                                                        ----------
            System.DirectoryServices.DirectorySearcher                  {}
            System.DirectoryServices.DirectorySearcher                  {searchRoot}
            System.DirectoryServices.DirectorySearcher                  {searchRoot, filter}
            System.DirectoryServices.DirectorySearcher                  {searchRoot, filter, propertiesToLoad}
            System.DirectoryServices.DirectorySearcher                  {filter}
            System.DirectoryServices.DirectorySearcher                  {filter, propertiesToLoad}
            System.DirectoryServices.DirectorySearcher                  {filter, propertiesToLoad, scope}
            System.DirectoryServices.DirectorySearcher                  {searchRoot, filter, propertiesToLoad, scope}

            Description
            -----------
            Takes input from pipeline and displays the output of the adsi contructors as an object

        .INPUTS
            System.Type

        .OUTPUTS
            System.Constructor
            System.String

        .NOTES
            Author: Boe Prox
            Date Created: 28 Jan 2013
            Version 1.0
    #>
    [CmdletBinding(HelpUri = 'https://raw.githubusercontent.com/SamErde/PSPreworkout/main/src/Help/')]
    Param (
        [parameter(ValueFromPipeline = $True)]
        [Type]$Type,
        [parameter()]
        [switch]$AsObject
    )
    Process {
        If ($PSBoundParameters['AsObject']) {
            $type.GetConstructors() | ForEach-Object {
                $object = New-Object PSobject -Property @{
                    Type       = $_.DeclaringType
                    Parameters = $_.GetParameters()
                }
                $object.pstypenames.insert(0, 'System.Constructor')
                Write-Output $Object
            }


        } Else {
            $Type.GetConstructors() | Select-Object @{
                Label      = "$($type.Name) Constructors"
                Expression = { ($_.GetParameters() | ForEach-Object { $_.ToString() }) -Join ', ' }
            }
        }
    }
}

#endregion
