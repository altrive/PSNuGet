
TestFixture "Install NuGet Package(Load PSModule under /tools)"{

    TestCase "Pester"{
        Use-NuGetPackage -PackageId "Pester"
        Get-Module Pester | should not be null
    }

    TestCase "PShould"{
        Use-NuGetPackage -PackageId "PShould"
        Get-Module PShould | should not be null
    }

    TestCase "PSMock"{
        Use-NuGetPackage -PackageId "PSMock"
        Get-Module PSMock | should not be null
    }

    TestCase "PSate"{
        Use-NuGetPackage -PackageId "PSate"
        Get-Module PSate | should not be null
    }

    TestCase "PSake"{
        Use-NuGetPackage -PackageId "PSake"
        Get-Module PSake | should not be null
    }
}


