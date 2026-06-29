
# ポケモン ブラック

上画面を崩壊させる(VRAM領域をいじる)

```lua
local arm9 = "ARM9 System Bus"

-- fill_in(0x6180000, 0x618ffff, 0x4f, "ARM9 System Bus")

for i = 0x6180000, 0x618ffff, 4 do
    w32(i, r32(i, arm9) | 0x00000001, arm9)
    -- w32(i, r32(i, arm9) | 0x01010101, arm9)
end
```

イルームも追加で

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

違うバリエーションのイルーム

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


アゴ化

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

アゴ part2 (座標変換を実装して、もっときれいなアゴにした)

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

ホドモエのおまけイルーム

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


帽子化 & テキストバグ

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

デブ化？

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


カッパ顔？

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

video4のやつ(ガリガリ & ムスッとした顔)

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
