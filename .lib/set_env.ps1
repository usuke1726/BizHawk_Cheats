
$currentDir = $PSScriptRoot -replace "\\", "/"
[Environment]::SetEnvironmentVariable("BizHawk_ULibPath", "${currentDir}/?.lua;", "User")
