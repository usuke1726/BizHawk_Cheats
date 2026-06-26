
# A列車で行こう DS

資金: 0x0215E374 (8 byte signed LE)
負の値になった瞬間にゲームオーバー

サウンド 0x03CE8670あたりから

文字コードは **UTF-16 LE**

テキスト幅
「画面下にある進むボタンで次に進みます。」が最大限 -> 19文字


会社のお終いだァーーー！テキスト & アゴ & game over BGMにつを与える
```lua
-- 倒産しましたの文字はここらへん
-- lib.fill_in(0x06500000, 0x065fffff, 0xff)

-- 人物の立ち絵
-- lib.fill_in(0x06603700, 0x06606fff, 0x42)

local function nishiki()

local block_width = 0x10
local block_span = 0x40
local blockline_span = 0x100
local W = block_width * (blockline_span // block_span)

local function offset_to_abs(v)
    return (v & 0xff) | ((v & 0xffffff00) << 1) | 0x100
end
-- 仮想座標から物理アドレスへ
local function change_pos(x, y)
    local a, b, c = block_span, blockline_span, block_width
    local v = W*y + x
    local v2, v3 = v % b, v // b
    local A1, A2 = v2 % W, v2 // W
    local C1, C2 = A1 % c, A1 // c
    local V1 = A2*c + C2*a + C1
    return offset_to_abs(v3*b + V1) + 0x06604d80
end

local vs = {}
local x, y = 0, 0
for i = 0x06604d80, 0x06605d7f, 4 do
    local _i = i - 0x06604d80
    if _i & 0x100 ~= 0 then
        local v1 = (_i & 0xfffffe00) >> 1
        local v2 = (_i & 0xff)
        local v = v1 | v2
        vs[change_pos(x, y)] = r32(change_pos(x, math.floor(y * 0.3)))
        x = (x + 4) % W if x == 0 then y = y + 1 end
    end
end
for i, v in pairs(vs) do
    w32(i, v)
end

end

local function change_text()
-- 資金が底をついたの会話は、 0x021C8644から
-- お終いだァーーーー！
lib.warr(0x021c862A,
lib.htob(
-- 我々はもうお終いだァーー！
"116205306f30823046304a30427d44306030a130fc30fc3001ff"

-- 我々はもうお終いだｧーー！
-- "116205306f30823046304a30427d4430603067fffc30fc3001ff"

.. "1a4f3e796e304a30427d44306030a130fc30fc30fc30fc30fc3001ff"
)
)
end

local state = 0
function loop()
    if state == 0 then
        if r8(0x021c862A) == 0x11 then
            print("FIRED")
            state = 1
            change_text()
        end
    elseif state < 3 then state = state + 1
    elseif state == 3 then
        nishiki()
        state = 4
    end
end

lib.irume.start(function()
    local m = lib.at(0x03ce8e91)
    return function()
        if m:r8() == 0x17 then m:w8(0x05) end
    end
end)
```

凍えている感じのにしきがお & テキスト

```lua
local function nishiki()
    local V = 0xff
    for i = 0x06603700, 0x06606fff do
        local v = r32(i)
        local _v = 0
        for i = 0, 3 do
            local _tmp = (v >> (i*8)) & 0xff
            local __v = _tmp
            if __v == 0xde then __v = V
            elseif __v == 0x8f then __v = V
            elseif __v == 0x84 then __v = V
            elseif __v == 0x9a then __v = V
            elseif within(__v, 0x20, 0x9f) then __v = V
            end
            _v = _v | (__v << (i*8))
        end
        w32(i, _v)
    end
end


local function change_text()
    lib.warr(0x021c862A,
    -- 私はもうお終いですョ
    lib.htob("c1796f30823046304a30427d443067305930e7300000")
    )
    lib.warr(0x021C8644,
    -- 冷凍庫の温度が底をつきました！
    -- lib.htob("b751cd51ab5e6e30296ea65e4c30955e923064304d307e3057305f3001ff0000")
    -- 冷凍庫の温度が底に達しました！
    lib.htob("b751cd51ab5e6e30296ea65e4c30955e6b30549057307e3057305f3001ff0000")
    )
end

local state = 0
function loop()
    if state == 0 then
        if r8(0x021c862A) == 0x11 then
            print("FIRED")
            state = 1
            change_text()
        end
    elseif state < 3 then state = state + 1
    elseif state == 3 then
        nishiki()
        state = 4
    end
end

lib.irume.start(function()
    local m = lib.at(0x03ce8e91)
    local c = 0
    local N = 240
    return function()
        if m:r8() == 0x17 then m:w8(0x30) c = 1 end
        if within(c, 1, N) then
            c = c + 1
            if c > N then
                m:w8(0x02)
            end
        end
    end
end)
```


証券社員のあらぶり(未使用。株式のメニュー画面で有効。)

```lua
local vs = {0, 1, 2}
local c = Cnt(2, #vs)
w8(0x0233faf4, 2)
function loop()
    w8(0x0233faf4, vs[c:next() + 1])
end
```

- `0x023362aC -> A3 or c1` <= ゲームオーバーの立ち絵を崩壊させられる？(動画未収録)

立ち絵データの取得：

```lua
-- lib.fill_in(0x06626380, 0x06628f7f, 0x42) -- 2bff surprise
-- lib.fill_in(0x06608f80, 0x0660bb7f, 0x42) -- 2bff smile
-- lib.fill_in(0x06623780, 0x0662637f, 0x22) -- 2bff normal

lib.range(0x06608f80, 0x0660bb7f):save():print() -- smile
-- lib.range(0x06626380, 0x06628f7f):save():print() -- surprise
-- lib.range(0x06623780, 0x0662637f):save():print() -- normal
```

23800F4を違う値に設定すると、いちいち立ち絵がスライドインする

