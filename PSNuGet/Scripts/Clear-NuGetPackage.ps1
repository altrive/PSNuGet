function Clear-NuGetPackage
{
    [CmdletBinding()]
    param (
        [string] $PackageId,
        [string] $Version = $null
    )

    #Initialize packagemanaer if not explicitly called
    if ($script:PackageManager -eq $null){
        Initialize-NuGetPackageManager -Verbose
    }

    [ValidateNotNull()]
    [NuGet.PackageManager] $manager = $script:PackageManager

    if ([String]::IsNullOrEmpty($PackageId))
    {
        [NuGet.IPackage[]] $packages = $manager.LocalRepository.GetPackages()

        foreach ($package in $packages)
        {
            Write-Verbose ($messages.UninstallPackage -f $package.ToString())
            $manager.UninstallPackage($package, $true, $false)
        }
    }
    else
    {
        $package = Find-LocalNuGetPackage -PackageId $PackageId -Version $Version
        if ($package -ne $null)
        {
            Write-Verbose ($messages.UninstallPackage -f $package.ToString())
            $manager.UninstallPackage($package, $true, $true)
        }
    }
}
