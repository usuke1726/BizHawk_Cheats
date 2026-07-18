
# サカつくDS

## 雑多メモ

```plaintext
背景真っ黒？
0x023F4E14 -- 0x023FB73E (0xa6)
0x02C0166B -- 0x02C0BD00 (0x33)
0x027CB1C8 -- 0x027D83D8 (0x71)
0x028062DE -- 0x0280DD5F (0x5b)
のどれか

文字消える？
0x02C80241, 0x02C88ABE, 0x67)


顔がおかしくなる
0x0245CDEB -- 0x0246AD7E (0xd8)
-- 下画面のアイコンがおかしくなる方
-- lib.fill_in(0x02460000, 0x02463FFF, 0xd8)

画面ブラックアウト?
0x02859C2A -- 0x02866F68 (0x59)


体がつぶれる
0x026E7347 -- 0x026EE770 (0xb7)

ポリゴン部分の領域？
start: 26E6858
end: 26E83E7
その後、8A19までindex?


26E67F9 -> 01とかにするとずれる

26CFC70 -> 芽衣のポリゴン崩壊?
FCB0, FCB1で顔の色変更?
顔の色:
芽衣: w16(FC90: 0033, 1033, 3333, 0000
直実: w16(FCB0: 3333, 3312, 3360, 3310, 3433
彩香: w16(FCA0: 3333, 3312, 3360, 3310



26CE800あたりで直実の顔面崩壊

26E6828: 直実のx座標
26E682C: 直実のy座標
26E6830: 直実のz座標(カメラからの距離)

```


## video10 体を徐々にゆがませる

```lua
local m = lib.at(0x02000000)

local scale = 0x40
local i = 0
local r = RC(90)

function loop()
    i = (i + 1) % 60
    local v = math.round(math.sin(i * 2 * math.pi / 60) * scale)
    local a = 0x026E6700
    while a <= 0x026E69FF do
        local __v = r32(a) & 0xffffff
        if __v == 0x003B38 or __v == 0x003A38 then
            for j = 1, 3 do
                a = a + 4
                -- if r() then
                --     m:with(a):w32(stou32(rand(-0x100, 0x100)))
                -- else
                    -- m:with(a):add32(v)
                -- end
                m:with(a):add32(rand(-scale, scale))
            end
        end
        a = a + 4
    end
end
```
