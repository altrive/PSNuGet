function Initialize-NuGetPackageManager
{
    [CmdletBinding()]
    param (
        [switch] $IgnoreFailingRepositories = $false,
        [switch] $UseOfficialRepository = $true,
        [switch] $UseChocolateyRepository = $false,
        [string] $PackageInstallPath
    )
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    $repositories = New-Object System.Collections.Generic.List[string]

    #Add repository path from environment variable if exists.
    if ($env:PSNuGetRepository -ne $null)
    {
        $paths = $env:PSNuGetRepository -split ";"
        foreach ($path in $paths)
        {
            if (!$repositories.Contains($path))
            {
                $repositories.Add($path)
            }
        }
    }
    
    #Setup official NuGet repository paths(Default:$true)
    $officialRepository = "https://packages.nuget.org/api/v2"
    if ($UseOfficialRepository -and !$repositories.Contains($officialRepository))
    {
        $repositories.Add($officialRepository)
    }

    #Setup chocolatey repository paths(Default:$false)
    $chocolateyRepository = "http://chocolatey.org/api/v2/"
    if ($UseChocolateyRepository -and !$repositories.Contains($chocolateyRepository))
    {
        $repositories.Add($chocolateyRepository)
    }

    #Create NuGet repository
    $nugetRepository = New-Object NuGet.AggregateRepository([NuGet.PackageRepositoryFactory]::Default, $repositories, $IgnoreFailingRepositories)

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