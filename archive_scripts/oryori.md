
# お料理ナビ

発話文字を強引に変更(フリーズ率高め)

```lua
local preset = {
-- {0x73, 0x14, 0x3b, 0x00, 0x00, 0x10, 0x2a, 0x3b},
{0x00, 0x00, 0x11, 0x00, 0x00, 0x11, 0x21, 0x00}, -- 「あ」？
-- {0x2a, 0x00, 0x0a, 0x00, 0x00, 0x0a, 0x15, 0x00}, -- 「い」？
}

local is_first = false
local values = {}
local function all_zero(addr)
    for i = 0, 7 do
        if r8(addr + i) ~= 0 then return false end
    end
    return true
end
function loop()
    if is_first then
        is_first = false
        for i = 0x2211c000, 0x2211ffff, 8 do
            -- if r8(i) ~= 0 then
            if not all_zero(i) then
                local news = {}
                for j = 0, 7 do
                    news[j + 1] = r8(i+j)
                end
                values[#values+1] = news
                -- w8(i, rand(1, 0xff))
            end
        end
    end
    for i = 0x2211b700, 0x2211ffff, 8 do
        if not all_zero(i) then
        -- if r8(i) ~= 0 then
            -- local n = values[rand(1, #values)]
            local n = preset[rand(1, #preset)]
            for j = 0, 7 do
                w8(i + j, n[j + 1])
            end
        end
    end
end
```


発話文字を強引に変更 その2(フリーズ率高め)

```lua
local function all_zero(addr)
    for i = 0, 7 do
        if r8(addr + i) ~= 0 then return false end
    end
    return true
end

local A = {0x00, 0x00, 0x11, 0x00, 0x00, 0x11, 0x21, 0x00}

local addrs = {
0x03eb9227,
0x03eb9267,
0x03eb92A7,
0x03eb92E7,
0x03eb9327,
0x03eb9367,
0x03eb93A7,
0x03eb93E7,
0x03eb9427,
0x03eb9477,
0x03eb94A7,
0x03eb94E7,
0x03eb9527,
0x03eb9567,
0x03eb95A7,
}
function loop()
    for i = 1, #addrs do
        if rand(1, 30) == 1 then
            w8(addrs[i], rand(0, 8))
        end
        if rand(1, 30) == 1 then
            w8(addrs[i]+3, rand(0, 8))
        end
        -- if rand(1, 60) == 1 then
        --     w8(addrs[i] + 4, stou8(rand(-5, 5)))
        -- end
        if rand(1, 60) == 1 then
            -- 00, 04, 07, 08
            w8(addrs[i] - 0x11, rand(1, 8))
        end
    end
    -- for a = 0x023cf400, 0x023cffff do
    --     if within(r8(a), 0x10,0x1f) then
    --     w8(a, rand(0x10, 0x1f))
    --     end
    -- end
    -- w16(0x023cff24, rand(0, 0xffff))
        -- w8(addr, rand(0, 8))
    -- end
    -- w16(0x023d0852, rand(0, 0xffff))

    -- for i = 0x0211b700, 0x0211bfff, 8 do
    --     if not all_zero(i) and rand(1, 10) == 1 then
    --     -- if r8(i) ~= 0 then
    --         -- local n = values[rand(1, #values)]
    --         for j = 0, 7 do
    --             w8(i + j, A[j + 1])
    --         end
    --     end
    -- end
end
```


色々試行錯誤

```lua
-- 「ください」
-- SJIS: lib.htob("82ad82be82b382a2")

-- FOUND 0x003A6D03 (ROM)

-- lib.findr(0x00300000, 0x003FFFFF, lib.htob("82ad82be82b382a2"))

-- _, addrs1 = lib.find_all(0x02000000, 0x02ffffff, lib.htob("82bb"), nil, true)
-- _, addrs2 = lib.find_all(0x02000000, 0x02ffffff, lib.htob("82ea"), nil, true)

-- print(string.format("found %d, %d", #addrs1, #addrs2))

local chars = {}
for i = 0x4f, 0x58 do chars[#chars+1] = i end
for i = 0x60, 0x79 do chars[#chars+1] = i end
for i = 0x81, 0x9a do chars[#chars+1] = i end
for i = 0x9f, 0xf1 do chars[#chars+1] = i end

-- local i = 0x02345f00
-- while i < 0x02345f2f do
local i = 0x02345000
while i < 0x023fffff do
    local v1 = r8(i)
    local v3 = r8(i + 2)
    if v1 == 0x82 and v3 == 0x82 then
        w8(i + 1, chars[rand(1, #chars)])
        w8(i + 3, chars[rand(1, #chars)])
        i = i + 3
    end
    i = i + 1
end

-- for _, i in pairs(addrs1) do
--     for _, j in pairs(addrs2) do
--         if math.abs(i - j) <= 0x20 then
--             print(string.format("NEAR (%08X, %08X)", i, j))
--         end
--     end
-- end

-- for _, ad in pairs(addrs) do
--     local a = {}
--     for i = 0, 7 do
--         a[#a+1] = _HEX(r8(ad + i), 2, true)
--     end
--     print(string.format("0x%08X: %s", ad, table.concat(a, " ")))
-- end

-- lib.find(0x02000000, 0x02ffffff, lib.htob("82bb82ea"))
-- lib.find(0x03000000, 0x03ffffff, lib.htob("82bb82ea82c582cd"))

-- sjis.print_range(0x003a2e41, 0x003a6d9d, ROM_DOMAIN_NAME)
-- sjis.print_range(0x003a6cd0, 0x003a6d3d, ROM_DOMAIN_NAME)
```
