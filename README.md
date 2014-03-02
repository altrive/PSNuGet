
PSNuGet
=======
PSNuGet is NuGet package loader utility for Windows PowerShell.  
Basic usage is very simple. use following statement. (Need PSNuGet install before execute)

``` powershell
Use-NuGetPackage [NuGetPackageId] -Verbose
```

It executes following tasks automatically.

* Download specified package from NuGet repositories.
    * Dependent NuGet packages are also downloaded.
    * Downloaded package is installed(cached).And no need to download second call.　
* Import following resources from NuGet packages to current PowerShell context
    * .NET assemblies (.dll)
    * PowerShell Modules (.psm1)

Install
=======
Execute following command from powershell console  
It automatically install PSNuGet PSModule to user module directory(%MyDocuments%\WindowsPowerShell\Modules).

``` powershell

(New-Object Net.WebClient).DownloadString("https://raw.github.com/altrive/PSNuGet/master/Release/Install.ps1") | Invoke-Expression

```

Usage examples
=======

Following scripts create Excel file(.xlsx) using ClosedXML library.
 
``` powershell

Use-NuGetPackage -PackageId ClosedXML -Verbose

#Set .Net current directory
[IO.Directory]::SetCurrentDirectory((Get-Location).Path)

#Output Excel file to current directory
$workbook = New-Object ClosedXML.Excel.XLWorkbook
$worksheet = $workbook.Worksheets.Add("Sample Sheet");
$worksheet.Cell("A1").Value = "Hello World!";
$workbook.SaveAs("HelloWorld.xlsx");
$worksheet.Dispose()
 
#Open Excel File
explorer "HelloWorld.xlsx"

```

**Other examples.**

- [C# dynamic eval using Roslyn/Mono.CSharp](https://gist.github.com/altrive/9051839)
- [Search GitHub API using OctokitDotNet](https://gist.github.com/altrive/8747840)


TODO Tasks
=======
- [] Cleanup NuGet package temporary workdir.(automatically extracted to "%Temp%\NuGet")
- [] Support NuGet package that contain native DLLs.(e.g. Microsoft.Diagnostics.Tracing.TraceEvent) 
- [] Support package install/deployment option(like [Octopus Deploy](http://docs.octopusdeploy.com/display/OD/PowerShell+scripts) PreDeploy/Deploy/PostDeploy scripts execution)





