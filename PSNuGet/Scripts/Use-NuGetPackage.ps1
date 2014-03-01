function Use-NuGetPackage
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $PackageId,
        [string] $Version = $null,
        [switch] $IncludePreRelease = $true,
        [switch] $Force = $false
    )
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    #Initialize packagemanaer if not explicitly called
    if ($script:PackageManager -eq $null){
        Initialize-NuGetPackageManager -Verbose
    }

    [NuGet.PackageManager] $manager = $script:PackageManager

    #Search installed package
    [NuGet.IPackage] $package = Find-LocalNuGetPackage -PackageId $PackageId -Version $Version

    if ($Force -and ($package -ne $null))
    {
        Write-Verbose ($messages.UninstallPackage -f $package.ToString())
        $manager.UninstallPackage($package, $true)
        $package = $null
    }

    #If package is not installed, do nothing, If local package is not found. install it.
    if ($package -eq $null)
    {
        #Validate PackageId exists
        if (!($PackageManager.SourceRepository.Exists($PackageId, $Version))){
            Write-Error ($messages.PackageNotFound -f $PackageId, $Version)
        }
        
        Write-Progress -Activity ($messages.InstallPackage -f $PackageId)
        $manager.InstallPackage($PackageId, $Version, $true, $IncludePreRelease) #Ignore dependency(manually resolve it)
        Write-Progress -Activity ($messages.InstallPackage -f $PackageId) -Complete
        
        #Write install log to verbose stream
        $package = Find-LocalNuGetPackage -PackageId $PackageId -Version $Version
        Write-Verbose ($messages.PackageInstalled -f $package.ToString())
    }
    else
    {
        Write-Verbose ($messages.UsePackage -f $package)
    }

    #TODO:Need to determine exact FrameworkVersion
    [Runtime.Versioning.FrameworkName] $frameworkName = $null
    switch ($PSVersionTable.PSVersion){
        "3.0"{ $frameworkName = ".NETFramework,Version=v4.0" }
        "4.0"{ $frameworkName = ".NETFramework,Version=v4.5" }
        default{ $frameworkName = [NuGet.VersionUtility]::DefaultTargetFramework }
    }

    #Load dependent NuGet packages first
    foreach ($dependency in [NuGet.PackageExtensions]::GetCompatiblePackageDependencies($package, $frameworkName))
    {
        #TODO: How to resolve best version?
        Use-NuGetPackage -PackageId $dependency.Id -Version $dependency.VersionSpec.MaxVersion
    }

    #Get loaded assembly names
    if ($LoadedAssemblyNames -eq $null)
    {
        $Script:LoadedAssemblyNames = [AppDomain]::CurrentDomain.GetAssemblies() | foreach { $_.GetName().Name }
    }

    #Load framework assemblies 
    $items = $null
    if ([NuGet.VersionUtility]::TryGetCompatibleItems($frameworkName, $package.FrameworkAssemblies, [ref] $items))
    {
        foreach ($item in $items)
        {
            $item = [NuGet.FrameworkAssemblyReference] $item
            if ($item.AssemblyName -notin $Script:LoadedAssemblyNames)
            {
                Write-Verbose ($messages.LoadAssembly -f $item.AssemblyName, $item.SupportedFrameworks.FullName)
                Add-Type -Path $item.AssemblyName
                $Script:LoadedAssemblyNames.Add($item.AssemblyName)
            }
        }
    }

    #Load referenced assemblies 
    $items = $null
    if ([NuGet.VersionUtility]::TryGetCompatibleItems($frameworkName, $package.AssemblyReferences, [ref] $items))
    {
        foreach ($item in $items)
        {
            $assemblyName = [IO.Path]::GetFileNameWithoutExtension($item.Name)
            if ($assemblyName -notin $Script:LoadedAssemblyNames)
            {
                Write-Verbose ($messages.LoadAssembly -f $item.Name, $item.TargetFramework)
                Add-Type -Path $item.SourcePath
                $Script:LoadedAssemblyNames.Add($assemblyName)
            }
        }
    }

    <#
    #TODO:Handle native DLL(Example:Microsoft.Diagnostics.Tracing.TraceEvent NuGet package). Need to copy dlls to appropriate directory?
    #Load Native DLLs if exists
    $items = $null
    [NuGet.VersionUtility]::TryGetCompatibleItems("native,Version=v0.0", $package.AssemblyReferences, [ref] $items) > $null
    foreach ($item in $items)
    {
        if ($item.EffectivePath.StartsWith("x86") -and [Environment]::Is64BitProcess)
        {
            continue #Don't load x86 DLL to 64bit process
        }
        #Write-Verbose ($messages.LoadNativeDll -f $item.Name, $item.EffectivePath)

        $paths = $env:Path.Split(';')
        $nativeDir = (Split-Path $item.SourcePath -Parent)
        if ($nativeDir -notin $paths)
        {
            Write-Verbose ("Add native dll path '{0}' to `$env:Path" -f $nativeDir)
            $env:Path += ";" + $nativeDir
        }

        #Add-Type -Path $item.SourcePath
        #$Script:LoadedAssemblyNames.Add($item.AssemblyName)
    }
    #>

    #Load PowerShell Module(.psm1) from Tools directory
    $toolFiles = [NuGet.PackageExtensions]::GetToolFiles($package)
    [NuGet.IPackageFile[]] $psModuleFiles = $toolFiles | where { $_.Path.EndsWith(".psm1")}
    if ($psModuleFiles -ne $null)
    {
        #Import .psm1 script files under "tools" directory, if exists.
        foreach ($file in $psModuleFiles)
        {
            Write-Verbose ($message.PSModuleImport -f $file.SourcePath)
            Import-Module $file.SourcePath
        }
    }

    #TODO:Import content files under "content" directory 
    <#
    foreach ($file in [NuGet.PackageExtensions]::GetContentFiles($package)){
        #Write-Verbose $file.EffectivePath
    }
    #>
}
