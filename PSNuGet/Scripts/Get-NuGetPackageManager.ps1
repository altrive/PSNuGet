function Get-NuGetPackageManager
{
    [OutputType([NuGet.PackageManager])]
    [CmdletBinding()]
    param (
    )

    #Initialize PackageManager with default parameter if it isn't explicitly initialized
    if ($script:PackageManager -eq $null){
        Initialize-NuGetPackageManager -Verbose:$true
    }

    return $script:PackageManager
}