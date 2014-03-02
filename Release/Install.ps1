#Requires -Version 3.0

function Main
{
[CmdletBinding()]
param()
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    if ($PSVersionTable.PSVersion.Major -lt 3){
        Write-Error "PowerShell 3.0 or above required!"
    }

    $ModuleName = "PSNuGet"
    $Url = "https://github.com/altrive/PSNuGet/raw/master/Release/PSNuGet.nupkg"
    try
    {
        $extractedPath = Get-ZipContentFromUrl -Url $Url
        $contentPath = Join-Path $extractedPath "content" -Resolve
        Install-PSModule -ModuleName $ModuleName -Path $contentPath -Target User
    }
    finally
    {
        Write-Verbose ("Cleanup temp directory '{0}'" -f $extractedPath)
        Remove-Item -path $extractedPath -Force -ErrorAction Ignore -Recurse
    }
}

function Get-ZipContentFromUrl
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Url
    )

    #Create temporary work dir
    $tempDir = Join-Path ([IO.Path]::GetTempPath()) ([Guid]::NewGuid())
    $tempFilePath = Join-Path $tempDir "temp.zip"
    [IO.Directory]::CreateDirectory($tempDir) > $null

    try
    {
        #Download zip file
        Write-Verbose ("Download file '{0}'" -f $Url)
        Invoke-WebRequest -Uri $Url -OutFile $tempFilePath -Verbose:$false

        #Unblock zip file
        Unblock-File -Path $tempFilePath
   
        #Extract zip file
        Write-Verbose ("`tExtract zip content to '{0}'" -f $tempDir)
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::ExtractToDirectory($tempFilePath, $tempDir)
    }
    finally
    {
        #Remove temporary zip file
        Write-Verbose ("`tRemove downloaded zip file")
        Remove-Item -Path $tempFilePath -Force -ErrorAction Ignore
    }

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