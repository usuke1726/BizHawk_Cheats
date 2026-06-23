
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

