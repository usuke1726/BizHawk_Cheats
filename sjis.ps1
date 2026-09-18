
Param(
    [Alias("h")][switch]$help,
    [string]$command,
    [string]$arg
)
if($help){
    Write-Host "./sjis <enc <arg>|v <arg>|from <arg>|ms [sep|]>"
    Write-Host "`tenc <arg>`t文字列 arg をsjisでencodeする"
    Write-Host "`tv <arg>`t`t辻libに渡す文字列として encode する`n`t`t`t(半角の ' を ’ にするなどの処理をはさむ)"
    Write-Host "`tfrom <arg>`tバイト列 arg をsjisとしてdecodeする"
    Write-Host "`tms [sep|]`tムシキングの .to_byte ファイルからバイト列書き込み処理を生成する`n`t`t`t(sepを指定すると1文字ごとにスペースが挿入される)"
    Write-Host "`tr`t`tお料理ナビの to_byte.py を実行"
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
    "v" {
        $arg = $arg -replace "`"", "\`""
        python -c @"
convert_table = {
    "/": "／",
    "'": "’",
    "_": "＿",
    "|": "｜",
    "～": "〜",
    "0": "０", "1": "１", "2": "２", "3": "３", "4": "４", "5": "５", "6": "６", "7": "７", "8": "８", "9": "９",
}
def convert(s):
    for bef, aft in convert_table.items():
        s = s.replace(bef, aft)
    return s

print(convert(`"$arg`").encode(encoding=`"sjis`").hex())
"@
    }
    "from" {
        $arg = $arg -replace "`"", "\`""
        python -c "print(bytes.fromhex(`"$arg`").decode(encoding=`"sjis`"))"
    }
    "ms" {
        python ./series/mushikin/to_byte.py $arg
    }
    "r" {
        python ./series/ryori/to_byte.py $arg
    }
    default {
        Write-Host -ForegroundColor Red "不明なコマンド: $command"
    }
}
