
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

