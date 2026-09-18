
local __use_normal_tsuji = true
local __tsuji_araburi = false
local __is_result_screen = false

local voice_main_pitch_active = true
local voice_main_speed_active = true

-- ================================
-- ========= イルーム処理 =========
-- ================================

local irume_master = function()
local irumes = {
function()
    local head = 0x03EB9210
    local as = {}
    local prevs = {}
    for i = 0, 14 do
        as[i] = head + 0x40*i
        prevs[i] = 0
    end
    local p1 = 0x0a
    local p2 = 0x17
    local t = 0x24
    local vol = 0x0e
    local v_i = 0
    local v_i_r = RC(60)
    local t_max = 0x28
    local t_max_r = RC(240)
    return function()
        if v_i_r() then v_i = rand(0,9) end
        if t_max_r() then
            t_max = rand(5, 0x40)
        end
        for i, a in pairs(as) do
            local _t = r8(a + t)
            if prevs[i] < _t then
                _t = rand(0x1, t_max)
                w8(a + p1, rand(0,0xff))
                w8(a + p2, stou8(rand(-6, 6)))
            end
            w8(a + t, _t)
            prevs[i] = _t
            if math.abs(i-v_i) <= 1 then
                w16(a + vol, 0x80)
            else
                w16(a + vol, 0)
            end
        end
    end
end,
function()
    local head = 0x03EB9210
    local as = {}
    for i = 0, 14 do
        as[i] = head + 0x40*i
    end
    local p = 0x10
    local t = 0x24
    local vol = 0x0e
    local v = ValueUpdater(90, -0x300, 0x600, "lerp")
    local r = RC(5)
    return function()
        v()
        if v.i == 0 and r() then
            v.n = rand(20, 90)
            r:N(450 // v.n)
        end
        for _, a in pairs(as) do
            w16(a+p, v.v)
            w16(a+vol, 0x40)
        end
    end
end,
function()
    local head = 0x03EB9210
    local as = {}
    for i = 0, 14 do
        as[i] = head + 0x40*i
    end
    local p = 0x10
    local t = 0x24
    local vol = 0x0e
    local v = ValueUpdater(30, -0x100, 0x200, "pingpong")
    local r = RC(5)
    return function()
        v()
        for _, a in pairs(as) do
            w16(a+p, v.v)
            w16(a+vol, 0x40)
        end
    end
end,
function()
    local head = 0x03EB9210
    local as = {}
    for i = 0, 14 do
        as[i] = head + 0x40*i
    end
    local p = 0x10
    local vol = 0x0e
    local pscl = 0x80
    local pscl_r = RC(120)
    local c = Cnt(6, 2)
    return function()
        c()
        if pscl_r() then
            pscl = rand(1, 5)*0x40
        end
        for _, a in pairs(as) do
            w16(a+p, c.i*pscl)
            w16(a+vol, 0x40)
        end
    end
end,
}

local N =#irumes
for i = 1, N do irumes[i] = irumes[i]() end
local i = rand(1, N)
local r = RC(300)
local cooltime = 0
return function()
    if cooltime > 0 then
        cooltime = cooltime - 1
    end
    if cooltime == 0 and r() then
        i = rand(1, N)
        cooltime = 90
    end
    irumes[i]()
end
end

-- ================================
-- ======= 左写真の画像処理 =======
-- ================================

--[[
== 雑多メモ ==

写真の加工関数:
順番もバラバラにする！

・座標stからスケールsclで上下引き伸ばす
・座標stからスケールsclで左右引き伸ばす
・x方向でnごとにループ
・y方向でnごとにループ
・x方向にdずらす
・y方向にdずらす

・y座標を fn(scl, ct, x) だけずらす (n = 1,...,3)
・x座標を fn(scl, ct, y) だけずらす (n = 1,...,3)
この2つは、sclのrand範囲が小さすぎて、結局効果なしになってしまった。次の動画ではちゃんと調整する！

f1(scl, ct, x) := round( scl*abs( 2*(x%ct)/ct - 1 ) )
f2(scl, ct, x) := round( scl * ( 2*(x%ct)/ct - 1 )^2 )
f3(scl, ct, x) := round( scl*(x%ct)/ct )
]]


local function update_shasin()
-- x in [0, 111], y in [0, 135]
local function pos(x, y)
    local head_ue = {
0x0660a580, 0x0660b580, 0x0660bd80
    }
    local head_shita = {
0x0660c180, 0x0660d180, 0x0660d980
    }
    ---@type int | int[]
    local head
    if y >= 128 then
        head = 0x0660dd80
        return lib.pos.Morton(x, y - 128, 8, 0x40, 0x380) + head
    elseif y >= 64 then
        head = head_shita
        y = y - 64
    else head = head_ue
    end
    local L
    if x >= 96 then
        head = head[3]
        x = x - 96
        L = 0x80
    elseif x >= 64 then
        head = head[2]
        x = x - 64
        L = 0x100
    else
        head = head[1]
        L = 0x200
    end
    return lib.pos.Morton(x, y, 8, 0x40, L) + head
end

-- x in [0, 129], y in [0, 135]
local function pos2(x, y)
    local head_ue = {
0x0640b000, 0x0640c000, 0x0640d000
    }
    local head_shita = {
0x0640d200, 0x0640e200, 0x0640f200,
    }
    ---@type int | int[]
    local head
    if y >= 128 then
        head = 0x0640f400
        return lib.pos.Morton(x, y - 128, 8, 0x40, 0x440) + head
    elseif y >= 64 then
        head = head_shita
        y = y - 64
    else head = head_ue
    end
    local L
    if x >= 128 then
        head = head[3]
        x = x - 128
        return lib.pos.Raster(x, y, 8) + head
    elseif x >= 64 then
        head = head[2]
        x = x - 64
        L = 0x200
    else
        head = head[1]
        L = 0x200
    end
    return lib.pos.Morton(x, y, 8, 0x40, L) + head
end

local vs = {}
for y = 0, 135 do
    local _v = {}
    for x = 0, 111 do
        _v[x] = r8(pos(x, y))
    end
    vs[y] = _v
end

local obj = lib.image.filterObj()
:width(112):height(136)
local obj_last = lib.image.filterObj()
:width(130):height(136)

---@return fun(x: int): int
local function special_f()
    local scl = rand(2, 20)/10
    local ct = rand(20, 40)
    local r = math.round
local fs = {
    function(x)
    return r(scl*math.abs(2*(x%ct)/ct - 1))
    end,
    function(x)
    local _x = 2*(x%ct)/ct - 1
    return r(scl*_x*_x)
    end,
    function(x)
    return r(scl*(x%ct)/ct)
    end,
}
    return fs[rand(1, #fs)]
end


---@type [int, fun(): (fun(x: int, y: int, _vs: int[][]): int)][]
local actions = {
{2, function()
    local scl = rand(3, 9) / 10
    local st = rand(20, 110)
    return function(x, y, _vs)
        local _y
        if y < st then
            _y = st - math.round((st-y)*scl)
        else
            _y = math.round((y-st)*scl) + st
        end
        return _vs[_y][x]
    end
end},
{2, function()
    local scl = rand(3, 9) / 10
    local st = rand(20, 90)
    return function(x, y, _vs)
        local _x
        if x < st then
            _x = st - math.round((st-x)*scl)
        else
            _x = math.round((x-st)*scl) - st
        end
        return _vs[y][_x]
    end
end},
{2, function()
    local st = rand(10, 90)
    return function(x, y, _vs)
        return _vs[y][math.abs(x-st)]
    end
end},
{2, function()
    local st = rand(10, 120)
    return function(x, y, _vs)
        return _vs[math.abs(y-st)][x]
    end
end},
{2, function()
    local n = rand(20, 60)
    return function(x, y, _vs)
        return _vs[y][x%n]
    end
end},
{2, function()
    local n = rand(20, 60)
    return function(x, y, _vs)
        return _vs[y%n][x]
    end
end},
{2, function()
    local d = rand(-40, 40)
    return function(x, y, _vs)
        return _vs[y][clamp(x+d, 0, 111)]
    end
end},
{2, function()
    local d = rand(-40, 40)
    return function(x, y, _vs)
        return _vs[clamp(y+d, 0, 135)][x]
    end
end},
{2, function()
    local _f = special_f()
    return function(x, y, _vs)
        return _vs[y][clamp(x+_f(y), 0, 111)]
    end
end},
{2, function()
    local _f = special_f()
    return function(x, y, _vs)
        return _vs[clamp(y+_f(x), 0, 135)][x]
    end
end},
}

local N = #actions

local function copy(_vs)
    local ret = {}
    for y = 0, 135 do
        local _v = {}
        for x = 0, 111 do
            _v[x] = _vs[y][x]
        end
        ret[y] = _v
    end
    return ret
end

---@param actions (fun(x: int, y: int, _vs: int[][]): int)[]
local function main(actions)
    local _vs1, _vs2 = copy(vs), copy(vs)
    local N = #actions
    for i = 1, N do
        for y = 0, 135 do
            for x = 0, 111 do
                _vs2[y][x] = actions[i](x, y, _vs1)
            end
        end
        _vs1 = copy(_vs2)
    end
    if __is_result_screen then
        obj_last:go(function(x, y)
            return pos2(x, y), _vs1[y][x%112]
        end)
    else
        obj:go(function(x, y)
            return pos(x, y), _vs1[y][x]
        end)
    end
end

local c = Cnt(2)
return function()
    if not c() then return end
    local _actions = {}
    local odr = {}
    for i = 1, N do odr[i] = i end
    for i = 1, N-1 do
        local j = rand(i, N)
        odr[i], odr[j] = odr[j], odr[i]
    end
    for _i = 1, N do
        local i = odr[_i]
        local A = actions[i]
        if rand(1, A[1]) == 1 then
            _actions[#_actions+1] = A[2]()
        end
    end
    if #_actions > 0 then
        main(_actions)
    end
end
end







-- ================================
-- ===== 右下辻先生の画像処理 =====
-- ================================

local update_last_tsuji_texture = (function()
local ready_m = lib.at(0x06506590)
local ready = false
local function make_pos(head)
    return function(x, y)
        if y < 64 then
            return lib.pos.Morton(x, y, 4, 0x20, 0x100) + head
        end
        y = y - 64
        if x < 16 then
            return lib.pos.Morton(x, y, 4, 0x20, 0x80) + head + 0x800
        end
        return lib.pos.Morton(x-16, y, 4, 0x20, 0x80) + head + 0x900
    end
end
local function O(head)
    return lib.image.filterObj_HalfByte()
    :reverse()
    :width(64):height(80):addr(make_pos(head))
end
---@type ImageFilterObj_HalfByte
local obj
---@type ImageFilterObj_HalfByte[]
local objs = {}
---@type fun()?
local setup = function()
    obj = O(0x06506500):save(true)
    local addrs = {
0x6506500,
0x6507f00,
0x6508900,
0x6509300,
0x6509d00,
    }
    for i, a in pairs(addrs) do
        objs[i] = O(a)
    end
    local hands = {
0x06505d00,
0x06506f00,
0x06507700,
    }
    for i = 0, 0x5ff, 4 do
        w32(hands[1]+i, 0)
        w32(hands[2]+i, 0)
        w32(hands[3]+i, 0)
    end
end
local c = Cnt(4, 2)
return function()
    if not ready then
        if ready_m:r32() == 0xfffb6270 then
            print("== LAST TSUJI READY ==")
            ready = true
        else return
        end
    end
    if setup then setup() setup = nil end
    c()
    for _, _obj in pairs(objs) do
        _obj:go(function(x, y)
            local _x = c.i == 0 and x or 63-x
            return obj.vs[y][_x]
        end)
    end
end
end)()


local function update_tsuji_texture()
local function pos_orig(x, y)
    return lib.pos.Morton(x, y, 4, 0x20, 0x100) + 0x066036c0
end

local function make_pos(head)
    return function(x, y)
        return lib.pos.Morton(x, y, 4, 0x20, 0x100) + head
    end
end

---@param pos_fun fun(x: int, y: int): int
local function _o(pos_fun)
    return lib.image.filterObj_HalfByte()
    :width(64):height(64):addr(pos_fun)
    :reverse():save(true)
end

local function delete_hands()
    for i = 0x06600ec0, 0x066010bf, 4 do w32(i, 0) end
    for i = 0x066018c0, 0x06601abf, 4 do w32(i, 0) end
    for i = 0x066057c0, 0x066059bf, 4 do w32(i, 0) end
end
delete_hands()

local obj = _o(pos_orig)

local objs = {
_o(make_pos(0x066010c0)),
_o(make_pos(0x06601ac0)),
_o(make_pos(0x066022c0)),
_o(make_pos(0x06602ac0)),
_o(make_pos(0x066036c0)),
_o(make_pos(0x06603ec0)),
_o(make_pos(0x066046c0)),
_o(make_pos(0x066059c0)),
}

local c = Cnt(2, 4)
local maps = {
function(x, y) return x, y end,
function(x, y) return 63-y, x end,
function(x, y) return 63-x, 63-y end,
function(x, y) return y, 63-x end,
}
return function()
    c()
    for _, o in pairs(objs) do
        o:go(function(x, y, vs)
            local _x, _y = maps[c.i+1](x, y)
            if __use_normal_tsuji then
                return obj.vs[_y][_x]
            end
            return vs[_y][_x]
        end)
    end
    if __tsuji_araburi then
        w8(0x21f4280, rand(0, 0xff))
        w8(0x21f4282, rand(0, 0xff))
        w8(0x21f4278, rand(0, 0xff))
        w8(0x21f427a, rand(0, 0xff))
        w8(0x21f4290, rand(0, 0xff))
        w8(0x21f4292, rand(0, 0xff))
    end
    if __is_result_screen then
        update_last_tsuji_texture()
    end
end
end



local setup_first_image = (function()
    local done = false
    local m = lib.at(0x022F98BA)
    return function()
        if done then return end
        if m:r8() == 0x72 then
            done = true
            print("SETUP FIRST IMAGE")
            m:w8(0x11)
        end
    end
end)()


-- ================================
-- ========== ボイス処理 ==========
-- ================================


local voice_main = (function()
local update_pitch = (function()
    local min, max = 0xf00, 0x4e00
    local cur = 0x2af8
    local target = cur
    local r = RC(30)
    return function()
        if not voice_main_pitch_active then return end
        if r() then
            x = rand(0, 1000) / 1000
            x = x * x
            target = math.round(x* (max - min)) + min
        end
        cur = math.ilerp(cur, target, 0.1)
        if __is_result_screen then
            w32(0x02341FB0, cur)
        else
            w32(0x023c1900, cur)
        end
    end
end)()
local update_speed = (function()
    -- local min, max = 0xf, 0xf0
    local min, max = 0x18, 0x90
    local cur = 0x37
    local target = cur
    local r = RC(10)
    return function()
        if not voice_main_speed_active then return end
        if __is_result_screen then
            max = 0x30
            target = clamp(target, min, max)
        end
        if r() then
            x = rand(0, 1000) / 1000
            x = x * x
            target = math.round(x* (max - min)) + min
        end
        cur = math.ilerp(cur, target, 0.1)
        if __is_result_screen then
            w8(0x02341FB4, cur)
        else
            w8(0x023c1904, cur)
        end
    end
end)()
return function()
    update_pitch()
    update_speed()
end
end)()

local function mizukke()
    for i = 0x23c5c30, 0x23c5fff do
        local v = r8(i)
        if v ~= 0 then
            w8(i, v + 1)
        end
    end
end
local function robot()
    for i = 0x23c6230, 0x23c62bf, 2 do
        w16(i, 0x1300)
    end
end
local pitch_abare = (function()
    local ps = {0x1200, 0x1600, 0x1a00, 0x1e00, 0x2200}
    local c = Cnt(5, #ps)
    return function()
        c()
        for i = 0x23c6230, 0x23c62bf, 2 do
            w16(i, ps[c.i+1])
        end
    end
end)()

local voice_ryori3 = (function()
    local r = RC(10)
    return function()
        if r() or r32(0x023D086C) == 0 then
        w32(0x023D086C, rand(0, 0xffffffff))
        end
    end
end)()


---@type fun(addr: int, s: string)
local function wr(addr, s)
    lib.warr(addr, lib.htob(s.."00"))
end

---@type fun(): bool
local v

---@type fun(addr: int, s: string)
local function VT(addr, s)
    local done = false
    local _s = lib.htob(s .. "00")
    w8(addr, 0)
    v = function()
        if done then return false end
        if r8(addr) ~= 0 then
            lib.warr(addr, _s)
            done = true
            return true
        end
        return false
    end
end

local setV, setVF, updateV = (function()
    ---@type fun()?
    local _callback = nil
    ---@type fun()?
    local _cleanup = nil
    ---@type fun(registerer?: fun(): fun()?, fun()?)
    local ret2 = function(registerer)
        if _cleanup then _cleanup() end
        if registerer then
            _callback, _cleanup = registerer()
        else
            _callback, _cleanup = nil, nil
        end
    end
    ---@type fun(callback?: fun())
    local ret1 = function(callback)
        ret2(function() return callback end)
    end
    local ret3 = function()
        if _callback then _callback() end
    end
    return ret1, ret2, ret3
end)()

SET_LOOP("VOICE_BUG", function()
    voice_main()
    updateV()
end)

---@type ActionsEntry
return {
function(obj)
    voice_main_pitch_active = false
    voice_main_speed_active = false
    print("READY: TOUCH 「つくる」")
end,
function(obj)
    obj:SKP(90)
end,
function(obj)
    -- obj:SKP(70) -- 範囲は60-90 (端値を安定しない)
wr(0x022F8A8C, -- 材木の腹ごしらえ
"8DDE96D882CC95A082B282B582E782A6"
)
VT(0x023D5904, -- サ'2ー__オイシー/ウメショ...
"3C5C5C5C5C566F6C3D8250825082583E835481668251815B81518151834983438356815B815E834583818356838781668251815B8386836D815E835483628370838A815E8349838D835681668251815E8375835E83568383816683828357836D8151815E8388815B8374815B8166815E8352834B83568166815E837D83698343835E8166815E8368838C8166836283568393834F836D8151815E83778166838B8356815B815E8375838983938366815B8166815E83748166815B837E815E836683938356838C816683938357836D815E836583428389837E83588374815B8166815E835E8363835E834183518166815E83898166815B83818393838F8151815E83418166834C836D815E837E834A834E8367835683658166815E8349836E8369837E836A8166815E835483438365834C836681668358815E834A81488166"
)
wr(0x022F8AB3, -- 干干干干干干干
"8ab18ab18ab18ab18ab18ab18ab1"
)
wr(0x022F8C22, -- <C:R>◆俺意するもの<C:...
"1A070000000003819F89B488D382B782E982E082CC1A0700000000010A8145838082C894C2819A89A1929A"
)
    obj.key_enable = false

local update_kouka = (function()
    local c = Cnt(2)
    local r = RC(180)
    local cool = 10
    local i = 0
    return function()
        if c.i == 0 then
            w8(0x3eb9a2c, 0x11)
            if r() then
                i = 0
                c()
            else return
            end
        end
        i = i + 1
        if i >= cool or r() then
            c()
        end
        w8(0x3eb9a2c, 0)
    end
end)()
SET_LOOP("update_kouka", update_kouka)

    return function()
        setup_first_image()
        if v() then
            obj:update_state(60)
            SET_LOOP("update_tsuji_texture", update_tsuji_texture())
            lib.irume.start(irume_master)
        end
    end
end,
function(obj)
    -- 半角カタカナを表示させるため(ム->ﾑ)にいじる
    local m = lib.at(0x02F48000):push16(0x5C04)
-- VT(0x023D5904,
-- "837d8166825183598151834583458345834583458345834583458345834583458345834583458345"
-- )
VT(0x023D5904, -- マ'2ズ_ニンゲンオ_デンシレ...
"837D8166825183598151836A83938351839383498151836683938356838C81668393835783668251815E8343835E8381837D8166824F835881938151815181518343835283938349815183548393835A83938360837A83688251815E836D83528166835683658349834E83678151837881668393838A83668358815E838881488251"
)
    return function()
        if v() then
            m:pop()
            voice_main_pitch_active = true
            voice_main_speed_active = true
            w8(0x3eb9a2c, 0)
            SET_LOOP("update_kouka", function()end)
        end
    end
end,
function(obj)
wr(0x022F8AB3, -- まさしをきざむ
"82DC82B382B582F082AB82B482DE"
)
wr(0x022F8B5D, -- 玉を取る
"8BCA82F08EE682E9"
)
wr(0x022F8C4F, -- 梅んじん刃 推しの種を○る。
"947E82F182B682F1906E0A908482B582CC8EED82F0819B82E98142"
)
VT(0x023D5904, -- デ'2ワ_マ'2ズ_ジャガイモ...
"836681668251838F8151837D816682518359815183578383834B834383828251815E835F816682518362835E815183458381837B8356836D8251815E834C835E836C81668251815B815E83498367835282508151834A8343838F838C835F8343816683528393836D815E83888166815B836A8151836381668388834E8151836381668388834E8151837D83698343835E83668250815E834C8355837E837D8166824F835881938144"
)
local _update_shasin = update_shasin()
local cnt = CntOnce(23)
return function()
    if cnt() then
        SET_LOOP("update_shasin", _update_shasin)
    end
    v()
end
end,
function(obj)
wr(0x022F8AB3, -- をむ干しを
"82F082DE8AB182B582F0"
)
wr(0x022F8B66, -- がり！ヌスォ便ざむ
"82AA82E88149836B8358834895D682B482DE"
)
wr(0x022F8C63, -- 梅干ゲの 金肉を かくきざ干し...
"947E8AB1835182CC0A8BE093F782F00A82A982AD82AB82B48AB182B582CC0A96B28342"
)
VT(0x023D5904, -- ツギ'2ニ_コムギコノ1/カワ...
"8363834D81668251836A815183528380834D8352836D8250815E834A838F8166825183498151834C836283608393836F8354837E816682518366815E8360815B81668354834E815E837D838B8381837D8358819381518151815183718387815B8381816682518393834B8151834C8363836C8343838D836A836981668251838B837D8366815E8374838983438370838C837D8166825183568193835E83898151835C834E835A834C8251815E835E837D8353836483508251815E837A8356836783458382838D8352816682518356836D81518366834C835C8352836983438251815E83668166824F835881938144"
)
return v
end,
function(obj)
    __use_normal_tsuji = false
wr(0x022F8AC2, -- しるょ梅くゆ
"82B582E982E5947E82AD82E4"
)
wr(0x022F8C82, -- <C:R>◆罪意するｗの<C:...
"1A070000000003819F8DDF88D382B782E9829782CC1A0700000000010A8145837C8345838B"
)
VT(0x023D5904, -- ソレデ'2ワ_アジツケ2/ミソ...
"835C838C836681668251838F815183418357836383508251815E837E835C8352839383728369815B816682518367836D815E837483898393834E8374838B8367816682518349815E8363834E838A837D8166824F83588193815181518151834C836D815B836D815E83528352838D836D816682518352838A835F8362835E815183608385815B8367836E81668251839383708369815E83578387815B836C836383498151838881668251815B8343835681938365815E834E835F83548256824F83438144"
)
return v
end,
function(obj)
wr(0x022F8AC2, -- つくるょ
"82C282AD82E982E5"
)
wr(0x022F8B7A, -- 調味料をタっせる
"92B296A197BF82F0835E82C182B982E9"
)
wr(0x022F8CA8, -- ボウ君に神の 爪肉、ヨし汁と ...
"837B83458C4E82C9905F82CC0A92DC93F78141838882B58F6082C60A8EE582F00A1A07000000000291E582D882B682BA82F182D41A0700000000010A93FC82EA82E38149"
)
VT(0x023D5904, -- マ'2ズ_ビ'2ールニ_サメノ...
"837D8166825183598151837281668251815B838B836A815183548381836D8251815E834A836A834E8151835F83568357838B8367815E8354835083678151837281668251815B838B815E837D835E81668251838F815E834983438356815B815E83458381835683858349815183588193834C8369835F83508151835E8362837681668251838A81518382815B83608387816682518362836781518382815B83718367816682518352834781518343838C8365815E834E835F83548166824F83438144"
)
return v
end,
function(obj)
    __use_normal_tsuji = true
    __tsuji_araburi = true
setV(mizukke)
wr(0x022F8AC2, -- くるくるくるだし汁
"82AD82E982AD82E982AD82E982BE82B58F60"
)
wr(0x022F8B8B, -- 悪ぜ言わせる
"88AB82BA8CBE82ED82B982E9"
)
wr(0x022F8CEF, -- しょ風ゆ <C:G>㌔さじぽん...
"82B582E5959782E40A1A070000000002876082B382B682DB82F11A07000000000181410A907C939C0A91E582B382E98142"
)
VT(0x023D5904, -- ソコエ_ショーユオ_サト'2ー...
"835C83528347815183568387815B8386834981518354836781668251815B834981518352835683878166815B83498151837483898343837083938349815183888393835A83938360836E8166836F83498151837B815B838B83498151837E8166834C8354815B83498151834A8343838F838C8166815E8375835E8352816683938375834981518366834C8341834B838A837D83568193835E8144"
)
return v
end,
function(obj)
setV()
wr(0x022F8AD5, -- ４肉を切る
"825393F782F090D882E9"
)
wr(0x022F8B98, -- ４町幅に切る
"825392AC959D82C990D882E9"
)
wr(0x022F8D44, -- 豚肉を切る。 切る。 肉を切る...
"93D893F782F090D882E981420A90D882E981420A93F782F090D882E9814282E981420A93F7814293D882E993D88142"
)
VT(0x023D5904, -- ツギ'2ワ_レートーフ'2リカ...
"8363834D81668251838F8151838C815B8367815B837481668251838A834A83508349815E8384834C837D8166824F83588193815181518151836A835A8367815B836F816682518393835783838393836A8151836A834F83898380837A8368815E834A834E8356837B81668251815B83608387815B8349815E8343838C824F8151837183848356815E837D8343835E8350835881668251815B8376836A815183498384816682518349815E8352838D8354838C83658251815E834E835F83548166824F83438144"
)
return v
end,
function(obj)
setV(voice_ryori3)
wr(0x022F8AE0, -- 豚元に下男をつける
"93D88CB382C989BA926A82F082C282AF82E9"
)
wr(0x022F8D5A, -- <C:R>◆もするもの<C:B...
"1A070000000003819F82E082B782E982E082CC1A0700000000010A81458E4D8145"
)
VT(0x023D5904, -- ココデ_ヤミツキノ_ヒョージュ...
"83528352836681518384837E8363834C836D815183718387815B835783858393815E8369837D83848350815E8349838D83568369835E83668352816682518352838F81518352836D834181668367836D8151836E839383578385834E815E8369837D83548389835F83418166825183758389834B815E834983438356815B834C8166835A8363836D815E8380835683568387815B834B8384834C8349815E8363834E838A837D83568387816682518349815B8149"
)
return v
end,
function(obj)
voice_main_pitch_active = false
setV(robot)
wr(0x022F8AE0, -- 豚　に　　　つ
"93D8814082C981408140814082C2"
)
wr(0x022F8BA6, -- 塩・こょんる
"8996814582B182E582F182E9"
)
wr(0x022F8D7C, -- 梅頭ぞ 更に盛れ 敵、多しょう...
"947E93AA82BC0A8D5882C990B782EA0A9347814191BD82B582E582A40A82F082C182E9834F"
)
VT(0x023D5904, -- ブタニクオ2_オシリニイレテ2...
"8375835E836A834E83498251815183498356838A836A8343838C8365825181518354834981668251815183508356838781668251815B83498151815181518349836281498251"
)
return v
end,
function(obj)
voice_main_pitch_active = true
setV()
wr(0x022F8AF3, -- きゅきゅ切り
"82AB82E382AB82E390D882E8"
)
wr(0x022F8BB9, -- 股切りに米る
"8CD290D882E882C995C482E9"
)
wr(0x022F8DB8, -- きもうりを <C:R>国刈り<...
"82AB82E082A482E882F00A1A0700000000038D918AA082E81A070000000001838682D382BF8142"
)
VT(0x023D5904, -- ツギ'2ニ＿キュ'2ーリオ/ミ...
"8363834D81668251836A8151834C838581668251815B838A8349815E837E8166834C8354815B836A835681938365815E834E835F83548166824F83438144"
)
return v
end,
function(obj)
wr(0x022F8B02, -- にんじんをとこ
"82C982F182B682F182F082C682B1"
)
wr(0x022F8BC6, -- 細切りにする
"8DD790D882E882C982B782E9"
)
wr(0x022F8DE0, -- Ｍんじんの 皮をむきー <C:...
"826C82F182B682F182CC0A94E782F082DE82AB815B0A1A0700000000038DD790D882E81A07000000000182C582C982E98142"
)
VT(0x023D5904, -- ツヅイテ_ニンジンノ2/カワ'...
"83638364834383658151836A839383578393836D8251815E834A838F816682518349815E83808343836581668251834A8389815183608385815B83728366815E83718387815B83818166825183938349815E83528393834B81668251838A815E8384834383658151836C83828367816682518349815E834C838A834981668251836783568365815183548343836F835683698166825183688349815E8363834A83628365815E837D835B8341838F81668251835A83658151837A835C834D838A836A8356819383658151836981668378836A815E8343838C8365815E83578362834E81668250838A815E836A835281668251839383668151815181518151"
)
return v
end,
function(obj)
wr(0x022F8B11, -- かかかかい大根根元元元る
"82A982A982A982A982A291E58DAA8DAA8CB38CB38CB382E9"
)
wr(0x022F8BD3, -- 根元元元元
"8DAA8CB38CB38CB38CB3"
)
wr(0x022F8E14, -- くえええ大根根 根元元切切 落...
"82AD82A682A682A691E58DAA8DAA0A8DAA8CB38CB390D890D80A978E978E978E94BC95AA95AA0A92B782B382B390D890D890D80A83548362836290F482A88142"
)
VT(0x023D5904, -- カイワレダ'2イコンノ/ネモト...
"834A8343838F838C835F81668251834383528393836D815E836C83828367816682518349815E834A8343838F838C835F81668251834383528393836783568151834A8343838F838C835F81668251834383528393836D815E836981668251834B8354836A815E834A8343838F838C835F8166825183628365834A83898151834A8343838F838C835F816682518343835283938366815E834A8343838F838C816683628367815E8341838983628365815E834A8343838F838C835F83548166824F83438144"
)
return v
end,
function(obj)
VT(0x023D5904, -- __コレデ/シタゴ'2シラエワ
"815181518352838C8366815E8356835E835381668251835683898347838F"
)
wr(0x022F8A9D, -- 料☆理
"97BF8199979D"
)
    obj:SKP(300)
return v
end,
function(obj)
wr(0x022F8B2A, -- 野魂を爆ぜる
"96EC8DB082F0949A82BA82E9"
)
wr(0x022F8E55, -- <C:R>ふ懇意すじもの<C:...
"1A07000000000382D38DA788D382B782B682E082CC1A0700000000010A8277837B82ED82D7"
)
VT(0x023D5904, -- デ'2ワ_キ'2ッタ/コドモタ...
"836681668251838F8151834C816682518362835E815E835283688382835E81668250836083498151837D836A8341838F835A837D8166824F83588193815181518151838881668251815B8343815E8358838B8382836D8166824F83498151838881668251815B8343835681938365815E834E835F83548166824F83438144"
)
return v
end,
function(obj)
wr(0x022F8B2A, -- 野ぜる
"96EC82BA82E9"
)
wr(0x022F8BDF, -- 混わる
"8DAC82ED82E9"
)
wr(0x022F8E7B, -- きせる。
"82AB82B982E98142"
)
VT(0x023D5904, -- ナベツ'1カミ_ボンジン_オイ...
"83698378836381668250834A837E8151837B839383578393815183498343837B838C835F81668251834383698353839383498151837B8166815B8359836A815E8343838C836581518371835D815B836D815E8358834E815B837683568383835683938166836983688349815E8363834A836283658151837D83538166824F836A815E8341838F81668251835A8365815E834E835F83548166825183438144"
)
return v
end,
function(obj)
wr(0x022F8B37, -- 器！
"8AED8149"
)
wr(0x022F8BEC, -- をしくォ
"82F082B582AD8348"
)
wr(0x022F8EB8, -- 時に 混ぜ合わせた 野菜婆？
"8E9E82C90A8DAC82BA8D8782ED82B982BD0A96EC8DD8946B8148"
)
VT(0x023D5904, -- ウツナノニ_マゼアワセ'2テ/...
"834583638369836D836A8151837D835B8341838F835A816682518365815E8356837D8362835E815E8384835483438349815183508363836A8356819383438365815E8349834C837D8166824F835881938144"
)
return v
end,
function(obj)
wr(0x022F8B46, -- 金金金金金
"8BE08BE08BE08BE08BE0"
)
wr(0x022F8ED7, -- <C:R>◆用金する金<C:B...
"1A070000000003819F97708BE082B782E98BE01A0700000000010A81458374838983438BE08393"
)
VT(0x023D5904, -- ソレデ'2ワ_コンジョ'0ーオ...
"835C838C836681668251838F815183528393835783878166824F815B8349815E8384834C837D8166824F8358819381518151815183438166824F837D8151834183698166824F835E834B815E83828362836781668382815E8369834F838A835E81668343815E8382836D8166824F83498151838881668251815B8343835681938365815E834E835F83548166824F83438144"
)
return v
end,
function(obj)
wr(0x022F8B46, -- タ肉をにく
"835E93F782F082C982AD"
)
wr(0x022F8BF8, -- 油を熟する
"96FB82F08F6E82B782E9"
)
wr(0x022F8F01, -- フライヤンに カラダ油 <C:...
"8374838983438384839382C90A834A8389835F96FB0A1A07000000000291E582D182B688EA906C914F1A0700000000010A82F093FC82EA81410A8FEE82C982A982AF82E98142"
)
VT(0x023D5904, -- マ'2ズ_キッチンペ'ーパーニ...
"837D8166825183598151834C83628360839383798166815B8370815B836A815183548389835F83418166825183758389834981518374834A8343836A836981668251838B837D8366815E835C835C834D815183718166836A815E834A8166825183508365815E834E835F83548166824F83438144"
)
return v
end,
function(obj)
    print("墨肉を抱く の部分")
wr(0x022F8B46, -- 墨肉を抱く
"966E93F782F095F882AD"
)
wr(0x022F8C03, -- ４面を泣く
"825396CA82F08B8382AD"
)
wr(0x022F8F48, -- ぷ肉を大枚ずつ キライパンに ...
"82D593F782F091E5968782B882C20A834C838983438370839382C90A89F382EA81411A070000000003928695941A07000000000182C50A8BD196CA82F082AA82E882AA82E80A906882AD8142"
)
VT(0x023D5904, -- ツギ'2ニ_ジューブ'1ン/ネ...
"8363834D81668251836A815183578385815B8375816682508393815E836C836283568193835E815E837483898343837083938349815183438360837D83438359816682518363815183498360834A834E836D815E8386815B837283938166825083458350836A815E8343838C836581518360838581668251815B8375836681518371838581668251815B837D83938349815183528393834B81668251838A815E8384834C83698166834B8389815E83498368838A834F834383568365815E834E835F83548166824F83438144"
)
return v
end,
function(obj)
wr(0x022F8B46, -- 汁恋べ苦く
"8F6097F682D78BEA82AD"
)
wr(0x022F8C0E, -- 裏芝を焼く
"97A08EC582F08FC482AD"
)
wr(0x022F8F95, -- 鬼童ぃ 店返して、 愚面にも弱...
"8B5393B682A10A935895D482B582C481410A8BF096CA82C982E08EE382AB90460A82DC82C282AF82E98142"
)
VT(0x023D5904, -- ブタニクノタ'イドオ/ウラガ'...
"8375835E836A834E836D835E8166834383688349815E83458389834B8166825183478356815183748389838183938352836A8166825183828151815E8384834C834383828349815E8358835883818365815E834E835F83548166824F83438144"
)
return v
end,
function(obj)
wr(0x022F8B51, -- 際グつけャ
"8DDB834F82C282AF8383"
)
wr(0x022F8C19, -- 技に盛る
"8B5A82C990B782E9"
)
wr(0x022F8FC1, -- 汚温ぐ腋に盛れ、 梅しボンゆを...
"899889B782AEE3FC82C990B782EA81410A947E82B5837B839382E482F00A837B82AF82C40A837B82AB82A082AA82E88149"
)
VT(0x023D5904, -- ウツワニ2_シ'イタケノ/ホネ...
"83458363838F836A82518151835681668343835E8350836D815E837A836C81668349815E837D8363838A81518384834E83548343836D815E8345834781668251836A815183758362835E836F834A838A836D815E8382838A8151835C83568193836581518367838C835E8365836D815E8352834583818356838781668251815B83868349815E83758362834A835081668251838C836F815183418351834A83938364816682518381836D81518363834A8166838C835E815E8376838D83548389838A815B837D83938374815B815E836A8393836A834E8343838A815E837E836C8389838B834583488166815B835E815B836D81518369837D838C836F815B83578166835E8365836D815E834983438356815B815E8352815B8393837C835E8166815B83578385836D815E8366834C8341834B838A836681668251835881938149"
)
return v
end,
function(obj)
lib.romwarr(0x003C046F, -- 輩へゅおゆ風の<LF>そっぽぎ...
lib.htob("947982D682E382A882E4959782CC1A0510000182BB82C182DB82AC93DB906C00")
)
local cnt = CntOnce(40)
return function()
    if cnt() then
        __is_result_screen = true
    end
end
end,
function()
VT(0x02355FB4, -- アリ'ガトーゴザ/シンデモライ...
"8341838A8166834B8367815B83538355815E835683938366838283898343837D83588149"
)
return v
end
}
