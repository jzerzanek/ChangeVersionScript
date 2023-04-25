# Universal tool to change assembly and file version in Visual studio projects. Support net framework AssemblyInfo file and new .NET

Write-Host "Change project version"
Write-Host "----------------------"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
$files = Get-Childitem -Path $dir -Exclude *UnitTest* -Include *.csproj, AssemblyInfo.cs -File -Recurse | %{ $_.FullName }
$newProjectVersion = Read-Host "Enter new version "

foreach ($item in $files)
{
    if($item -like "*UnitTest*")
    {
        continue;
    }

    if($item -like "*.csproj")
    {
        [xml]$xmlData = Get-Content $item
        $fileVerElement = $xmlData.SelectSingleNode("//FileVersion")
        $assemblyVerElement = $xmlData.SelectSingleNode("//AssemblyVersion")

        if(($fileVerElement -ne $null) -and ($assemblyVerElement -ne $null))
        {
            $fileVerElement.InnerText=$newProjectVersion
            $assemblyVerElement.InnerText = $newProjectVersion
            $xmlData.Save($item)
        }
    }
    else
    {
        [string]$ai = Get-Content $item -Raw
        $newAi = $ai -replace '"\d+\.\d+\.\d+\.\d+"', -join('"' , $newProjectVersion , '"')
        $newAi | Set-Content -Path $item
    }
}