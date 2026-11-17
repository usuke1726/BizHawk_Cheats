
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

## オーディオ関連

- baseアドレス: `0x03E78CE0`から`0x40`ごと
- volume: `0x16` (signed 2 byte LE)
- p1: `0x1f` (signed 1 byte)
- p2: `0x18` (signed 2 byte LE)
- vib speed: `0x25` (unsigned 1byte)
- vib: depth: `0x26`, `0x27` (unsigned 1byte) 両方の総合点?
- vib delay: `0x28` (unsigned 2byte LE)
- vib ?: `0x23`
- time: `0x2c`

タイトルコールは音源再生型: `0x03E6951D`でスピードを変えるか、波形ごといじるか、のいずれか
`20F4280, 20F42FF`
`20F76E0, 20F78DF`
`21D9500, 21DA4FF` (0x1000)

## FAT関連

```
ROMのFNTは、RAMの0x02514C40からの領域にまるごとコピーされ、恐らくこちらが使われているものと思われる。

FATは、恐らく0x02110AA0からまるごとコピー
```

### FNT調査用スクリプト


```lua
local FNTaddress = 0x15B800
local FNTsize = 0x7EE1
local FATaddress = 0x163800
local FATsize = 0x41A0
local RAM_FAT_address = 0x02110AA0

---@param filenameAddr int
---@return int
local function findID(filenameAddr)
    local function findOffset()
        local firstOffset = FNTaddress + r32r(FNTaddress)
        local lastOffset = firstOffset
        for a = FNTaddress + 8, firstOffset - 1, 8 do
            local offset = r32r(a)
            if FNTaddress + offset > filenameAddr then
                local firstID = r16r(a - 4)
                print(string.format("FOUND OFFSET TABLE\n  addr: 0x%08X\n  offset: 0x%X\n  firstID: 0x%X", a-8, lastOffset, firstID))
                return lastOffset, offset, firstID
            end
            lastOffset = offset
        end
        return lastOffset
    end
    local offset, nextOffset, firstID = findOffset()
    local a = FNTaddress + offset
    local idOffset = 0
    while true do
        if a + 1 >= filenameAddr then
            local fileID = firstID + idOffset
            print(string.format("FOUND FILE ID: 0x%X", fileID))
            return fileID
        end
        local len = r8r(a)
        a = a + len + 1
        idOffset = idOffset + 1
        if a > FNTaddress + FNTsize then
            error("OUT OF FNT ADDRESS RANGE!!!")
        end
    end
end

---@param fileID int
local function print_FAT_ADDR(fileID)
    local ad1 = FATaddress + fileID * 8
    local ad2 = RAM_FAT_address + fileID * 8
    print(string.format("ROM: 0x%08X", ad1))
    print(string.format("RAM: 0x%08X", ad2))
end

print("TITLE ADRESS ID:")
local title_t = 0x1625F7 -- --> RAM: 0x021142F8
local title_p = 0x1625BB -- --> RAM: 0x021142E0
print_FAT_ADDR(findID(title_t))
-- print_FAT_ADDR(findID(0x15E734))

-- addr 0x167058
-- 002A4B01 006A4B01
```


## video13 「ケン・ジ」バグ & 飛行グラバグ ほか

```lua

local update_logo = function()
    -- ロゴ画像: 0x100で1行のラスタスキャン
    -- 2a00から 5affまで

    local function pos(x, y)
        return lib.pos.Raster(x, y, 0x100) + 0x014B2A00
    end

    local function hide(x, y)
        if within(y, 27, 34) and within(x, 0x90, 0x97) then return false end

        if within(x, 0, 0x2b) then return true end
        if within(y, 10, 19) and within(x, 0x2c, 0x33) then return true end
        if within(y, 20, 23) and within(x, 0x2c, 0x2f) then return true end
        if within(x, 0x49, 0x5f) then return true end
        if within(x, 0x80, 0xb0) then return true end
        if y >= 29 and within(x, 0x7b, 0x7f) then return true end
        if y >= 38 and within(x, 0x78, 0x7f) then return true end
        if y < 32 and within(x, 0x60, 0x63) then return true end
        if y > 31 and within(x, 0x45, 0x48) then return true end
        if y < 30 and within(x, 0xb0, 0xb3) then return true end
        if x >= 0xd8 then return true end
        if y >= 18 and x >= 0xd2 then return true end
        if y >= 29 and x >= 0xcc then return true end
        if y >= 38 and x >= 0xc8 then return true end
        return false
    end

    local vs = {}
    for y = 0, 48 do
        for x = 0, 0xff do
            -- if hide(x, y) then vs[pos(x, y)] = 0x66 end
            if hide(x, y) then vs[pos(x, y)] = 0 end
        end
    end
    for a, v in pairs(vs) do w8r(a, v) end

    lib.fill_in(0x00120000, 0x0012000F, 0x11, ROM_DOMAIN_NAME)
end



-- =================================
-- =======  キャラクターバグ =======
-- =================================

local UPDATE_READY = false

local function update_hinata()
    local function _p(x, y) return lib.pos.Morton(x, y, 0x04, 0x20, 0x80) end
    local function pos1(x, y) return _p(x, y) + 0x06401020 end
    local function pos2(x, y) return _p(x, y) + 0x064023a0 end
    ---@param f 1 | 2
    local function update(f)
        local pos = f == 1 and pos1 or pos2
        return function(x, y)
            -- local _y = y < 47 and y // 2 + 8 or y // 2 + 29
            local _y = y < 47 and y // 2 + 8 or y // 2 + 32
            return pos(x, y), r8(pos(x, _y))
        end
    end
    lib.image.filterObj()
    :width(16):bound(0x600)
    :go(update(1))
    lib.image.filterObj()
    :width(16):bound(0x600)
    :go(update(2))
end

local update_hayate = (function()
    local vs1 = {}
    local vs2 = {}
    local head1 = 0x06400a00
    local head2 = 0x06401fa0
    local headb = 0x06400e00
    local function pos(x, y) return lib.pos.Morton(x, y, 0x04, 0x20, 0x80) end
    local function setup()
        for i = 0, 0x400 - 1 do
            vs1[i] = r8(head1 + i)
            vs2[i] = r8(head2 + i)
        end
        for i = 0x400, 0x600 - 1 do
            vs1[i] = r8(headb + i - 0x400)
            vs2[i] = r8(headb + i - 0x400)
        end
    end
    -- local c = Cnt(4, 2)
    local c = Cnt(30)
    local is_first = true
    return function()
        if not UPDATE_READY then return end
        if is_first then
            is_first = false
            setup()
        end
        local _i = c:next()
        local v = {}
        -- 95 (0x60) = 0x600 / 0x80 * 8
        for y = 0, 95 do
            for x = 0, 15 do
                local scale = math.sin(_i * 2 * math.pi / c.n) * 0.5 + 1
                local _y = math.round(y * scale)
                -- local _y = _i == 1 and (y // 2) or (y // 3)
                v[pos(x, y)] = vs1[pos(x, _y)]
            end
        end
        for i = 0, 0x400 - 1, 4 do
            local _v = 0
            for j = 0, 3 do
                local __i = i + (3-j)
                _v = (_v << 8) | (v[__i] or 0)
            end
            w32(head1 + i, _v)
            w32(head2 + i, _v)
        end
        for i = 0x400, 0x600 - 1, 4 do
            local _v = 0
            for j = 0, 3 do
                local __i = i + (3-j)
                _v = (_v << 8) | (v[__i] or 0)
            end
            w32(headb + i - 0x400, _v)
        end
    end
end)()

local function update_plusle()
    local function to_black(begin, inclusiveEnd)
        for i = begin, inclusiveEnd, 4 do
            local v = r32(i)
            local v2 = 0
            for j = 0, 3 do
                v2 = v2 << 8
                local _v = (v >> (8*(3-j))) & 0xff
                if _v ~= 0 then v2 = v2 | 0x11 end
            end
            w32(i, v2)
        end
    end
    to_black(0x06401620, 0x064017df)
    to_black(0x064029a0, 0x06402b1f)
    to_black(0x064032e0, 0x0640345f)
    to_black(0x06403cc0, 0x06403e3f)
    for i = 0, 3 do
        w32(0x06401620 + 0xd0 + 4*i, i < 2 and 0x11113311 or 0x33111111)
        w32(0x064029a0 + 0x80 + 4*i, i < 2 and 0x11113311 or 0x33111111)
        w32(0x064032e0 + 0x80 + 4*i, i < 2 and 0x11113311 or 0x33111111)
        w32(0x06403cc0 + 0x80 + 4*i, i < 2 and 0x11113311 or 0x33111111)
    end
end

local update_drill = (function()
    local vs = {0x11, 0xaa, 0xdd}
    local c = Cnt(3, #vs)
    local function go(begin, inclusiveEnd)
        local function update_value(v, j)
            local s = (j * 3) // (inclusiveEnd - begin)
            return vs[((s+c.i) % #vs) +1] or 0x11
        end
        local k = 0
        for i = begin, inclusiveEnd, 4 do
            k = k + 4
            local v = r32(i)
            local v2 = 0
            for j = 0, 3 do
                v2 = v2 << 8
                local _v = (v >> (8*(3-j))) & 0xff
                if _v ~= 0 then v2 = v2 | update_value(_v, k) end
            end
            w32(i, v2)
        end
    end
    return function()
        if not UPDATE_READY then return end
        c()
        go(0x06400000, 0x064009ff)
        go(0x064017e0, 0x06401f9f)
        go(0x06402b20, 0x064032df)
        go(0x06403460, 0x06403cbf)
    end
end)()

local update_time = (function()
    local time = lib.at(0x021DA6D0)
    local time_ready = false
    local update_chara_done = false
    local target = 0x0410
    local time_write_r = RC(3)
    local time_write_c = Cnt(30)
    local target_r = RC(3)
    local target_t = 0x0410

    local function update_target(target)
        local vs = {
            0x03b7,
            0x03e9,
            0x0419,
            0x044a,
        }
        for _, v in pairs(vs) do
            if math.abs(target - v) <= 5 then return v end
        end
        return target
    end
    return function()
        if not time_ready then
            local t = time:r16()
            if t >= 0x0473 then
                time_ready = true
                time:w16(target)
            elseif (not UPDATE_READY) and t ~= 0 then
                UPDATE_READY = true
                print("== UPDATE READY ==")
                update_hinata()
                update_plusle()
            else return
            end
        end
        target = ilerp(target, target_t, 0.1)
        if time_write_c() or time_write_r() then
            time:w16(target)
        else
            time:add16(rand(0, 2))
        end
        if target_r() then
            target_t = update_target(rand(0x03c0, 0x046a))
        end
    end
end)()



-- =========================
-- =======  サウンド =======
-- =========================

local update_voice = (function()
    local ps_sc = 0.95

    local ps = {
        1.0 * ps_sc,
        5/4 * ps_sc,
        3/2 * ps_sc,
        5/4 * ps_sc,
        -- 2.0,
    }
    local cc = Cnt(7, #ps)

    local head = 0x21D9500
    local width = 0x1000
    local ready = RL(300)
    return function()
        if not UPDATE_READY then return end
        if not ready() then return end
        local scale = ps[cc:next() + 1]
        local vs = {}
        for i = 0, width-1, 2 do
            local _i = head + (math.round(i * scale) % width)
            vs[head + i] = r16(_i)
        end
        for a, v in pairs(vs) do
            w16(a, v)
        end
    end
end)()

update_logo()


function loop()
    update_hayate()
    update_drill()
    update_time()
    update_voice()
end

```


## テキストについて

- 文字コードを調べる
    - 主人公の名前入力中 `21ECDB6` -> 直接入力する場合に有効

## video13のテキストバグのテキスト案

<details>
<summary>テキスト</summary>
<div>

```
0x023DF6FA
おっと
わすれるところ　だった
>
おっと
わすれるところ　だった

0x023DF71C
レンジャーの　あかしである
「にんていしょう」を
きみに　さずけよう
(「: 0x0142, 」: 0x0143)
>
ジンジャーの　おかしである
「もホじるおべべ」を
きみに　おざきよう

0x023DF764
ほんらいなら　せいしきな
にんていテストを　うけてもらい
>
にほんえらいなら　いきな
にんてんテストを　うけてもらい

0x023DF7A0
その　ごうかくの　あかしとして
わたすもの　なのだが……
(…: 0x0147)
>
いその　どうくつの　あじと　
わたしのもの　なのだが……

0x023DF7DC
テストどころか
げんばでの　じっさいのトラブルに
きみは　みごとな　こたえをだした
>
ヒテストどころか
げまでの　じっさいのアラブルに
きみは　みさとな　こたえをだした

0x023DF832
レンジャーとして　にんていしない
りゆうなんて　どこにもないよ
>
レジャーとして　にんだいしたい
りゆうなんて　どこにもないある

0x023DF874
この　「にんていしょう」に
かかれていることを　よくよんで
ここに　サインをしてほしい
>
この　「にげてよいでしょう」に
つかれているひとを　くよくよんで
ここ　サインをっほい

== 認定証 ==

0xC10D38
<ちかいの　ことば>
>
ち　いいの　あかいの

0xC10D54
わたしは
>
るっざな
わたすは
わし^^

0xC10D60
ポケモンレンジャーとして
>
ヘゲマ　ロワコユ♀なさち
ツケモンシンジャーとして

0xC10D7C
ほこりと　ゆうきを　むねに
>
むぐゅと　ゃぉげん　まねば
ほこりと　ほうきを　あねに

0xC10D98
こまっている　ひとを　たすけ
>
ごぼぢないょ　ぶづを　ぜぜこ
こまっている　ひとをまるやき

0xC10DB8
しぜんを　まもりつづけることを
>
ごずゎゐ　ほもゎだどきらぐなろ
かいんを　きもりつづけンジャー

0xC10DD8
ここに　ちかいます。
>
じじで　づぇえぺそ円
or
さくど　つぐあみすー
ここに　ちがいます。

============

0x023DF6FA
おめでとう　はまだ！
>
ホぬへとう　はまだ！

0x023DF712
これで　きみは
しょうしん　しょうめいの
ポケモンレンジャーと　いうわけだ
>
これで　ぺみは
しゅうしん　しょうめいの
ねつケないんだモン　いうたわけだ

0x023DF760
……とはいえ　まだまだ
みぎも　ひだりも　わからない
みならいレンジャーに　すぎない
>
とはいえ　まはまだ
みぎも　ひだりも　わからないのだ
おならいランのジャー　すいすい

0x023DF7B8
とにかく　けいけんを　つむことだ
やすんでる　ひまは　ないぞ
>
とにかく　わい　けついたむことだ
やすんでる　ひまは　いいぞ

0x023DF7F8
まずは　リングタウン　めざして
おおぞらを　ひとっとびだ！
>
まずは　リングタブン　めそして
かおぞらを　ひてっとびだ！

0x023DF836
さあ　こっちへ……
>
さあ　こっちへ♂♂

最後は0D000C00ではなく00 00 で締める

0x023DF6FA
またせたな　オニドリル！
いつものように　たのむぞ！
>
ま　　　な　オニまリル！
いものような　みずのむぞ！
```

</div>
</details>

### 雑多メモ

```
000D 000C で次のページ, 改行は普通に\n (0x000A)、スペースも普通に 0x0020

ひらがな => SJIS code - 0x829F + 0x81
カタカナ => SJIS code - 0x8340 + 0xE1

python: 
format(int("あ".encode(encoding="sjis").hex(), 16) - 0x829F + 0x81, "x") # => '82'

英数字, 記号: ASCII
ただし, 0x26の&だけはなく、0x27～0x2fの範囲は1だけ小さくしたものを使う。(つまり0x26は本来0x27である ' に相当)

日本語系の記号はまた別:
         0  1  2  3  4  5  6  7  8  9  a  b  c   d   e  f
0x014*  『  』 「 」 ゛ ゜ ・ … ♂  ♀  。 円 ー  ↑  →  ↓
0x015*  → ＆ (ここで終わり)

違う、これUTF-8、あるいはUTF16の順番だ！
https://www.seiai.ed.jp/sys/text/java/utf8table.html
0xc2a1から

0161: 逆びっくり
0162: Cにスラッシュ
0163: むの上にキャレット
0164: ユーロ記号
0165: 円記号
0166: Sの上にキャレット
0167: セクション記号§
0168: Sの上に逆キャレット
0169: © コピーライト記号
016a: 上付きのa
016b: ≪
017b: ≫
016c: 」を左回転させたやつ
016e: 登録商標マーク
0171: ±
0172: 2乗
0173: 3乗
```

## テキスト変換コード(python)

```python
special_chars = {
    "　": 0x20,
    "！": 0x21,
    "？": 0x3f,
    "『": 0x0140,
    "』": 0x0141,
    "「": 0x0142,
    "」": 0x0143,
    "゛": 0x0144,
    "゜": 0x0145,
    "・": 0x0146,
    "…": 0x0147,
    "♂": 0x0148,
    "♀": 0x0149,
    "。": 0x014a,
    "円": 0x014b,
    "ー": 0x014c,
    "↑": 0x014d,
    "→": 0x014e,
    "↓": 0x014f,
    "→": 0x0150,
    "&": 0x0151,
    "＆": 0x0151,
}

def c1(s):
    if s in special_chars:
        return special_chars[s]
    a = int(s.encode(encoding = "utf-16be").hex(), 16)
    if a >= 0x3041 and a <= 0x30F6:
        # ひらがな&カタカナ
        return a - 0x3040 + 0x80
    elif a >= 0x27 and a <= 0x2f:
        return a - 1
    else:
        return a

def c2(c):
    s = format(c1(c), '04X')
    return s[2:4] + s[0:2]

def S0(s):
    return "".join([c2(c) for c in s])

def S(addr, s):
    addr = hex(addr)
    s2 = S0(s)
    print(f"lib.romwarr({addr}, lib.htob(\"{s2}\")) -- {s}")

def S2(addr, s):
    addr = hex(addr)
    s2 = S0(s)
    s = s.replace("\n", "\\n")
    print(f"lib.warr({addr}, lib.htob(\"{s2}\")) -- {s}")

# S(0xC10D54, "るっざな")
# S2(0x023DF6FA, "ホぬへとう　はまだ！")
```

## video13 命名 & テキスト & イルーム & タイトルコールをクラブハウス風(なんどもお)に

<details>
<summary>コード</summary>
<div>


```lua
-- タイトルコールのタイマー
local update_time = (function()
    local screen_m = lib.at(0x04000010)
    local screen_d = 2
    local screen_v = 0
    local time = lib.at(0x021DA6D0)
    local time_ready = false
    local c = Cnt(120)
    local cnt = 0
    local vvs = {
        {4, 60},
        {2, 30},
        {4, 15},
        {8, 7},
        {8, 3},
        {16, 2},
    }
    local vvs_i = 1
    return function()
        if not time_ready then
            local t = time:r16()
            if within(t, 0x0148, 0x014f) then
                print("== TIMER READY ==")
                time_ready = true
            else return
            end
        end
        screen_v = (screen_v + screen_d) % 0x10000
        screen_m:w16(screen_v)
        if c() then
            cnt = cnt + 1
            local _v = vvs[vvs_i]
            if _v and cnt >= _v[1] then
                screen_d = screen_d * 2
                c:N(_v[2])
                vvs_i = vvs_i + 1
                cnt = 0
            end
            time:w16(0x0148)
        end
    end
end)()

local function update_rom_text1()
lib.romwarr(0xc10d54, lib.htob("CB00A3009600AA00")) -- るっざな
lib.romwarr(0xc10d60, lib.htob("1801F2001E0120002D012F01F30026014901AA009500A100")) -- ヘゲマ　ロワコユ♀なさち
lib.romwarr(0xc10d7c, lib.htob("C0009000C500A8002000C30089009200D3002000BE00AD00B000")) -- むぐゅと　ゃぉげん　まねば
lib.romwarr(0xc10d98, lib.htob("9400BC00A200AA008400C7002000B600A500D20020009C009C009300")) -- ごぼぢないょ　ぶづを　ぜぜこ
lib.romwarr(0xc10db8, lib.htob("94009A00CE00D0002000BB00C200CE00A000A9008D00C9009000AA00CD00")) -- ごずゎゐ　ほもゎだどきらぐなろ
lib.romwarr(0xc10dd8, lib.htob("98009800A7002000A50087008800BA009D004B01")) -- じじで　づぇえぺそ円
end

update_rom_text1()


local function update_rom_text2()
lib.romwarr(0xc10d38, lib.htob("A100200084008400AE00200082008B008400AE00")) -- ち　いいの　あかいの
-- lib.romwarr(0xc10d54, lib.htob("CF009F009900AF00")) -- わたすは
lib.romwarr(0xc10d54, lib.htob("CF0097005E005E00")) -- わし^^
lib.romwarr(0xc10d60, lib.htob("0401F10022013301F7003301F80023014C01A8009700A600")) -- ツケモンシンジャーとして
lib.romwarr(0xc10d7c, lib.htob("BB009300CA00A8002000BB0086008D00D20020008200AD00AB00")) -- ほこりと　ほうきを　あねに
lib.romwarr(0xc10d98, lib.htob("9300BE00A300A6008400CB002000B200A800D200BE00CB00C4008D00")) -- こまっている　ひとをまるやき
lib.romwarr(0xc10db8, lib.htob("8B008400D300D20020008D00C200CA00A400A50091003301F80023014C01")) -- かいんを　きもりつづけンジャー
lib.romwarr(0xc10dd8, lib.htob("93009300AB002000A1008C008400BE0099004A01")) -- ここに　ちがいます。
end

local update_text2 = (function()
local function go()
lib.warr(0x23df6fa, lib.htob("1B01AC00B800A80086002000AF00BE00A0002100")) -- ホぬへとう　はまだ！
lib.warr(0x23df712, lib.htob("9300CC00A7002000BA00BF00AF000A009700C50086009700D30020009700C7008600C1008400AE000A00AD00A400F100AA008400D300A000220133012000840086009F00CF009100A000")) -- これで　ぺみは\nしゅうしん　しょうめいの\nねつケないんだモン　いうたわけだ
lib.warr(0x23df760, lib.htob("A800AF00840088002000BE00AF00BE00A0000A00BF008E00C2002000B200A000CA00C2002000CF008B00C900AA008400AE00A0000A008A00AA00C900840029013301AE00F80023014C0120009900840099008400")) -- とはいえ　まはまだ\nみぎも　ひだりも　わからないのだ\nおならいランのジャー　すいすい
lib.warr(0x23df7b8, lib.htob("A800AB008B008F002000CF00840020009100A40084009F00C0009300A800A0000A00C4009900D300A700CB002000B200BE00AF002000840084009E00")) -- とにかく　わい　けついたむことだ\nやすんでる　ひまは　いいぞ
lib.warr(0x23df7f8, lib.htob("BE009A00AF0020002A013301F000FF00160133012000C1009D009700A6000A008B008A009E00C900D2002000B200A600A300A800B300A0002100")) -- まずは　リングタブン　めそして\nかおぞらを　ひてっとびだ！
lib.warr(0x23df836, lib.htob("9500820020009300A300A100B80048014801")) -- さあ　こっちへ♂♂
end
local function go2()
lib.warr(0x023DF6FA, lib.htob("BE00200020002000AA002000EA000B01BE002A012B0121000A008400C200AE00C8008600AA002000BF009A00AE00C0009E002100")) -- ま　　　な　オニまリル！\nいものような　みずのむぞ！
end
    local m = lib.at(0x023DF6FC)
    local mode = 0
    return function()
        if mode >= 2 then return end
        if mode == 0 and m:r16() == 0xc1 then
            go()
            mode = 1
        elseif mode == 1 and m:r16() == 0x9f then
            go2()
            mode = 2
        end
    end
end)()

-- 冒頭のテキスト
local function update_text1()
lib.warr(0x23df71c, lib.htob("F8003301F80023014C01AE0020008A008B009700A7008200CB000A004201C2001B019800CB008A00B900B9004301D2000A008D00BF00AB0020008A0096008D00C8008600")) -- ジンジャーの　おかしである\n「もホじるおべべ」を\nきみに　おざきよう
lib.warr(0x23df764, lib.htob("AB00BB00D3008800C9008400AA00C900200084008D00AA000A00AB00D300A600D3000601F9000801D200200086009100A600C200C9008400")) -- にほんえらいなら　いきな\nにんてんテストを　うけてもらい
lib.warr(0x23df7a0, lib.htob("84009D00AE002000A90086008F00A400AE00200082009800A80020000A00CF009F009700AE00C200AE002000AA00AE00A0008C0047014701")) -- いその　どうくつの　あじと　\nわたしのもの　なのだが……
lib.warr(0x23df7dc, lib.htob("12010601F9000801A9009300CD008B000A009200BE00A700AE0020009800A30095008400AE00E200290116012B01AB000A008D00BF00AF002000BF009500A800AA00200093009F008800D200A00097009F00")) -- ヒテストどころか\nげまでの　じっさいのアラブルに\nきみは　みさとな　こたえをだした
lib.warr(0x23df832, lib.htob("2C01F80023014C01A8009700A6002000AB00D300A000840097009F0084000A00CA00C6008600AA00D300A6002000A9009300AB00C200AA0084008200CB00")) -- レジャーとして　にんだいしたい\nりゆうなんて　どこにもないある
lib.warr(0x23df874, lib.htob("9300AE0020004201AB009200A600C8008400A7009700C70086004301AB000A00A4008B00CC00A6008400CB00B200A800D20020008F00C8008F00C800D300A7000A00930093002000F500E4003301D200A300BB008400")) -- この　「にげてよいでしょう」に\nつかれているひとを　くよくよんで\nここ　サインをっほい
end


lib.irume.start(function()
    local head = 0x03E78CE0
    local as = {}
    for i = 0, 16 do
        as[i] = head + 0x40*i
    end
    local vol = 0x16
    local p1 = 0x1f
    local p2 = 0x18
    local vib_speed = 0x25
    local vib_depth = 0x26
    local vib1 = 0x23
    local time = 0x2c
    local r1 = RC(30)
    local r2 = RC(90)
    return function()
        for i, a in pairs(as) do
            if r1() then
                w8(a + p1, stou8(rand(-5, 5)))
            end
            if r1() then
                w16(a + p2, rand(0,0xf) * 0x10)
            end
            if r2() then
                w8(a + vib_speed, rand(0, 0x20))
            end
            if r2() then
                w8(a + vib_depth, rand(0, 0x20))
            end
            if r2() then
                w8(a + vib1, rand(0, 0x4))
            end
            if r2() then
                w8(a + vib_speed, 0x10)
                w8(a + vib_depth, 0)
                w8(a + vib1, 0)
            end
            if rand(1, 2) == 1 then
                w8(a + time, clamp(r8(a + time) + rand(-4, 3), 1, 0x30))
            end
        end
    end
end)


photo_ok = false

local update_photo = (function()
    -- ヒナタ顔写真
    -- lib.fill_in(0x06600000, 0x06600bff, 0x11)
    local function pos(x, y)
        return lib.pos.Morton(x, y, 4, 0x20, 0x100) + 0x06600000
    end
    local vs = {}
    local function setup()
        for i = 0x06600000, 0x06600BFF do
            vs[i] = r8(i)
        end
    end
    -- block_w: 4, block_span: 0x20, line_span: 0x100
    -- 縦12block => 12*8 = 96行
    local imageObj = lib.image.filterObj()
    :width(32):height(96)
    local watcher = lib.at(0x066000C0)
    local end_watcher = lib.at(0x06600E30)
    local mode = 0
    local function go1()
        local st = 57
        imageObj:go(function(x, y)
            local _y = y >= st and math.round((y - st) * 0.15) + st or y
            return pos(x, y), vs[pos(x, _y)]
        end)
    end
    local go2 = (function()
        local c = Cnt(30)
        return function()
            local scale = math.sin01(c:next() / c.n) * 3 + 1
            imageObj:go(function(x, y)
                local _y = math.round(y / scale) + math.round(40 * (scale-1) * 0.23)
                return pos(x, y), vs[pos(x, _y)]
            end)
        end
    end)()
    local go3 = (function()
        local c = Cnt(20)
        local yc = Cnt(15)
        local st = 57
        return function()
            c()
            local scale = math.sin01(c:next() / c.n) * 7 + 1
            imageObj:go(function(x, y)
                local _y = y >= st and math.round((y - st) / scale) + st or y
                local _x = (x + math.round(c.i * 32 / c.n)) % 32
                return pos(x, y), vs[pos(_x, _y)]
            end)
        end
    end)()
    local go4 = (function()
        local c = Cnt(31)
        local yloop_c = Cnt(33)
        local yc = Cnt(187)
        local st = 57
        local r = RC(3)
        return function()
            c()
            yloop_c()
            local scale = math.sin(yc:next()*2*math.pi / yc.n) * 2 + 2.15
            imageObj:go(function(x, y)
                local _y = math.round((y - st) / scale) + st
                _y = (_y + math.round(yloop_c.i * 96 / yloop_c.n)) % 96
                local _x = (x + math.round(c.i * 32 / c.n)) % 32
                return pos(x, y), vs[pos(_x, _y)]
            end)
            if c.i == 0 and r() then
                c:N(clamp(c.n + rand(-3, 3)*4, 15, 40))
            end
            if yloop_c.i == 0 and r() then
                yloop_c:N(clamp(yloop_c.n + rand(-3, 3)*4, 15, 40))
            end
            if yc.i == 0 and r() then
                yc:N(clamp(yc.n + rand(-3, 3)*20, 60, 190))
            end
        end
    end)()
    local cooltime = 10
    local finished = false
    return function()
        if finished then return end
        if mode == 0 then
            if watcher:r32() == 0 then
                print("== PHOTO ACTIVATED! ==")
                mode = 1
            else return
            end
        end
        if photo_ok then
            photo_ok = false
            mode = mode + 1
        end
        if mode == 1 then
            if cooltime > 0 then
                cooltime = cooltime - 1
                if cooltime == 0 then
                    setup()
                    go1()
                end
            end
            return
        end
        if mode == 2 then go2()
        elseif mode == 3 then go3()
        elseif mode >= 4 then go4()
        end
        if mode >= 4 and end_watcher:r32() == 0 then
            print("== PHOTO FINISHED ==")
            finished = true
        end
    end
end)()


local update_naming = (function()
    local NAMES = {
        hinami = "12010A01BF0000000000",
        hitomi = "12010801BF0000000000",
        MA = "5E005E00BE0000000000",
        hamada = "AF00BE00A00000000000",
    }

    local addr = 0x02132FAE

    local prevs = nil
    ---@param force_update bool?
    local function update_prev(force_update)
        if prevs == nil then
            prevs = {}
            for i = 0, 4 do
                prevs[i+1] = r16(addr + i)
            end
        else
            for i = 0, 4 do
                local v = r16(addr + i)
                if force_update then
                    prevs[i+1] = v
                elseif v ~= prevs[i+1] then return true
                end
            end
        end
        return false
    end

    --- デフォルト名: 無印: ヒナタ、バトナージ: ヒトミ、光: ミナミ
    --- -- 入力する順番、 無記入(ヒナタ) => ヒトミ => ミナミ => ヒロミ => ナナミ
    local _names = {
        NAMES.hinami,
        NAMES.hitomi,
        NAMES.MA,
        NAMES.hamada,
    }
    local names_i = 0
    local prev_active = false
    local done = false
    return function()
        if done then return end
        if not naming_active then
            if prev_active then
                print("== UPDATE ROM TEXT2 ==")
                update_rom_text2()
                prev_active = false
                done = true
            end
            return
        end
        prev_active = true
        if update_prev() then
            names_i = names_i + 1
            lib.warr(addr, lib.htob(_names[names_i] or NAMES.hamada))
            update_prev(true)
        end
    end
end)()

naming_active = false

go_upate_text1 = false
local update_text1_done = false


function loop()
    if go_upate_text1 and (not update_text1_done) then
        update_text1()
        go_upate_text1 = false
        update_text1_done = true
    end
    update_text2()
    update_time()
    update_photo()
    update_naming()
end
```

### 制御用

```lua
--- -- 入力する順番、 無記入(ヒナタ) => ヒトミ => ミナミ => ヒロミ => ナナミ
go_upate_text1 = true

naming_active = not naming_active


-- 211E6DC -> 決めポーズのときのグラがほうかいする(def: 0300 (BE))
-- 211E95C を見よ！

photo_ok = true
```

</div>
</details>

## video13 雑多メモ

```lua
-- テキストがある場所を検索する

-- local ome = lib.htob("8A00C100A700A8008600")
-- local otto = lib.htob("8A00A300A800")
-- local watashiha = lib.htob("CF009F009700AF00")
-- local watashiha = lib.htob("CF9F97AF")
-- local tikaimasu = lib.htob("A1008B008400BE009900")

local mataseta = lib.htob("BE009F009B009F00AA00")
lib.find_all(0x02000000, 0x025fffff, mataseta)
-- lib.findr(0x0000000, 0x00ffffff, tikaimasu)
```

```lua
-- 誓約書の文言を適当にいじってみる
for i = 0x00C10D54, 0x00C10DEB, 2 do
    local v = r16r(i)
    if v ~= 0x20 and v ~= 0 then
        w16r(i, v + rand(-5, 5))
    end
end

-- w32(0x02134F74, 0x11111111) -- ロゴを突然出す(video13では未使用)

-- w32r(0x11ffdc, 0) -- タイトルの挙動がおかしくなる

-- ロゴ関係? ROM120000付近
-- 120010: ロゴのy値

-- ロゴ: 後ろの光や青いループを消す(こちらはケンジで使ったはず)
lib.fill_in(0x00120000, 0x0012000F, 0x11, ROM_DOMAIN_NAME)

-- ロゴバグ1(video13では未使用?)
-- w32r(0x120438, 0x020F9AB4)

-- ロゴバグ2(video13では未使用?)
w32r(0x12041C, 0x020F9AB4) -- orig: 020f99e4

-- 20F89E3, 11 -> 赤くなる(video13では未使用。使うのを忘れた)
-- title/title_main_t.dat title/title_main_p.dat がタイトルの画像データ?
```


## video13 ケモケモ


```lua
-- (太鼓の達人で「試験も」の部分を記録しておく)

local head = 0x21D9500
local width = 0x1000

local kyoku_broken_head = 0x020E1660
local kyoku_broken_width = 0xa00


local i = 0
local n = #DATA_kemo2
print("n:" .. tostring(n))

local kemo2 = {}
local j = 0
for _i = 1, n do
    -- if not within(_i, -1, 0) then
    if within(_i, 4, 16) or within(_i, 30, 46) then
    -- if not within(_i, 13, 29) then
        j = j + 1
        kemo2[j] = DATA_kemo2[_i]
    end
end
-- local __n = #(DATA_kemo2[1])
-- for _i = 1, 4 do
--     j = j + 1
--     kemo2[j] = {}
--     for _j = 1, __n do
--         kemo2[j][_j] = 0
--     end
-- end
n = j

local time = lib.at(0x021DA6D0)
local ready = false
local print_stop = false

function loop()
    local t = time:r16()
    if not ready then
        if within(t, 0x0191, 0x02ff) then
            print("== TIMER READY ==")
            ready = true
        else return
        end
    end
    if t >= 0x03ad then
        if not print_stop then
            print("STOP")
            print_stop = true
        end
        lib.fill_in(head, head + width - 1, 0)
    else
        i = (i % n) + 1
        lib.fill_in_arr(head, head + width - 1, kemo2[i])
    end
end


local update_logo = function()
    -- ロゴ画像: 0x100で1行のラスタスキャン
    -- 2a00から 5affまで
    local function pos(x, y)
        return lib.pos.Raster(x, y, 0x100) + 0x014B2A00
    end

    local vs = {}
    local st = 0x2e
    local ed = 0x5f
    for y = 0, 48 do
        for x = 0, 0xff do
            local _x = (x - st) % (ed - st)
            if within(y, 10, 19) and within(_x, 0, 6) then
                vs[pos(x, y)] = 0
            else
                vs[pos(x, y)] = r8r(pos(_x + st, y))
            end
        end
    end
    for a, v in pairs(vs) do w8r(a, v) end

    lib.fill_in(0x00120000, 0x0012000F, 0x11, ROM_DOMAIN_NAME)
end

update_logo()

-- ↓ロゴが消え始めてから実行

local orig = {}
local begin = 0x6400000
local inclusiveEnd = 0x640ffff
for i = begin, inclusiveEnd, 4 do
    orig[i] = r32(i)
end

local span = 0x100
local r = RC(1)

SET_LOOP("gra_bug", function()
    local vs = {}
    for i = begin, inclusiveEnd, span do
        if r() then
            local n = rand(-32, 32) * 0x210
            local _i = clamp(i + n, begin, inclusiveEnd + 1 - span)
            for j = 0, span-1, 4 do
                vs[i+j] = orig[_i + j]
            end
        end
    end
    for a, v in pairs(vs) do
        w32(a, v)
    end
end)
```

## 野生ポケモンを変更する

1. 変更元・変更先ポケモンのIDを調べる
    - 図鑑から対象ポケモンの図鑑Noを控え、次のようにして検索:
    ```lua
    local function zukan_from_Rno(R)
        local addr = 0x00B2A02E + (R-1)*14
        local id = r16r(addr)
        local height = r16r(addr+4)/10
        local weight = r16r(addr+6)/10
        printf("ID 0x%X %.1fm %.1fkg (at 0x%08X)", id, height, weight, addr)
    end
    zukan_from_Rno(184) -- ブースター => ID 0x5D 0.9m 25.0kg (at 0x00B2AA30)
    ```
    - アドレスが見つかったら、高さ・重さをいじってみて図鑑を再度開き、値が変化するかを調べる
    - もし上記の方法で失敗したら、図鑑から入手した対象の高さ・重さから検索:
    ```lua
    ---@param height int `9.2`なら`92`
    ---@param weight int `3.6`なら`36`
    local function search_zukan(height, weight)
        local d = {
            height&0xff,
            (height>>8) & 0xff,
            weight&0xff,
            (weight>>8) & 0xff,
        }
        local a = 0x00B2A02E
        local found, addr = lib.findr(a, a+0xffff, d)
        if found then
            printf("FOUND at 0x%08X (ID: 0x%X)", addr, r16r(addr-4))
        else
            print("not found")
        end
    end
    search_zukan(9, 250) -- ブースター(0.9m, 25.0kg)=>ID: 5D
    ```
    - アドレスが見つかったら、そのアドレスの値を実際に変えて図鑑を再度開いて高さ・重さが変更されるのを確認
1. 対象マップへ行き、マップデータのアドレスを調べる
    - 該当マップに登場するポケモンのデータは、マップデータとともにlz10圧縮されて配置されている
        - 例: ライラのもり: `ROM0x007E8600`
    - そして、そのマップをRAM上に展開して使用する(だいたい`0x229****`～`0x022B****`あたりの位置？)
    - 同じポケモンが複数登場するマップなら、例えばそのポケモンのIDを`0x2E`として、
    ```lua
    local l = 4
    local d = {}
    for i = 0, l-1 do
        d[i*0x14+1] = 0x16
        d[i*0x14+2] = 0
        d[i*0x14+3] = 0
        d[i*0x14+4] = 0
    end
    lib.find_all(0x02000000, 0x023fffff, d, 0x14*(l-1)+4)
    ```
    などとしてアドレスの候補を取得する
    - マップを切り替えると、大体そこらへんの値が変わるので、また同じ場所に戻り、値が先ほどのものに戻った瞬間に、`2E`の箇所を全部別のIDに変え、ポケモンが変わっているかを調べる

## 主人公の座標をいじる

1. RAM Seatchを開く
1. 下方向に移動した状態でPauseし、Not Equal To 0検索(4byte unsigned)
1. Unpauseして静止し、equal to 0絞り込み
1. この時点で、`21****`辺り(もしダメなら`22****`, `23****`も調べる)のアドレスをhex editorで調べる
- その少し上のアドレスで、
```
<x座標1> <dummy> <y座標1>
<x座標2> <dummy> <y座標2>
<x座標3> <dummy> <y座標3>
```
というデータ？が4byteずつ並んでいる。
3つのx/y座標は、値が(一致とまではいかないが)かなり近しい。
実際に上下に移動すると3つのy座標の値が激しく変動し、左右に移動すると3つのx座標の値が激しく変動する。
そういった場所を見つけたら、座標1の2つの値をいじってみて主人公が瞬間移動すれば成功。

## 経験値

`0x02133980` (`0x11480`くらいにするとMAX直前になる)
レベルMAXになった後も加算され続けるので、正確な値に設定する必要はない

## 連れていけるポケモンの数

`0x0213399A` (8以上の値にすると即フリーズ)

## ラインの長さ

`0x02133992`(プロフィール上の値)

例えばラインの長さを無限にしたい、という場合は、
キャプチャ中に使用中の長さを管理するアドレスを検索し、その箇所を0固定すればよい。
検索方法は `start_search_line_length_addr` 関数を参照。

## HP

現在HP: `0x02133990`
MAX HP: `0x02133998`

上記2つを変更した場合、その変更はキャプチャ中画面に移行した際に反映される

- 見かけ上のHP: `0x0224413C` (時間差で`0x0224413E`の値が`C`の方に合わせていく)
    - こちらはフィールド上も機能する
- 内部HP: `0x0224418C` (こっちが0になるとゲームオーバー(見かけ上のHPは関係ない))
    - 戦闘中のみ使用

## video26 ヘルガーチュートリアルのポケモン&BGM変更 ほか

```lua
package.loaded["misc/ranger"] = nil
local ranger = require "misc/ranger"
local Z = ranger.zukan_from_Rno

-- lib.replace16(0x02165580, 0x021fffff, 0x84, 0x77)
-- w16(0x02165588, Z(208)) -- キャプチャ中のヘルガーをカイオーガに
w16(0x02165588, Z(184)) -- キャプチャ中のヘルガーをブースターに

w16(0x02165590, 0x8) -- ポケモンの匹数を変更
-- w16(0x021655b4, 0x0c) -- 音楽変更(ボツ)
-- w8(0x021655bc, 0x0d) -- 音楽変更(こっちの方が色々変更できる)
w8(0x0227087c, 0x27) -- プラスルの方のBGMを変更
w16(0x02212F18, 0x8c) -- キャプチャ中のプラスルを別ポケモンに(8bがいせきエンテイ,8cがラスボスエンテイ)
w8(0x02133998, 0) -- MAX HPを0に

-- BGMの例
-- 0a: ボス戦
-- 0b: そうげん
-- 0d: チャレンジ
-- 22: トラブル
-- 26: ボス戦っぽいBGM
-- 27: ラスボスエンテイ
-- 2d: 中ボス?
-- 2e: 多分キャプチャアリーナ
-- 38: 4兄弟のギター 39: バイオリン 3a ベース 3b パーカス 40 全員 (どれも効果音扱い)
-- 3e: ゴーゴーのポケモン
-- 43 ラゴウ
-- 44: ゴーゴー4兄弟のポケモン
-- 45: バンギラスのところ?
-- 4d: ラストラゴウと教授が会うシーン(まろうじんっぽい?)
```

## video26 エンテイ 音ハメ

```lua

local time = 0

local update_touch = (function()
local tempo = 100 -- or 101
local touch_time = 0
local ready = false
local k = DS.key.lis("A"):on("down", function() ready = true end)
local rensha = Cnt(3)
local humen = {
4, 8, 24, 24, 24,
4, 8, 24, 24, 24,
4, 8, 24, 24, 24,
8, 8, 24, 24, 24, 24, 24, 24,

4, 8, 24, 24, 24,
4, 8, 24, 24, 24,
4, 8, 24, 24, 24,
16, 16, 8, 32, 32, 32, 32, 32, 32, 32, 32,

4, 8, 24, 24, 24,
4, 8, 24, 24, 24,
4, 8, 24, 24, 24,
8, 8, 16, 16, 16, 16,

4, 8, 8, 16, 16, 8, 16, 16, 16, 16,
8, 16, 16, 16, 16, 24, 24, 24,
32, 32, 32, 32, 32, 32, 32, 32,
}
local ts = {}
local _t = 0
local N = #humen
ts[1] = 0
for i = 1, N do
    _t = _t + ( 240.0 / (humen[i] * tempo) )
    ts[i+1] = _t
end
local idx = 1
return function()
    if not ready then k() if not ready then return end end
    CLS()
    printf("idx %d", idx)
    printf("time: %f", time/60)
    time = time + 1
    if idx > N then
        joypad.set({["Touch"] = rensha:next()==0})
        return
    end
    if touch_time == 0 and ts[idx] <= time / 60 then
        idx = idx + 1
        touch_time = 2
    end
    if touch_time > 0 then
        touch_time = touch_time - 1
        joypad.set({["Touch"] = true})
    else
        joypad.set({["Touch"] = false})
    end
end
end)()

local target = 19.15 * 60

function loop()
    update_touch()
    -- ダメージ時のエフェクトを最小限にする(フレッシュ防止)
    w8(0x022ebfe4, 0)
    w8(0x022ebfe8, 0)
    w8(0x022ebff4, 0)

    if time >= target then
        if r8(0x0224418c) > 1 then
            w8(0x0224418c, 1)
        end
    else
        w8(0x0224418c, 64)
    end
    w8(0x0224413c, 0)
    w8(0x0224413e, 0)
    w32(0x02325BF4, 0)
end
```

## video26 カイオーガだらけ & テキスト改変

```lua
w16(0x02165588, Z(208)) -- キャプチャ中のヘルガーをカイオーガに

w16(0x02165590, 0x8) -- ポケモンの匹数を変更
w8(0x021655bc, 0x0d) -- 音楽変更(こっちの方が色々変更できる) (2B 10 2B 00で検索して探す)

local update_text = (function()
local idx = 1
local waiting = true
local watcher = lib.at(0x023DE7B8)
local head = 0x023DE7BC
local data = {
-- ハヤテ: いまから　わたしたちの ハッピー　アンド　ゴージャ...
"04000F01240106013a0005008400BE008B00C9002000CF009F0097009F00A100AE000A000F01030114014C012000E200330109012000F4004C01F8002301F900AA000A00910084008B008F00D20020008A0097008800A60082009200CB00CF000d000c001F010301F7002701330120001F010301F7002701330121000A001F010301F70027010301F70027014C013301210020002901F400E6009500D3000A009D00CC0084009800C7008600AF002000BF009000CB00970084009C000d000c00BE009A002000FF00030101011A013301A7000A00E200F8000801A8008B0020009C00D300B60020009300CF009700A6008D00A6000A008D00A300A8002000E4002A011201C20020009D0086009900CB00CF000000",
-- ハヤチ: タッチしたまま　ペンを　うごかすと ちていかざんが...
"04000F01240101013a0005000a00FF000301010197009F00BE00BE0020001A013301D2002000860094008B009900A8000A00A100A60084008B009600D3008C002000B500D3008B009700BE0099000000",
-- パヤテ: このスリープおじさんで わかいムスメに いやいや　...
"04001101240106013a0005009300AE00F9002A014C0117018A0098009500D300A7000A00CF008B0084002001F9002101AB000A008400C4008400C4002000AA00D300A700C2002000AA008400AA00840021000d000c00C400A300B10020008A00CC00C2000A009300AE002000EB00040129012000AC008400A70095000A001D01F10022013301A80020008400A3009700C700AB002000F40015012000F400150115010000",
-- ハゃテ: ポケモンを　かこむと ゴーゴゴ　あぶないから　ダメ...
"04000F01C30006013a0005000a001D01F10022013301D20020008B009300C000A8000A00F4004C01F400F40020008200B600AA0084008B00C900200000012101A000A300A6000d000c009300AE00990086009800AF002000EB003301100133018B00A300A4004C01AE000A001D01F10022013301D20020008B009300BF002000A400A5009100CB00A8000A00E400290103012000A80020009700A6009700BE0086000000",
-- ハヤデ: あおいすうじが　でなくなるまで ラゴウは　ききうで...
"04000F01240107013a0005000a0082008A0084009900860098008C002000A700AA008F00AA00CB00BE00A7000A002901F400E600AF0020008D008D008600A700D200200084009F00C1000A002C013301F80023014C01A8009700A60020008A00CF00A3009F000d000c00A800A100C5008600A70020001A013301D2002000AF00AA009900A8000A00ED002301170101012301AF0020009700A300B1008400AB002000AA00CB008B00C9000A00A100A300B1008400AF0020009B00840093008600AE0020001E01F6004C0121000000",
-- セヤデ: いまのが　これからの キャッチフレーズ　なんで よ...
"0400FB00240107013a0005008400BE00AE008C0020009300CC008B00C900AE000A00ED0023010301010115012C014C01FA002000AA00D300A7000A00C800CD0097008F0020009F00AE00C000AA000000",
-- ナンヤテ: ラインに　きづかなかった イリヒの　バカも　せき...
"04000A013301240106013a0005002901E4003301AB0020008D00A5008B00AA008B00A3009F000A00E4002A011201AE0020001001EB00C20020009B008D00AB00D300D20020008B00D30098000A009200D300930086002000AA008F009700A100C300A3009F008200820082008200820082000000",
-- ハゲテ: このように　ラインは きえてしまう　なっ　なんだ ...
"04000F01F20006013a0005009300AE00C8008600AB0020002901E4003301AF000A008D008800A6009700BE0086002000AA00A3002000AA00D300A0000A008A00BE008800C90020001D01F10022013301AE0020008F009B00AB00210021000d000c009500C900AB002000ED00F5001E01AE009B008400A7000A002C013301F80023014C018C002000A7008D00AA008F00AA00A3009F00AE00A0009E0021000A00BF009800C10099008E00CB009C0020008A00CC00A300A600C400A400AF002000BD00A3000000",
-- ハッパテw: ジュプトルが　ダメージを　うけると じかんが　...
"04000F0103011101060177003a0005000a00F8002501170108012B018C002000000121014C01F800D200200086009100CB00A8000A0098008B00D3008C002000A800BE00A300A600CB00BF009F008400A0000000",
-- ハヤベン: エネルギーが　ゼロになると はらへったし おまえ...
"04000F012401190133013a000500E8000D012B01EE004C018C002000FC002D01AB00AA00CB00A8000A00AF00C900B800A3009F0097000A008A00BE008800AB002000C400A40082009F00CA00A00021000d000c00BE0082002000840084008B009F00D20020008B008800CC00B0000A0042019800B0008F009D008600A1004301A80084008600CF009100A0000A00E80033010701E3003301F000AE002000AF009800BE00CA00A00021000d000c00A700AF0020009800A300950084002000CF009F009700A300A6000d000c008B00CF0084008F00A300A6002000BF009A00BF009A0097008F00A6000d000c00F900FF00E4002A010301F7002501A70020008600A4008F0097008F00A6000d000c00A1009B008400A6008D00A7002000FB00EF00F7004C01A7000d000c002A0103010101A7002000F900FF00E4002A010301F7002501AA00A0009100AE000A00A400BE00C900AA00840020009800C7009B008400AA00D300A000CF000d000c002C013301F80023014C01A8009700A600C2002000B200A800A8009700A600C2000A0000012101A300A60020009300A800A000C80021000A00BB00D300A80020008F00A000C900AD008700210021000000",
-- ハジテ: このまま　ペンを　はなさずに マナフィの　ママにな...
"04000F01F80006013a0005000a009300AE00BE00BE0020001A013301D2002000AF00AA0095009A00AB000A001E010A011501E300AE0020001E011E01AB00AA00A300A6000d000c00B200BE00950088008200CC00B0002000820082009700A6000A008A00C20086009E00D300B600D30020008200B000CC00CB008C00C800840021000d000c0082008A0084009900860098008C002000A700AA008F00AA00CB00BE00A7000A00AA00AB008B0017012C01FC0033010801D2002000CF009F009700A6000A0094008D009200D300D2002000A800CB009300A800AB009900CB0021000000",
-- ハんだこテ: あおいすうじが　きえて パシリのおれ　めちゃく...
"04000F01D300A000930006013a00050082008A0084009900860098008C0020008D008800A6000A001101F7002A01AE008A00CC002000C100A100C3008F00A100C3000A0084009D008C009500CC00A600CB00D300A000C800AD0021000d000c00C200860020001A013301D2002000AF00AA009700A600C2000A008A009700A100C30086002000CF00CB0084001C01EF000A009D00CC008C0020001D01F1002201330120002C013301F80023014C0121000d000c00EB000D012000EB000D012000EB000D0121002000EB000D01950088008200CC00B0000A009800D3009B008400AA00D300A60020008A00C2008400AE00BE00BE0021000A009D00CC008C0020001D01F1002201330120002C013301F80023014C0121000d000c008200D3009F008C002000C200A300A600CB002000A00084009800AA00C200AE000A00CF00CB0084008C00200084009F00A0008400A60084008F009C0021000A009D00CC008C0020001D01F1002201330120002C013301F80023014C0121000d000c00840084008B0084003F000A009300CC00AF002000A00084009800AA009300A800A0008B00C9000A00C20086008400A100A9002000840086009E000d000c00BB00AE008A00AE00A1008B00C9002000BF00AB00BE00A80084000A003400BB00D30082009700AE00200082008B008D0020001D01F100220133010A009700A300BD008C0020008B00CF0084008400AE00C800AD000d000c00F4004C01F4004C01A000D300AF002000BE00A0002000AA00A900A800AF000A008F00C900B900C200AE00AB002000AA00C900AA008400CF0021000A00BE00A6004C0121002000ED0023011701010123019700A600C400CB009E004C0121000000",
-- テテテ: OK!　おれの　ひざ ガクガク　ふるえちゃってるよ...
"04000601060106013a0005000a004F004B00210020008A00CC00AE002000B20096000A00EC00EF00EC00EF002000B500CB008800A100C300A300A600CB00C8004C0121000000",
}
local N = #data
return function()
    if idx > N then return end
    if waiting then
        if watcher:r8() == 0xBC then
            waiting = false
            lib.warr(head, htob(data[idx]))
            idx = idx + 1
        end
    elseif watcher:r8() == 0xBD then
        waiting = true
    end
end
end)()

function loop()
    update_text()
end
```
