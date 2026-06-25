
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
    return s.replace("\n", "\ufffe").encode(encoding="utf-16le").hex()

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
