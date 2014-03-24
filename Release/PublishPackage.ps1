$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Use-NuGetPackage NuGet.Core #-Verbose

#TODO:Publish NuGet package
$package = New-Object NuGet.OptimizedZipPackage($packagePath)

$stream = $null
try
{
    $stream = $package.GetStream()
    [NuGet.PackageServer] $packageServer = New-Object NuGet.PackageServer($source, "PSNuGet")
    $packageServer.PushPackage("apikey", $package, $stream.Length, [Threading.TimeOut]::Infinite)
    $packagePath
}
finally
{
    if ($stream -ne $null){
        $stream.Dispose()
    }
}