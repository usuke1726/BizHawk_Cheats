
package.path = os.getenv("BizHawk_ULibPath") .. package.path
lib = require "lib"

lib.irume.stop()
CLS()

print("READY")


local _FONTS = {
["危"] = {
    "........",
    "...###..",
    ".##..#..",
    "..######",
    "..#.###.",
    "..#.#.#.",
    "..#.#..#",
    ".#..####",
},
["な"] = {
    "........",
    "...#....",
    ".####.##",
    "...#..#.",
    "..#...#.",
    ".#..###.",
    ".#.#..##",
    "....###.",
},
["い"] = {
    "........",
    ".#....#.",
    ".#.....#",
    ".#.....#",
    ".#.....#",
    ".#.....#",
    ".#.#....",
    "..#.....",
},
["っ"] = {
    "........",
    "........",
    "........",
    "...###..",
    ".##...#.",
    "......#.",
    ".....#..",
    "...##...",
},
["て"] = {
    "........",
    ".#######",
    "....#...",
    "...#....",
    "...#....",
    "...#....",
    "...#....",
    "....###.",
},
["…"] = {
    "........",
    "........",
    "........",
    "........",
    ".#..#..#",
    "........",
    "........",
    "........",
},
["フ"] = {
    "........",
    ".#######",
    ".......#",
    ".......#",
    ".......#",
    ".......#",
    "......#.",
    "..####..",
},
["メ"] = {
    "........",
    "......#.",
    "......#.",
    "..#...#.",
    "...#.#..",
    "....#...",
    "...#.#..",
    ".##.....",
},
["モ"] = {
    "........",
    ".#####..",
    "...#....",
    "...#....",
    ".######.",
    "...#....",
    "...#....",
    "....###.",
},
["リ"] = {
    "........",
    ".#...#..",
    ".#...#..",
    ".#...#..",
    ".....#..",
    ".....#..",
    "....#...",
    "..##....",
},
["サ"] = {
    "........",
    "..#...#.",
    ".#######",
    "..#...#.",
    "......#.",
    "......#.",
    ".....#..",
    "...##...",
},
["イ"] = {
    "........",
    ".......#",
    "......#.",
    ".....#..",
    "...###..",
    ".##..#..",
    ".....#..",
    ".....#..",
},
["ケ"] = {
    "........",
    "..#.....",
    "..######",
    "..#..#..",
    ".#...#..",
    ".....#..",
    "....#...",
    "...#....",
},
["デ"] = {
    ".....#.#",
    "..####.#",
    "........",
    ".#######",
    "....#...",
    "....#...",
    "....#...",
    "..##....",
},
["ン"] = {
    "........",
    ".##.....",
    "...#....",
    "........",
    ".......#",
    "......#.",
    "....##..",
    "..##....",
},
["ク"] = {
    "........",
    "...#....",
    "...#####",
    "..#....#",
    ".#.....#",
    "......#.",
    "....##..",
    "..##....",
},
["シ"] = {
    "........",
    "..##....",
    "....#...",
    ".##.....",
    "...#...#",
    "......#.",
    "....##..",
    "..##....",
},
["ジ"] = {
    ".....#.#",
    "..##.#.#",
    "....#...",
    ".##.....",
    "...#...#",
    "......#.",
    "....##..",
    "..##....",
},
["ボ"] = {
    ".....#.#",
    "....##.#",
    ".#######",
    "....#...",
    "..#.#.#.",
    "..#.#..#",
    ".#..#..#",
    "...##...",
},
["ャ"] = {
    "........",
    "........",
    "..#.....",
    "..#.###.",
    ".###..#.",
    "...#.#..",
    "...#....",
    "....#...",
},
["ウ"] = {
    "........",
    "....#...",
    ".#######",
    ".#.....#",
    ".#.....#",
    "......#.",
    ".....#..",
    "...##...",
},
["ア"] = {
    "........",
    ".#######",
    ".......#",
    "....#.#.",
    "....##..",
    "....#...",
    "....#...",
    "..##....",
},
["ス"] = {
    "........",
    "........",
    "..#####.",
    "......#.",
    "......#.",
    ".....#..",
    "...##.#.",
    ".##....#",
},
["ー"] = {
    "........",
    "........",
    "........",
    "........",
    ".#######",
    "........",
    "........",
    "........",
},
["ル"] = {
    "........",
    ".....#..",
    "...#.#..",
    "...#.#..",
    "...#.#..",
    "...#.#.#",
    "..#..#.#",
    ".#...##.",
},
["ド"] = {
    "........",
    ".#..#.#.",
    ".#..#.#.",
    ".#......",
    ".###....",
    ".#..##..",
    ".#......",
    ".#......",
},
["ヌ"] = {
    "........",
    ".######.",
    "......#.",
    "...#..#.",
    "....##..",
    ".....##.",
    "...##..#",
    ".##.....",
},
["ヘ"] = {
    "........",
    "........",
    "...#....",
    "..#.#...",
    ".#...#..",
    "......#.",
    ".......#",
    "........",
},
["パ"] = {
    "........",
    "...#..#.",
    "...#.#.#",
    "...#..#.",
    "..#...#.",
    "..#....#",
    "..#....#",
    ".#.....#",
},
["マ"] = {
    "........",
    "........",
    ".#######",
    ".......#",
    "......#.",
    "...#.#..",
    "....#...",
    ".....#..",
},
["ぞ"] = {
    ".....#.#",
    "..######",
    "....#...",
    "...#....",
    ".#######",
    "....#...",
    "...#....",
    "....###.",
},
["。"] = {
    "........",
    "........",
    "........",
    "........",
    "........",
    "..#.....",
    ".#.#....",
    "..#.....",
},
["め"] = {
    "........",
    "..#..#..",
    "..#.###.",
    "..##.#.#",
    ".#.#.#.#",
    ".#.##..#",
    ".#.#...#",
    "..#..##.",
},
["だ"] = {
    ".....#.#",
    "...#.#.#",
    ".####...",
    "...#.###",
    "..#.....",
    "..#..#..",
    ".#..#...",
    ".#...###",
},
["ま"] = {
    "........",
    "....#...",
    ".#######",
    "....#...",
    ".#######",
    "..#.#...",
    ".#..##..",
    "..###.##",
},
["％"] = {
    "........",
    "..#....#",
    ".#.#..#.",
    "..#..#..",
    "....#...",
    "...#..#.",
    "..#..#.#",
    ".#....#.",
},
["X"] = {
    "........",
    "..#...#.",
    "..#...#.",
    "...#.#..",
    "....#...",
    "...#.#..",
    "..#...#.",
    "..#...#.",
},
["カ"] = {
    "........",
    "...#....",
    ".#######",
    "...#...#",
    "...#...#",
    "...#...#",
    "..#....#",
    ".#...##.",
},
["ラ"] = {
    "........",
    "..#####.",
    "........",
    ".#######",
    ".......#",
    ".......#",
    ".....##.",
    "...##...",
},
["！"] = {
    "........",
    "....#...",
    "....#...",
    "....#...",
    "....#...",
    "....#...",
    "........",
    "....#...",
},
}



local _t = 0x2c
local hat = 0x22
local p1 = 0x1f
local p2 = 0x18
local vib = 0x26
local vol = 0x16
local _pos = 0x34

-- 草むら、主人公顔出しシーン
local function irume1()
    local as = {}
    for i = 0, 15 do
        as[i] = 0x03E57B80 + 0x40*i
    end
    local ps = {0, 2, 4, 5, 7, 5, 4, 2}
    local c = Cnt(3, #ps)
    local cooltime = 360
    return function()
        if cooltime > 0 then
            cooltime = cooltime - 1
            if cooltime == 0 then
                print("OK")
                c.n0 = 1
            end
        end
        w16(as[4]+hat, 0x80)
        w16(as[4]+vol, 0x40)
        w16(as[5]+vol, 0x80)
        c()
        for i = 0, 15 do
            if i ~= 4 then
            w16(as[i]+p2, 0x40*ps[c.i+1])
            end
        end
    end, function()
        w16(as[4]+hat, 0)
        w16(as[4]+vol, 0)
        w16(as[5]+vol, 0)
        for i = 0, 15 do
            w16(as[i]+p2, 0)
        end
    end
end

-- 町紹介
local function irume2()
    local as = {}
    local tones = {}
    for i = 0, 15 do
        as[i] = 0x03E57B80 + 0x40*i
        tones[i] = r8(as[i]+0x0e)
    end
    local p = 0x200
    return function()
        p = clamp(p - 3, -0x300, 0x200)
        for i = 0, 15 do
            w8(as[i] + 0x0e, 0x11)
            w16(as[i] + p2, p)
        end
    end, function()
        for i = 0, 15 do
            w8(as[i] + 0x0e, tones[i])
            w16(as[i] + p2, 0)
        end
    end
end

-- ライバル
local function irume3()
    local as = {}
    for i = 0, 15 do
        as[i] = 0x03E57B80 + 0x40*i
    end
    local r = RC(20)
    local time = 90
    return function()
        time = math.max(time - 1, 0)
        local _vol = time > 0 and 0x40 or 0x20
        for i = 0, 15 do
            w16(as[i] + vol, _vol)
            if r() then
                w8(as[i] + p1, rand(2, 7))
            end
            if r() then
                w16(as[i] + p2, rand(0x20, 0x70))
            end
        end
    end, function()
        for i = 0, 15 do
            w16(as[i] + vol, 0)
            w8(as[i] + p1, 0)
            w16(as[i] + p2, 0)
        end
    end
end

-- ロケット団用
local function irume4()
    local as = {}
    local vs = {}
    for i = 0, 15 do
        as[i] = 0x03E57B80 + 0x40*i
        vs[i] = 0x200
    end
    local r = RC(10)
    return function()
        for i = 0, 15 do
            if r() then
                vs[i] = -1 * vs[i]
            end
            w16(as[i]+hat, vs[i])
            if vs[i] < 0 then
                w8(as[i]+p1, rand(0x8, 0x10))
            else
                w8(as[i]+p1, -rand(0x4, 0x8))
            end
        end
    end, function()
        for i = 0, 15 do
            w16(as[i]+hat, 0x00)
            w8(as[i]+p1, 0)
        end
    end
end

local function irume5()
    local as = {}
    local ps = {}
    for i = 0, 15 do
        as[i] = 0x03E57B80 + 0x40*i
        ps[i] = 0
    end
    local c = Cnt(4, 2)
    local r = RC(20)
    return function()
        c()
        for i = 0, 15 do
            w16(as[i] + vol, 0x20)
            if r() then
                ps[i] = rand(-0x100, 0x100)
            end
            w16(as[i] + p2, c.i * 0x80 + ps[i])
        end
    end, function()
        for i = 0, 15 do
            w16(as[i] + vol, 0)
            w16(as[i] + p2, 0)
        end
    end
end

-- ===========================================
-- ===========================================
-- ===========================================

lib.actions.remove_all()
lib.actions.register("poke opening", nil, {
function(obj)
    obj.name = "スタート待機"
    local m = lib.at(0x021DCA7C)
    obj.key_enable = false
    return function()
        if m:r8() ~= 0 then
            obj:update_state()
        end
    end
end,
function(obj)
    obj.name = "スタート"
    obj:SKP(180)
    lib.warr(0x062c0210, lib.htob("01000C000C000C000C000C000C000C000C000C00080009000A000B0000000000"))
    lib.warr(0x062c0290, lib.htob("01000C000C000C000C000C000C00050013001400150016001700180005001900"))
    lib.warr(0x062c0310, lib.htob("19001A001B001C001A001D0019001A001B001C001C001A001D00190019001900"))
    lib.warr(0x062c0380, lib.htob("21002200200021002200200021002200200021002200200021002200200021002200200021002200200021002200200021002200200021002200200021002200"))
    local i = 0
    local a = 0
    local head = 0x062c0000
    local vs = {0x00210020, 0x00200022, 0x00220021}
    local c = Cnt(1)
    return function()
        if c() then
            for _ = 1, 2 do
                i = (i % 3) + 1
                w32(head + a, vs[i])
                a = a + 4
            end
        end
    end
end,
function(obj)
    obj.name = "GAME FREAK presents画面"
    lib.warr(0x060002E4, lib.htob("0520062000200720082009200A200B2000200C200020002000200020"))
    lib.warr(0x06000324, lib.htob("1820192000201A201B201C201D201E2000201F2000200020"))
    obj:SKP(260, true)
end,
function(obj)
    obj.name = "日の出&ルギア羽ばたきシーン"
    obj:SKP(790)
    local x_offsets = {0x9080, 0xB080, 0xA060, 0x8060}
    local y_offsets = {0x54, 0x74, 0x74, 0x54}
    local spy = 0x6
    local ry = RC(30)
    local vy = ValueUpdater(1, -0x60, 0x50, VUO.add(0x6))
    :overflow_behavior("loop")
    :calc(function(o)
        if ry() then spy = rand(-0x4, 0x4)*0x3 end
        return o.v + spy
    end)
    :write(function(v)
        for i = 0, 3 do
            w16(0x021D7B78 + 8*i, y_offsets[i+1]+v)
        end
    end)
    local spx = 0x10
    local rx = RC(30)
    local vx = ValueUpdater(1, -0x100, 0x100)
    :overflow_behavior("loop")
    :calc(function(o)
        if rx() then spx = rand(-0x4, 0x4)*0x8 end
        return o.v + spx
    end)
    :write(function(v)
        for i = 0, 3 do
            w16(0x021D7B7a + 8*i, x_offsets[i+1]+v)
        end
    end)

    local rug_wait = lib.at(0x021D7B7F)
    local rug_waiting = true
    local backup
    local d = lib.htob("00049700C9030DC2C8109700C90372C4C8100000C0004A82A0100000C0007584A0109700C0004AC2A810C000C00075C4A810C000")
    return function()
        vx() vy()
        if rug_waiting then
            if rug_wait:r8() == 0 then
                return
            end
            rug_waiting = false
        end
        lib.warr(0x021D7B94, d)
    end
end,
function(obj)
    obj.name = "草むらを駆け抜けるシーン"
    obj:SKP(90, true)
end,
function(obj)
    obj:SKP(450)
    obj.name = "主人公顔出しシーン"
    lib.irume.start(irume1, 60)
    local function main(head)
        local function pos(x, y)
            local _y = y >> 3
            local left = x < 0x10
            local L = 0x100
            local d = 0
            if within(_y, 4, 5) then
                d = (left and 4 or 5)*0x100
                x = left and x or x - 0x10
                L = 0x80
                y = y-4*8
            elseif within(_y, 6, 10) then
                d = 6*0x100
                y = y-6*8
            elseif within(_y, 11, 12) then
                d = (left and 11 or 12)*0x100
                x = left and x or x - 0x10
                L = 0x80
                y = y-11*8
            elseif within(_y, 13, 17) then
                d = 13*0x100
                y = y-13*8
            end
            return lib.pos.Morton(x, y, 4, 0x20, L) + head + d
        end

        lib.image.filterObj()
        :width(0x20)
        :height(0x90)
        :go(function(x, y)
            local d = math.min(math.abs(x - 0xc), 0x10)
            local _y = (y - 0x20) // 10 + 0x20
            if y < 0x20 then _y = y end
            local _x = math.round(x * 0.7)
            local v = r8(pos(_x, _y))
            if v ~= 0 then v = v | 0x22222222 end
            return pos(x, y), v
        end)
    end
    main(0x06401000)
    main(0x06402400)

    ---@type string[][]
    local texts = {
        {"危", "な", "い", "っ", "て", "…"},
        {"メ", "モ", "リ", "モ", "リ", "モ", "リ"},
        {"カ", "！"},
        {"フ", "フ", "フ", "フ", "フ", "フ"},
        {"ア", "ヘ", "パ", "ン", "マ", "ン"},
        {"ア", "イ", "ス", "シ", "ー", "ル", "ド"},
        {"ジ", "ャ", "ン", "ボ", "ウ"},
        {"ラ", "イ", "ヌ"},
        {"サ", "イ", "ケ", "デ", "リ", "ン", "ク"},
        {"い", "い", "ぞ", "。"},
        {"め", "だ", "ま", "X", "X", "X", "％"},
    }
    local function R(prev)
        while true do
            local i = rand(1, #texts)
            if prev ~= i then return texts[i], i end
        end
    end
    ---@type string[][]
    local text_cueues = {}
    for i = 1, 4 do
        local _c = 0
        local prev = -1
        local __t = {}
        while _c < 200 do
            local t
            t, prev = R(prev)
            for j = 1, #t do
                __t[#__t+1] = t[j]
            end
            _c = _c + #t
        end
        text_cueues[i] = __t
    end

    local huhuhu = (function()
        local function pos(x, y)
            if x < 32 then
                return y*0x40 + x*2 + 0x06000800
            else
                x = x - 32
                return y*0x40 + x*2 + 0x06001000
            end
        end
        local _x = 0
        local function IN(x, y)
            local cueue = text_cueues[(y // 8) + 1]
            x = x + _x
            local c = assert(cueue[(x // 8) + 1], string.format("CUEUE (x: %d)", x))
            local font = assert(_FONTS[c], string.format("FONT (c: %s)", c))
            x = (x % 8) + 1
            y = (y % 8) + 1
            return string.sub(font[y], x, x) ~= "."
        end

        local setup_done = false
        local vs = {}
        local function setup()
            if setup_done then return true end
            if r32(0x06000800) == 0 then return false end
            for y = 0, 31 do
                for x = 0, 47 do
                    local p = pos(x, y)
                    vs[p] = r16(p)
                end
            end
            setup_done = true
            return true
        end
        return function()
            if not setup() then return end
            _x = _x + 3
            for y = 0, 31 do
                for x = 0, 47 do
                    local p = pos(x, y)
                    w16(p, IN(x, y) and 0 or vs[p])
                end
            end
        end
    end)()
    return huhuhu
end,
function(obj)
    obj.name = "街並みシーン"
    obj:SKP(420)
    lib.irume.start(irume2, 5)

    -- 21D9A10: ズーム
    local v1 = ValueUpdater(45, 0xFFFFD000, 0xFFFFF400, "pingpong"):w32(0x021D9A10)
    local sc = 0x80000
    local v2 = ValueUpdater(20, 0, 100, "lerp"):write(function(v)
        w32(0x021D9A14, math.icos(v/100, sc))
        w32(0x021D9A18, math.isin(v/100, sc))
    end)
    local cooltime = 300
    return function()
        v1()
        v2()
        w32(0x021D9A5C, rand(0, 2)*0x18181818)
        if cooltime > 0 then cooltime = cooltime - 1 return end
        w8(0x021D9A23, 0x11)
    end
end,
function(obj)
    obj.name = "ライバルスチル"
    obj:SKP(300, true)
    lib.irume.stop(8)
    lib.timer.setTimeout(200, function()
        print("OK")
        lib.irume.start(irume3)
    end)
    local vs = {}
    local rs = {
    0x06304b40, 0x06304d00, 0x06304e80, 0x06305060
    }
    for i = 0, 0x5f, 4 do
        for j = 1, 4 do
        vs[rs[j]+i] = r32(rs[j]+i)
        end
    end
    for i = 0, 0x5f, 4 do
        w32(rs[1]+i, vs[rs[3]+i])
        w32(rs[3]+i, vs[rs[1]+i])
        w32(rs[2]+i, vs[rs[4]+i])
        w32(rs[4]+i, vs[rs[2]+i])
    end

    -- lib.fill_in(0x06304b40, 0x06304b9f, 0x00)
    -- lib.fill_in(0x06304d00, 0x06304d5f, 0x00)
    -- lib.fill_in(0x06304e80, 0x06304edf, 0x00)
    -- lib.fill_in(0x06305060, 0x063050bf, 0x00)

    w32(0x06201A58, 0x3059304D)
    w32(0x06201A5C, 0x305B305A)
    w32(0x06201A60, 0x3059304C)
    w32(0x06201A64, 0x305D304D)

    w32(0x06201A9C, 0x30693068)
    w32(0x06201AA0, 0x3066306A)
    w32(0x06201AA4, 0x30663066)
    -- w32(0x06201AA4, 0x306D306C)
    -- w32(0x06201AA8, 0x306D3065)
    w32(0x06201AE0, 0x307A307A)
end,
function(obj)
    obj:SKP(210)
    obj.name = "3犬登場シーン"
    -- 3犬ともエンテイにする => ボツ
    -- for i = 0, 0x1ff, 4 do
    --     w32(0x06200200 + i, r32(0x06200800 + i))
    --     w32(0x06201400 + i, r32(0x06200800 + i))
    -- end

local function pos(x, y)
    -- x in [0, 32*3-1=95], y in [0, 7]
    if x < 32 then
        -- エンテイ
        return x * 2 + y * 0x40 + 0x06200800
    end
    x = x - 32
    if x < 32 then
        -- スイクン
        return x * 2 + y * 0x40 + 0x06200200
    end
    x = x - 32
    -- ライコウ
    return x * 2 + y * 0x40 + 0x06201400
end
local vs = {}
for y = 0, 7 do
    for x = 0, 95 do
        local _p = pos(x, y)
        vs[_p] = r16(_p)
    end
end

---@param type "E" | "S" | "R"
local roll = function(type, x_start, cooltime, d)
    local _x = x_start
    local done = false
    local x_base
    if type == "E" then x_base = 0 end
    if type == "S" then x_base = 32 end
    if type == "R" then x_base = 64 end
    return function()
        if done then return end
        cooltime = math.max(cooltime - 1, 0)
        if cooltime == 0 and math.abs(_x) <= math.abs(d) then
            done = true
            _x = 0
        else
            _x = (_x + d) % 96
        end
        for y = 0, 7 do
            for x = 0, 31 do
                w16(pos(x_base+x, y), vs[pos((_x+x) % 96, y)])
            end
        end
    end
end

local ST = 60
local p_en = roll("E", 0, ST, 3)
local p_sui = roll("S", 0, ST + 30, -3)
local p_rai = roll("R", 0, ST + 50, 5)

    return function()
        p_en() p_sui() p_rai()
    end
end,
function(obj)
    obj:SKP(180)
    obj.name = "ミナキ登場シーン"
    local function pos(x, y)
        if y < 64 then return lib.pos.Morton(x, y, 4, 0x20, 0x100) + 0x06601800
        else return lib.pos.Morton(x, y-64, 4, 0x20, 0x100) + 0x06601000
        end
    end
    local img = lib.image.filterObj()
    :width(32):height(128)

    local vs = {}
    for y = 0, 127 do
        for x = 0, 31 do
            vs[pos(x, y)] = r8(pos(x, y))
        end
    end

    local c = Cnt(3, 2)

    return function()
        c()
        img:go(function(x, y)
            if c.i == 0 then
                return pos(x, y), vs[pos(x, y)]
            end
            local v = vs[pos(31-x, y)]
            v = ((v & 0xf) << 4) | (v >> 4)
            return pos(x, y), v
        end)
    end
end,
function(obj)
    obj:SKP(160)
    obj.name = "アンノーン登場シーン&R団バグ準備"
    lib.irume.start(irume4, 100)

local function ROCKET()
local V = 3

for i = 0x062E6000, 0x062E6fff, 4 do
    local v = r32(i)
    local _v = 0
    for j = 0, 7 do
        local __v = (v >> (j*4)) & 0xf
        if __v == 0xa then __v = V end
        if __v == 0x9 then __v = V end
        if __v == 0x8 then __v = V end
        _v = _v | (__v << (j*4))
    end
    w32(i, _v)
end
for i = 0x062E6740, 0x062E67bf, 4 do
    local v = r32(i)
    local _v = 0
    for j = 0, 7 do
        local __v = (v >> (j*4)) & 0xf
        if within(__v, 1, 0x3) then __v = 0x3 end
        if within(__v, 5, 0x5) then __v = 0x3 end
        if i < 0x062E6780 and within(__v, 5, 0xf) then __v = 0x0 end
        if i >= 0x062E6780 and within(__v, 7, 0x9) then __v = 0x3 end
        _v = _v | (__v << (j*4))
    end
    w32(i, _v)
end
for i = 0x062E6880, 0x062E68ef, 4 do
    local v = r32(i)
    local _v = 0
    for j = 0, 7 do
        local __v = (v >> (j*4)) & 0xf
        if within(__v, 1, 0xf) then __v = 0x3 end
        _v = _v | (__v << (j*4))
    end
    w32(i, _v)
end
for i = 0x062E6920, 0x062E69ff, 4 do
    local v = r32(i)
    local _v = 0
    for j = 0, 7 do
        local __v = (v >> (j*4)) & 0xf
        if within(__v, 0x1, 0x5) then __v = 0 end
        if within(__v, 0xe, 0xf) then __v = 0 end
        _v = _v | (__v << (j*4))
    end
    w32(i, _v)
end
for i = 0x062E69f0, 0x062E7fff, 4 do
    local v = r32(i)
    local _v = 0
    for j = 0, 7 do
        local __v = (v >> (j*4)) & 0xf
        if within(__v, 0x1, 0x6) then __v = 0 end
        if within(__v, 0xa, 0xf) then __v = 0 end
        if i >= 0x062E6d00 then __v = 0 end
        _v = _v | (__v << (j*4))
    end
    w32(i, _v)
end

for i = 0x062E4420, 0x062E4fff, 4 do
    local v = r32(i)
    local _v = 0
    for j = 0, 7 do
        local __v = (v >> (j*4)) & 0xf
        if __v == 0xa then __v = V end
        if __v == 0x9 then __v = V end
        if __v == 0x8 then __v = V end
        _v = _v | (__v << (j*4))
    end
    w32(i, _v)
end
for i = 0x062E4800, 0x062E5fff, 4 do
    local v = r32(i)
    local _v = 0
    for j = 0, 7 do
        local __v = (v >> (j*4)) & 0xf
        if within(__v, 0x1, 0x6) then __v = 0 end
        if within(__v, 0xa, 0xf) then __v = 0 end
        if i >= 0x062E4d00 then __v = 0 end
        _v = _v | (__v << (j*4))
    end
    w32(i, _v)
end

local addrs = {
0x06221860,
0x062218A0,
0x062218E0,
0x06221920,
0x06221960,
0x062219A0,
0x062219E0,
0x06221A20,
0x06221A60,
0x06221AA0,
}

for _, a in pairs(addrs) do
    w32(a - 0x10, 0x401c401c)
    w32(a|0x4, 0x401c401c)
    w32(a|0x8, 0x401c401c)
    w32(a|0xc, 0x401c401c)
end
w32(0x06221864, 0x40014001)
w32(0x062218A4, 0x40054005)
end

local function pos(x, y)
    return lib.pos.Morton(x, y, 4, 0x20, 0x100)
end

local h1 = 0x06602000
local h2 = 0x06602800

lib.image.filterObj()
:width(32):height(64)
:go(function(x, y)
    if within(x, 12, 19) and within(y, 24, 36) then
        return pos(x, y)+h1, 0xee
    end
    local _y = clamp(math.round((y - 32) * 0.5) + 32, 0, 63)
    return pos(x, y)+h1, r8(pos(x, _y)+h1)
end)
:go(function(x, y)
    local v = r8(pos(x, y)+h2)
    local v1 = v & 0xf0
    local v2 = v & 0x0f
    v1 = v1 == 0 and v1 or (v1 ~ 0x30)
    v2 = v2 == 0 and v2 or (v2 ~ 0x03)
    return pos(x, y)+h2, v1 | v2
end)

local h3 = 0x06603000
local vs = {}
for y = 0, 63 do
    local _v = {}
    for x = 0, 31 do
        local v = r8(pos(x, y)+h3)
        _v[x*2] = v & 0xf
        _v[x*2+1] = v >> 4
    end
    vs[y] = _v
end
local c = Cnt(4)
local __vs = {}
for _y = 0, 63 do
    local _v = {}
    for _x = 0, 63 do
        _v[_x] = 0
    end
    __vs[_y] = _v
end
local ROCKET_cooltime = 90
return function()
    if ROCKET_cooltime > 0 then
        ROCKET_cooltime = ROCKET_cooltime - 1
        if ROCKET_cooltime == 0 then
            ROCKET()
        end
    end
    c()
    for _y = 0, 63 do
        for _x = 0, 63 do
            local x, y = _x, _y
            if c.i == 1 then
                x, y = y, x
            elseif c.i == 2 then
                x, y = x, 63-y
            elseif c.i == 3 then
                x, y = 63-y, x
            end
            __vs[_y][_x] = vs[y][x]
        end
    end
    local V = {}
    for y = 0, 63 do
        for x = 0, 31 do
            local v1 = __vs[y][2*x]
            local v2 = __vs[y][2*x+1] << 4
            V[pos(x, y)+h3] = v1 | v2
        end
    end
    for i = 0x06603000, 0x066037ff, 4 do
        local v = (V[i+3] << 24) | (V[i+2] << 16) | (V[i+1] << 8) | (V[i+0])
        w32(i, v)
    end
end
end,
function(obj)
    obj:SKP(230, true)
    obj.name = "R団表示中"
end,
function(obj)
    obj:SKP(90, true)
    obj.name = "主人公顔出しシーン2"
    lib.irume.start(irume5)

local function KOTONE()
    local head = 0x06185000
    local function pos(x, y)
        return lib.pos.Morton(x, y, 4, 0x20, 0x400) + head
    end

    lib.image.filterObj()
    :width(256):height(64)
    :go(function(x, y)
        local _y = math.round(y*0.7)
        return pos(x, y), r8(pos(x, _y))
    end)

    lib.image.filterObj()
    :width(256):height(130)
    :go(function(x, y)
        local p = pos(x, y)
        local v = r8(p)
        local v1, v2 = v >> 4, v & 0xf
        if v1 == 0xc then v1 = 0x8 end
        if v2 == 0xc then v2 = 0x8 end
        if v1 == 0xb then v1 = 0x7 end
        if v2 == 0xb then v2 = 0x7 end
        return p, (v1 << 4) | v2
    end)

    local function s(v)
        if v == 0xc then v = 0x6 end
        if v == 0xb then v = 0x5 end
        return v
    end

    for i = 0x6400800, 0x6400e67, 4 do
    -- for i = 0x6400800, 0x6400f67, 4 do
        local v = r32(i)
        local _v = 0
        for j = 0, 7 do
            _v = _v | s((v >> (4*j)) & 0xf) << (4*j)
        end
        w32(i, _v)
    end
end
local function HIBIKI()
    local head2 = 0x06385000
    local function pos2(x, y)
        return lib.pos.Morton(x, y, 4, 0x20, 0x200) + head2
    end
    lib.image.filterObj()
    :width(256):height(180)
    :go(function(x, y)
        local p = pos2(x, y)
        local v = r8(p)
        local v1, v2 = v >> 4, v & 0xf
        if v1 ~= 0 then v1 = v1 ~ 0xf end
        if v2 ~= 0 then v2 = v2 ~ 0xf end
        return p, (v1 << 4) | v2
    end)


    local head = 0x06386c00
    local function pos(x, y)
        return lib.pos.Morton(x, y, 4, 0x20, 0x200) + head
    end

    local offsets = {
        0, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 5, 99, 99, 99, 99, 99, 99, 99
    }
    for i = -9999, 0 do
        offsets[i] = 99
    end
    for i = 20, 1000 do
        offsets[i] = 99
    end

    local function IN(_x, _x2, y)
        return y >= offsets[_x] and y <= 17 + offsets[_x2]
    end
    local color = 0x8
    -- local color = 0x1

    lib.image.filterObj()
    :width(128):height(30)
    :go(function(x, y)
        if within(y, 0, 25) and within(x, 22, 30) then
            -- C or A
            local _x = (x - 22)*2
            local _x2 = (30-x)*2
            if within(x, 22, 25) then
                _x = _x - math.round((12-math.abs(y-12))*0.6)
                _x2 = _x2 - math.round((12-math.abs(y-12))*0.6)
            end
            -- _x = (30-x)*2
            local v1, v2 = 0xc, 0xc
            v1 = v1 ~ 0xf v2 = v2 ~ 0xf
            if IN(_x+1, _x2+1, y) then v1 = color end
            if IN(_x+2, _x2+2, y) then v2 = color end
            return pos(x, y), (v2 << 4) | v1
        end
    end)

    for i = 0x66FC000, 0x66FCFFF, 4 do
        w32(i, 0)
    end
end
    KOTONE() HIBIKI()

end,
function(obj)
    obj:SKP(320)
    obj.name = "御三家登場シーン"
    -- ボツ
    -- for i = 0, 0xfff, 4 do
    --     w32(i + 0x6401f00, r32(i + 0x6401A80))
    -- end

local function pos(x, y)
    x = x // 2
    if x < 16 then
        if y < 32 then
            return lib.pos.Morton(x, y, 4, 0x20, 0x80) + 0x06401A80
        else
            return lib.pos.Morton(x, y-32, 4, 0x20, 0x80) + 0x06401A80 + 0x20*24
        end
    else
        x = x - 16
        if y < 32 then
            return lib.pos.Morton(x, y, 4, 0x20, 0x40) + 0x06401A80 + 0x20*16
        else
            return lib.pos.Morton(x, y-32, 4, 0x20, 0x40) + 0x06401A80 + 0x20*32
        end
    end
end

local vs = {}
for y = 0, 47 do
    local _v = {}
    for x = 0, 47, 2 do
        local v = r8(pos(x, y))
        _v[x+1] = v >> 4
        _v[x] = v & 0xf
    end
    vs[y] = _v
end

local c = Cnt(2, 4)
local __vs = {}
for _y = 0, 47 do
    local _v = {}
    for _x = 0, 47 do
        _v[_x] = 0
    end
    __vs[_y] = _v
end

return function()
    c()
    for _y = 0, 47 do
        for _x = 0, 47 do
            local x, y = _x, _y
            if c.i == 1 then
                x, y = 47-y, x
            elseif c.i == 2 then
                x, y = 47-x, 47-y
            elseif c.i == 3 then
                x, y = y, 47-x
            end
            __vs[_y][_x] = vs[y][x]
        end
    end
    local V = {}
    for y = 0, 47 do
        for x = 0, 23 do
            local v1 = __vs[y][2*x]
            local v2 = __vs[y][2*x+1] << 4
            V[pos(x*2, y)] = v1 | v2
            V[pos(x*2, y)+0x900] = v1 | v2
        end
    end
    -- ヒノアラシ用
    for _y = 0, 47 do
        for _x = 0, 47 do
            local x, y = _x, _y
            if c.i == 0 then
                x, y = 47-x, y
            elseif c.i == 1 then
                x, y = 47-y, 47-x
            elseif c.i == 2 then
                x, y = x, 47-y
            elseif c.i == 3 then
                x, y = y, x
            end
            __vs[_y][_x] = vs[y][x]
        end
    end
    for y = 0, 47 do
        for x = 0, 23 do
            local v1 = __vs[y][2*x]
            local v2 = __vs[y][2*x+1] << 4
            V[pos(x*2, y)+0x480] = v1 | v2
        end
    end

    for i = 0x06401A80, 0x06401A80+0x480*3-1, 4 do
        local v = (V[i+3] << 24) | (V[i+2] << 16) | (V[i+1] << 8) | (V[i+0])
        w32(i, v)
    end
end
end,
function(obj)
    obj.name = "スイクン登場シーン待機"
    obj:SKP(50, true)
end,
function(obj)
    obj.name = "スイクン登場シーン"
    obj:SKP(240)

local BB = 0x20
-- local BB = 0x200

local r = RC(60)
return function()
for i = 0x06180e00, 0x061814ff, 4 do
    local _i = i
    -- if r() then _i = _i + (0x06200e00 - 0x06180e00) end
    local v = 0
    for j = 0, 1 do
        local _v
        if r() then
            _v = r16(clamp(_i + rand(-BB, BB) * 4, 0x06180e00, 0x061814fc))
        else
            _v = r16(_i)
        end
        v = v | (_v << (j*16))
    end
    w32(i, v)
end
local __v = rand(0, 0xffff)
__v = (__v << 16) | (__v+1)
for i = 0x06200000, 0x062003ff, 4 do
    __v = (__v + 0x00020002) % 0x100000000
    if r() then __v = rand(0, 0xfffe) __v = (__v << 16) | (__v+1) end
    -- w32(i, r() and 0 or 0x10001000)
    -- w32(i, rand(0, 0xffffffff))
    w32(i, __v)
end
for i = 0x06200e00, 0x062014ff, 4 do
    local _i = i
    -- if r() then _i = _i - (0x06200e00 - 0x06180e00) end
    local v = 0
    for j = 0, 1 do
        local _v
        if r() then
            _v = r16(clamp(_i + rand(-BB, BB) * 4, 0x06200e00, 0x062014fc))
        else
            _v = r16(_i)
        end
        v = v | (_v << (j*16))
    end
    w32(i, v)
end
end
end,
function(obj)
    obj:SKP(60)
    obj.name = "ムービー終了、移行待ち"
    lib.irume.start(irume3)
end,
function(obj)
    obj:SKP(1)
    obj.name = "タイトル画面"

local function pos(x, y)
    return lib.pos.Morton(x, y, 8, 0x40, 0x800) + 0x06200800
end

lib.image.filterObj()
:width(256):height(96)
:go(function(x, y)
    local _x
    if y >= 62 and x < 185 then
        _x = (x + 15) % 25
        if _x <= 15 then
            return pos(x, y), r8(pos(185 + _x, y))
        end
        _x = _x - 15
        local v = y <= 70 and r8(pos(200+_x, y)) or 0
        return pos(x, y), v
    end
    if y < 62 and x < 150 then
        _x = (x + 4) % 22
        return pos(x, y), r8(pos(150 + _x, y))
    end
end)
end,

function(obj)
    obj.name = "ルギア崩壊"


local ready = true
local update_bg = (function()
    local m = lib.at(0x022A752C)
    local mode = 0
    return function()
        if mode == 0 and m:r32() == 0 then
            mode = 1
        end
        if mode == 1 and within(m:r32(), 0x1000, 0x2000) then
            mode = 2
            ready = true
        end
        if ready then
            m:w32(0x11052000)
        end
    end
end)()

-- ボツ
local update_rug = (function()
    local c1 = Cnt(10, 2)
    return function()
        if not ready then return end
        c1() w8(0x22A74E2, c1.i == 0 and 4 or 0x11)
        c1() w8(0x22A74E8, c1.i == 0 and 7 or 9)
        -- c1() w8(0x22A74F0, c1.i == 0 and 2 or 1)
        w8(0x22A74F0, rand(0, 0x6))
        -- w8(0x22A74F2, rand(0, 0x6))
        -- w8(0x22A74F4, rand(0, 0x6))
        -- w8(0x22A74F6, rand(0, 0x6))
        -- w8(0x22A74F8, rand(0, 0x6))
        w8(0x22A74FA, rand(0, 0x1f))
    end
end)()

local update_rug2 = (function()
    local addrs = {
0x22C8560,
0x22C8578,
0x22C8590,
0x22C85a8,
0x22C85c0,
0x22C85d8,
0x22C85f0,
0x22C8608,
0x22C8620,
0x22C8630,
0x22C8644,
0x22C8658,
0x22C866c,
0x22C8680,
0x22C8698,
0x22C86b0,
0x22C86c8,
0x22C86e0,
0x22C86f8,
0x22C8710,
    }
    local backup = {}
    local r = RC(90)
    return function()
        if not ready then return end
        for _, a in pairs(addrs) do
            if not backup[a+4] then
                for i = 1, 2 do
                    backup[a+i*4] = r32(a+i*4)
                end
            end
            if r() then
                for i = 1, 2 do
                    w32(a+i*4, backup[a+i*4])
                end
            end
            for i = 1, 2 do
                add32(a+i*4, rand(-0x20, 0x20)*0x400)
            end
        end
    end
end)()

return function()
    update_bg()
    update_rug2()
end

end

})

while true do
    lib.main()
    emu.frameadvance()
end

