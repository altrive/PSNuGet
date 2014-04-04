

TestFixture "Install NuGet Package(.NET)"{

    #region Helper methods
    function IsAssemblyLoaded
    {
        [OutputType([bool])]
        param (
            [Parameter(Mandatory)]
            [string] $AssemblyName,
            [ValidateSet("3.0", "4.0", "4.5", "4.5.1")]
            [string] $Version
        )
        $loadedAssemblyNames = [AppDomain]::CurrentDomain.GetAssemblies().GetName()
        [bool] $result = $loadedAssemblyNames.Name.Contains($AssemblyName)

        if ($result -and ![String]::IsNullOrEmpty($Version)){
            #TODO:VersionCheck
        }

        return $result
    }
    #endregion

    TestCase "RazorMachine"{
        Use-NuGetPackage -PackageId "RazorMachine"
        IsAssemblyLoaded ("Xipton.Razor") | should be $true
        IsAssemblyLoaded ("System.Web.Razor") | should be $true

    }
    
    TestCase "ClosedXML"{
        Use-NuGetPackage -PackageId "ClosedXML"
        IsAssemblyLoaded ("DocumentFormat.OpenXml") | should be $true
        IsAssemblyLoaded ("ClosedXML") | should be $true
    }
    
    TestCase "Windows7APICodePack-Shell"{
        Use-NuGetPackage -PackageId "Windows7APICodePack-Shell"
        IsAssemblyLoaded ("Microsoft.WindowsAPICodePack") | should be $true
        IsAssemblyLoaded ("Microsoft.WindowsAPICodePack.Shell") | should be $true
    }

    TestCase "NuGet.Server"{
        Use-NuGetPackage -PackageId "NuGet.Server"
        IsAssemblyLoaded ("Microsoft.Web.XmlTransform") | should be $true
        IsAssemblyLoaded ("Elmah") | should be $true
        IsAssemblyLoaded ("Ninject") | should be $true
        IsAssemblyLoaded ("RouteMagic") | should be $true
        IsAssemblyLoaded ("Microsoft.Web.Infrastructure") | should be $true
        IsAssemblyLoaded ("WebActivatorEx") | should be $true
        IsAssemblyLoaded ("System.ServiceModel.Web") | should be $true
        IsAssemblyLoaded ("NuGet.Server") | should be $true
    }

    TestCase "Tx.Windows"{
        Use-NuGetPackage -PackageId "Tx.Windows"
        IsAssemblyLoaded ("System.Reactive.Interfaces") | should be $true
        IsAssemblyLoaded ("System.Reactive.Core") | should be $true
        IsAssemblyLoaded ("System.Reactive.Linq") | should be $true
        IsAssemblyLoaded ("System.Reactive.PlatformServices") | should be $true
        IsAssemblyLoaded ("Tx.Core") | should be $true
        IsAssemblyLoaded ("Tx.Windows") | should be $true
    }

    TestCase "LiveSDK"{
        Use-NuGetPackage -PackageId "LiveSDK"
        IsAssemblyLoaded ("System.Net") | should be $true
        IsAssemblyLoaded ("Microsoft.Threading.Tasks") | should be $true
        IsAssemblyLoaded ("Microsoft.Threading.Tasks.Extensions") | should be $true
        IsAssemblyLoaded ("Microsoft.Live") | should be $true
    }

    TestCase "Microsoft.IdentityModel.Clients.ActiveDirectory"{
        Use-NuGetPackage -PackageId "Microsoft.IdentityModel.Clients.ActiveDirectory"
        IsAssemblyLoaded ("System.Net") | should be $true
        IsAssemblyLoaded ("Microsoft.IdentityModel.Clients.ActiveDirectory") | should be $true
        IsAssemblyLoaded ("Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms") | should be $true
    }

    TestCase "StackExchange.Redis"{
        Use-NuGetPackage -PackageId "StackExchange.Redis"
        IsAssemblyLoaded ("StackExchange.Redis") | should be $true
    }

}

