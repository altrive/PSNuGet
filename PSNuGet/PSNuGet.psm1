#Import localize messages
Import-LocalizedData -BindingVariable messages -FileName Messages.psd1

#Load NuGet.Core.dll assembly(Load dll as byte stream to avoid dll locking issue)
$loadedDll = [AppDomain]::CurrentDomain.GetAssemblies() | where { $_.FullName.StartsWith("NuGet.Core")}
if($null -eq $loadedDll)
{
    $dllPath = Join-Path $PSScriptRoot "NuGet.Core.dll" -Resolve      
    $dllBytes = [IO.File]::ReadAllBytes($dllPath)
    [System.Reflection.Assembly]::Load($dllBytes) > $null
}

#Define script variables
[NuGet.PackageManager]$Script:PackageManager = $null
[Collections.Generic.List[string]] $Script:LoadedAssemblyNames = [AppDomain]::CurrentDomain.GetAssemblies().GetName().Name
[Collections.Generic.List[string]] $Script:LoadedPackageNames = @()

#Load script files using dot-souced
$scriptFiles = Get-ChildItem "$PSScriptRoot\Scripts\*\*.ps1" -Exclude "*.Tests.ps1" -Recurse
foreach ($script in $scriptFiles)
{
    try
    {       
        . $script.FullName
    }
    catch [Management.Automation.ScriptRequiresException]
    {
        $errorRecord = $_
        $exception = $errorRecord.Exception

        #TODO: Suppress $Error entry recorded after module loading completion(can't suppress inside psm1 module?)
        switch ($errorRecord.FullyQualifiedErrorId)
        {
            "ScriptRequiresElevation"{
                Write-Warning ("`tSkip script load: {0,-30}(Require runas administrator)" -f $script.Name)
            }
            "ScriptRequiresMissingModules"{
                Write-Warning ("`tSkip script load: {0,-30}(Require missing modules: {1})" -f $script.Name, $exception.MissingPSSnapIns[0])
            }
            "ScriptRequiresMissingPSSnapIns"{
                Write-Warning ("`tSkip script load: {0,-30}(Require PSSnapin: {1})" -f $script.Name, $exception.MissingPSSnapIns[0])
            }
            "ScriptRequiresUnmatchedPSVersion"{
                Write-Warning ("`tSkip script load: {0,-30}(Require PowerShell version: {1})" -f $script.Name, $exception.RequiresPSVersion)
            }
            "RequiresShellIDInvalidForSingleShell"{
                Write-Warning ("`tSkip script load: {0,-30}(Require PowerShell host ShellID: {1})" -f $script.Name, $exception.RequiresShellId)
            }
            default{
                throw
            }
        }
    }
}
