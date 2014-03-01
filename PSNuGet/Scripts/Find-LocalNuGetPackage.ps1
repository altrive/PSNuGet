#Find installed NuGet packages
function Find-LocalNuGetPackage
{
    [OutputType([NuGet.IPackage])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $PackageId,
        [string] $Version
    )

    #Initialize PackageManager with default parameter if it isn't explicitly initialized
    if ($script:PackageManager -eq $null){
        Initialize-NuGetPackageManager -Verbose:$true
    }

    [ValidateNotNull()]
    [NuGet.PackageManager] $manager = $script:PackageManager

    if ([String]::IsNullOrEmpty($Version))
    {
        #If Version is not specified, return latest version
        return $manager.LocalRepository.FindPackagesById($PackageId) | sort Version -Descending | select -First 1
    }
    else
    {
        $Version = [NuGet.SemanticVersion]::ParseOptionalVersion($Version)
        return $manager.LocalRepository.FindPackage($PackageId, $Version)
    }
}