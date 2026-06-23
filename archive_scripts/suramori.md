
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
