
$currentDir = $PSScriptRoot -replace "\\", "/"
$outputDir = (Resolve-Path "${currentDir}/../_out") -replace "\\", "/"
if(Test-Path -LiteralPath $outputDir -PathType Leaf){
    Write-Host -ForegroundColor Red "エラー: outputDirがファイルとして存在します`noutputDir: $outputDir"
    return
}elseif(-not (Test-Path -LiteralPath $outputDir -PathType Container)){
    New-Item -Path $outputDir -ItemType Directory
}
[Environment]::SetEnvironmentVariable("BizHawk_ULibPath", "${currentDir}/?.lua;", "User")
[Environment]::SetEnvironmentVariable("BizHawk_UOutputPath", "${outputDir}", "User")
