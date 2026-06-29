
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
