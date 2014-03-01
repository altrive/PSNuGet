Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Use-NuGetPackage NuGet.Core #-Verbose

$metadata = [NuGet.ManifestMetadata] @{
    Id = "PSNuGet"
    Version = "0.9.0"
    #Title = ""
    Authors = "altrive"
    Owners = "altrive"
    IconUrl = "http://www.gravatar.com/avatar/85f44e96c1ca239444069d1355086036?s=120&d=identicon"
    ProjectUrl = "https://github.com/altrive/PSNuGet"
    RequireLicenseAcceptance = $false
    LicenseUrl = "https://github.com/altrive/PSNuGet/blob/master/LICENSE"
    Summary = "NuGet package loader utilities for PowerShell"
    Description = "Utility commandlets loading resources(DLL/PSModule) from NuGet repository"
    ReleaseNotes = ""
    Copyright = "Copyright 2014"
    #Language = "en-us"
    Tags = "PowerShell"
}

#Define package files
$manifestFiles = @(
    [NuGet.ManifestFile] @{ Target = "/content"; Source = "PSNuGet\**";}
)

#Set package BaseDir to  ".\PSNuGet
$baseDir = Split-Path $PSScriptRoot -Parent
$builder = New-Object NuGet.PackageBuilder
$builder.PopulateFiles($baseDir, [NuGet.ManifestFile[]] $manifestFiles)
$builder.Populate($metadata)

#Output NuGet package to BaseDir
$packagePath = Join-Path $baseDir "Release\PSNuGet.nupkg"
try
{
    $stream = [IO.File]::Open($packagePath, [IO.FileMode]::Create)
    $builder.Save($stream);
}
finally
{
    $stream.Dispose()
}