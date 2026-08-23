
Param(
    [Alias("h")][switch]$help,
    [string]$command,
    [string]$arg
)
if($help){
    Write-Host "./sjis <enc <arg>|from <arg>|ms [sep|]>"
    Write-Host "`tenc <arg>`t文字列 arg をsjisでencodeする"
    Write-Host "`tfrom <arg>`tバイト列 arg をsjisとしてdecodeする"
    Write-Host "`tms [sep|]`tムシキングの .to_byte ファイルからバイト列書き込み処理を生成する`n`t`t`t(sepを指定すると1文字ごとにスペースが挿入される)"
    return
}
if($command -eq $null -or $command -eq ""){
    Write-Host -ForegroundColor Red "コマンドを入力してください"
    return
}
switch($command){
    "enc" {
        $arg = $arg -replace "`"", "\`""
        python -c "print(`"$arg`".encode(encoding=`"sjis`").hex())"
    }
    "from" {
        $arg = $arg -replace "`"", "\`""
        python -c "print(bytes.fromhex(`"$arg`").decode(encoding=`"sjis`"))"
    }
    "ms" {
        python ./series/mushikin/to_byte.py $arg
    }
    default {
        Write-Host -ForegroundColor Red "不明なコマンド: $command"
    }
}
