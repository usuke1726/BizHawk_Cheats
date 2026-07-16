
# スラもり2

イルーム & メタキンの盾に何度か雷が落ちてからかいめつフリーズ

```lua
local i = 400
local cnt = 0
local N = 40
local cnt2 = 0
function loop()
    w8(0x03f98b94, math.max(r8(0x03f98b94) - 1, 1))
    w8(0x03f98bc7, 0x03)
    w8(0x03f98c07, 0x03)
    w8(0x03f98c0b, 0xff)
    w8(0x03f98e07, stou8(rand(-2, 2)))
    i = i - 1
    local thund = 0x02154e04
    cnt = (cnt + 1) % N
    if cnt == 0 then
        cnt2 = cnt2 + 1
        N = N - 2
        if i > 0 then w8(thund, 0x12)
        else
            -- fill_in(0x2152000, 0x216ffff, 0xff)
            w8(0x021498ee, 0x01)
            w8(0x021498e9, 0xff)
            w8(0x021498dc, 0xff)
            w8(0x021498d8, 0xff)
            if i < 0 then
            w8(thund, 0x13)
            error("DONE")
            end
        end
    end
end
```

イルーム(初期版のコード？)

```lua
function loop()
    w8(0x03f98b94, math.max(r8(0x03f98b94) - 1, 1))
    w8(0x03f98bc7, 0x03)
    w8(0x03f98c07, 0x03)
    w8(0x03f98c0b, 0xff)
    w8(0x03f98e07, stou8(rand(-2, 2)))
end
```

## video9

```lua

local addrs = {}

local r = RC(40)

function loop()
    -- for i = 0x02154D80, 0x02154FFF do
    for i = 0x02153D80, 0x02156FFF do
        if r8(i) == 0x8A then
            addrs[#addrs+1] = i
        end
    end
    for _, a in pairs(addrs) do
        if r8(a) == 0x8A or r() then
            w8(a, 0xC1)
        end
    end
end

lib.irume.start(function()
    local head = 0x03f98AF0
    local as = {}
    local ps = {}
    local A = 0x80
    local vs = {
        0x1080,0x1080,0,0,0,
        A,A,A,A,A,
        A,A,A,A,A,A,
        0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,
    }
    for i = 0, 16 do
        as[i] = head + 0x40*i
        ps[i] = -12
    end
    local r = RC(40)
    return function()
        for i, a in pairs(as) do
            if r() then
                ps[i] = rand(-24, -4)
            end
            w16(a + 0x0e, vs[i+1])
            w8(a + 0x17, stou8(ps[i]))
            w16(a + 0x1a, 0x0202)
        end
    end
end)

-- 途中で実行する1
-- lib.fill_in(0x0235d3ED, 0x0235FFFF, 0xcf)

-- 途中で実行する2
-- lib.fill_in(0x02235311, 0x0223F675, 0x82)
```

メモ

```plaintext
画面ノイズ?
0x0266ED50 -- 0x0267A72F (0xb4)

地面判定がおかしくなる?
0x02235311 -- 0x0223F675 (0x82)

フリーズ
0x02B4B735 -- 0x02B51EF8 (0x84)


主人公が消える?
0x024B2463 -- 0x024BB107 (0x83)
0x022D60F2 -- 0x022E0646 (0x11)



0x022FCE52 -- 0x02306407 (0xee)

アイテムスプライト破壊
0x026B4AF4 -- 0x026BF17D (0x5b)

投げられなくなる
0x02C4E889 -- 0x02C549FA (0x81)

敵戦車崩壊
0x027638BD -- 0x0276DE11 (0xeb)

画面崩壊&動かなくなる
0x02479BAF -- 0x0247EC48 (0x42)

下画面の背景が白くなる
0x0223BB83 -- 0x0224776B (0xb0)

戦車かいめつ
0x023503ED -- 0x0235B859 (0xcf)


2154DC2 -> 8Aから投げると80 -> 8aに戻すとアイテムが手元に戻る->そこでスラストライクでフリーズ あるいは、c0にすると発砲されるが自分の戦車にあたる
```

