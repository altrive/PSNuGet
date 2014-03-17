function Initialize-NuGetPackageManager
{
    [CmdletBinding()]
    param (
        [hashtable] $Repository = [ordered] @{},
        [switch] $IgnoreFailingRepositories = $false,
        [switch] $UseOfficialRepository = $true,
        [switch] $UseChocolateyRepository = $false,
        [string] $PackageInstallPath
    )
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    #Add repository path from environment variable if exists.
　　if($env:PSNUGET_REPOSITORY_PATH -ne $null)
    {
        $paths = $env:PSNUGET_REPOSITORY_PATH -split ";"
        foreach($path in $paths)
        {
            if(!$Repository.Contains($path))
            {
                $Repository.Add("OfficialRepository", $path)
            }
        }
    }
    
    #Setup official NuGet repository paths(Default:$true)
    $officialRepository = "https://packages.nuget.org/api/v2"
    if ($UseOfficialRepository -and !$Repository.ContainsValue($officialRepository))
    {
        $Repository.Add("OfficialRepository", $officialRepository)
    }

    #Setup chocolatey repository paths(Default:$false)
    $chocolateyRepository = "http://chocolatey.org/api/v2/"
    if ($UseChocolateyRepository -and !$Repository.ContainsValue($chocolateyRepository))
    {
        $Repository.Add("ChocolateyRepository", $chocolateyRepository)
    }
      
    #Convert repositories to string array
    [string[]] $packageSources = $Repository.Values | select

    #Create NuGet repository
    $nugetRepository = New-Object NuGet.AggregateRepository([NuGet.PackageRepositoryFactory]::Default, $packageSources, $IgnoreFailingRepositories)

    #Set NuGet package directory(if not specified, use %MyDocuments%\WindowsPowerShell\packages)
    if ([String]::IsNullOrEmpty($PackageInstallPath))
    {
        $PackageInstallPath = Join-Path (Split-Path $profile -Parent) "packages"
    }

    #Ensure package directory exists
    [IO.Directory]::CreateDirectory($PackageInstallPath) > $null

    #Create NuGet PackageManager, and store instance to script variable
    $script:PackageManager = New-Object NuGet.PackageManager($nugetRepository, $PackageInstallPath)
}