
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

