
# ポケモン ブラック

## 上画面を崩壊させる(VRAM領域をいじる)

```lua
local arm9 = "ARM9 System Bus"

-- fill_in(0x6180000, 0x618ffff, 0x4f, "ARM9 System Bus")

for i = 0x6180000, 0x618ffff, 4 do
    w32(i, r32(i, arm9) | 0x00000001, arm9)
    -- w32(i, r32(i, arm9) | 0x01010101, arm9)
end
```

### イルームも追加で

```lua
lib.irume.start(function()
    local r = RC(30)
    local pet_vol = lib.at(0x03ebaa46)
    local pet_p = lib.at(0x03ebaa49)
    local pet_delay = lib.at(0x03ebaa47)
    local r2 = RC(90)
    return function()
        w8(0x03eba786, 0x60)
        w8(0x03eba791, 0x22)
        w8(0x03ebaa06, 0x80)
        w8(0x03ebaa11, 0x22)
        w8(0x03ebaa16, 0x80)
        if r() then
            pet_vol:w8(pet_vol:r8() > 0 and 0 or 0x80)
        end
        if r2() then
            pet_delay:w8(pet_delay:r8() > 0 and 0 or rand(0x10, 0x20))
        end
        pet_p:w8(0xff)
    end
end)
lib.irume.stop()

-- local _r = RC(90)
-- function loop()
--     if _r() then
        -- for i = 0x6180000, 0x618ffff, 4 do
        --     w32(i, r32(i, arm9) | rand(1, 0x1), arm9)
        -- end
--     end
-- end

for i = 0x6180000, 0x618ffff, 4 do
    -- w32(i, r32(i, arm9) | 0x00000001, arm9)
    w32(i, r32(i, arm9) | 0x08080808, arm9)
end
```

### 違うバリエーションのイルーム

```lua
lib.irume.start(function()
    local head = 0x03eba789
    ---@type AtObj[]
    local ms = {}
    for i = 1, 16 do ms[i] = lib.at(head + 0x40 * (i-1)) end
    local r = RC(20)
    return function()
        for _, v in pairs(ms) do
            if r() then
                v:w8(stou8(rand(-12, 12)))
            end
        end
    end
end)

-- for i = 0x6180000, 0x618ffff, 4 do
--     w32(i, r32(i, arm9) | 0x80040200, arm9)
-- end
local vs = {}
for i = 0x6180000, 0x618ffff, 4 do
    vs[i] = r32(i & 0xffffdfff, arm9) | 0x00000101
    -- vs[i] = r32(i + rand(-0x08, 0x08) + 0x20, arm9)
    -- w32(i, , arm9)
end
for i, v in pairs(vs) do w32(i, v) end
```


## アゴ化

```lua
local arm9 = "ARM9 System Bus"

CLS()

local vs = {}
local _jj = -1
local prev = ""
-- キャラクター部分: 6186940 -- 6186abf
for i = 0x6186800, 0x61897ff, 4 do
    local _i = i & 0x3ff
    if _i == 0 then _jj = _jj + 1 end
    if within(_i, 0x140, 0x2bf) then
        local ff = math.floor(_jj * 0.4)
        local aa
        local v = nil
        if ff < 4 then
        aa = (_i & 0xfcf) | (ff * 0x10)
        elseif _jj == 10 then
            local __i = _i & 0x7
            if within(_i, 0x1c0, 0x1df) and within(__i, 0x0, 0x3) then
                aa = (_i & 0xfcf) | (3 * 0x10)
            elseif within(_i, 0x1c0, 0x1df) and within(__i, 0x4, 0x7) then
                aa = (_i & 0xfcf) | (3 * 0x10)
            elseif within(_i, 0x200, 0x21f)  then
                aa = (_i & 0xfcf) | (3 * 0x10)
            elseif within(_i, 0x1e0, 0x1ff) and within(__i, 0x04, 0x7) then
                aa = (_i & 0xfcf) | (3 * 0x10)
            elseif within(_i, 0x220, 0x23f) then
                aa = (_i & 0xfcf) | (3 * 0x10)
            elseif within(_i, 0x140, 0x17f) or within(_i, 0x280, 0x2bf) then
                aa = (_i & 0xfcf) | (3 * 0x10)
            else
                aa = ((0x180 | (_i & 0x1f)) & 0xfcf) | (3 * 0x10)
                aa = aa & 0xfff8
            end
        else
            local __i = _i & 0x7
            if within(_i, 0x200, 0x20f) and within(__i, 0x0, 0x3) then
                aa = (_i & 0xfcf) | (3 * 0x10)
            elseif within(_i, 0x140, 0x17f) or within(_i, 0x280, 0x2bf) then
                aa = (_i & 0xfcf) | (3 * 0x10)
            else
                aa = ((0x180 | (_i & 0x1f)) & 0xfcf) | (3 * 0x10)
                aa = aa & 0xfff8
            end
        end
        vs[i] = v or r32(aa | 0x6186800)
    end
end
for i = 0x6189800, 0x6189fff, 4 do
    local _i = (i - 0x6189800) >> 4
    if within(_i, 24, 50) then
        vs[i] = 0x01010101
    elseif within(i & 0x3ff, 0x170, 0x2bf) then
        vs[i] = 0x01010101
    end
end
for i, v in pairs(vs) do w32(i, v, arm9) end

lib.timer.setTimeout(50, function()
    -- 強制フリーズ
    lib.fill_in(0x02210000, 0x0221ffff)
end)

-- そのときのイルーム
lib.irume.start(function()
    local head = 0x03eba749
    ---@type AtObj[]
    local ms = {}
    for i = 1, 16 do ms[i] = lib.at(head + 0x40 * (i-1)) end
    local r = RC(20)
    local pitch_c = Cnt(7, 24)
    return function()
        pitch_c()
        for _, v in pairs(ms) do
            v:reset()
            v:w8(stou8(pitch_c.i - 12))
            v:step(0x13):Tadd8(1, rand(-3, 0), 1)
        end
    end
end)

print("DONE " .. tostring(rand(0, 9999)))
```

## アゴ part2 (座標変換を実装して、もっときれいなアゴにした)

```lua

local arm9 = "ARM9 System Bus"

CLS()

local function MAIN()

local block_width = 0x08
local block_span = 0x40
local blockline_span = 0x400
local W = block_width * (blockline_span // block_span)
assert(block_span % block_width == 0)
assert(blockline_span % block_span == 0)

-- 仮想座標から物理アドレスへ
local function change_pos(x, y)
    local a, b, c = block_span, blockline_span, block_width
    local v = W*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % W, v2 // W
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06186000
end

local vs = {}
local _jj = -1
local prev = ""
local x, y = 0, 0
for i = 0x6186000, 0x61897ff, 4 do
    vs[change_pos(x, y)] = r32(change_pos(x, math.floor(y * 0.3)), arm9)
    x = (x + 4) % W if x == 0 then y = y + 1 end
end
for i, v in pairs(vs) do w32(i, v, arm9) end
end

local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end

lib.irume.start(function()
    local r = RC(30)
    local pet_vol = lib.at(0x03ebaa46)
    local pet_p = lib.at(0x03ebaa49)
    local pet_delay = lib.at(0x03ebaa47)
    local r2 = RC(90)
    local pitch1 = lib.at(0x03eba789)
    return function()
        if rand(1, span) == 1 or pitch1:r8() == 0 then pitch1:w8(stou8(rand(2, 9))) end
        w8(0x03eba786, 0x60)
        w8(0x03eba791, 0x22)
        w8(0x03ebaa06, 0x80)
        w8(0x03ebaa09, 0x02)
        w8(0x03ebaa11, 0x22)
        w8(0x03ebaa16, 0x80)
        if r() then
            pet_vol:w8(pet_vol:r8() > 0 and 0 or 0x80)
        end
        if r2() then
            pet_delay:w8(pet_delay:r8() > 0 and 0 or rand(0x10, 0x20))
        end
        pet_p:w8(0xff)
    end
end)
```

## ホドモエのおまけイルーム

```lua
lib.irume.start(function()
    local a1 = 0x03eba740
    local a2 = 0x03eba880
    local m1 = lib.at(0x03eba789)
    local r1 = RC(40)
    local rl = RL(150)
    local as = {
        0x03eba780,
        0x03eba7c0,
        0x03eba800,
        0x03eba840,
        0x03eba8c0,
        0x03eba900,
        0x03eba940,
        0x03eba980,
        0x03eba9c0,
        0x03ebaa00,
        0x03ebaa40,
        0x03ebaa80,
        0x03ebaac0,
    }
    return function()
        w8(a1 + 0x13, 0x01)
        w8(a1 + 0x15, 0x01)
        w8(a1 + 0x16, 0x01)
        w8(a1 + 0x17, 0xff)
        w8(a1 + 0x06, 0x40)
        if r1() then m1:w8(stou8(rand(-1, 2))) end
        if not rl() then return end
        for _, a in pairs(as) do
            if r1() then
                w8(a + 0x09, stou8(rand(-3, 3)))
            end
        end
    end
end)
```


## テキスト編集

- アドレス **0x0225b19b** 付近を調べる
- 文字コードは **UTF-16 LE**

```python
def C(s):
    return s.replace("\n", "\ufffe").replace("…", "\u2026").encode(encoding="utf-16le").hex()

C("チャンピオン") # この結果をコピペして、次のようにして検索する
```

```lua
local mes = lib.htob("<コピペしたバイト列>")
lib.find_all(0x0225b000, 0x0225bfff, mes)
```

例:

State 7
ボクは チャンピオンを 超える
-> 0x0225B194から

```plaintext
0x0225B190 ECD2 F8B6 DC30 AF30 6F30 0030 C130 E330 
                      ボ   ク   は   　   チ   ャ  
0x0225B1A0 F330 D430 AA30 F330 9230 0030 858D 4830
            ン   ピ   オ   ン   を   　   超   え  
0x0225B1B0 8B30 00F0 01BE 0000 6030 8C30 6B30 8230
            る   (ページ送り)   だ   れ   に   も
0x0225B1C0 0030 A08C 5130 8B30 5330 6830 6E30 6A30
            　   負   け   る   こ   と   の   な
0x0225B1D0 4430 FEFF 2F55 004E 2171 8C4E 6E30 0030
            い   \n   唯   一   無   二   の   　
0x0225B1E0 585B 2857 6830 0030 6A30 8A30 00F0 01BE
            存   在   と   　   な   り   (頁送り)
0x0225B1E0 0000 5930 7930 6630 6E30 0030 C830 EC30
                 す   べ   て   の   　   ト   レ
※ 0030 は全角空白。
半角空白 2000 も使ってよいが、若干幅が狭くなる
```

- 改行は 0xfeff (LE)
- ページ送りは 00f0 01be 0000
    - Aを押したら、そのまま次のアドレスを読み込む
    - つまり、テキスト改変で文字数が変動したら、その後ろもずらさないといけない
- 1行送りは 00f0 00be 0000
- …(3点)は 0x2620 (LE)


## 帽子化 & テキストバグ

```lua
local arm9 = "ARM9 System Bus"

CLS()

local function MAIN()

local block_width = 0x08
local block_span = 0x40
local blockline_span = 0x400
local W = block_width * (blockline_span // block_span)
assert(block_span % block_width == 0)
assert(blockline_span % block_span == 0)

-- 仮想座標から物理アドレスへ
local function change_pos(x, y)
    local a, b, c = block_span, blockline_span, block_width
    local v = W*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % W, v2 // W
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06183800
end

local vs = {}
local _jj = -1
local prev = ""
local x, y = 0, 0
for i = 0x6183800, 0x61897ff, 4 do
    vs[change_pos(x, y)] = r32(change_pos(x, math.floor(y * 0.3)) + 0x800, arm9)
    x = (x + 4) % W if x == 0 then y = y + 1 end
end
for i, v in pairs(vs) do w32(i, v, arm9) end
end

local function text1()
-- ボクは　チョ～～～～～～ン！？
lib.warr(0x0225B194, lib.htob("dc30af306f300030c130e7305eff5eff5eff5eff5eff5efff33001ff1fff"))

-- だれにも　化けることのない 唯一の　ｳﾎ存在と　なり
lib.warr(0x0225B1B8, lib.htob("60308c306b3082300030165351308b30533068306e306a304430feff2f55004e6e30003073ff8eff585b2857683000306a308a30"))

-- すべてのキレーダナーに ポケ物を　解放させりゅ！
lib.warr(0x0225B1F2, lib.htob("5930793066306e30ad30ec30fc30c030ca30fc306b30feffdd30b130697292300030e3893e6555305b308a30853001ff"))

-- キミが　グヘヘポケモンと いつまでも　デブ
lib.warr(0x0225B228, lib.htob("ad30df304c300030b030d830d830dd30b130e230f3306830feff443064307e30673082300030c730d630"))

-- そう　ﾎｲむなら 各地の　ジバにゃ姫……♥
lib.warr(0x0225B258, lib.htob("5d30463000308eff72ff80306a308930feff045430576e300030b830d0306b308330eb59262026206526"))

-- ヌケモンリーりえ！　　　　
lib.warr(0x0225B288, lib.htob("cc30b130e230f330ea30fc308a30483001ff0030003000300030"))

-- そこで　ボクを　褒めてみせるんだ
lib.warr(0x0225B2A8, lib.htob("5d30533067300030dc30af30923000301289813066307f305b308b3093306030"))
end
local function text2()
-- それほどの 熱い　気持ちで　なければ
lib.warr(0x0225B19C, lib.htob("5d308c307b3069306e30feffb17144300030176c01636130673000306a3051308c307030"))

-- ボクは　ｳﾋ幸せです！
lib.warr(0x225B1C6, lib.htob("dc30af306f30003073ff8bff785e5b306730593001ff"))
end

local text_trigger_mode = 0

local function update_trigger()
    if text_trigger_mode == 0 and r16(0x0225B19C) == 0x30c1 then
        text1()
        text_trigger_mode = 1
    elseif text_trigger_mode == 1 and r16(0x0225B19C) == 0x305D then
        text2()
        text_trigger_mode = 2
    end
end


local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    update_trigger()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        print("AUTO MODE END")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end

lib.irume.start(function()
    local head = 0x03eba740
    local as = {}
    for i = 0, 16 do as[i] = head + 0x40*i end
    local c = Cnt(8, 6)
    return function()
        c()
        w8(as[0] + 0x7, 1)
        for i = 0, 16 do
            w8(as[i] + 0x0f, c.i*2)
        end
    end
end)
```

## デブ化？

```lua

local arm9 = "ARM9 System Bus"
CLS()

local function MAIN()

local block_width = 0x08
local block_span = 0x40
local blockline_span = 0x400
local W = block_width * (blockline_span // block_span)
assert(block_span % block_width == 0)
assert(blockline_span % block_span == 0)

local function round(x)
    return math.floor(x + 0.5)
end

local function lerp(x, w, b)
    local _w = w * 0.5
    local _bi = 1.0 / b
    local v = round((x - _w) * (w * _bi) + _w)
    if v < 0 then return 0
    elseif v >= w then return w-1
    else return v
    end
end

-- 仮想座標から物理アドレスへ
local function change_pos1(x, y)
    local a, b, c = block_span, blockline_span, block_width
    local v = W*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % W, v2 // W
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06183800
end
-- 目の部分
local function change_pos2(x, y)
    x = x - 0x28
    y = y - 0x40
    -- local a, b, c = block_span, blockline_span, block_width
    local a, b, c = 0x40, 0x180, 0x08
    local _w = c * (b // a)
    local v = _w*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % _w, v2 // _w
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06189800
end
local function change_pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return change_pos2(x, y)
    else return change_pos1(x, y)
    end
end

local vs = {}
local _jj = -1
local prev = ""
local x, y = 0, 0
for i = 0x6183800, 0x61897ff, 4 do
    vs[change_pos(x, y)] = r32(change_pos(lerp(x, W, W*2.0), y) + 0x1400, arm9)
    x = (x + 4) % W if x == 0 then y = y + 1 end
end
for i, v in pairs(vs) do w32(i, v, arm9) end

end

local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end

lib.irume.start(function()
    local head = 0x03eba740
    local as = {}
    local poses = {}
    for i = 0, 18 do
        as[i] = head + 0x40*i
        poses[i] = -1
    end
    local pr = RC(90)
    local pr2 = RC(60)
    return function()
        for i = 0, 18 do
            if poses[i] < 0 or pr() then
                poses[i] = r32(as[i] + 0x24)
            end
            if poses[i] > 0 and pr2() then
                w32(as[i] + 0x24, poses[i])
                w8(as[i] + 0x0f, stou8(rand(-4, 4)))
            end
        end
    end
end)
```

<details>
<summary>video3のバグテキスト</summary>
<div>


```plaintext

trigger: 0x0225B19C (30C1 1回目, 305D 2回目)

0x0225B194
ボクは　チャンピオンを　超える
>
ボクは　チョ～～～～～～ン！？
dc30af306f300030c130e7305eff5eff5eff5eff5eff5efff33001ff1fff

0x0225B1B8
だれにも　負けることのない
唯一無二の　存在と　なり
>
だれにも　化けることのない
唯一の　ｳﾎ存在と　なり
60308c306b3082300030165351308b30533068306e306a304430feff2f55004e6e30003073ff8eff585b2857683000306a308a30

0x0225B1F2
すべての　トレーナーに
ポケモンを　解放させる！
>
すべてのキレーダナーに
ポケ物を　解放させりゅ！
5930793066306e30ad30ec30fc30c030ca30fc306b30feffdd30b130697292300030e3893e6555305b308a30853001ff

0x0225B228
キミが　ポケモンと
いつまでも　一緒……！
>
キミが　グヘヘポケモンと
いつまでも　デブ
ad30df304c300030b030d830d830dd30b130e230f3306830feff443064307e30673082300030c730d630

0x0225B258
そう　望むなら
各地の　ジムバッジを　集め
>
そう　ﾎｲむなら
各地の　ジバにゃ姫……♥
5d30463000308eff72ff80306a308930feff045430576e300030b830d0306b308330eb59202620266526
0x0225B288
ポケモンリーグに　向かえ！
>
ヌケモンリーりえ！　　　　
cc30b130e230f330ea30fc308a30483001ff0030003000300030

0x0225B2A8
そこで　ボクを　とめてみせるんだ
>
そこで　ボクを　褒めてみせるんだ
5d30533067300030dc30af30923000301289813066307f305b308b3093306030

0x0225B19C
それほどの
強い　気持ちで　なければ
>
それほどの
熱い　気持ちで　なければ
5d308c307b3069306e30feffb17144300030176c01636130673000306a3051308c307030
0x225B1C6
ボクは　とめられないよ
>
ボクは　ｳﾋ幸せです！
dc30af306f30003073ff8bff785e5b306730593001ff
```

</div>
</details>


---


## カッパ顔？

```lua

local arm9 = "ARM9 System Bus"
CLS()

local function MAIN()

local block_width = 0x08
local block_span = 0x40
local blockline_span = 0x400
local W = block_width * (blockline_span // block_span)
assert(block_span % block_width == 0)
assert(blockline_span % block_span == 0)

local function round(x)
    return math.floor(x + 0.5)
end

local function lerp(x, w, b)
    local _w = w * 0.5
    local _bi = 1.0 / b
    local v = round((x - _w) * (w * _bi) + _w)
    if v < 0 then return 0
    elseif v >= w then return w-1
    else return v
    end
end

-- 仮想座標から物理アドレスへ
local function change_pos1(x, y)
    local a, b, c = block_span, blockline_span, block_width
    local v = W*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % W, v2 // W
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06183800
end
-- 目の部分
local function change_pos2(x, y)
    x = x - 0x28
    y = y - 0x40
    -- local a, b, c = block_span, blockline_span, block_width
    local a, b, c = 0x40, 0x180, 0x08
    local _w = c * (b // a)
    local v = _w*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % _w, v2 // _w
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06189800
end
local function change_pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return change_pos2(x, y)
    else return change_pos1(x, y)
    end
end

local ys = 0x5c
local ye = 0x70
local _y_b = ye - ys
assert(_y_b % 2 == 0)
local _hy_b = _y_b >> 1
local function y_scale(y)
    if y < _hy_b then
        return -2*y + _y_b
    else
        return 2*y - _y_b
    end
end

local vs = {}
local _jj = -1
local prev = ""
local x, y = 0, 0
for i = 0x6183800, 0x61897ff, 4 do
    if within(x, 0x28, 0x57) and within(y, ys, ye) then
    vs[change_pos(x, y)] = r32(change_pos(x, y_scale(y-ys) + ys), arm9)
    end
    x = (x + 4) % W if x == 0 then y = y + 1 end
end
for i, v in pairs(vs) do w32(i, v, arm9) end

end


local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end

lib.irume.start(function()
    local head = 0x03eba740
    local as = {}
    for i = 0, 16 do as[i] = head + 0x40*i end
    local c = Cnt(8, 6)
    local m = lib.at(head)
    return function()
        c()
        for i = 0, 16 do
            m:with(as[i] + 0x1c):Tadd8(1, rand(-9, -1), 1)
            w8(as[i] + 0x0f, c.i*2)
        end
    end
end)


```

## video4のやつ(ガリガリ & ムスッとした顔)

```lua


local arm9 = "ARM9 System Bus"
CLS()

local function MAIN()

local block_width = 0x08
local block_span = 0x40
local blockline_span = 0x400
local W = block_width * (blockline_span // block_span)
assert(block_span % block_width == 0)
assert(blockline_span % block_span == 0)

local function round(x)
    return math.floor(x + 0.5)
end

local function lerp(x, w, b)
    local _w = w * 0.5
    local _bi = 1.0 / b
    local v = round((x - _w) * (w * _bi) + _w)
    if v < 0 then return 0
    elseif v >= w then return w-1
    else return v
    end
end

-- 仮想座標から物理アドレスへ
local function change_pos1(x, y)
    local a, b, c = block_span, blockline_span, block_width
    local v = W*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % W, v2 // W
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06183800
end
-- 目の部分
local function change_pos2(x, y)
    x = x - 0x28
    y = y - 0x40
    -- local a, b, c = block_span, blockline_span, block_width
    local a, b, c = 0x40, 0x180, 0x08
    local _w = c * (b // a)
    local v = _w*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % _w, v2 // _w
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06189800
end
local function change_pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return change_pos2(x, y)
    else return change_pos1(x, y)
    end
end

local xs = 0x20
-- local xs = 0x28
local xe = 0x57
local ys = 0x5c
local ye = 0x70
local _y_b = ye - ys
local _x_b = xe - xs
local slope = (_y_b / _x_b)
local function y_scale(x)
    if x < _x_b * 0.5 then
        return round(-2*slope*x + _y_b)
    else
        return round(2*slope*x - _y_b)
    end
end

local vs = {}
local _jj = -1
local prev = ""
local x, y = 0, 0
for i = 0x6183800, 0x61897ff, 4 do
    if within(x, xs, xe) and within(y, ys, ye) then
    vs[change_pos(x, y)] = r32(change_pos(lerp(x-xs, 0x30, 0x80)+xs, y_scale(x-xs) + y), arm9)
    end
    if y >= 0x75 then
        vs[change_pos(x, y)] = r32(change_pos(lerp(x, W, 0.4*W) + W, y))
    end
    x = (x + 4) % W if x == 0 then y = y + 1 end
end
for i, v in pairs(vs) do w32(i, v, arm9) end

end


local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end

lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    for i = 0, 10 do as[i] = head + 0x40*i end
    local tones = {}
    for i, addr in pairs(as) do tones[i] = r32(addr + 0x0c) end
    local r = RC(30)
    local r2 = RC(60)
    return function()
        for i, a in pairs(as) do
            if r() then
                w32(a + 0x0c, tones[rand(0, 10)])
            end
        end
    end
end)

```


<details>
<summary>video5のバグテキスト</summary>
<div>

```plaintext

0x0225B1B0
きみが　強い　理由は
ポケモンとの　信頼関係かもしれない
>
君が　強い　理由は\nポケモンとの　信頼関係かもしれないな

0x0225B1EE
だけど　問題ない
ぼくだって　チャオブーたちから
>
でも　問題ない\n僕だって　ぶぅ…チャオブー達から

0x0225B224
もっと　強さを　ひきだせるよ
>
もっと　強さを　引き出せるよ


ハーイ！ <= 変更しない

0x02277ABE
ムユルン！
ちょっと　つきあってくれない？
>
(全部"…"に変える)

ここでテキストデータが更新

0x02277A84
アララギ博士
なにか　ご用ですか
>
(全部"…"に変える)

0x02277BD8
……ベルは　呼び出しに
気づいて　いないのよねー
>
(全部"…"に変える)

0x02277C0E
何に　夢中なのかしら？
>
(全部"…"に変える)

0x02277C2A
あとで　別に
連絡するしか　ないわねー
>
(全部"…"に変える)

0x02277C56
じゃ！　おふたりさん
>
(全部"…"に変える)

0x02277C70
ライモンシティの　手前の
ゲートで　待ってるわね！
>
(全部"…"に変える)

0x02277A64
……あ　あの！？
>
(全部"…"に変える)

0x0225B194
チェレン『……だって
>
チェレ助『……………

0x0225B1AE
ライモンシティの　ゲートなら
この　4番道路を
>
(全部"…"に変える)

0x0225B1E2
まっすぐ　進むだけさ
>
(全部"…"に変える)
```

</div>
</details>

---

## ライブキャスターでにしきがお

```lua

-- lib.fill_in(0x06400000, 0x064fffff)
-- アララギ口
-- 2500から0x100ずつ
-- lib.fill_in(0x06402600, 0x064027ff)

local arm9 = "ARM9 System Bus"

local head = 0x06006800

local orig = {}

local mode_offsets = {
    -- 0,
    0x40,
    0x42,
}


---@param on bool
---@param mode int
local function swap_person(on, mode)
    local vs = {}
    local o = mode_offsets[mode] or 0
    for i = 0x0, 0x2ff, 2 do
        local a = head + i
        local a2 = a ~ 0x20
        local is_left = a & 0x20 == 0
        if on then
            vs[a] = orig[a2 + (is_left and o or -o)] or orig[a]
        else vs[a] = orig[a]
        end
    end
    for a, v in pairs(vs) do w16(a, v) end
end
local function setup_swapping()
    for i = 0x0, 0x2ff, 2 do
        local a = head + i
        orig[a] = r16(a)
    end
    local cnt = Cnt(2)
    local mode = 2
    local is_first = true
    local on = false
    lib.timer.setInterval(30, function()
        on = not on
        if is_first then is_first = false
        elseif cnt() then mode = rand(1, #mode_offsets)
        end
        swap_person(on, mode)
    end)
end

---@param bound int
---@param from_addrs int[]
---@param target_addrs? int[]
---@param get_idx? fun(): int, bool
---@param get_n0? fun(): int
local function araburi_base(bound, from_addrs, target_addrs, get_idx, get_n0)
    target_addrs = target_addrs or from_addrs
    local mouses = {}
    for _, a in pairs(from_addrs) do
        local v = {}
        for i = 0, bound - 1, 4 do
            v[i] = r32(a + i, arm9)
        end
        mouses[#mouses+1] = v
    end
    local cnt = Cnt(2, #mouses)
    if not get_idx then
        get_idx = function()
            local fired = cnt()
            return cnt.i + 1, fired
        end
    end
    return function()
        local idx, fired = get_idx()
        if fired then
            if get_n0 then cnt.n0 = get_n0() end
        end
        local m = mouses[idx]
        for _, a in pairs(target_addrs) do
            for i = 0, bound - 1, 4 do
                w32(a + i, m[i], arm9)
            end
        end
    end
end

local function Araragi_mouse()
    return araburi_base(0x100, {
        0x06402500,
        0x06402600,
        0x06402700,
    })
end

local function Tyeren_mouse()
    return araburi_base(0x80, {
        0x06402c80,
        0x06402d80,
    }, {
        0x06402c80,
        0x06402d00,
        0x06402d80,
    })
end

local araragi_eye_cnt = Cnt(3, 2)
local araragi_eye_update_n0 = RC(60)

local araragi_eye
local araragi_mouse
local tyeren_eye
local tyeren_mouse
local function setup_funcs()

araragi_eye = araburi_base(0x280, {
    0x06401d80,
    0x06402000,
    0x06402280,
}, nil, function()
    araragi_eye_cnt()
    if araragi_eye_update_n0() then araragi_eye_cnt.n0 = rand(2, 5) end
    return araragi_eye_cnt.i * 2 + 1, false
end)

tyeren_eye = araburi_base(0x180, {
0x06402800,
0x06402980,
0x06402b00,
})

araragi_mouse = Araragi_mouse()
tyeren_mouse = Tyeren_mouse()
end

local _i = 0
local ts = {
    10,
    240,
    360,
    450,
    540,
    690,
    780,
    870,
    960,
    1050,
    1210, -- 通話切れるタイミング
    1300,
    1350,
    1440,
    1530,
    1620,
    1710,
    1800,
    1890,
}

local go_time = 50

ADD_LOOP(function()
    _i = _i + 1
    for _, t in pairs(ts) do
        if _i == t then
            print(tostring(_i))
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
    if _i < go_time then return end
    if _i == go_time then
        setup_swapping()
        setup_funcs()
    end
    araragi_mouse()
    araragi_eye()
    tyeren_mouse()
    tyeren_eye()

    -- 主人公の口をいじる
    for i = 0, 0x7f, 4 do
        if not within(i, 0x28, 0x3b) then
            w32(0x060241c0 + i, 0x08080808)
            w32(0x060181c0 + i, 0x08080808)
        end
    end
end)


-- 2c80から0x80ずつ
-- lib.fill_in(0x06402c80, 0x06402d7f)

```

## ライブキャスター部分の雑多メモ

```lua
CLS()

local head = 0x06006800

local orig = {}
for i = 0x0, 0x2ff, 2 do
    local a = head + i
    orig[a] = r16(a)
end

-- 博士とチェレンの立ち絵
-- lib.fill_in(0x06006800, 0x06006aff)
-- lib.fill_in(0x06006800, 0x0600681f)
local vs = {}
for i = 0x0, 0x2ff, 2 do
    local a = head + i
    local a2 = a ~ 0x20
    local is_left = a & 0x20 == 0
    vs[a] = orig[a2 + (is_left and 0x40 or -0x40)] or orig[a]
    vs[a] = orig[a2 + (is_left and 0x42 or -0x42)] or orig[a]
end
for a, v in pairs(vs) do w16(a, v) end
-- w16(0x06006840, 0x11)

-- 6800から、0x20ずつ、博士、チェレン、博士、チェレン、...と交互に配置されている

-- 6800 <=> 6820 (**** **** **0* **** <=> **** **** **1* ****)
-- 6840 <=> 6860 (**** **** *10* **** <=> **** **** *11* ****)

-- 口など動く部分
-- lib.fill_in(0x06400000, 0x064fffff)
```


## ライブキャスターでテキスト&イルーム

```lua
-- チェレン会話変更

CLS()

-- 君が　強い　理由は\nポケモンとの　信頼関係かもしれないな
lib.warr(0x0225B1B0, lib.htob("1b544c300030375f44300030067431756f30feffdd30b130e230f33068306e300030e14f3c98a295c24f4b30823057308c306a3044306a30"))

-- でも　問題ない\n僕だって　ぶぅ…チャオブー達から
lib.warr(0x0225B1EE, lib.htob("6730823000304f554c986a304430feffd5506030633066300030763045302620c130e330aa30d630fc3054904b308930"))

-- もっと　強さを　引き出せるよ
lib.warr(0x0225B224, lib.htob("8230633068300030375f553092300030155f4d30fa515b308b308830"))

local state = 0

local function change_text1()
    lib.warr(0x02277ABE, lib.htob("26202620262026202620feff262026202620262026202620262026202620262026202620262026202620"))
end
local function change_text2()
lib.warr(0x02277A84, lib.htob("262026202620262026202620feff262026202620262026202620262026202620"))
end
local function change_text3()
lib.warr(0x02277BD8, lib.htob("26202620262026202620262026202620262026202620feff262026202620262026202620262026202620262026202620"))
lib.warr(0x02277C0E, lib.htob("26202620262026202620262026202620262026202620"))
lib.warr(0x02277C2A, lib.htob("262026202620262026202620feff262026202620262026202620262026202620262026202620"))
lib.warr(0x02277C56, lib.htob("2620262026202620262026202620262026202620"))
lib.warr(0x02277C70, lib.htob("262026202620262026202620262026202620262026202620feff262026202620262026202620262026202620262026202620"))
end
local function change_text4()
lib.warr(0x02277A64, lib.htob("26202620262026202620262026202620"))
end
local function change_text5()
-- チェレ助『……………
lib.warr(0x0225B194, lib.htob("c130a730ec30a9520e3026202620262026202620"))
-- ……………………………………\n……………………
lib.warr(0x0225B1AE, lib.htob("26202620262026202620262026202620262026202620262026202620feff26202620262026202620262026202620"))
-- …………………………
lib.warr(0x0225B1E2, lib.htob("2620262026202620262026202620262026202620"))
end

ADD_LOOP(function()
    if state == 0 and r16(0x02277ABE) == 0x30e0 then
        print("TEXT1")
        state = 1
        change_text1()
    elseif state == 1 and r16(0x02277A84) == 0x30A2 then
        print("TEXT2")
        state = 2
        change_text2()
    elseif state == 2 and r16(0x02277BD8) == 0x2026 then
        print("TEXT3")
        state = 3
        change_text3()
    elseif state == 3 and r16(0x02277A64) == 0x2026 then
        print("TEXT4")
        state = 4
        change_text4()
    elseif state == 4 and r16(0x0225B194) == 0x30C1 then
        print("TEXT5")
        state = 5
        change_text5()
    end
end)



lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    for i = 0, 10 do as[i] = head + 0x40*i end
    local hat = {}
    for i, _ in pairs(as) do hat[i] = false end
    local c = Cnt(15)
    local r = RC(120)
    local m = lib.at(head)
    return function()
        c()
        for i, a in pairs(as) do
            m:with(a + 0x2c):add8(rand(0, 3), 1, 0x20)
            if r() then
                hat[i] = not hat[i]
            end
            if hat[i] then
                m:with(a + 0x24):w32(0x11111100)
                m:with(a + 0x17):w8(0x03)
            else
                m:with(a + 0x24):w32(0x11001100)
                m:with(a + 0x17):w8(0x00)
            end
        end
        for i = 11, 16 do
            local a = 0x03eba730 + 0x40 * i
            m:with(a + 0x24):w32(0x11111100)
            m:with(a + 0x17):w8(0x03)
        end
    end
end)
```

## video 5 Nにしきがお

```lua
local arm9 = "ARM9 System Bus"
CLS()

local function MAIN()

local block_width = 0x08
local block_span = 0x40
local blockline_span = 0x400
local W = block_width * (blockline_span // block_span)
assert(block_span % block_width == 0)
assert(blockline_span % block_span == 0)

local function round(x)
    return math.floor(x + 0.5)
end

local function lerp(x, w, b)
    local _w = w * 0.5
    local _bi = 1.0 / b
    local v = round((x - _w) * (w * _bi) + _w)
    if v < 0 then return 0
    elseif v >= w then return w-1
    else return v
    end
end

-- 仮想座標から物理アドレスへ
local function change_pos1(x, y)
    local a, b, c = block_span, blockline_span, block_width
    local v = W*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % W, v2 // W
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06183800
end
-- 目の部分
local function change_pos2(x, y)
    x = x - 0x28
    y = y - 0x40
    -- local a, b, c = block_span, blockline_span, block_width
    local a, b, c = 0x40, 0x180, 0x08
    local _w = c * (b // a)
    local v = _w*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % _w, v2 // _w
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06189800
end
local function change_pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return change_pos2(x, y)
    else return change_pos1(x, y)
    end
end

local xs = 0x20
-- local xs = 0x28
local xe = 0x57
local ys = 0x50
local ys2 = 0x2c
local ye = 0x67
local _y_b = ye - ys
local _x_b = xe - xs
local slope = (_y_b / _x_b)
local function y_scale(x)
    if x < _x_b * 0.5 then
        return round(-2*slope*x + _y_b)
    else
        return round(2*slope*x - _y_b)
    end
end

local vs = {}
local _jj = -1
local prev = ""
local x, y = 0, 0
for i = 0x6183800, 0x61897ff, 4 do
    if y < ys then
    vs[change_pos(x, y)] = r32(change_pos(x, ys2 - 0x06 - math.floor((ys2 - y)*0.7)), arm9)
    end
    if within(y, ys, ye) then
    vs[change_pos(x, y)] = r32(change_pos(x, ye - math.floor((ye - y)*2.0)), arm9)
    end
    if y >= 0x75 then
        vs[change_pos(x, y)] = r32(change_pos(lerp(x, W, 1.4*W) + W, y))
    end
    x = (x + 4) % W if x == 0 then y = y + 1 end
end
for i, v in pairs(vs) do w32(i, v, arm9) end

end


local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end

-- MAIN()
-- loop = nil


lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    for i = 0, 10 do as[i] = head + 0x40*i end
    local hat = {}
    for i, _ in pairs(as) do hat[i] = false end
    local c = Cnt(15)
    local r = RC(120)
    local m = lib.at(head)
    local count = 0
    return function()
        c()
        if count > 0 then
            count = count - 1
        elseif r() then count = rand(30, 90)
        end
        for i, a in pairs(as) do
            m:with(a + 0x2c):Tadd8(1, rand(-4, -1), 1)
            m:with(a + 0x1f):w8(stou8(rand(-24, -12)))
            if count > 0 then
                m:with(a + 0x16):w8(0x80)
                m:with(a + 0x24):w32(0x03818100)
            else
                m:with(a + 0x16):w8(0)
                m:with(a + 0x24):w32(0x12001000)
            end
        end
    end
end)
```

## video6 にしきがお

```lua
local arm9 = "ARM9 System Bus"
CLS()

local function MAIN()

local block_width = 0x08
local block_span = 0x40
local blockline_span = 0x400
local W = block_width * (blockline_span // block_span)
assert(block_span % block_width == 0)
assert(blockline_span % block_span == 0)

local function round(x)
    return math.floor(x + 0.5)
end

local function lerp(x, w, b)
    local _w = w * 0.5
    local _bi = 1.0 / b
    local v = round((x - _w) * (w * _bi) + _w)
    if v < 0 then return 0
    elseif v >= w then return w-1
    else return v
    end
end

-- 仮想座標から物理アドレスへ
local function change_pos1(x, y)
    local a, b, c = block_span, blockline_span, block_width
    local v = W*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % W, v2 // W
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06183800
end
-- 目の部分
local function change_pos2(x, y)
    x = x - 0x28
    y = y - 0x40
    -- local a, b, c = block_span, blockline_span, block_width
    local a, b, c = 0x40, 0x180, 0x08
    local _w = c * (b // a)
    local v = _w*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % _w, v2 // _w
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06189800
end
local function change_pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return change_pos2(x, y)
    else return change_pos1(x, y)
    end
end

local xs = 0x20
-- local xs = 0x28
local xe = 0x57
local ys = 0x50
local ys2 = 0x2c
local ye = 0x67
local _y_b = ye - ys
local _x_b = xe - xs
local slope = (_y_b / _x_b)
local function y_scale(x)
    if x < _x_b * 0.5 then
        return round(-2*slope*x + _y_b)
    else
        return round(2*slope*x - _y_b)
    end
end

local vs = {}
local _jj = -1
local prev = ""
local x, y = 0, 0
for i = 0x6183800, 0x61897ff, 1 do
    if within(y, 0x40, 0x70) then
        local __x = (x - W*0.5) * 2 / W
        local __sign = __x < 0 and -1 or 1
        __x = W*0.5 + __sign * __x * __x * W*0.5
        __x = math.max(math.min(__x, W-1), 0)
        vs[change_pos(x, y)] = r8(change_pos(__x, y))
    elseif y >= 0x75 then
        local _h = 0x10
        local center = {W*0.5, 0x75 + _h}
        local __x = (x - center[1]) * 2 / W
        local __sign = __x < 0 and -1 or 1
        __x = center[1] + __sign * __x * __x * W*0.5
        __x = math.max(math.min(__x, W-1), 0)
        -- local __y = (y - center[2]) / _h
        -- __y = center[2] + __y * __y * _h
        vs[change_pos(x, y)] = r8(change_pos(__x, y))
    end
    x = (x + 1) % W if x == 0 then y = y + 1 end
end
-- for i, v in pairs(vs) do w32(i, v, arm9) end

for i = 0x6183800, 0x61897ff, 4 do
    local v = 0
    for j = 0, 3, 1 do
        local _i = i + 3 - j
        v = (v << 8) | (vs[_i] or r8(i))
        -- v = (v << 8) | r8(_i)
    end
    w32(i, v)
end

end


local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end

-- MAIN()
-- loop = nil

lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    for i = 0, 18 do as[i] = head + 0x40*i end
    local m = lib.at(head)
    return function()
        for i, a in pairs(as) do
            m:with(a + 0x21):w8(0x22)
            m:with(a + 0x23):w8(0x22)
        end
    end
end)
```

## video7 にしきがお

```lua
local arm9 = "ARM9 System Bus"
CLS()

local function MAIN()

local block_width = 0x08
local block_span = 0x40
local blockline_span = 0x400
local W = block_width * (blockline_span // block_span)
assert(block_span % block_width == 0)
assert(blockline_span % block_span == 0)

local function round(x)
    return math.floor(x + 0.5)
end

local function lerp(x, w, b)
    local _w = w * 0.5
    local _bi = 1.0 / b
    local v = round((x - _w) * (w * _bi) + _w)
    if v < 0 then return 0
    elseif v >= w then return w-1
    else return v
    end
end

-- 仮想座標から物理アドレスへ
local function change_pos1(x, y)
    local a, b, c = block_span, blockline_span, block_width
    local v = W*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % W, v2 // W
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06183800
end
-- 目の部分
local function change_pos2(x, y)
    x = x - 0x28
    y = y - 0x40
    -- local a, b, c = block_span, blockline_span, block_width
    local a, b, c = 0x40, 0x180, 0x08
    local _w = c * (b // a)
    local v = _w*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % _w, v2 // _w
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return (v3*b + V1) + 0x06189800
end
local function change_pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return change_pos2(x, y)
    else return change_pos1(x, y)
    end
end

local xs = 0x20
-- local xs = 0x28
local xe = 0x57
local ys = 0x50
local ys2 = 0x2c
local ye = 0x67
local _y_b = ye - ys
local _x_b = xe - xs
local slope = (_y_b / _x_b)
local function y_scale(x)
    if x < _x_b * 0.5 then
        return round(-2*slope*x + _y_b)
    else
        return round(2*slope*x - _y_b)
    end
end

local vs = {}
local _jj = -1
local prev = ""
local x, y = 0, 0

local xs = 0x10
local xe = 0x6f
local x2s = 0x30
local x2e = 0x3f
local ys = 0x10
local ye = 0x6f
local y2s = 0xb0
local y2e = 0xbf

for i = 0x6183800, 0x61897ff, 1 do
    if within(y, ys, ye) and within(x, xs, xe) then
        local _x = math.floor((x - xs) * (x2e - x2s) / (xe - xs)) + x2s
        local _y = math.floor((y - ys) * (y2e - y2s) / (ye - ys)) + y2s
        vs[change_pos(x, y)] = r8(change_pos(_x, _y))
    elseif within(y, 0xb0, 0xbf) and within(x, 0x30, 0x3f) then
        vs[change_pos(x, y)] = 0
    end
    x = (x + 1) % W if x == 0 then y = y + 1 end
end

for i = 0x6183800, 0x61897ff, 4 do
    local v = 0
    for j = 0, 3, 1 do
        local _i = i + 3 - j
        v = (v << 8) | (vs[_i] or r8(_i))
    end
    w32(i, v)
end

for i = 0x6189800, 0x6189fff, 4 do
    local v = 0
    for j = 0, 3, 1 do
        local _i = i + 3 - j
        v = (v << 8) | (vs[_i] or r8(_i))
    end
    w32(i, v)
end

end


local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end




lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    for i = 0, 16 do as[i] = head + 0x40*i end
    local r = RC(40)
    return function()
        for i, a in pairs(as) do
            if i <= 8 then
                w16(a + 0x1a, 0)
                w16(a + 0x1c, 0)
            else
                local v = 0x60
                -- local v = 0x20
                w8(a + 0x17, v)
                w8(a + 0x18, v)
                w8(a + 0x1f, stou8(rand(-1, 24)))
                if r() then
                    if r8(a + 0x26) == 0 then
                        w16(a + 0x26, 0x3030)
                    else
                        w16(a + 0x26, 0)
                    end
                end
            end
        end
    end
end)

```

## video9 笑顔N(ver1) & 高音ビブラートイルーム

```lua
CLS()

local function change_pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return lib.pos.Morton(x - 0x28, y - 0x40, 0x08, 0x40, 0x180) + 0x06189800
    else return lib.pos.Morton(x, y, 0x08, 0x40, 0x400) + 0x06183800
    end
end

local function MAIN()

local W = 0x80
local hW = W // 2

lib.image.filterObj()
:width(W)
:bound(0x6000)

-- ver1
:go(function(x, y)
    local _x = clamp(0x08 + hW + math.abs(x - hW), 0, 0x80)
    return change_pos(x, y), r8(change_pos(_x, y))
end)
end

local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end


lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    local prevs = {}
    for i = 0, 16 do
        as[i] = head + 0x40*i
        prevs[i] = 0
    end
    local __v = 0x3
    return function()
        for i, a in pairs(as) do
            local _a = a + 0x2c
            local t = r8(_a)
            if prevs[i] < t then
                t = rand(0x15, 0x2f)
                w8(a + 0x1f, stou8(rand(25, 50)))
                w8(a + 0x26, rand(0, 0x10))
                w8(a + 0x27, rand(0, 0x70))
            end
            w8(_a, t)
            prevs[i] = t
        end
    end
end)
```

## video9 ムスッと顔 & 爆音

```lua
CLS()

local function change_pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return lib.pos.Morton(x - 0x28, y - 0x40, 0x08, 0x40, 0x180) + 0x06189800
    else return lib.pos.Morton(x, y, 0x08, 0x40, 0x400) + 0x06183800
    end
end

local function MAIN()

local W = 0x80
local hW = W // 2

lib.image.filterObj()
:width(W)
:bound(0x6000)

-- ver2
:go(function(x, y)
    if within(y, 0x10, 0x2f) and (within(x, 0x10, 0x1f)) then return change_pos(x, y), 0 end
    local _x = clamp(-0x08 + hW - math.abs(x - hW), 0, W-1)
    return change_pos(x, y), r8(change_pos(_x, y))
end)

end

local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end



lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    for i = 0, 16 do
        as[i] = head + 0x40*i
    end
    local __v = 0x3
    local r = RC(20)
    return function()
        for i, a in pairs(as) do
            local _a = a + 0x2c
            local t = r8(_a)
            if r() then
                w8(a + 0x1f, stou8(rand(-2, 2)))
            end
            w16(a + 0x16, 0x1000)
            w8(a + 0x25, 0x3)
            w8(a + 0x26, 0x1)
            w8(a + 0x27, 0x70)
            w8(_a, t)
        end
    end
end)

```


## video9 モリゾー的N(ver3) & 愉快なBGM

```lua

CLS()

local function change_pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return lib.pos.Morton(x - 0x28, y - 0x40, 0x08, 0x40, 0x180) + 0x06189800
    else return lib.pos.Morton(x, y, 0x08, 0x40, 0x400) + 0x06183800
    end
end

local function MAIN()

local W = 0x80
local hW = W // 2

lib.image.filterObj()
:width(W)
:bound(0x6000)

-- ver3
:go(function(x, y)
    if within(y, 0x10, 0x2f) and (within(x, 0x20, 0x2f) or within(x, 0x50, 0x60)) then return change_pos(x, y), 0 end
    local _x = clamp(-0x18 + hW - math.abs(x - hW), 0, W-1)
    return change_pos(x, y), r8(change_pos(_x, y))
end)
:go(function(x, y)
    local _x = clamp(hW - math.abs(x - hW) // 2, 0, W-1)
    return change_pos(x, y), r8(change_pos(_x, y))
end)

end

local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end




lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    local prevs = 0
    local ps = {
        20,20,20,20,20,
        20,20,20,20,20,
        20,20,20,20,20,20,20,20,0
    }
    for i = 0, 16 do
        as[i] = head + 0x40*i
    end
    local r = RC(40)
    local c = Cnt(2)
    local __v = 0x10
    return function()
        local _a = as[0] + 0x2c
        local t = r8(_a)
        if prevs < t then
            c()
            t = c.i == 0 and __v or __v*2
            for i, a in pairs(as) do
                w8(a + 0x1f, stou8(ps[i+1] + rand(-5, 10)))
            end
        end
        for i, a in pairs(as) do
            w8(a + 0x2c, t)
        end
        prevs = t
    end
end)


```


## リュウラセンイベント

```plaintext
26C459C: ゼクロムX座標(4byte signed LE)
26C45A8: ゼクロムZ座標(4byte signed LE)
26C45B4: ゼクロム上半身Y座標(4byte signed LE)
回転?: 0x026C486C
yscale: 0x026C486E (2byte)
x軸回転: 0x026C4870 (2byte)
右腕: 26C46F8
顔Y座標: 26C4688
顔Z座標: 26C468C
顔X座標: 26C4690

左足 26C4784
=> 38 3A/3B 00 <index> が目印?

アニメーション時間: 26CA984
```

## video11 ゼクロムを楽しそうにダンスさせる

```lua
local update_zek = (function()
    local function found(v)
        local v1 = (v >> 0) & 0xff
        local v2 = (v >> 8) & 0xff
        local v3 = (v >> 16) & 0xff
        local v4 = (v >> 24) & 0xff
        return (
            v1 == 0x38
        ) and (
            v2 == 0x3A or v2 == 0x3B
        ) and (
            v3 == 0
        ) and within(v4, 1, 0x20)
    end

    local begin = 0x026C45A8
    local inclusiveEnd = 0x026C486F

    local _i = 0
    local ready = false
    local ready_m = lib.at(0x026C45A2)
    return function()
        if not ready then
            if ready_m:r8() ~= 0 then
                print("READY")
                ready = true
            end
            return
        end
        _i = (_i + 1) % 30
        -- local _v = math.round(math.cos(_i*2*math.pi/30) * 0x1000)
        local _v = math.round(math.cos(_i*2*math.pi/30) * 0x600)
        -- w32(0x02278424, 0xd2000)
        local i = begin
        while i <= inclusiveEnd do
            local v = r32(i)
            i = i + 4
            if found(v) then
                for j = 1, 3 do
                    -- add32(i, rand(-1, 1) * 0x400)
                    add32(i, _v)
                    i = i + 4
                end
            end
        end
    end
end)()


lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    local prevs = {}
    local ps = {
        20,20,20,20,20,
        20,20,20,20,20,
        20,20,20,20,20,20,20,20,0
    }
    for i = 0, 16 do
        as[i] = head + 0x40*i
        prevs[i] = 0
    end
    local r = RC(40)
    local c = Cnt(2)
    local __v = 0x2
    return function()
        for i, a in pairs(as) do
            w8(a + 0x2c, math.min(r8(a+0x2c), 1))
            w32(a + 0x24, 0x80100100)
            -- local t = r8(a + 0x2c)
            -- if prevs[i] < t then
            --     t = rand(1, 5)
                w8(a + 0x1f, stou8(ps[i+1] + rand(-5, 10)))
            -- end
            -- w8(a + 0x2c, t)
            -- prevs[i] = t
        end
    end
end)

function loop()
    update_zek()
end
```

## video11 ゼクロムを回転させつつ胴の伸び縮みさせる

```lua
local i = 0
local span = 45
local scalex = 0x8000
local scalez = 0x40000
local iy = 0
local spany = 63
function loop()
    local v
    i = (i + 1) % span
    iy = (iy + 1) % spany
    v = math.round(math.cos(i * 2 * math.pi / span) * scalex) + 0x89D8
    w32(0x026C459C, v)
    v = math.round(math.sin(i * 2 * math.pi / span) * scalez) - 0x8A6C3
    w32(0x026C45A8, v)
    v = math.round(math.sin(iy * 2 * math.pi / spany) * 0x10000) + 0x7B24
    w32(0x026C45B4, v)
    w32(0x02278424, 0xc2000)
end
```

## video11 ゲーチスBGMバグ

```lua
-- ge
-- C17F6400
-- chis
-- C17F6600

lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    for i = 0, 19 do as[i] = head + 0x40*i end
    local __p = 12
    local ps = {
        __p, __p, __p, __p, __p, __p, __p, __p,
        __p, __p, __p, __p, __p, __p, __p, __p,
        __p, __p, __p, __p, __p, __p, __p, __p,
    }
    local chis = {}
    local chis2 = {}
    for i, addr in pairs(as) do chis[i] = false chis2[i] = rand(0, 1) == 1 end
    local r = RC(60)
    local r2 = RC(60)
    return function()
        for i, a in pairs(as) do
            if r() then
                chis[i] = not chis[i]
                chis2[i] = rand(0, 1) == 1
            end
            if r2() then
                w8(a + 0x1f, stou8(ps[i+1] + rand(0, 1)*12))
            end
            w32(a + 0x0c, chis[i] and 0x00647FC1 or 0x00667FC1)
            w16(a + 0x17, 0x0060)
        end
    end
end)
```

## video11 ゲーチス戦闘開始画面で固定 & ゲーチス立ち絵伸び縮み

```lua
--[[
-- 雑メモ
local addrs = {
0x023553F4, -- 黒背景&ゲーチスのanimation time
0x02355478, -- 電撃のanimation time
0x023554E8, -- hata to name no animation time & 画面遷移もこれでブロックできる
0x023556E8, -- 中心の青帯のanimation time & 画面遷移ブロック
-- 5480 -> 電撃がかいめつ
}

local r = RC(30)
local c = Cnt(60)
function loop()
    -- if c() then
    --     savestate.loadslot(5)
    -- end
    c()
    for _, a in pairs(addrs) do
        if r() or c.fired then
        w32(a, rand(16, 16) * 0x4000)
        end
        -- if r() then
        --     w32(a, rand(0, 0xffffffff))
        -- end
    end
end

-- 2353154 ゲーチスの名前のX座標
-- 2353158 ゲーチスの名前のY座標

-- 2353186 -> 01で立ち絵、見切れ部分も表示
-- 2353188 影の位置?
-- 2348E74付近 -> ゲーチスがゆがむ
]]

local update_timers = (function()
    local a1 = 0x023553F4 -- 黒背景&ゲーチスのanimation time
    local a2 = 0x02355478 -- 電撃のanimation time
    local a3 = 0x023554E8 -- hata to name no animation time & 画面遷移もこれでブロックできる
    local a4 = 0x023556E8 -- 中心の青帯のanimation time & 画面遷移ブロック
    local r = RC(30)
    local c = Cnt(60)
    return function()
        c()
        if r() or c.fired then
            w32(a1, 16 * 0x4000)
        end
        if r() or c.fired then
            w32(a2, 16 * 0x4000)
        end
        if r() or c.fired then
            w32(a3, 18 * 0x4000)
        end
        if r() or c.fired then
            w32(a4, rand(0, 18) * 0x4000)
        end
    end
end)()


local update_name_pos = (function()
    -- local xmin = -0x37800
    local xmin = -0x5f800
    local xmax = 0x5F080
    local ymin = -0x33400
    local ymax = 0x32400
    local xspeed = 0x1000
    local X = ValueUpdater(1, xmin, xmax)
    :init(-0x12000)
    :calc(function(obj)
        return obj.v - xspeed
    end)
    :write(function(v) w32(0x02353154, v) end)
    local Y = ValueUpdater()
    :init(-0x14800)
    :calc(function() return rand(ymin + 0x8000, ymax - 0x8000) end)
    :write(function(v) w32(0x02353158, v) end)
    return function()
        if X() then Y() xspeed = rand(2, 4) * 0x800 end
    end
end)()

local _i = 0

local vobj = {
    ValueUpdater(60, 0, 0x1000)
    :calc(function(obj) return obj:isin() end)
    :write(function(v) w32(0x02348E74, v) end),
    ValueUpdater(450, 0, 0x7000)
    :calc(function(obj) return obj:isin() end)
    :write(function(v) w16(0x02348E70, v) end),
    ValueUpdater(410, 0xC000, 0xF000)
    :calc(function(obj) return obj:isin() end)
    :write(function(v) w16(0x02348E72, v) end),
}

local move_active = false

local update_gechis_name = (function()
    local done = false
    local ge = "b230"
    local chis = "c130b930"
    local small_e = "a730"
    local big_e = "a830"
    local s = ge
    for i = 1, 6 do s = s .. small_e end
    s = s .. chis .. "FFFF"
    -- 0x0226EED0: ゲーチスの名前
    local m = lib.at(0x0226EED0)
    return function()
        if done then return end
        if m:r32() == 0x30FC30B2 then
            print("GECHIS NAME CHANGED")
            m:warr(lib.htob(s))
            done = true
            move_active = true
        end
    end
end)()

function loop()
    update_gechis_name()
    if not move_active then return end
    for _, obj in pairs(vobj) do obj() end
    update_timers()
    update_name_pos()
end
```

## video11 vの口笑顔のNしきがお

```lua
CLS()

local function change_pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return lib.pos.Morton(x - 0x28, y - 0x40, 0x08, 0x40, 0x180) + 0x06189800
    else return lib.pos.Morton(x, y, 0x08, 0x40, 0x400) + 0x06183800
    end
end

local function MAIN()

local W = 0x80
local hW = W // 2

local wid = 0x20
local hwid = wid // 2
local yscale = 0x10
CLS()

lib.image.filterObj()
:width(W)
:bound(0x6000)
:go(function(x, y)
    if within(x, 0, 0x7) then
        return nil
    end
    local x1 = x % (2*wid)
    local f, x2 = x // wid == 0, x1 % wid
    local yd = hwid - math.abs(x2 - hwid)
    local y2 = y + (f and -1 or 1) * math.round(yd * yscale / hwid)
    y2 = clamp(y2, 0, 0xbf)
    return change_pos(x, y), r8(change_pos(x, y2))
end)

end

local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end


lib.irume.start(function()
    local head = 0x03eba730
    local poses = {}
    local as = {}
    for i = 0, 16 do
        as[i] = head + 0x40*i
        poses[i] = r32(as[i] + 0x34)
    end
    local r = RC(30)
    local r2 = RC(120)
    return function()
        for i, a in pairs(as) do
            local pos = as[i] + 0x34
            if r2() then
                poses[i] = r32(pos)
            end
            if r() then
                w32(pos, poses[i])
            end
        end
    end
end)
```

## video11 ゼクロム崩壊 & だるまさん?

```lua

local active = true

local ready = false

local update_zek = (function()
    local function found(v)
        local v1 = (v >> 0) & 0xff
        local v2 = (v >> 8) & 0xff
        local v3 = (v >> 16) & 0xff
        local v4 = (v >> 24) & 0xff
        return (
            v1 == 0x38
        ) and (
            v2 == 0x3A or v2 == 0x3B
        ) and (
            v3 == 0
        ) and within(v4, 1, 0x20)
    end

    local begin = 0x026C45A8
    local inclusiveEnd = 0x026C486F

    local _i = 0
    local ready_m = lib.at(0x026C45A2)
    local r = RC(5)
    local backup = nil
    local prev_active = 30
    return function()
        if not ready then
            if ready_m:r8() ~= 0 then
                print("READY")
                ready = true
            end
            return
        end
        if not backup then
            backup = lib.range(begin - 0x10, inclusiveEnd + 0x10):save()
        end
        if not active then
            prev_active = 5
            return
        end
        if prev_active > 0 then
            prev_active = prev_active - 1
        elseif prev_active == 0 then
            backup:rollback()
            prev_active = -1
        end
        _i = (_i + 1) % 30
        -- local _v = math.round(math.cos(_i*2*math.pi/30) * 0x1000)
        local _v = math.round(math.cos(_i*2*math.pi/30) * 0x600)
        -- w32(0x02278424, 0xd2000)
        local i = begin
        while i <= inclusiveEnd do
            local v = r32(i)
            i = i + 4
            if found(v) then
                for j = 1, 3 do
                    if r() then
                    add32(i, rand(-4, 4) * 0x1000)
                    end
                    -- add32(i, _v)
                    i = i + 4
                end
            end
        end
    end
end)()

-- カメラをいじって、ゼクロムを何度見しているようにする
local update_camera = (function()
    local addr = 0x02278424
    local v = 0x130000

    local target = 0x130000
    local r = RC(10)
    local f = 1
    local vals = {
        0xf0000,
        -- 0x20000,
        0x8000,
    }
    local rl = RL(100)
    return function()
        if not ready then return end
        if not rl() then return end
        if r() then
            f = rand(1, #vals)
            active = f ~= 1
            target = vals[f]
            -- target = rand(0x0800, 0x140000)
            -- target = rand(0x8000, 0xf0000)
            -- target = rand(0x0800, 0x1c0000)
            -- target = rand(0x1c0000, 0x1c0000)
        end
        v = ilerp(v, target, 0.3)
        w32(addr, v + rand(-0x1000, 0x1000))
    end
end)()


function loop()
    update_camera()
    update_zek()
end

lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    local vs = {}
    for i = 0, 16 do
        as[i] = head + 0x40*i
        vs[i] = 0x10
    end
    local r = RC(30)
    local r2 = RC(120)
    return function()
        for i, a in pairs(as) do
            if r() then
                w8(as[i] + 0x1f, rand(11, 16))
            end
            if ready then
                w8(as[i] + 0x16, 0x50)
                w8(as[i] + 0x26, 0x70)
                if r2() then
                    vs[i] = rand(0, 0x40)
                end
                w8(as[i] + 0x27, vs[i])
            end
        end
    end
end)
```

ゲーチス立ち絵調査

- 234892C: 関係あり? (`EE62432E`)
- 2348934: color (`6A01CE1F`)


2E<0010> = AE<1010> = EE<1110>
8E<1000> = CE<1100> -> GB
4E<0100> -> GB&loop
6E<0110> -> loop

ROM領域の03472CA4を00000000にすると、「都会」とか「中身」とかテキストがおかしくなる
恐らくここはテキストメッセージなどを管理する場所。他のアドレスの値などに書き換えても面白い。


## レシラムバグ集

`228E600`あたりをいじる

(例: `228E60E -> 00, 11, etc.`)

228e019 -> アゴ

アゴを適時いじる

```lua
local m = lib.at(0x0228e019)

local vs = {
    {300, 0x5},
    {345, 0x9},
    {560, 0x8},
    {970, 0x40},
    {995, 0x13},
    {1050, 0x4c},
    {1280, 0x06},
    {1410, 0x20},
    {1668, 0x07},
}

local _i = 5
local cnt = 1
local prev = false

function loop()
    _i = _i + 1
    if DS.key.get("A") then
        if not prev then
            prev = true
            print(string.format("i: %d", _i))
            -- cnt = cnt + 1
        end
    elseif prev then prev = false
    end
    if cnt > #vs then return end
    local d = vs[cnt]
    if _i >= d[1] then
        cnt = cnt + 1
        m:w8(d[2])
    end
end
```

## video12 ゼクロムNの城登場シーンバグ

```lua



---@type {addr: int, cnt: int, data: [int, int][]}[]
local vs = {
{
    addr = 0x022c9574,
    cnt = 1,
    data = {
        {174, 0x27B24},
        {490, 0x7b24},
    }
}
}

local rl = RL(490)

local v1 = ValueUpdater(36, -0x40000, 0x40000, function(obj) return rl.fired and obj:isin() or nil end)
:w32(0x022c957c)

local v2 = ValueUpdater(36, -0x4000, 0x10000, function(obj) return rl.fired and obj:isin() or nil end)
:w32(0x022c95a8)


local v3 = ValueUpdater(36, -0x4000, 0x20000, function(obj) return rl.fired and obj:isin() or nil end)
:w32(0x022c95c0)

local v4 = ValueUpdater(36, -0x4000, 0x20000, function(obj) return rl.fired and obj:isin() or nil end)
:w32(0x022c96d4)

local v5 = ValueUpdater(36, -0x10000, 0x10000)
:calc(function(obj)
    if not rl.fired then return end
    w32(0x022c9678, stou32(obj:isin() - 0x1b))
    w32(0x022c967C, stou32(obj:icos()))
end):write(function()end)

-- 9674が首

local _i = 0
function loop()
    rl()
    -- v1()
    v2()
    v3()
    v4()
    v5()
    _i = _i + 1
    for _, v in pairs(vs) do
        local d = v.data[v.cnt]
        if d and _i >= d[1] then
            v.cnt = v.cnt + 1
            w32(v.addr, d[2])
        end
    end
end


lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    local vs = {}
    for i = 0, 29 do
        as[i] = head + 0x40*i
        vs[i] = 0x10
    end
    local r = RC(10)
    return function()
        for i, a in pairs(as) do
            if r() then
                w8(as[i] + 0x1f, rand(23, 39))
            end
        end
    end
end)
```

### ゼクロムをじたばた(リュウラセンのときの流用)

```lua

local update_zek = (function()
    local function found(v)
        local v1 = (v >> 0) & 0xff
        local v2 = (v >> 8) & 0xff
        local v3 = (v >> 16) & 0xff
        local v4 = (v >> 24) & 0xff
        return (
            v1 == 0x38
        ) and (
            v2 == 0x3A or v2 == 0x3B or v2 == 0x38
        ) and (
            v3 == 0
        ) and within(v4, 1, 0x20)
    end

    local begin = 0x022C9500
    local inclusiveEnd = 0x022C988F

    local _i = 0
    local r = RC(5)
    local backup = nil
    return function()
        if not backup then
            backup = lib.range(begin - 0x10, inclusiveEnd + 0x10):save()
        end
        if r() then
            backup:rollback()
        end
        _i = (_i + 1) % 30
        local _v = math.round(math.cos(_i*2*math.pi/30) * 0x600)
        local i = begin
        while i <= inclusiveEnd do
            local v = r32(i)
            i = i + 4
            if found(v) then
                for j = 1, 3 do
                    if r() then
                    add32(i, rand(-4, 4) * 0x1000)
                    end
                    i = i + 4
                end
            end
        end
    end
end)()
function loop()
    update_zek()
end

lib.irume.start(function()
    local head = 0x03eba730
    local as = {}
    local prevs = {}
    local fs = {}
    for i = 0, 29 do
        as[i] = head + 0x40*i
        prevs[i] = 0
        fs[i] = false
    end
    local r = RC(10)
    local _T = 0x0a
    return function()
        for i, a in pairs(as) do
            local t = r8(a + 0x2c)
            if prevs[i] < t then
                fs[i] = not fs[i]
                t = fs[i] and _T or _T*2
            end
            w8(a + 0x2c, t)
            prevs[i] = t
        end
    end
end)
```

<details>
<summary>雑多</summary>
<div>

```lua

local function found(v)
    local v1 = (v >> 0) & 0xff
    local v2 = (v >> 8) & 0xff
    local v3 = (v >> 16) & 0xff
    local v4 = (v >> 24) & 0xff
    return (
        v1 == 0x38
    ) and (
        v2 == 0x3A or v2 == 0x3B
    ) and (
        v3 == 0
    ) and within(v4, 1, 0x20)
end

-- local begin = 0x026C45A8
-- local inclusiveEnd = 0x026C486F

local function main(begin, inclusiveEnd)
    local i = begin
    while i <= inclusiveEnd do
        local v = r32(i)
        i = i + 4
        if found(v) then
            for j = 1, 3 do
                add32(i, rand(-4, 4) * 0x1000)
                -- add32(i, rand(4, 4) * 0x1000)
                i = i + 4
            end
        end
    end
end
-- 2292030
-- 228E000

function loop()
    main(0x02287C30, 0x022aFFFF)
    main(0x02687c34, 0x02687d6f)
end
loop = nil

local ok = false
CLS()
for i = 0x02000000, 0x025fffff, 4 do
    local v = r32(i)
    if found(v) then
        ok = true
        print("FOUND!!!")
        _HEXP(i)
        break
    end
end
if not ok then print("not found") end
```

```lua


local function found(v)
    local function ok(_v)
        return _v == 0x22 or _v == 0x23 or _v == 0x25 --or _v == 0x1b or _v == 0x14
    end
    local v1 = (v >> 0) & 0xff
    local v2 = (v >> 8) & 0xff
    local v3 = (v >> 16) & 0xff
    local v4 = (v >> 24) & 0xff
    return ok(v1) and ok(v2) and ok(v3) and ok(v4)
end
local function main(begin, inclusiveEnd)
    local i = begin
    while i <= inclusiveEnd do
        local v = r32(i)
        i = i + 4
        if found(v) then
            for j = 1, 3 do
                add32(i, rand(4, 4) * 0x10)
                i = i + 4
            end
        end
    end
end
-- 2292030
-- 228eba0

function loop()
    main(0x02290000, 0x0229ffff)
    -- main(0x02687c34, 0x02687d6f)
end
```

```lua

local _i = 5
local cnt = 1
local prev = false

local v = ValueUpdater(36, -0x40000, 0x40000, function(obj) return obj:isin() end)
:w32(0x022c957c)

function loop()
    -- v()
    _i = _i + 1
    if DS.key.get("A") then
        if not prev then
            prev = true
            print(string.format("i: %d", _i))
            -- _i = 0
            -- cnt = cnt + 1
        end
    elseif prev then prev = false
    end
end
```

</div>
</details>

## ROMハック: レベル技変更

- http://blog.livedoor.jp/nnnnnnnnnnaito/archives/3554242.html

> 【ポケモンのレベル技変更】
> おそらくROMを直接バイナリ書き換えしたほうが早い。
> レベル技はROM内に暗号化なしでずらーっと並んでるので、Stirlingで検索して書き換えるだけで良い。
> たとえばレベル20で銀色の風を覚えるポケモンのレベル技を変えたいなら、
> 「3E 01 13 00」でROM内を検索。銀色の風の技コードが「3E 01」で、レベル20が16進数で13に該当。
> ポケモンとポケモンの間は「FF FF FF FF」で区切られている。

図: 領域はROMの `06FAE3A0--06FAE4BF`

一部

```
06FAE400 9D 01 3F 00 77 00 46 00 FF FF FF FF FE 01 01 00 <= "FE 01 01 00"がレベル1で技"01 FE"(やきつくす)を覚える
06FAE410 7A 00 01 00 3C 01 06 00 14 00 0B 00 53 00 10 00
06FAE420 9A 00 15 00 21 01 1A 00 E1 01 1F 00 C2 01 24 00
06FAE430 A3 00 29 00 85 00 2E 00 35 00 33 00 FE 00 38 00
06FAE440 FF 00 38 00 00 01 38 00 05 02 3D 00 FF FF FF FF
```

> 図はクイタランの例。
> 黒い選択部分がクイタラン。FF FF FF FFで挟まれた領域が1つのポケモン。
> これはバイナリ編集だけで出来、面倒なnarc処理やツールがいらないので結構手軽。
> なお、このポケモンレベル技はNitroでいうとa-0-1-8に該当する。
> 検索候補が多すぎてわからない場合のために、a-0-1-8を抽出しておくと楽かも（検索で余計なものに当たらない）。
> なお技コードはぐぐれば出る。PAR等の改造コードのページに技リストとして良く載ってる。
> たとえば銀色の風なら、バイナリ上では「3E 01」だが、改造コードでは「013E」となっていることもあるので注意。
> 16進数への換算は、windows標準の電卓の機能で可能。
> あ、技変更も先ほど同様、ファイルサイズを変えてはいけない。
> つまり新技の追加は無理。いらない技を置き換えるのが手軽。あとは、おそらく覚える順番に並べたほうが良い。
> なお奥の手として、まあ入手できないだろうという幻ポケモンの技を削るという荒業がある。
> お気に入りのポケモンに新レベル技をひとつ追加するかわりに、シェイミやアルセウスの技をひとつ削る。
> これならファイルサイズは変わらないし、影響はないはず。たぶん。


## ゲーチス立ち絵調査

ROM内のゲーチス立ち絵の圧縮データと思われる箇所を発見！ => `0AF4C210` (恐らくNintendo LZ10 algorithm)

```
FNT: 00 1E 2F 00
FNT: 08 04 00 00
FAT: 00 24 2F 00
FAT: 20 0F 00 00
```

`0x22148B0`あたりのデータが候補か?

1つ手がかり発見！ `0AF4C262, 0AF4C268`を0x11で埋める

```lua
w8r(0x0AF4C264, 0x11)
```

- C9B5からC9F1だけを0でうめつくしたら、立ち絵の右下端だけかいめつした。なんかLZ77ぽい？

C750からは安全にこわせる? => ちがう、C730とかは、1バイトずれていて、その途中から塗りつぶすとエラーのもと。(恐らく2byte構成みたくなっていて、そのうちの片方だけ、となるとエラーになってしまう)
つまり、前半部分は `*0` からではなく、 `*1` から塗りつぶすとエラーになりにくい

C249からいじれる。それ以前のデータは0とかにするとフリーズエラー。
C210が先頭？やっぱりLZ10かも。

RAM 2274D30付近 => ROM AF4C330付近の圧縮データを、ここらへんの場所に一瞬だけコピーしているみたい。
同じように、圧縮データとして壊れた形でいじるとフリーズする

## video13 博士&チェレン アゴ化

```lua
CLS()

local _i = 0
local ts = {
    160,
    470,
}
local do_time = 515


local function MAIN()
    print("== MAIN ==")

local function pos(x, y)
    local function pos_l(x, y)
        local addr = 0x06010000
        if y >= 96 then
            addr = addr + 0x6000
            y = y - 96
        end
        return lib.pos.Morton(x, y, 8, 0x40, 0x400) + addr
    end
    local function pos_r(x, y)
        local addr = 0x06013000
        if y >= 96 then
            addr = addr + 0x6000
            y = y - 96
        end
        return lib.pos.Morton(x, y, 8, 0x40, 0x400) + addr
    end
    if x >= 0x80 then
        return pos_r(x - 0x80, y)
    else return pos_l(x, y)
    end
end

local orig = {}
for a = 0x06010000, 0x0601bfff do
    orig[a] = r8(a)
end
local st = 44
local st2 = 49

local vs = {}
for y = 0, 96*2-1 do
    for x = 0, 0x7f do
        if y >= st and x < 80 then
            local _y = (y - st) // 5 + st
            vs[pos(x, y)] = orig[pos(x, _y)]
        end
    end
    for x = 0x80, 0xff do
        if y >= st then
            local _y = (y - st2) // 5 + st2
            vs[pos(x, y)] = orig[pos(x, _y)]
        end
    end
end
for a = 0x06010000, 0x0601bfff, 4 do
    local v = 0
    for i = 3, 0, -1 do
        local _v = vs[a + i] or r8(a + i)
        v = (v << 8) | _v
    end
    w32(a, v)
end
lib.fill_in(0x6400000, 0x640ffff) -- 上にのっかってる目や口の可動部分を消す
lib.fill_in(0x6007B00, 0x6007BAF) -- ムユルンの名前を消す
end


function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 8 then
        -- 強制フリーズ
        lib.fill_in(0x02400000, 0x0240ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end


-- araragi: 0x06010000
-- 8, 0x40, 0x400 bound: 0x3000
-- width: (0x400/0x40)*8 = 80
-- height: (0x40/8) * (0x3000/0x400) = 96
-- tyeren: 0x06013000
-- touko: 0x06016000
-- bell: 0x06019000


-- araragi mouse: 6402500
-- araragi eye 6401D80 (8, 0x20, 0x80)


lib.irume.start(function()
    local head = 0x03eba730
    local p2 = 0x18
    -- local p2_range = 0x20
    local p2_range = 0x40
    local as = {}
    for i = 0, 19 do
        as[i] = head + 0x40*i
    end
    local r = RC(5)
    return function()
        for i, a in pairs(as) do
            if r() then
                w16(a + p2, stou16(rand(-p2_range, p2_range)))
            end
        end
    end
end)

```

## video13 Nアゴ

```lua
local function MAIN()

local function pos(x, y)
    if within(y, 0x40, 0x4f) and within(x, 0x28, 0x57) then
        return lib.pos.Morton(x - 0x28, y - 0x40, 0x08, 0x40, 0x180) + 0x06189800
    else return lib.pos.Morton(x, y, 0x08, 0x40, 0x400) + 0x06183800
    end
end

local W = 0x80
local hW = W // 2

local st1 = 0x40
local st2 = 0x58

lib.image.filterObj()
:width(W)
:bound(0x6000)
:go(function(x, y)
    if within(y, 0xb0, 0xbf) and within(x, 0x38, 0x47) then
        local _x = (x - 0x38) % 16 - 7
        local _y = (y - st2) // 7 + st2
        if _x < 0 then _x = -_x end
        _x = 0x30 + _x
        return pos(x, y), r8(pos(_x, _y))
    end
    if y >= st2 then
        local _y = (y - st2) // 7 + st2
        return pos(x, y), r8(pos(x, _y))
    else
        local _y = y // 6 + st1
        _y = _y + math.round(math.sin(x * 2 * math.pi // 0x10) * 0x4)
        return pos(x, y), r8(pos(x, _y))
    end
end)
end

local _i = 0
local ts = {
    360,
    480,
    540,
}
local do_time = 595

local span = 10

function loop()
    _i = _i + 1
    if _i == do_time then MAIN() span = 30
    elseif _i == do_time + 58 then
        -- 強制フリーズ
        lib.fill_in(0x02210000, 0x0221ffff)
        print("DONE")
        return
    elseif _i > do_time then return
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end

lib.irume.start(function()
    local head = 0x03eba730
    local p2 = 0x18
    -- local p2_range = 0x20
    local p2_range = 0x40
    local as = {}
    local prevs = {}
    for i = 0, 19 do
        as[i] = head + 0x40*i
        prevs[i] = 0
    end
    local r = RC(5)
    local time = 0x2c
    return function()
        for i, a in pairs(as) do
            local t = r8(a + time)
            if prevs[i] < t then
                t = rand(0x10, 0x30)
            end
            w8(a + time, t)
            prevs[i] = t
            if r() then
                w16(a + p2, stou16(rand(-p2_range, p2_range)))
            end
        end
    end
end)
```

