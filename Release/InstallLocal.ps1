#Requires -Version 3.0
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Main
{
    [CmdletBinding()]
    param ()

    #Create NuGet package
    $path = Join-Path $PSScriptRoot "CreatePackage.ps1" -Resolve
    Write-Host $path
    Invoke-Expression -Command "$path -IncludeTestFiles" -Verbose
    #Invoke-Command -FilePath $path -ArgumentList @()
    $packagePath = Join-Path $PSScriptRoot "PSNuGet.nupkg" -Resolve

    #Install PSModule
    try
    {
        $extractedPath = Get-ZipContent -Path $packagePath
        $contentPath = Join-Path $extractedPath "content" -Resolve
        Install-PSModule -ModuleName "PSNuGet" -Path $contentPath -Target User
    }
    finally
    {
        Write-Verbose ("Cleanup temp directory '{0}'" -f $extractedPath)
        Remove-Item -path $extractedPath -Force -ErrorAction Ignore -Recurse
    }
}


#Extract zip file to %Temp% directory and return path
function Get-ZipContent
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Path
    )

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    #Create temporary work dir
    $tempDir = Join-Path ([IO.Path]::GetTempPath()) ([Guid]::NewGuid())
    [IO.Directory]::CreateDirectory($tempDir) > $null

    #Extract zip file to temp directory
    Write-Verbose ("Extract zip content to '{0}'" -f $tempDir)
    [IO.Compression.ZipFile]::ExtractToDirectory($Path, $tempDir)

    #Return extracted content directory
    return $tempDir
}

function Install-PSModule
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ModuleName,
        [Parameter(Mandatory)]
        [string] $Path,
        [ValidateSet("User", "System", "ProgramFiles", "Local")]
        [string] $Target = "User"
    )

    if (!(Test-Path $Path -PathType Container))
    {
        Write-Error ("Directory is not found! : {0}" -f $Path)
    }

    #Resolve target module base directory
    switch ($Target)
    {
        "Local"{
            $moduleBasePath = Join-Path (Resolve-Path .) "Modules" #Use Current Directory
        }
        default{
            #TODO:Specify ProgramFiles may exists multiple items
            $moduleBasePath = $env:PSModulePath.Split(";") | where { $_ -like ("{0}*" -f [Environment]::GetFolderPath($Target))} | select -First 1
        }
    }

    #Validate module directory exist
    if ([String]::IsNullOrEmpty($moduleBasePath)){
        Write-Error ("PowerShell module path is not found for target({0})" -f $Target)
    }
   
    #Set target module directory
    $modulePath = Join-Path $moduleBasePath $ModuleName
 
    #Change current directory to get relative path from module root
    Push-Location -Path $Path
    try
    {
        #Get files under current directory
        $items = Get-ChildItem -File -Recurse
        Write-Verbose ("Install PowerShell module to '{0}'" -f $modulePath)
        foreach ($item in $items)
        {
            #Relative path to CopyFrom basepath
            $relativePath = Resolve-Path $item.FullName -Relative

            #Copy file operation target path 
            $destination = Join-Path $modulePath $relativePath

            #Create directory if not exist already
            (New-Object IO.FileInfo($destination)).Directory.Create()
            
            Write-Verbose ("`tCopy file '{0}'" -f $relativePath)
            Copy-Item -Path $item.FullName -Destination $destination -Force
        }
    }
    finally
    {
        Pop-Location -ErrorAction Ignore
    }
}

#execute Main function
Main -Verbose