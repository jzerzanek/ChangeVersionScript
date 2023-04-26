# Universal tool to change assembly and file version in Visual studio projects. Support net framework AssemblyInfo file and new .NET

Write-Host "Change project version"
Write-Host "----------------------"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
$files = Get-Childitem -Path $dir -Include *.csproj, AssemblyInfo.cs -File -Recurse | %{ $_.FullName }
$newProjectVersion = Read-Host "Enter new version in format x.x.x.x"
[string[]]$skipProjects ="*UnitTest*", "*Test*"

foreach ($item in $files)
{
    [bool]$isSkip = 0;
    
    foreach($skipProject in $skipProjects)
    {
        if($item -like $skipProject)
        {
            $isSkip = 1;
        }   
    }

    if($isSkip)
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

            Write-Host $item
        }
    }
    else
    {
        [string]$ai = Get-Content $item -Raw
        $newAi = $ai -replace '"\d+\.\d+\.\d+\.\d+"', -join('"' , $newProjectVersion , '"')
        $newAi | Set-Content -Path $item

        Write-Host $item
    }
}
