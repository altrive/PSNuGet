@{
# Script module or binary module file associated with this manifest
ModuleToProcess = 'PSNuGet.psm1'

# Version number of this module.
ModuleVersion = '0.9'

# ID used to uniquely identify this module
GUID = '8917e122-e951-4d05-8c35-452440ae6fc2'

# Author of this module
Author = 'Altrive'

# Company or vendor of this module
CompanyName = 'Altrive'

# Copyright statement for this module
Copyright = '2014'

# Description of the functionality provided by this module
Description = 'PowerShell Package Manager Utilities'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = ''

# Processor architecture (None, X86, Amd64, IA64) required by this module
ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# for example 'ActiveDirectory'
# RequiredModules = @('')

# Assemblies that must be loaded prior to importing this module
# for example 'System.Management.Configuration'
#RequiredAssemblies = @("NuGet.Core.dll")

# Script files (.ps1) that are run in the caller's environment prior to importing this module
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @()

# Modules to import as nested modules of the module specified in ModuleToProcess
NestedModules = @("PSNuGet.psm1")

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = @(
    "Initialize-NuGetPackageManager",
    "Get-NuGetPackageManager",
    "Use-NuGetPackage",
    "Clear-NuGetPackage"
)

# Variables to export from this module
# VariablesToExport = '*'

# Aliases to export from this module
# AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in ModuleToProcess
# PrivateData = @{ }
}