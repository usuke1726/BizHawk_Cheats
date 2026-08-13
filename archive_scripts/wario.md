
# さわる メイドインワリオ


```lua
-- さわるメイドインワリオ

-- イルーム: 0x3E0BBB0付近
--- offset
--- 0x17 pitch
--- 0x0e vol(2 byte LE signed)
--- 0x19 vib (19: speed(大きいほど遅い), 1b: depth)


CLS()

lib.irume.start(function()
    local head = 0x3E0BBB0
    local as = {}
    for i = 0, 16 do as[i] = head + i*0x40 end
    local r = RC(60)
    return function()
        for i = 0, 16 do
            -- w16(as[i] + 0x0e, 0x7777)
            w8(as[i] + 0x19, 0x21)
            w8(as[i] + 0x1b, 0xfb)
            if r() then
                w8(as[i] + 0x17, stou8(rand(-6, 6)))
            end
        end
    end
end)

local r = RC(30)
function loop()
    if r() then
        -- local _v = rand(0, 0x01)
        -- local v = 0
        -- for i = 0, 3 do v = (v << 8) | _v end
        for i = 0x06080000, 0x608ffff, 4 do
            w32(i, r32(i + rand(-1, 1)))
        end
    end
    if r() then
        local e = rand(0x64802ff, 0x64805ff) | 0x3
        for i = 0x06480000, e, 4 do
            w32(i, 0)
        end
    end
    if r() then
        local _v = rand(1, 3) == 1 and rand(0, 0xff) or 0
        local v = 0
        for i = 0, 3 do v = (v << 8) | _v end
        local s = rand(0x06488000, 0x648b000) & 0xfffffffc
        local b = rand(0x1000, 0x2000)
        -- local e = rand(0x6488fff, 0x648afff) | 0x3
        for i = 0, b-1, 4 do
            w32(s + i, v)
        end
    end
    if r() then
        local s = rand(0x06300000, 0x638ffff)
        local b = rand(0x2000, 0x10000)
        for i = 0, b-1, 4 do
            w32(s + i, r32(s + i + rand(-0x200, 0x100)))
        end
    end
end

print("OK")
```

## video15 アシュリー

```lua
-- イルーム1 (ミニゲームが始まるまでのムービー部分)
lib.irume.start(function()
    local head = 0x3E0BBB0
    local p1 = 0x17
    local p2 = 0x10
    local vib1 = 0x19
    local vib2 = 0x1b
    local r = RC(10)
    local r2 = RC(90)
    local as = {}
    local vibs = {}
    for i = 0, 17 do
        as[i] = head + i*0x40
        vibs[i] = 0
    end
    local c = Cnt(5, 2)
    return function()
        c()
        for i, a in pairs(as) do
            if r2() then
                vibs[i] = rand(0, 7)
            end
            w8(a + vib1, 0x00)
            w8(a + vib2, vibs[i])
            w16(a + p2, c.i == 1 and 0x80 or 0)
            w8(a + p1, rand(-12, 12))
        end
    end
end)
```

```lua
-- イルーム2 (ミニゲーム開始してからほんのちょっと待って実行)

lib.irume.start(function()
    local head = 0x3E0BBB0
    local p1 = 0x17
    local p2 = 0x10
    local r = RC(10)
    local c = Cnt(10)
    local as = {}
    for i = 0, 17 do as[i] = head + i*0x40 end
    local tone = lib.htob("00007F7F0002")
    return function()
        c()
        -- 音声の部分はここ? BF1C, BF50
        for i, a in pairs(as) do
            if c.fired then
                -- w16(a + p2, rand(-0x200, 0x400))
                w16(a + p2, rand(-0x100, 0x100))
            end
            if r() then
                add8(a + 0x24, rand(-2, 2), 1)
            end
            -- w8(a + p1, rand(-12, 12))
            if not within(r32(a + 0x2c), 0x021EFBDA, 0x021F006F) then
                w32(a + 0x2c, 0x021EFBDA)
            end
            lib.warr(a + 0x6, tone)
        end
    end
end)
```

```lua

local M1 = 0x100
-- local M1 = 0x80
local M2 = 0x20
local W = (M1 * 4) // M2

local img = lib.image.filterObj()
:width(W)
:height(0x20)

local head_tmp
gra_active = true
start_n = 4

local function pos(x, y)
    return lib.pos.Morton(x, y, 4, M2, M1) + head_tmp
end
local r = RC(30)

function loop()
    if not gra_active then return end
    if start_n < 0 or start_n >= 5 then return end
    local i = 0x06000000 + start_n * 0x100000
    while i <= 0x064fffff do
        if r32(i) ~= 0 then
            head_tmp = i
            if r() then
                img:go(function(x, y)
                    local _y = y // 2
                    return pos(x, y), r8(pos(x, _y))
                end)
            end
            i = i + W * 0x20
        else
            i = i + 4
        end
    end
end

-- lib.fill_in(0x06400000, 0x064fffff)
```

```lua
-- 制御用
gra_active = not gra_active
print("GRA " .. (gra_active and "=ON=" or "off"))

start_n = 5
```


