
# FABSTYLE

## オーディオ

アドレス `0x03E18DD0`
ボイスは3E19640あたり  3E19649の60を大きくするとジョバババババみたくなる

## テキストデータ

```plaintext
-- ROM内のテキスト：
-- 漢字はそのままSJIS、しかしひらがな・カタカナは容量削減のため1byte独自encoding
-- 色変更・改行もそのまま
-- \x1Bh0019 (1B 68 30 30 31 39)とかは謎

-- 一連の流れ?  1B 48  1B 43 36  1B 68 30 30 31 39

-- rom 0x0493D862: 「アパレルショップ」 B1 CA DF DA D9 BC AE AF CC DF
-- B1から順にアイウエオカキクケコ

-- 1B 43 3* 色変更
-- 0: 黒, 1: 白, 2: 黒い赤, 3: 薄い赤(ピンク)
-- 4: 青, 5: 赤, 6: 黄色(通常色), 7: 薄い緑
-- 8: 薄い紫, 9: 濃いピンク, A: 水色?, B: 濃い紫
-- C: 濃い赤, D: 暗い濃い赤, E: 灰色, F: 暗い灰色

-- 1B 4B => カタカナモードにシフトチェンジ
-- 1B 48 => ひらがなモードにチェンジ
-- ただし、上2つは、直後に文字が来ないと強制ひらがなになる(直後に1B系の制御文字が来たらダメ)

-- 05 05 05がダイアログの区切り箇所

--     0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
-- A                     ヲ ァ ィ ゥ ェ ォ ャ ュ ョ ッ
-- B      ア イ ウ エ オ カ キ ク ケ コ サ シ ス セ ソ
-- C   タ チ ツ テ ト ナ ニ ヌ ネ ノ ハ ヒ フ ヘ ホ マ
-- D   ミ ム メ モ ヤ ユ ヨ ラ リ ル レ ロ ワ ン ゛ ゜

=> このカタカナコードは、まんま半角カタカナのSJISコードになっている！

各ダイアログの開始アドレスは固定なので、
会話を送るたびに書き換える必要がある
=>
一番最初のテキストはROMの方を、以降はRAMをいじる
```


## フレミング ポーズ1崩壊

```lua

local head = 0x022a9800
local head = 0x022aa000
-- local head = 0x022b8800
local r = RC(120)
function loop()
    for i = 0, 0x590, 4 do
        if r() then
            add32(head+i, rand(-4, 4)*0x100)
        end
    end
end
```

## フレミング 雑多

```lua
-- 口がおかしくなる?
-- lib.fill_in(0x022D3BC0, 0x022Da1F4, 0x5e)
-- lib.fill_in(0x022A3E3E, 0x022A3F22, 0x88)

-- 体が横になって自由に飛びまわる
lib.fill_in(0x0228FB51, 0x0228FD9B, 0xec)

-- 顔が半分消えたり吹っ飛んだり
lib.fill_in(0x02287180, 0x0228721f, 0x22)
```

```lua

-- 先生の動きがおかしくなる
-- lib.fill_in(0x022aa000, 0x022acfff, 0x11)
-- lib.fill_in(0x022ad000, 0x022affff, 0x77)
-- lib.fill_in(0x022a9000, 0x022a9fff, 0x33)

-- lib.fill_in(0x022bd000, 0x022bffff, 0x33)
-- lib.fill_in(0x022c0000, 0x022c7fff, 0x22)

-- lib.fill_in(0x02253000, 0x02257fff, 0x11)

-- local s = "HM_"
-- local d = {string.byte(s, 1, #s)}
-- lib.find(0x02285400, 0x027fffff, d)

-- local head = 0x02287820
-- local head = 0x02292700

local update_moves = (function()
local r = RC(120)
local function go(st, ed)
    for i = st, ed, 4 do
        if r() then
            add32(i, rand(-4, 4)*0x400)
        end
    end
end

return function()
    go(0x022a9800, 0x022aa800)
    go(0x022b8800, 0x022b8f00)
    -- go(0x022b0000, 0x022b0f00) -- ボツ
    go(0x022b1000, 0x022b1f00)
    go(0x022b4300, 0x022b4700)
    go(0x022bb800, 0x022bbf00)
end
end)()

local update_voice = (function()
local c = Cnt(20)
-- ボイス破壊
local h1 = 0x0212F3C0
local h2 = 0x0212FBC0
local h3 = 0x021303C0
local hs = {h1, h2, h3}
return function()
    if not c() then return end
    local j = rand(1, 3)
    for i = 0, 0x7ff, 4 do
        local v = r32(hs[j]+i)
        for k = 1, 3 do
            if k ~= j then w32(hs[k]+i, v) end
        end
    end
end
end)()

function loop()
    update_moves()
    update_voice()
end

-- そのときのイルーム
lib.irume.start(function()
    local base = 0x03E18DD0
    local p2 = 0x14
    local as = {}
    for i = 0, 16 do as[i] = base + i*0x40 end
    local r = RC(15)
    return function()
        for i, a in pairs(as) do
            if r() then
                w16(a+p2, rand(-20, 20)*0x20)
            end
        end
    end
end)

```

```lua
-- 頂点座標をいじって顔を巨大化させたときのやつ(10/06)

local go = (function()

local commands = {
[0x0] = 0, -- NOP
[0x14] = 1, -- MTX_RESTORE
[0x1b] = 3, -- MTX_SCALE
[0x20] = 1, -- COLOR
[0x21] = 1, -- NORMAL
[0x22] = 1, -- TEXCOORD
[0x23] = 2, -- VTX_16
[0x24] = 1, -- VTX_10
[0x25] = 1, -- VTX_XY
[0x26] = 1, -- VTX_XZ
[0x27] = 1, -- VTX_YZ
[0x28] = 1, -- VTX_DIFF
[0x40] = 1, -- BEGIN_VTXS
[0x41] = 0, -- END_VTXS
}

local function is_command(value)
    for j = 0, 3 do
        if not commands[(value >> (8*j)) & 0xff] then
            return false
        end
    end
    return true
end

---@type fun(begin: int, incEnd: int)
return function(begin, incEnd)

local i = begin
while i <= incEnd do
    local v = r32(i)
    i = i + 4
    if is_command(v) then
        for j = 0, 3 do
            local _v = (v>>(8*j)) & 0xff
            local pnum = commands[_v]
            if _v == 0x23 then
                -- print(string.format("found 0x%08X", i))
                -- y座標のみいじる
                -- add16(i+4, rand(1, 5)*0x200)
                add16(i+4, 0x6000)
                w16(i, r16(i)*4)
                -- w16(i+2, r16(i)*2)
            end
            i = i + pnum * 4
        end
    end
end
end
end)()

-- go(0x228C2D0, 0x229FFFF)
go(0x2282200, 0x2289FFF)

-- 22A8B53を60にすると微振動する
```


## フレミング ボイスバグ案

```lua
local begin = 0x20E2A10
local iend = 0x20E3F1F
local bound = iend - begin + 1
local vs = {}
for i = begin, iend, 4 do
    vs[i-begin] = r32(i)
end
for i = begin, iend, 4 do
    local v = 0
    for j = 0, 3 do
        local a = clamp(i - begin+5, 0)
        local _v = assert(vs[a & 0xfffffffc])
        local _j = a & 0x3
        v = v | ( ( (_v >> (8*j)) & 0xff ) << (8*j) )
    end
    w32(i, v)
end
```

```lua
local begin = 0x20E2A10
local iend = 0x20E3F1F
local bound = iend - begin + 1
local vs = {}
for i = begin, iend, 4 do
    vs[i-begin] = r32(i)
end
for i = begin, iend, 4 do
    local v = 0
    for j = 0, 3 do
        -- local a = math.round((i - begin + j) * 0.5) % bound
        local a = clamp(i - begin-1, 0)
        local _v = assert(vs[a & 0xfffffffc])
        local _j = a & 0x3
        v = v | ( ( (_v >> (8*_j)) & 0xff ) << (8*j) )
    end
    w32(i, v)
end
```

```lua

local begin = 0x20E2A10
local iend = 0x20E3F1F
local bound = iend - begin + 1
local vs = {}
for i = begin, iend, 4 do
    vs[i-begin] = r32(i)
end
for i = begin, iend, 4 do
    local v = 0
    for j = 0, 3 do
        -- local a = math.round((i - begin + j) * 0.5) % bound
        local a = clamp(i +j- begin+8, 0, bound-1)
        local _v = assert(vs[a & 0xfffffffc])
        local _j = a & 0x3
        v = v | ( ( (_v >> (8*_j)) & 0xff ) << (8*j) )
    end
    w32(i, v)
end
```

```lua
local begin = 0x20E2A10
local iend = 0x20E3F1F
local bound = iend - begin + 1
local vs = {}
for i = begin, iend, 4 do
    vs[i-begin] = r32(i)
end
for i = begin, iend, 4 do
    local v = 0
    for j = 0, 3 do
        -- local a = math.round((i - begin + j) * 0.5) % bound
        -- local a = clamp(i +j- begin+4, 0, bound-1)
        local a = clamp((i +j - begin)~0x8, 0, bound-1)
        local _v = assert(vs[a & 0xfffffffc])
        local _j = a & 0x3
        v = v | ( ( (_v >> (8*_j)) & 0xff ) << (8*j) )
    end
    w32(i, v)
end
```

```lua

-- 無駄無駄系
local r = RC(10)
function loop()
    if r() then
    w8(0x02107638, rand(1,8)) -- 十分ボイスが短くないと(恐らくout of rangeで)フリーズ
    end
end
```

CRI ADX file format: https://wiki.multimedia.cx/index.php/CRI_ADX_file


```
(「NDS AHX binary format」で検索)
ニンテンドーDS（NDS）などのゲームソフトで主に使用される .ahx 形式は、CRI・ミドルウェア社が開発した独自の音声圧縮フォーマット（音声コンテナ）です。
同じCRI社の主力コーデックである「ADX」の姉妹フォーマットにあたり、主にボイス・音声再生（MPEG-2 オーディオベースの圧縮アルゴリズム）に特化して最適化されています。 [1] (/goto?url=CAESZwHrOzAVwkWEdaMnU2huBbOpr0Mhh5sqDaAoRrUnh4Q2b9VweqgNQnJXA39hgYD-iFXfPTq81-1_q4mJuPiYSuCKKSrSWvKJ3Je4ypEvjfiHIdHtFXLtdru9kpgK_H63KeRU3GBKNu0), [2] (/goto?url=CAESUQHrOzAVvZCDDlHBDdJm5P398Raj1bohToHwsZ6W4ufhxcvgh_8ghManfKGxFaF_Nt631ihYAtcuX8OxMo8Ix2PAWHMGMowALpv8RdQfrf_FwA)
以下に、AHXバイナリファイルの構造とその詳細を解説します。

📂 全体構造

AHXファイルは基本的にビッグエンディアン（Big-Endian）で記録されており、以下の3つのセクションで構成されています。 [1] (/goto?url=CAESaQHrOzAVnjCECaaJD0fJ4IRZ7onx0SPpxYyzD7q95smiwrsCSTQMf3m3wm5GFFFqfy8R9ofYaL0akj9Yyr2wQoMlkAc_g1dhbTCq0zZteJ9emqeLjH1P_wZFBjS58jZRh-wqR4ak4SbcJw), [2] (/goto?url=CAESZwHrOzAVwkWEdaMnU2huBbOpr0Mhh5sqDaAoRrUnh4Q2b9VweqgNQnJXA39hgYD-iFXfPTq81-1_q4mJuPiYSuCKKSrSWvKJ3Je4ypEvjfiHIdHtFXLtdru9kpgK_H63KeRU3GBKNu0)
1. 基本ヘッダー（メタデータ、サンプリングレートなどの情報）
2. パディング（著作権表記）（データの開始位置までを埋めるセクション）
3. オーディオデータ（ペイロード）（圧縮された音声フレームの連続）

1. 基本ヘッダー構造（Header Format）

ファイルの先頭から始まるヘッダー（通常 0x18 〜 0x2c バイト程度、拡張により変動）のレイアウトです。 [1] (/goto?url=CAESaQHrOzAVnjCECaaJD0fJ4IRZ7onx0SPpxYyzD7q95smiwrsCSTQMf3m3wm5GFFFqfy8R9ofYaL0akj9Yyr2wQoMlkAc_g1dhbTCq0zZteJ9emqeLjH1P_wZFBjS58jZRh-wqR4ak4SbcJw)

オフセット	サイズ (Byte)	型	説明
0x00	2	u16	マジックナンバ（シグネチャ）
通常は 0x8000 固定。
0x02	2	u16	データ開始オフセット
ヘッダーとパディングを含んだ、実際の音声データが始まる絶対位置。
0x04	1	u8	エンコード形式 (Encoding Type)
ADXは 0x03 や 0x04 ですが、AHXの場合は 0x11 が入ります。
0x05	1	u8	ブロックサイズ
1フレーム（ブロック）あたりのバイト数。
0x06	1	u8	チャンネル数
ボイス用のため通常は 1（モノラル）または 2（ステレオ）。
0x07	1	u8	予約領域 / バージョン情報
0x08	4	u32	サンプリング周波数 (Hz)
例: 32000 (0x00007D00) など。
0x0C	4	u32	総サンプル数
0x10	2	u16	ハイパスフィルタ係数（通常無視可能）
0x12	1	u8	暗号化フラグ
0x08 の場合は簡易XOR暗号化が施されています。
0x13	1	u8	予備
0x14	4	u32	ループ有無 / ループ開始位置（非ループ時は 0）


2. パディングと著作権表記

基本ヘッダーの直後から、0x02 で指定された「データ開始オフセット」の手前まではパディング領域です。
ここにはCRI社のシグネチャ（ASCIIコード）が含まれるのが特徴です。 [1] (/goto?url=CAESaQHrOzAVnjCECaaJD0fJ4IRZ7onx0SPpxYyzD7q95smiwrsCSTQMf3m3wm5GFFFqfy8R9ofYaL0akj9Yyr2wQoMlkAc_g1dhbTCq0zZteJ9emqeLjH1P_wZFBjS58jZRh-wqR4ak4SbcJw)
• シグネチャ文字列: (c)CRI
バイナリをテキストエディタやバイナリエディタで開いた際、ヘッダー付近にこの文字列が見えれば、CRI系のファイル（ADX/AHX）であると一目で判別できます。 [1] (/goto?url=CAESaQHrOzAVnjCECaaJD0fJ4IRZ7onx0SPpxYyzD7q95smiwrsCSTQMf3m3wm5GFFFqfy8R9ofYaL0akj9Yyr2wQoMlkAc_g1dhbTCq0zZteJ9emqeLjH1P_wZFBjS58jZRh-wqR4ak4SbcJw)

3. オーディオデータセクション

データ開始オフセット以降は、固定長ブロックに分割された音声ストリーム（MPEG-2 Audio レイヤ構造をベースに変調されたデータ）が並びます。 [1] (/goto?url=CAESXAHrOzAVl0fznh812QoRFQKRFNOUcnBqx2f7iK46mTY-Xs59jUxZr1LQvOzRXH3_p2V3V2x_FH2XBg28bmjC5beFgOomgN2rE7zw3LnidpIGS2I1BSSeXuRhDM6m), [2] (/goto?url=CAESZwHrOzAVwkWEdaMnU2huBbOpr0Mhh5sqDaAoRrUnh4Q2b9VweqgNQnJXA39hgYD-iFXfPTq81-1_q4mJuPiYSuCKKSrSWvKJ3Je4ypEvjfiHIdHtFXLtdru9kpgK_H63KeRU3GBKNu0)
• 終端ブロック（Dummy Frame）:
ストリームの最後には、終了を示す特殊なダミーフレーム（スケール値 0x8001 など）が配置され、デコーダーに再生終了を伝えます。 [1] (/goto?url=CAESaQHrOzAVnjCECaaJD0fJ4IRZ7onx0SPpxYyzD7q95smiwrsCSTQMf3m3wm5GFFFqfy8R9ofYaL0akj9Yyr2wQoMlkAc_g1dhbTCq0zZteJ9emqeLjH1P_wZFBjS58jZRh-wqR4ak4SbcJw)

💡 補足：NDSにおける展開

NDSのゲームアーカイブ（例：.afs や .msnd など独自形式のパックファイル）を展開すると、中に独立した .ahx や .adx が格納されているケースがよくあります。
これらはオープンソースのオーディオデコーダーツールである vgmstream (GitHub) や、FFmpeg を使用することで、直接PCで再生可能な .wav 形式等に変換・解析することができます。 [1] (/goto?url=CAESeQHrOzAVqdGLaJyOmN2okt8JK2yQh_Fr0iew28WHX4L0KYB35HraDNmtpS9WJUx3uEeMz8_0ovkIGOcGOHGX1kiwGHaKkEYC7femdL1ho0HV2Z9yOcMzllqwkGCDs-9pERsm7DcdwPbUuBbcNqnVo60eOvU4oGji5nI), [2] (/goto?url=CAEShQEB6zswFeJxFxIaTXN8fYeSUPnr4pxjm4wCD-u9XgYogUvpNH_tyFL8RzfmW3kdO-8wgfIYO-KwgkpbJ5xiIHA1fhwTVWAyg-EdOwosxeUBtp3wzxgKKVOrpW65u8sGeVYFwPr-fzFfZlLyuD6h7HwuRgXGk58kK7805iQGmfdZ2f0QCniY), [3] (/goto?url=CAESZwHrOzAVwkWEdaMnU2huBbOpr0Mhh5sqDaAoRrUnh4Q2b9VweqgNQnJXA39hgYD-iFXfPTq81-1_q4mJuPiYSuCKKSrSWvKJ3Je4ypEvjfiHIdHtFXLtdru9kpgK_H63KeRU3GBKNu0), [4] (/goto?url=CAESXAHrOzAVl0fznh812QoRFQKRFNOUcnBqx2f7iK46mTY-Xs59jUxZr1LQvOzRXH3_p2V3V2x_FH2XBg28bmjC5beFgOomgN2rE7zw3LnidpIGS2I1BSSeXuRhDM6m), [5] (/goto?url=CAESYwHrOzAVYbOQAwbGdVP9lN4BAz34Scq8SflG-ettCwRKFQcaBAZApiTpfY8FuLp30cU28VvlviIm6D5rR4ZZsQAsLnA-3-FrErw0m8Wns2B0xJq4B8bn_h-cEXe7gq_Sh4hYSg)
今後の作業のために、特定のゲームタイトルや、解析に使用したいプログラミング言語（C++, Python等）などの前提条件はありますか？必要であれば、さらに具体的なデコードロジックやスクリプトの書き方についてご案内できます。

```

## フレミング ボイスデータダンプ

```lua
local function search(query)
    local d = htob(query)
    for i = 6, 0x9 do
        local a = 0x01000000*i
        local found, addr = lib.findr(a, a+0x00ffffff, d, nil, true)
        if found then
            print(string.format("local begin = 0x%08X", addr))
            local _f, addr2 = lib.findr(addr + 0x40, addr + 0x000fffff, ascii("CRI"), nil, true)
            assert(_f)
            addr2 = addr2 + 4
            print(string.format("local iend = 0x%08X", addr2))
            return addr, addr2
        end
    end
    return nil, nil
end

local function dump_voice(idx, query, skip_writing)
    print(string.format("VOICE %02d", idx))
    local begin, iend = search(query)
    assert(begin and iend, "not found")
    assert(r8r(iend) == 0 and r8r(iend + 1) == 0xff, "iend may be wrong?")
    if skip_writing then return end
    local f = io.open(lib.path.output(string.format("fab_voices/i%02d.ahx", idx)), "wb")
    f:write(longchars(lib.romrarr(begin, iend))) f:close()
end

-- i01(私英語ダメなの)
dump_voice(1, "800000201100000100005FE20001B8330000060000000000000000000000286329435249FFF5E0C066669180080000000001801653267851ACDA572E584F9E55718D9AE76BDEF7BDEF7BDEF7BBBBBBAD8D7BDEF839EF6BDEF7777775B1B0986EBDB02E5C28CFACF918A8A30B56C91B29F366991F582A1D67A25EF7BE2F8293C4")

-- i02(静かにしたまえ)
dump_voice(2, "800000201100000100005FE2000233EF0000060000000000000000000000286329435249FFF5E0C0666691828000000000065F05B44B85B9E36DFB61BE38E78DBA5F53DEF7BDEF7BDEF7BBBBBBAD8D7CF7BDEF83DEE7BDEEEEEEEB635F3D73756AC631EC74D5BB837B6C3CD660C0999D841335CEFA6558C45CD7BD2F4C28593B")

-- i03(初めに言っておくが)
dump_voice(3, "800000201100000100005FE2000143490000060000000000000000000000286329435249FFF5E0C06666918000000000001DEF573DD9DFAE1AE3B6193DEF7BDEF7BDEF7BBBBBBAD8F7BDEF83DCD7B9EEEEEEEB649A785CCA0452884E25500F0D202917D71151C35BA7DAC01CE881DB2A35F1BD3BABBD3C4110D352BAF68A7752")

-- i04(グローバルな視点なくして)
dump_voice(4, "800000201100000100005FE20000F5680000060000000000000000000000286329435249FFF5E0C0666691800000000000187F5725F4D9A5D5697696EB7DEF7BDEF7BDEF7BDEEEEEEEB63DEF7BDCF845F07BBBBBC2D8D845E5DCFCD9C60E74D54B1EF9915B50D47710A01EB2232E751CD6BDD37CA110AE90BAD9F07CE083122B")


-- i05(諸君が英語を)
dump_voice(5, "800000201100000100005FE2000199640000060000000000000000000000286329435249FFF5E0C0666691800000000000047FD344B7658DDA61A61A63B64F7BDEF7BDEF7BDEEEEEEEB63DEF7BDEF7C1EF6BBBBBBAD908A20E33A92701956D3622A84CF649D7EBA3670283A00AB08BD7456D364C98B2C0CA88A67B99B8AA65B4")


-- i06(世界から)
dump_voice(6, "800000201100000100005FE20000D92C0000060000000000000000000000286329435249FFF5E0C06666918000000000001F975926576986D8E9867864F7BDEF7BDEF7BDEEEEEEEB63DEF7BDEF7BDEF8BBBBBBAD8E7D9CECC5E8A6D2EC8EB6E341E08A41090BB93ABC3858E0D4AA1194A8378CAC74CB4BAB9CD8164AC221913B")

-- i07(私との出会いを)
dump_voice(7, "800000201100000100005FE200020A440000060000000000000000000000286329435249FFF5E0C0666691A20C88A202000000000025512F95AF67647AE13EB9D7A614E99D1B5D5EF9DFB677ED959B6567195FB697F395FADFCE57BDEF7BDEF7BDEF7BBBBBBAD8F9AD7CD6B5AD6BDEF7C1EF7B5EE83BBBBBAD8F9AD7CD6B5AD6")

-- i08(グッドラック)
dump_voice(8, "800000201100000100005FE2000063480000060000000000000000000000286329435249FFF5E0C0666691800080800000020795D3397BF9592696D59556E946D76F9DF7BDEF7BDEF7BDEF7BBBBBBAD8D6BDEE7BE2F735EF83BBBBBAD8D6CD077F52A03992CC404CABD396D7998BA3388D9B219CD38D2566B9CE9910C7BDEC84")


-- i09(さて、目標と時間は)
dump_voice(9, "800000201100000100005FE20001670D0000060000000000000000000000286329435249FFF5E0C06666918000000000001D7DDB3DB7E786D8E1AE0F7BDEF7BDEF7BDEEEEEEEB63DEF7BDEF7BDEF7BBBBBBAD8C8F1CCA42329406E52EF2B5B9C73AEBC84E8C63AECC5B20E94DA9929C73B0511AF0E92C29184CBD71BD21839A4")


-- i10(目標を達成するには)
dump_voice(10, "800000201100000100005FE20001A3A10000060000000000000000000000286329435249FFF5E0C0666691800000200000015E164F1617D3761BE3BE3A6786DA5EF7BDEF7BDEF7BDEEEEEEEB635EF7BDEE7BDEF7BDDD9DE16C6BE0A8AD507AA136A013CF0E0AA63A6E0DB064E462782529D516A5672B3E32845D6D16B0342AB1")

-- i11(おわかりかな)
dump_voice(11, "800000201100000100005FE20000741E0000060000000000000000000000286329435249FFF5E0C06666918008000000001FFB774D9E1B5FA5FADF95F8F77BDEF7BDEF7BDEF7BBBBBBAD8D7BDEF7BDF07BDF07777775B1AE7ED8D555548E4ACA111AAD698706FBED012B2794AAF1ABA6BD41A6A5892DDA39BD641904D0911190")

-- i12(結構。物分かりの)
dump_voice(12, "800000201100000100005FE200018AB90000060000000000000000000000286329435249FFF5E0C066669180000000000005DFD744976B7DFA61B63D60F7BDEF7BDEF7BDEEEEEEEB63DEF7BDEF73DEF7BBC3BBAD91896114B12D7320F814DC5689888E5AED8B115AB01CAD3095324B7520BAC152D2EF0E7B50899AC2599E63BC")

-- i13(とはいえ、君たちが)
dump_voice(13, "800000201100000100005FE200023A790000060000000000000000000000286329435249FFF5E0C0666691B6DEAAAAAAAAA0208820000008015508E3827962BE4769921AE48E69E991F923CE8A6D92D9ABB646EDA2FBE4AF1AB5BE4BED9B7B68CF9A33BE8DF3A39C68CED9BBBBBC6CD75B3FD6ACEFAB5CECC3DEF7BDEF7BDEF7")

-- i14(1名、店を経営している人が)
dump_voice(14, "800000201100000100005FE20001B39D0000060000000000000000000000286329435249FFF5E0C066669190008020000001E8715CD167859A5FBDD8E1C657E99DFCDD7ED95EF7BDEF7BDEF7BDEEEEEEEB635AD7BDEF7C1EE6BDCF7777875B1AD6C5E89ECAA1AD89644A551C8696914127A1876D830755C3A24F12910A5356E7")
```

## video19 ジョバババ再現的なカット

```lua
-- フレミングイベント
-- 事前に作成したahxファイルを順に書き込んでいく

local update = (function()
    local idx = 0
local addrs = {
-- VOICE 01(私日本語ダメなの)
{0x08354600, 0x0835DB6F, 1},
-- VOICE 02
{0x0626B200, 0x06275C47, 1},
-- VOICE 03
{0x06275E00, 0x0627C2FF, 1},
-- VOICE 04
{0x0627C400, 0x06281819, 1},
-- VOICE 05
{0x06281A00, 0x06289CAD, 3},
-- 実際はここまで、06以降は撮らなかった
-- VOICE 06
{0x06289E00, 0x0628E5F8, 1},
-- VOICE 07
{0x0628E600, 0x06298948, 1},
-- VOICE 08
{0x06298A00, 0x0629A72A, 1},
-- VOICE 09
{0x0629A800, 0x062A1A5A, 1},
-- VOICE 10
{0x062A1C00, 0x062AA4A6, 1},
-- VOICE 11
{0x062AA600, 0x062ACBAD, 1},
-- VOICE 12
{0x062ACC00, 0x062B3CF8, 1},
-- VOICE 13
{0x062B3E00, 0x062BF245, 1},
-- VOICE 14
{0x062BF400, 0x062C7A72, 1},
}
    return function()
        idx = idx + 1
        local path = lib.path.output(string.format("fab_voices/o%02d.ahx", idx))
        local voice = addrs[idx]
        if not voice then print("voice out of bound") return end
        local begin = assert(voice[1])
        local rate_change = voice[3]
        local file = io.open(path, "rb")
        if not file then print("not found path " .. path) return end
        local content = file:read("a")
        file:close()
        local bytes = {}
        for i = 1, #content do
            bytes[i] = content:byte(i)
        end
        for i = 1, 0x30 do
            table.insert(bytes, 0xff)
        end
        lib.romwarr(begin, bytes)
        if rate_change then
            local i = begin + 10
            local v = (r8r(i) << 8) | r8r(i+1)
            if rate_change == 2 and v % 2 == 0 then
                v = v // 2
                w8r(i, v >> 8)
                w8r(i+1, v & 0xff)
            elseif rate_change == 3 and v % 3 == 0 then
                v = v // 3
                w8r(i, v >> 8)
                w8r(i+1, v & 0xff)
            elseif rate_change == 4 and v % 3 == 0 then
                v = v * 2 // 3
                w8r(i, v >> 8)
                w8r(i+1, v & 0xff)
            end
        end
        print(string.format("idx %d written", idx))
    end
end)()

local key = DS.key.lis("L")
function loop()
    if key:update() then
        update()
    end
end


local go = (function()

local commands = {
[0x0] = 0, -- NOP
[0x14] = 1, -- MTX_RESTORE
[0x1b] = 3, -- MTX_SCALE
[0x20] = 1, -- COLOR
[0x21] = 1, -- NORMAL
[0x22] = 1, -- TEXCOORD
[0x23] = 2, -- VTX_16
[0x24] = 1, -- VTX_10
[0x25] = 1, -- VTX_XY
[0x26] = 1, -- VTX_XZ
[0x27] = 1, -- VTX_YZ
[0x28] = 1, -- VTX_DIFF
[0x40] = 1, -- BEGIN_VTXS
[0x41] = 0, -- END_VTXS
}

local function is_command(value)
    for j = 0, 3 do
        if not commands[(value >> (8*j)) & 0xff] then
            return false
        end
    end
    return true
end

---@type fun(begin: int, incEnd: int)
return function(begin, incEnd)

local i = begin
while i <= incEnd do
    local v = r32(i)
    i = i + 4
    if is_command(v) then
        for j = 0, 3 do
            local _v = (v>>(8*j)) & 0xff
            local pnum = commands[_v]
            if _v == 0x23 then
                -- print(string.format("found 0x%08X", i))
                -- y座標のみいじる
                -- add16(i+4, rand(1, 5)*0x200)
                add16(i+4, 0x4000)
                w16(i, 0x8000-r16(i)*8)
                -- w16(i+2, r16(i)*2)
            end
            i = i + pnum * 4
        end
    end
end
end
end)()

-- go(0x228C2D0, 0x229FFFF)
go(0x2282200, 0x2289FFF)

lib.warr(0x0215BA65, htob( -- 静かにしたまえ 無駄にする時間...
"90c3b6c6bcc0cfb40a96b391cac6bdd98e9e8ad4ca0a8c4ec0c1c6cab1afc3d3a481488148814881488148050505"
))

lib.warr(0x0215BAED, htob( -- \C9グロろろろろろろろろろろ...
"1b43391b4bb8dedb1b48dbdbdbdbdbdbdbdbdbdbdbdbdbdbdbdbdbdb0a1b4bcadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecade0a1b4bcadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecadecade1b481b4331050505"
))

lib.irume.start(function()
    local base = 0x03E18DD0
    local p1 = 0x1b
    local p2 = 0x14
    local t = 0x28
    local as = {}
    local modes = {}
    local ds = {}
    for i = 0, 16 do
        as[i] = base + i*0x40
        modes[i] = 0
        ds[i] = 4
    end
    local r = RC(30)
    local m = lib.at(0x03000000)
    return function()
        for i, a in pairs(as) do
            if r() then
                modes[i] = rand(0, 2)
                ds[i] = rand(1, 10) * 4
            end
            if modes[i] == 0 and rand(1,1)==1 then
                w16(a+p2, rand(-10, 10)*0x10)
            elseif modes[i] == 1 then
                add16(a+p2, ds[i])
                if within(r16(a+p2), 0x800, 0x8ff) then
                    w16(a+p2, 0xf800)
                end
            elseif modes[i] == 2 then
                add16(a+p2, -ds[i])
                if within(r16(a+p2), 0xf700, 0xf7ff) then
                    w16(a+p2, 0x800)
                end
            end
            w8(a+p1, rand(-4, 4))
            m:with(a+t):T8(8, 8)
        end
    end
end)


-- ======================
-- 以降、少し遅れて実行する
-- ======================


local JNT0_addrs = {
0x022A8AA0, -- 冒頭
0x022AF7C4, -- 諸君が英語をマスターしなければ...
0x022B3BF0, -- 初めに言っておくが
0x022B6244, -- さて、目標と時間は常にセット
0x022B7CB0, -- 静かにしたまえ
0x022BAC50, -- グローバルな視点なくして&世界から取り残される

-- 0x022C85FC, -- ?
-- 0x022C95A4, -- ?
-- 0x022CA3A4, -- ?
-- 0x022CB2DC, -- ?
-- 0x022CBE4C, -- ?
-- 0x022CCAFC, -- ?
-- 0x022CD7E4, -- ?
-- 0x022CE940, -- ?
-- 0x022D19CC, -- ?
-- 0x022D1B5C, -- ?
-- 0x022D1F7C, -- ?
-- 0x022D292C, -- ?
-- 0x022D3C7C, -- ?
-- 0x022D3E5C, -- ?

}

local addrs = {}
for _, a in pairs(JNT0_addrs) do
    local _a = Nitro.read_JNT0(a, lib.path.dummy()).addrs_tr
    for _, v in pairs(_a) do
        table.insert(addrs, v)
    end
end

local origs = {}
for _, a in pairs(addrs) do
    origs[a] = r8(a)
    origs[a+1] = r8(a+1)
end

local r = RC(5)
local r2 = RC(30)
SET_LOOP("MOVE", function()
    for _, a in pairs(addrs) do
        if r() then
            add8(a + rand(0,1), rand(-3, 3))
        end
        if r2() then w8(a, origs[a]) end
        if r2() then w8(a+1, origs[a+1]) end
    end
end)


-- バグテキストの直後のテキストを正常に戻す
lib.warr(0x0215BA90, htob( -- 初めに言っておくが、 今、ビジ...
"8f89d2c68cbeafc3b5b8b6dea40a8da1a41b4bcbdebcdec8bd1b48c990a28a45c3decaa4050505"
))

lib.warr(0x0215BB25, htob( -- 世界から 取り残されることにな...
"90a28a45b6d70a8ee6d88e63bbdad9bac4c6c5d9050505"
))
```

## フレミング 顔座標 & 机撤去

```
0x022A8B80 => y座標
0x022A8B84 => z座標
0x022A8B88 => x座標
w32(0x023155C0, 0x100000) -- 机を撤去
```

## フレミング アニメーションアドレス

```lua
local fr_addrs = {
0x022A8AA0, -- 冒頭
0x022AF7C4, -- 諸君が英語をマスターしなければ...
0x022B3BF0, -- 初めに言っておくが
0x022B6244, -- さて、目標と時間は常にセット
0x022B7CB0, -- 静かにしたまえ
0x022BAC50, -- グローバルな視点なくして&世界から取り残される
0x022C85FC, -- 初めに言っておくがのトゥース止めポーズ
0x022CB2DC, -- グローバルな視点 の止めポーズ
0x022C95A4, -- さて、目標と時間はの止めポーズ
0x022CD7E4, -- グッドラック, おわかりかな
0x022C1500, -- 結構 ものわかりがよい生徒で助かるよ
0x022CCAFC, -- 結構 ものわかりがよい の止めポーズ
0x022CE940, -- ゆっくりと名簿を読み上げましたの直後の主人公名を読む瞬間のポーズ(浜井…恵？)
}
```

## video20 超笑顔 & パワーワード?

```lua
local addrs = {
0x02281B30, -- 顔
0x02287DE8, -- 髪
0x0228B2A0,
0x02318018,
0x0231D658,
}

local res = Nitro.read_MDL0(addrs[1], 0)
local mesh = res.addrs_mesh
local vs = {}
local count = {}
local len = #mesh
printf("len: %d", len)
for i = 1, len do
    printf("idx %d", i)
    local xmin, xmax = 100000000, -100000000
    local ymin, ymax = 100000000, -100000000
    local zmin, zmax = 100000000, -100000000
    Nitro.filter_mesh(mesh[i].begin, mesh[i].iend, function(addr, cmd, pnum, name)
        count[name] = (count[name] or 0) + 1
        if name ~= MESH_COMMANDS.VTX_16 then return end
        assert(addr%2==0)
        local x, y, z = r16(addr+0), r16(addr+2), r16(addr+4)
        local _x, _y, _z
        _x = intToFixFloat(x, 3, 12)
        _y = intToFixFloat(y, 3, 12)
        _z = intToFixFloat(z, 3, 12)
        xmin = math.min(xmin, _x) xmax = math.max(xmax, _x)
        ymin = math.min(ymin, _y) ymax = math.max(ymax, _y)
        zmin = math.min(zmin, _z) zmax = math.max(zmax, _z)
        local d = math.abs(_x) < 0.5 and 4*math.abs(_x) or 0
        -- local d = 0
        local __d = -8
        if math.abs(_x-__d) < 0.5 then d = d + 4*math.abs(_x-__d) end
        w16(addr+0, fixFloatToInt(_x*8, 3, 12))
        w16(addr+2, fixFloatToInt(_y*4+(_y < 0 and 0.1 or -0.1)+d, 3, 12))
        w16(addr+4, fixFloatToInt(_z*4+1, 3, 12))
    end)
    printf("x: [%f, %f]", xmin, xmax)
    printf("y: [%f, %f]", ymin, ymax)
    printf("z: [%f, %f]", zmin, zmax)
end
for name, c in pairs(count) do printf("%s: %d", name, c) end
local fr_addrs = {
0x022A8AA0, -- 冒頭
0x022AF7C4, -- 諸君が英語をマスターしなければ...
0x022B3BF0, -- 初めに言っておくが
0x022B6244, -- さて、目標と時間は常にセット
0x022B7CB0, -- 静かにしたまえ
0x022BAC50, -- グローバルな視点なくして&世界から取り残される
0x022C85FC, -- 初めに言っておくがのトゥース止めポーズ
0x022CB2DC, -- グローバルな視点 の止めポーズ
0x022C95A4, -- さて、目標と時間はの止めポーズ
0x022CD7E4, -- グッドラック, おわかりかな
0x022C1500, -- 結構 ものわかりがよい生徒で助かるよ
0x022CCAFC, -- 結構 ものわかりがよい の止めポーズ
0x022CE940, -- ゆっくりと名簿を読み上げましたの直後の主人公名を読む瞬間のポーズ(浜井…恵？)
}
for _, addr in pairs(fr_addrs) do
    local res = Nitro.read_JNT0(addr, 0)
    w32(res.tracks[1][5].CurveX_Const.addr, 0x1111)
    w32(res.tracks[1][5].CurveY_Const.addr, 0x1111) -- 34011くらいでようやくdeskの前へ
end
-- w32(0x022A8B80, 0x1111)-- C022A8B84 C022A8B88
-- w32(0x022B7D94, 0x1111)-- C022B7D98 C022B7D9C
w32(0x023155C0, 0x100000) -- 机を撤去


lib.irume.start(function()
    local base = 0x03E18DD0
    local p1 = 0x1b
    local p2 = 0x14
    local t = 0x28
    local as = {}
    local modes = {}
    local ds = {}
    local vol = 0x12
    local p = 0
    for i = 0, 16 do
        as[i] = base + i*0x40
        modes[i] = 0
        ds[i] = 4
    end
    local r = RC(3)
    local m = lib.at(0x03000000)
    local _d = {-2,-1,1,2}
    return function()
        if r() then p = p + _d[rand(1, #_d)] * 0x40 end
        for i, a in pairs(as) do
            w16(a+vol, -0x40)
            w16(a+p2, p)
        end
    end
end)


local update = (function()
    local idx = 0
local addrs = {
-- VOICE 01(私日本語ダメなの)
{0x08354600, 0x0835DB6F, 1},
-- VOICE 02
{0x0626B200, 0x06275C47, 1},
-- VOICE 03
{0x06275E00, 0x0627C2FF, 1},
-- VOICE 04
{0x0627C400, 0x06281819, 2},
-- VOICE 05
{0x06281A00, 0x06289CAD, 1},
-- VOICE 06
{0x06289E00, 0x0628E5F8, 1},
-- VOICE 07
{0x0628E600, 0x06298948, 1},
-- VOICE 08
{0x06298A00, 0x0629A72A, 2},
-- 実際はここまで、09以降は撮らなかった
-- VOICE 09
{0x0629A800, 0x062A1A5A, 1},
-- VOICE 10
{0x062A1C00, 0x062AA4A6, 1},
-- VOICE 11
{0x062AA600, 0x062ACBAD, 1},
-- VOICE 12
{0x062ACC00, 0x062B3CF8, 1},
-- VOICE 13
{0x062B3E00, 0x062BF245, 1},
-- VOICE 14
{0x062BF400, 0x062C7A72, 1},
}
    return function()
        idx = idx + 1
        local path = lib.path.output(string.format("fab_voices/video20/o%02d.ahx", idx))
        local voice = addrs[idx]
        if not voice then print("voice out of bound") return end
        local begin = assert(voice[1])
        local rate_change = voice[3]
        local file = io.open(path, "rb")
        if not file then print("not found path " .. path) return end
        local content = file:read("a")
        file:close()
        local bytes = {}
        for i = 1, #content do
            bytes[i] = content:byte(i)
        end
        for i = 1, 0x30 do
            table.insert(bytes, 0xff)
        end
        lib.romwarr(begin, bytes)
        if rate_change then
            local i = begin + 10
            local v = (r8r(i) << 8) | r8r(i+1)
            if rate_change == 2 and v % 2 == 0 then
                v = v // 2
                w8r(i, v >> 8)
                w8r(i+1, v & 0xff)
            elseif rate_change == 3 and v % 3 == 0 then
                v = v // 3
                w8r(i, v >> 8)
                w8r(i+1, v & 0xff)
            elseif rate_change == 4 and v % 3 == 0 then
                v = v * 2 // 3
                w8r(i, v >> 8)
                w8r(i+1, v & 0xff)
            end
        end
        print(string.format("idx %d written", idx))
    end
end)()

lib.actions.register("fab_video_20", lib.actions.KF.button("L"), {
function()
end,
function()
lib.warr(0x0215BA37, htob( -- 私、清水のバレンタイン・アキラ...
"8e84814190b49085c91b4bcadedaddc0b2dd1b4881451b4bb1b7d70a8ef68bc681411b4bcdded9cca7d11b4894c497708d558c82c3de0a8989bcded7dad9d6b3c6c5d8c0b2c5050505"
))
end,
function()
lib.warr(0x0215BA65, htob( -- デービス・ノゾミにしたまえ 先...
"1b4bc3de1b48815b1b4bcbdebd1b4881451b4bc9bfded01b48c6bcc0cfb40a90e69163c61b4bb1ccd8b61b488c6ec98c8cc6bdd98e9e8ad4ca0a89b4c0c1c6cab1afc3d381418a4f8e918c6e8b4395aa050505"
))
end,
function()
lib.warr(0x0215BA90, htob( -- 初めに「件名）お姉さん、大好き...
"8f89d2c681758c8f96bc816ab58e6fbbdd814191e58d44b781490a1b4bbcddccdfd91b48c51b4bcbdebcdec8bd1b488aa0d80abadeafc21b4bbade1b48815b1b4bbcdeacbd1b48c51b4bcededadb1b48d4dd050505"
))
end,
function()
lib.warr(0x0215BABA, htob( -- あっという間にデヴ炎上してるよ...
"b1afc4b2b38ad4c61b4bc3deb3de1b48898a8fe3bcc3d9d60a97a096caa68e86d4bdd8c3de8da18c8ecacfc0de0a94fcbcb2b58eab8b56a6bdd9c9c0de050505"
))
end,
function()
lib.warr(0x0215BAED, htob( -- 諸君が パンツ以外はいてないん...
"8f948c4eb6de0a1b4bcadfddc21b4888c88a4fcab2c3c5b2ddc0ded6c881630a8dc296b192b489dfc4ca89bdc997aac0dedbb38148050505"
))
end,
function()
lib.warr(0x0215BB25, htob( -- 黄色ベースの選択肢を選ぶと 「...
"89a990461b4bcdde1b48815b1b4bbd1b48c9914991f08e88a69149ccdec40a8175c5ddb690b688d38b43c0ded6c8816381760a90a2c9928681418ad488e1afc4d9dc8149050505"
))
end,
function()
lib.warr(0x0215BB3C, htob( -- 私との合コン大成功ですね ネバ...
"8e84c4c98d871b4bbadd1b4891e590ac8cf7c3debdc80a1b4bc8cade1b48815b88e194bdc4bbdad91b4bc4deb2c21b48c90a91e58d718a438e9e91e31b4bb5b5c0c61b4881451b4bd6bcb8c6050505"
))
end,
function()
lib.warr(0x0215BB6F, htob( -- グッドだらしない服装 胸にジー...
"1b4bb8deafc4de1b48c0ded7bcc5b2959e91950a8bb9c61b4bbcde1b48815b1b4bdd1b48c40a9497d9d3c9b6deb1d8cfbcc0050505"
))
end,
}):onStateChanged(function()update() end)
```
