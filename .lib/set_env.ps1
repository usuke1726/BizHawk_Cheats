
$currentDir = $PSScriptRoot -replace "\\", "/"
$outputDir = (Resolve-Path "${currentDir}/../_out") -replace "\\", "/"
[Environment]::SetEnvironmentVariable("BizHawk_ULibPath", "${currentDir}/?.lua;", "User")
[Environment]::SetEnvironmentVariable("BizHawk_UOutputPath", "${outputDir}", "User")
