
# ポケモンレンジャー

HP: `0x0224413C`, `0x0224418C`

## プラスル(or マイナン) キャプチャ前に自由に移動する

```lua
local xp = 0x02214960
local yp = 0x02214968

local m = lib.at(0x02000000)
function loop()
    local xd, yd = 0, 0
    if DS.key.get("Right") then
        xd = 0x800
    elseif DS.key.get("Left") then
        xd = -0x800
    end
    if DS.key.get("Up") then
        yd = -0x800
    elseif DS.key.get("Down") then
        yd = 0x800
    end
    m:with(xp):add32(xd)
    m:with(yp):add32(yd)

    -- Aを押したらその場で衝突扱いにする
    if DS.key.get("A") then
        w32(0x02214960, 0x44444444)
    end
end
```

## とりあえず、移動の際に値が変わるアドレスを見つけては適当にいじって反応を調べようとしたヤツ

```lua
function loop()
    w32(0x02134388, rand(0, 0x00ff))
    w32(0x02134390, rand(0, 0x00ff))
    w32(0x021339A0, rand(0, 0xffff))
    w32(0x021339A8, rand(0, 0xffff))
    w32(0x021339AC, rand(0, 0xffff))
    w32(0x021339B4, rand(0, 0xffff))

    w32(0x021E19F4, rand(0, 0xffff))
    w32(0x021E19FC, rand(0, 0xffff))
    w32(0x021E1A00, rand(0, 0xffff))
    w32(0x021E1A08, rand(0, 0xffff))

    w32(0x021E08D8, rand(0, 0xffff))
    w32(0x021E08E8, rand(0, 0xffff))

    local ps = {
        0x21345D4,
        0x21345F8,
        0x213461C,
        0x2134640,
        0x2134664,
        0x2134688,
        0x21346AC,
        0x21346D0,
        0x21E0948,
        0x21E1A5C,
        0x221A14C,
        0x221A178,

        0x221A3E4,
        0x221A4A8,

        0x221A4B4,
        0x221A4C0,
        0x221A5FC,
        0x221A684,
        0x221A68C,
        0x227AF64,
        0x227AF70,
    }
    local m = lib.at(0x2200000)
    for _, i in pairs(ps) do
        m:with(i):add32(rand(-0xfff, 0xfff))
        -- w32(i, rand(0, 0xffff))
    end
end

-- ===================================================
-- ===================================================
-- ===================================================

function loop()
    w32(0x021343B8, rand(0, 0xffffffff))
    w32(0x021343DC, rand(0, 0xffffffff))
    w32(0x02134400, rand(0, 0xffffffff))
    w32(0x02134424, rand(0, 0xffffffff))
    w32(0x02134448, rand(0, 0xffffffff))
    w32(0x0213446C, rand(0, 0xffffffff))
    w32(0x022136F8, rand(0, 0xffffffff))
    w32(0x02214018, rand(0, 0xffffffff))
    w32(0x0221489C, rand(0, 0xffffffff))
    w32(0x022148A4, rand(0, 0xffffffff))
    w32(0x0221496C, rand(0, 0xffffffff))
    w32(0x02214974, rand(0, 0xffffffff))
    w32(0x02214978, rand(0, 0xffffffff))
    w32(0x02214980, rand(0, 0xffffffff))

    w32(0x02215B78, rand(0, 0xffffffff))
    w32(0x02216498, rand(0, 0xffffffff))
    w32(0x022176D8, rand(0, 0xffffffff))
    w32(0x02218918, rand(0, 0xffffffff))
    w32(0x022208d8, rand(0, 0xffffffff))
    w32(0x02215258, rand(0, 0xffffffff))
    w32(0x02216DB8, rand(0, 0xffffffff))
    w32(0x02217FF8, rand(0, 0xffffffff))
    w32(0x02219238, rand(0, 0xffffffff))
    w32(0x02222438, rand(0, 0xffffffff))
end

-- ===================================================
-- ===================================================
-- ===================================================

local addrs = {
-- 0x021339A0,
-- 0x021339A8,
-- 0x021339AC,
-- 0x02134388,
-- 0x02134394,
-- 0x02134398,
-- 0x021343B8,
-- 0x021343DC,
-- 0x02134400,
-- 0x02134424,
-- 0x02134448,
-- 0x0213446C,
-- 0x021344A4,
-- 0x021344AC,
-- 0x02134C98,
-- 0x021E08D8,
-- 0x021E0938,
-- 0x021E19F4,
-- 0x021E1A00,
-- 0x021E1A54,
-- 0x022136F8,
-- 0x02214018,
-- 0x0221460C,
-- 0x02214630,
-- 0x0221489C,
-- 0x022148A4,
0x02214960,

-- 0x02214968,

-- 0x0221496C,
-- 0x02214974,
-- 0x02214978,
-- 0x02214980,
-- 0x02214AB4,
-- 0x02214B38,
-- 0x02214B3C,
-- 0x02214B40,
-- 0x02214B44,
-- 0x02214B48,
-- 0x02214B4C,
-- 0x02214C64,
-- 0x02215258,
-- 0x02215B78,
-- 0x02216498,

-- 0x02216DB8,
-- 0x022176D8,
-- 0x02217FF8,
-- 0x02218918,
-- 0x02219238,
-- 0x02220148,
-- 0x022208D8,
-- 0x02222438,
-- 0x02274850,
-- 0x0227485C,
-- 0x022ACC10,
-- 0x022ACC14,
-- 0x022ADF78,
-- 0x022ADF7C,
}

local xp = 0x02214960
local yp = 0x02214968

local m = lib.at(0x02000000)
function loop()
    local xd, yd = 0, 0
    if DS.key.get("Right") then
        xd = 0x800
    elseif DS.key.get("Left") then
        xd = -0x800
    end
    if DS.key.get("Up") then
        yd = -0x800
    elseif DS.key.get("Down") then
        yd = 0x800
    end
    m:with(xp):add32(xd)
    m:with(yp):add32(yd)

    if DS.key.get("A") then
        w32(0x02214960, 0x44444444)
    end

    -- for _, i in pairs(addrs) do
    --     -- m:with(i):add32(0xfff)
    --     -- m:with(i):add32(rand(-0xfff, 0xfff))
    --     w32(i, rand(0, 0xffffffff))
    -- end
end
```
