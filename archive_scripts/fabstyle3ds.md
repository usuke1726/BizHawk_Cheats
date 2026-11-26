
# FABSTYLE(3DS版)

文字コードはDS版と同じっぽい？


## 11/25 FabStyle15周年記念バグ(Discordにupしたやつ)

```lua
-- 中央位置アキラが登場する前に実行
lib.warr(0x0629196D, htob( -- 15周年… おめでたいですねェ...
"31358efc944e81630ab5d2c3dec0b2c3debdc81b4baa1b488163050505"
))

-- 中央位置アキラが登場した後に実行
local head = 0x00B0B140
local iend = 0x00B0CFFF

local function utof32(v)
    return (string.unpack(">f", string.pack(">I4", v)))
end
local function ftou32(v)
    return (string.unpack(">I4", string.pack(">f", v)))
end

local i = head
while i <= iend do
    i = i + 8
    for j = 1, 3 do
        local x = utof32(r32(i + 0))
        local y = utof32(r32(i + 4))
        local z = utof32(r32(i + 8))
        x = x * 3.0
        y = y * 3.0
        z = z + 1.0

        y = y - 2.0

        local x2 = math.abs(x)
        -- 15回だったどうかは忘れたけど大体その辺り
        local count = 15
        if within(y, -1, 1) and within(x2, 0, 1) then
            y = y + x2 * 0.1 * count
        end
        w32(i + 0, ftou32(x))
        w32(i + 4, ftou32(y))
        w32(i + 8, ftou32(z))
        i = i + 12
    end
end
```

