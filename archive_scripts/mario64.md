
# マリオ64 DS

メモ

```lua
-- 023096c0付近
-- 230f1a0

-- 22f659A -> ピーチあらぶり
-- 22f6593-6 を33でうめつくすと、いい感じに荒ぶる
```

イルーム1

```lua
lib.irume.start(function()
    local m1 = lib.at(0x03e07D57)
    local vib_sp1 = lib.at(0x03e07d5e)
    local vib_dp1 = lib.at(0x03e07d5f)
    local m2 = lib.at(0x03e07D97)
    local m3 = lib.at(0x03e07DD7)
    local vib_sp3 = lib.at(0x03e07ddd)
    local vib_dp3 = lib.at(0x03e07dde)
    local m4 = lib.at(0x03e07E17)
    local r = RC(30)
    local voice1 = lib.at(0x03e07e57)
    local voice2 = lib.at(0x03e07e97)
    local voice1p = lib.at(0x03e07e5d)
    local voice2p = lib.at(0x03e07e9d)
    local voice_p = 0
    return function()
        if r() then m1:w8(stou8(rand(-4, 4))) end
        if r() then m2:w8(stou8(rand(-4, 4))) end
        vib_dp1:w8(0x20)
        vib_sp1:w8(0x10)
        vib_dp3:w16(0x3020)
        vib_sp3:w8(0x01)
        m3:w8(rand(1, 6))
        if r() then m4:w8(stou8(rand(-2, 8))) end
        if rand(1, 20) == 1 then
            voice_p = stou8(rand(-5, 2))
        end
        voice1:w8(voice_p)
        voice2:w8(voice_p)
        voice1p:warr({0x08, 0x20, 0x20})
        voice2p:warr({0x08, 0x20, 0x20})
    end
end)
```

イルーム2

```lua
-- 鳴りっぱなし爆音
lib.irume.start(function()
    local head = {
        0x03e07d40,
        0x03e07d40 + 0x40,
        0x03e07d40 + 0x40 * 2,
        0x03e07d40 + 0x40 * 3,
        0x03e07d40 + 0x40 * 4,
        0x03e07d40 + 0x40 * 5,
        0x03e07d40 + 0x40 * 6,
        0x03e07d40 + 0x40 * 7,
        0x03e07d40 + 0x40 * 8,

        0x03e07d40 + 0x40 * 9,
        0x03e07d40 + 0x40 * 10,
        0x03e07d40 + 0x40 * 11,
        0x03e07d40 + 0x40 * 12,
        0x03e07d40 + 0x40 * 13,
        0x03e07d40 + 0x40 * 14,
        0x03e07d40 + 0x40 * 15,
        0x03e07d40 + 0x40 * 16,
    }
    local r = RC(30)
    return function()
        for _, a in pairs(head) do
            w16(a + 0x0e, 0x1212)
            if r() then
                w8(a + 0x17, stou8(rand(-6, 6)))
            end
        end
    end
end)
```

腕をチカチカ上下させた後、奥にすっ飛ぶ

```lua
local m1 = lib.at(0x022f659a)
local c1 = Cnt(20, 2)
local c2 = Cnt(15)
local tate = lib.at(0x022f657c)
local yoko = lib.at(0x022f6580)
local tate_c = RC(2)
local yoko_c = RC(2)
local rl = RL(240)
local V = 0
function loop()
    m1:w16(c1:next() == 1 and 0xff01 or 0)
    if c2() then
        c1.n0 = math.max(c1.n0 - 1, 5)
    end
    if rl() then
        V = math.min(V + 0x5000, 0xffffff)
        -- V = math.min(V + 0x3000, 0xffffff)
        yoko:add32(V)
    else
        -- ブルブル震える(動画ではボツにした？)
        -- if tate_c() then tate:add32(rand(-0x2, 0x2) * 0x1000) end
        -- if yoko_c() then yoko:add32(rand(-0x2, 0x2) * 0x1000) end
    end
end
```

荒ぶり系

```lua
local m1 = lib.at(0x022f659a)
local c1 = Cnt(20, 2)
local c2 = Cnt(15)
local v1 = {0xff01, 0x20ff, 0xff}
local m2 = lib.at(0x022f6572)
local tate = lib.at(0x022f657c)
local yoko = lib.at(0x022f6580)
local tate_c = RC(2)
local yoko_c = RC(2)
local rl = RL(240)
local V = 0
local arabu = lib.at(0x022f6593)
function loop()
    if c1() then
        m1:w16(v1[rand(1, #v1)])
    end
    -- arabu:warr({0x33,0x33,0x33,0x33})
    -- m1:w16(0xff01)
    -- m1:w16(0x4444)

    -- m2:w16(rand(0, 0xffff)) -- 何のコードか忘れた
end
```

色変化系

```lua
function loop()
    for i = 0x023095f0, 0x0230962f, 4 do
        w32(i, rand(0, 0xffffffff))
    end
end
```


ルイージ細長&どんな気持ち煽り, キノピオおドム化

```lua
local v = 0
local t = 0
local n = 2
local rl = RL(120)
local c = Cnt(60)

function loop()
    w32(0x0217d528, 0) -- キノピオをおドム化
    w8(0x0217d419, 0x05)
    w8(0x0217d429, 0x14)
    w32(0x0217d440, 0xffffefff)
    w32(0x0217d444, 0x14000)
    if not rl() then return end
    t = t + n
    if c() then n = n + 1 end
    w32(0x0217d43c, stou32(math.sin(t / 20.0) * 0x2000))
end
```

キノピオ荒ぶり & ルイージさっ白

```lua
local r = RC(10)
local m = lib.at(0x0217d528)

function loop()
    w8(0x0228ba93, 0)
    w8(0x0217d441, 0x40)
    w32(0x0228ba30, 0)
    w32(0x0228ba60, 0)
    w8(0x0228c499, 0x40)
    if r() then
        m:w32(rand(0, 0xffff) << 8)
    end
end

lib.irume.start(function()
    local m1 = lib.at(0x03e07d4e)
    local mp1 = lib.at(0x03e07d57)
    local m2 = lib.at(0x03e07e1b)
    local m3 = lib.at(0x03e07e9b)
    local mp3 = lib.at(0x03e07e97)
    local mp4 = lib.at(0x03e07e57)
    local m4 = lib.at(0x03e07e4c)
    local c4 = Cnt(1, 2)
    return function()
        m1:w16(0x1212)
        mp1:w8(stou8(rand(-3, 3)))
        m2:w8(0x11)
        m3:w8(0x01)
        mp3:w8(stou8(rand(-3, 3)))
        mp4:w8(stou8(c4:next() * 2 - 1))
        m4:w32(0x0600000f)
    end
end)
```

ルイージフリーダムに大きさ・位置変化 & キノピオ悪い顔

```lua

local i = 0
local r = Cnt(3)


local r2 = Cnt(1)
-- local r2 = Cnt(20)

local eyes = {
    function() w8(0x0228ba7d, 0) end,
    function() w8(0x0228ba7d, 0x20) end,
    function() w8(0x0228ba7d, 0x3f) end,
    function() w8(0x0228ba7d, 0x60) end,
    function() w8(0x0228ba7d, 0x80) end,

    function() w8(0x0228ba81, 0x0c) end,
    function() w8(0x0228ba81, 0x16) end,
    function() w8(0x0228ba81, 0x13) end,
    function() w8(0x0228ba81, 0x10) end,
    function() w8(0x0228ba81, 0x03) end,
    function() w8(0x0228ba81, 0x20) end,
}
local kino_c = Cnt(4)
function loop()
    if r() then
        i = (i + 1) % 0x180
    end
    w8(0x022921b4, 0x21)
    if kino_c() then w32(0x0217d52C, 0) end
    if r2() then
        eyes[rand(1, #eyes)]()
        w8(0x0217d419, rand(1, 0x80))
        w8(0x0217d421, rand(1, 0x80))
        w8(0x0217d441, rand(1, 0x80))
        w32(0x0217d444, stou32(rand(-0x60000, 0x10000)))
    end
    -- w16(0x04000010, ((i & 0xff) << 4) | ((i & 0xff00) >> 4)) -- 背景をKGBさせる
end

lib.irume.start(function()
    local head = {
        0x03e07d40,
        0x03e07d40 + 0x40,
        0x03e07d40 + 0x40 * 2,
        0x03e07d40 + 0x40 * 3,
        0x03e07d40 + 0x40 * 4,
        0x03e07d40 + 0x40 * 5,
        0x03e07d40 + 0x40 * 6,
        0x03e07d40 + 0x40 * 7,
        0x03e07d40 + 0x40 * 8,

        0x03e07d40 + 0x40 * 9,
        0x03e07d40 + 0x40 * 10,
        0x03e07d40 + 0x40 * 11,
        0x03e07d40 + 0x40 * 12,
        0x03e07d40 + 0x40 * 13,
        0x03e07d40 + 0x40 * 14,
        0x03e07d40 + 0x40 * 15,
        0x03e07d40 + 0x40 * 16,
    }
    local r = RC(30)
    return function()
        for _, a in pairs(head) do
            w16(a + 0x0e, 0x1212)
            w8(a + 0x1a, 0x80)
            if r() then
                w8(a + 0x17, stou8(rand(-6, 6)))
            end
        end
    end
end)

```

背景を傾け & にしきかげ

```lua
w8(0x0228c48d, 0x03)

w8(0x0400100E, 0x10)

w8(0x04000240, 0xff)
w8(0x04000243, 0xff)

-- 高速化イルーム
lib.irume.start(function()
    local head = {
        0x03e07d40,
        0x03e07d40 + 0x40,
        0x03e07d40 + 0x40 * 2,
        0x03e07d40 + 0x40 * 3,
        0x03e07d40 + 0x40 * 4,
        0x03e07d40 + 0x40 * 5,
        0x03e07d40 + 0x40 * 6,
        0x03e07d40 + 0x40 * 7,
        0x03e07d40 + 0x40 * 8,

        0x03e07d40 + 0x40 * 9,
        0x03e07d40 + 0x40 * 10,
        0x03e07d40 + 0x40 * 11,
        0x03e07d40 + 0x40 * 12,
        0x03e07d40 + 0x40 * 13,
        0x03e07d40 + 0x40 * 14,
        0x03e07d40 + 0x40 * 15,
        0x03e07d40 + 0x40 * 16,
    }
    local r = RC(3)
    local m = lib.at(0x03e07d40)
    return function()
        for _, a in pairs(head) do
            if r() then
                m:with(a + 0x24):Tadd8(1, rand(-15, -3), 1)
                -- (a + 0x24, stou8(rand(-6, 6)))
            end
        end
    end
end)
```

どすこい距離 & 目がサイバー風に & 何度もおじぎ

```lua
local st = 0xa
local ed = 0x3ff

local rl = RL(150)

local n = 60

local c = Cnt(1, n + 1)

local bc = Cnt(60)
local bowing = false
local bi = 0
local b_n = 0
local function ease_in_out(x)
    local x2 = -2 * x + 2
    return x < 0.5 and 4 * x * x * x or 1 - x2 * x2 * x2 / 2.0
end
local function do_bow(n)
    bi = 0
    b_n = n
    bowing = true
end
local function update_bow()
    if not bowing then return end
    bi = bi + 1
    if bi == b_n then
        bowing = false
    end
    w32(0x0217d434, stou32(math.floor(math.sin(ease_in_out(bi / b_n) * math.pi) * (-0xf00))))
end

function loop()
    w8(0x0217d419, 0x40)
    w8(0x0217d441, 0x20)
    w8(0x0217d445, 0x70)
    w8(0x0228ba91, 0x1e)
    w8(0x0228ba92, 0x20)
    if rl() then
        local x = c:next()
        w32(0x0228ba7c, math.floor(x * x * 256 / (n * n)) * (ed - st) + (st << 8))
        update_bow()
        if (not bowing) and bc() then
            do_bow(rand(20, 60))
        end
    else
        w32(0x0228ba7c, 0x1d00)
    end
end

lib.irume.start(function()
    local m = lib.at(0x03e07eac)
    local p = lib.at(0x03e07e97)
    local r = RC(30)
    local mute1 = lib.at(0x03e07e62)
    local mute2 = lib.at(0x03e07e22)
    return function()
        if r() then
            m:w32(0x02182A93)
            p:w8(stou8(rand(-6, 6)))
        end
        mute1:w16(0)
        mute2:w16(0)
    end
end)
```

ホラーピーチにしき & 左右あらぶり

```lua

local tate = lib.at(0x022f657c)
local yoko = lib.at(0x022f6580)
local tate_c = RC(2)
local yoko_c = RC(2)
local m2 = lib.at(0x022f661c)
local m3 = lib.at(0x022f6614)
local c = Cnt(4)
local V = 0
local p1 = lib.at(0x022f678c)
local rl = RL(330)
function loop()
    p1:w32(0x22222222)
    V = math.min(V + 0x5000, 0xffffff)
    if c:next() < 2 then m2:w32(V)
    else m3:w32(V)
    end
    if rl() then
        if tate_c() then tate:add32(rand(-0x2, 0x2) * 0x1000) end
        if yoko_c() then yoko:add32(rand(-0x2, 0x2) * 0x1000) end
    end
end

lib.irume.start(function()
    local voice1 = 0x03e07e40
    local voice2 = 0x03e07e80
    local voice_p = 0xfd
    local voice_p_c = Cnt(120)
    local head = 0x03e07d40
    local as = {}
    local idxes = {0,1,2,3, 6, 7,8,9,10,11,12,13,14,15,16}
    local rl = RL(600)
    local not_yet = true
    for _, i in pairs(idxes) do as[i] = head + 0x40*i end
    return function()
        if voice_p_c() then
            voice_p = voice_p - 4
        end
        w16(voice1 + 0x0e, 0x7f7f)
        w16(voice2 + 0x0e, 0x7f7f)
        w8(voice1 + 0x17, voice_p)
        w8(voice2 + 0x17, voice_p)
        if rl() then
            if not_yet then
                not_yet = false
                print("DODO")
            end
            for _, a in pairs(as) do
                w8(a + 0x17, stou8(rand(-1, 0)))
            end
        end
    end
end)
```
