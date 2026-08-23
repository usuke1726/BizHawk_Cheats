
---出力画面をクリアする
function CLS() console.clear() end

---@param v int
---@param digits? int
---@param no_prefix? bool
local function to_hexstr(v, digits, no_prefix)
    local f = (no_prefix and "" or "0x") .. "%0" .. (digits and tostring(digits) or "") .. "X"
    return string.format(f, v)
end
_HEX = to_hexstr
---@param v int
---@param digits? int
---@param no_prefix? bool
local function print_hexstr(v, digits, no_prefix)
    print(to_hexstr(v, digits, no_prefix))
end
_HEXP = print_hexstr

---`m`以上`n`以下の整数をランダムに取得する。
---@param m int
---@param n int
---@return int
function rand(m, n) return math.random(m, n) end
---@generic T
---@param arr T[]
---@return T
function randelt(arr) return arr[rand(1, #arr)] end
---@param v int
---@param min int
---@param max int
---@return bool
local function _within(v, min, max)
    return v >= min and v <= max
end
within = _within

---@generic T : table
---@param table T
---@return T
local function _table_copy(table)
    local out = {}
    for i, v in pairs(table) do
        out[i] = v
    end
    return out
end
table_copy = _table_copy
---負値の可能性がある1バイト値`val`を非負にする。(負の場合は1byteオーバーフロー)
---@param val int
---@return int
local function _stou8(val)
    return val >= 0 and val or (0x100 + val)
end
---負値の可能性がある2バイト値`val`を非負にする。(負の場合は2byteオーバーフロー)
---@param val int
---@return int
local function _stou16(val)
    return val >= 0 and val or (0x10000 + val)
end
---負値の可能性がある4バイト値`val`を非負にする。(負の場合は4byteオーバーフロー)
---@param val int
---@return int
local function _stou32(val)
    return val >= 0 and val or (0x100000000 + val)
end
stou8 = _stou8
stou16 = _stou16
stou32 = _stou32

---文字列で記述されたバイト列を配列に変換する。
---@param bytes_str string
---@return int[] bytes
local function _htob(bytes_str)
    bytes_str = bytes_str:gsub(" ", "")
    local pr = string.sub(bytes_str, 1, 2)
    if pr == "0x" or pr == "0X" then bytes_str = string.sub(bytes_str, 3) end
    local n = #bytes_str
    local ret = {}
    if n <= 8 then
        for i = 1, n - 1, 2 do
            ret[#ret+1] = tonumber(string.sub(bytes_str, i, i + 1), 16)
        end
        return ret
    end
    local j = 0
    for i = 1, n - 8, 8 do
        local v = tonumber(string.sub(bytes_str, i, i + 7), 16)
        ret[#ret+1] = (v & 0xff000000) >> 24
        ret[#ret+1] = (v & 0x00ff0000) >> 16
        ret[#ret+1] = (v & 0x0000ff00) >> 8
        ret[#ret+1] = v & 0x000000ff
        j = i
    end
    for i = j + 8, n - 1, 2 do
        ret[#ret+1] = tonumber(string.sub(bytes_str, i, i + 1), 16)
    end
    return ret
end
htob = _htob
---文字列で記述されたバイト列を、luaコードとしてコピペ可能な配列文字列に変換して出力する。
---
---例: `"00001B4359"` -> 文字列 `{0x00, 0x00, 0x1B, 0x43, 0x59}` が出力される
---@param bytes_str string
local function print_htob(bytes_str)
    local arr = _htob(bytes_str)
    local s = {}
    for i, v in arr do s[#s+1] = string.format("%02X", v) end
    console:log("{" .. table.concat(s, ", ") .. "}")
end

---`value`を[`min_`, `max_`]の範囲に収める
---@param value int
---@param min_ int?
---@param max_ int?
---@return int
local function _clamp(value, min_, max_)
    if min_ and value < min_ then value = min_ end
    if max_ and value > max_ then value = max_ end
    return value
end
clamp = _clamp
math.clamp = _clamp

---@param value int
---@param min_ int?
---@param max_ int?
---@param bytemax int
---@return int
local function _clamp_tmp(value, min_, max_, bytemax)
    if min_ and min_ < 0 then
        if value > (bytemax >> 1) then
            value = value - bytemax
        end
    end
    if min_ and value < min_ then value = min_ end
    if max_ and value > max_ then value = max_ end
    return value
end
---`value`を**signed**と解釈した上でclampする
---@param value int
---@param min_ int?
---@param max_ int?
---@return int
local function _clamp8(value, min_, max_)
    return _clamp_tmp(value, min_, max_, 0x100)
end
---`value`を**signed**と解釈した上でclampする
---@param value int
---@param min_ int?
---@param max_ int?
---@return int
local function _clamp16(value, min_, max_)
    return _clamp_tmp(value, min_, max_, 0x10000)
end
---`value`を**signed**と解釈した上でclampする
---@param value int
---@param min_ int?
---@param max_ int?
---@return int
local function _clamp32(value, min_, max_)
    return _clamp_tmp(value, min_, max_, 0x100000000)
end
clamp8 = _clamp8
clamp16 = _clamp16
clamp32 = _clamp32

---整数に丸める。
---@param v number
---@return int
local function _round(v)
    return math.floor(v + 0.5)
end
math.round = _round
round = _round

---@param x number
---@param scale number
---@return int
local function _isin(x, scale)
    return _round(math.sin(x * 2 * math.pi) * scale)
end
---@param x number
---@param scale number
---@return int
local function _icos(x, scale)
    return _round(math.cos(x * 2 * math.pi) * scale)
end
math.isin = _isin
math.icos = _icos
---`[0,1]`の範囲の`x`から`[0,1]`範囲のsinカーブを返却する。
---@param x number
---@return number
local function _sin01(x)
    return math.sin(x * 2 * math.pi) * 0.5 + 0.5
end
---`[0,1]`の範囲の`x`から`[0,1]`範囲のcosカーブを返却する。
---@param x number
---@return number
local function _cos01(x)
    return math.cos(x * 2 * math.pi) * 0.5 + 0.5
end
math.sin01 = _sin01
math.cos01 = _cos01
---整数`x`を`[min, max]`の範囲でmodをとる。
---@param x int
---@param min int
---@param max int
---@return int
local function _mod(x, min, max)
    return (x - min) % (max - min) + min
end
math.mod = _mod

---線形補間を行う。
---@param value number
---@param target number
---@param t number
---@return number
local function _lerp(value, target, t)
    return value + (target - value) * t
end
---整数の線形補間を行う。
---@param value int
---@param target int
---@param t number
---@return int
local function _ilerp(value, target, t)
    return _round(_lerp(value, target, t))
end
lerp = _lerp
ilerp = _ilerp
math.lerp = _lerp
math.ilerp = _ilerp

---@generic T
---@class SetObj<T>
---@field protected _tbl table<T, bool>
local SetObj = {}

---@generic T
---@param self SetObj<T>
---@return T[]
function SetObj:arr()
    local ret = {}
    for v, f in pairs(self._tbl) do
        if f then ret[#ret+1] = v end
    end
    return ret
end
---@generic T
---@param self SetObj<T>
---@param v T
---@return bool
function SetObj:has(v) return self._tbl[v] end
---@generic T
---@param self SetObj<T>
---@param v T
---@return bool changed
function SetObj:add(v) local ret = not self._tbl[v] self._tbl[v] = true return ret end
---@generic T
---@param self SetObj<T>
---@param v T
---@return bool changed
function SetObj:remove(v) local ret = self._tbl[v] self._tbl[v] = nil return ret end

---@generic T
---@param arr T[]?
---@return SetObj<T>
local function _Set(arr)
    arr = arr or {}
    local tbl = {}
    for _, v in pairs(arr) do tbl[v] = true end
    return setmetatable({
        _tbl = tbl,
    }, {
        __index = SetObj,
    })
end
Set = _Set

---@param min int
---@param max int
---@param num int
---@param allow_dup bool?
---@return int[]
local function _random_set(min, max, num, allow_dup)
    if min > max then min, max = max, min end
    local range = max - min + 1
    if range < num and (not allow_dup) then
        error("[random_set] too small range: " .. tostring(range))
    end
    local choose_excludes = (range >> 1) < num
    local _num = choose_excludes and range - num or num
    local i = 0
    if allow_dup then
        local ret = {}
        for _i = 1, num do
            ret[#ret+1] = rand(min, max)
        end
        return ret
    else
        ---@type table<int, bool>
        local _map = {}
        while true do
            local v = rand(min, max)
            if not _map[v] then
                _map[v] = true
                i = i + 1
                if i == _num then break end
            end
        end
        local ret = {}
        if choose_excludes then
            for j = min, max do
                if not _map[j] then ret[#ret+1] = j end
            end
        else
            for j, _ in pairs(_map) do
                ret[#ret+1] = j
            end
        end
        return ret
    end
end
random_set = _random_set

---2次元座標をモートン順序に基づき1次元配列の座標に変換する。
---
--- - `W`: ブロック幅("W"idth, ブロック内の次の行に移行するまでの距離)
--- - `N`: 次のブロックに移行するまでの距離(つまりブロックのピクセル総数)
---     - ("N"eighbor, "N"ext block, "N"umber of pixels per block)
--- - `L`: 次のブロック行("L"ine)に移行するまでの距離
--- 
--- #### 注意
--- 
--- - `W | N | L`、つまり`N`は`W`の倍数、`L`は`N`の倍数でなければならない。
---
--- #### 図解 (`W = 4, N = 8, L = 16`)
--- 
--- ```plaintext
---             N
---      |-- -- -- ---|
---      |<-- W -->|  v  
---   -- 00 01 02 03 08 09 10 11
--- L |  04 05 06 07 12 13 14 15
---   -> 16 17 18 19 24 25 26 27
---      20 21 22 23 28 29 30 31
--- ```
---@param x int
---@param y int
---@param W int
---@param N int
---@param L int
---@return int
local function pos_Morton(x, y, W, N, L)
    local block_lines = N // W
    local a1, a2 = y // block_lines, y % block_lines
    local b1, b2 = x // W, x % W
    return (
        a1 * L
        + b1 * N
        + a2 * W
        + b2
    )
end

-- 他には、ヒルベルト曲線による走査や、ジグザグスキャンがある

---2次元座標をラスタスキャンの順序で1次元配列の座標に変換する。
---
--- #### 図解 (`W = 8`)
--- 
--- ```plaintext
--- |<--       W       -->|
--- 00 01 02 03 04 05 06 07
--- 08 09 10 11 12 13 14 15
--- 16 17 18 19 20 21 22 23
--- 24 25 26 27 28 29 30 31
--- ```
---@param x int
---@param y int
---@param W int
---@return int
local function pos_Raster(x, y, W)
    return y*W + x
end

local __RandomCheating_DefaultConf = {
    delay = 10,
    reset_time = 60,
    print_maxlines = 10,
    enable_key_reseting = true,
    reset_key = "L",
    do_reset = nil,
    get_addr = function()
        return rand(0x02200000, 0x02dfffff)
    end,
    get_bound = function()
        return rand(0x1000, 0x10000)
    end,
    get_val = function()
        return rand(0, 0xff)
    end,
}

---@class RandomCheatingConf
---@field delay int state読み込みをしてメモリ書き込みをするまでの遅延 (Default: `10`)
---@field reset_time int state読み込みをするインターバル (Default: `60`)
---@field print_maxlines int メモリ書き込み情報を表示する行数 (Default: `10`)
---@field get_addr fun(i: int): int 書き込む先頭アドレスを与える関数 (Default: `rand(0x02200000, 0x02dfffff)`)
---@field get_bound fun(i: int): int 書き込む範囲を与える関数 (Default: `rand(0x1000, 0x10000)`)
---@field get_val fun(i: int): int 書き込む値を与える関数 (Default: `rand(0, 0xff)`)
---@field enable_key_reseting bool インターバルを待たずともキー入力でstate読み込みをするか否か 
---@field reset_key DS_Keys インターバルを待たずにリセットするためのキー (Default: `"L"`)
---@field do_reset? fun(i: int): bool インターバルやキー入力以外の特殊リセットトリガー処理
__RandomCheating_Conf = {}

---@class RandomCheatingConfArgs
---@field delay? int state読み込みをしてメモリ書き込みをするまでの遅延 (Default: `10`)
---@field reset_time? int state読み込みをするインターバル (Default: `60`)
---@field print_maxlines? int メモリ書き込み情報を表示する行数 (Default: `10`)
---@field get_addr? fun(i: int): int 書き込む先頭アドレスを与える関数 (Default: `rand(0x02200000, 0x02dfffff)`)
---@field get_bound? fun(i: int): int 書き込む範囲を与える関数 (Default: `rand(0x1000, 0x10000)`)
---@field get_val? fun(i: int): int 書き込む値を与える関数 (Default: `rand(0, 0xff)`)
---@field enable_key_reseting? bool インターバルを待たずともキー入力でstate読み込みをするか否か 
---@field reset_key? DS_Keys インターバルを待たずにリセットするためのキー (Default: `"L"`)
---@field do_reset? (fun(i: int): bool) | "nil" インターバルやキー入力以外の特殊リセットトリガー処理

local function __setDefaultRandomCheatingConf()
    __RandomCheating_Conf.delay = __RandomCheating_DefaultConf.delay
    __RandomCheating_Conf.reset_time = __RandomCheating_DefaultConf.reset_time
    __RandomCheating_Conf.print_maxlines = __RandomCheating_DefaultConf.print_maxlines
    __RandomCheating_Conf.enable_key_reseting = __RandomCheating_DefaultConf.enable_key_reseting
    __RandomCheating_Conf.reset_key = __RandomCheating_DefaultConf.reset_key
    __RandomCheating_Conf.do_reset = __RandomCheating_DefaultConf.do_reset
    __RandomCheating_Conf.get_addr = __RandomCheating_DefaultConf.get_addr
    __RandomCheating_Conf.get_bound = __RandomCheating_DefaultConf.get_bound
    __RandomCheating_Conf.get_val = __RandomCheating_DefaultConf.get_val
end
__setDefaultRandomCheatingConf()

--- RandomCheatingテストを開始する。
---
--- - RandomCheatingテスト: 一定間隔ごとにload stateしつつ、ランダムアドレス範囲にランダム値を書き込んでいって、どのアドレス範囲がゲームの挙動に影響しうるかを大雑把に調べるテスト。
--- - 設定項目は、引数 `options` に渡すか、あるいはこの関数を呼び出した後に変数 `__RandomCheating_Conf` に直接書き込めば良い。
---
--- ※この関数を呼び出す前に `__RandomCheating_Conf` に施した変更はすべてリセットされるので注意！
---@param saveslot 0|1|2|3|4|5|6|7|8|9
---@param options RandomCheatingConfArgs?
local function _setRandomCheating(saveslot, options)
    __setDefaultRandomCheatingConf()
    if options then
        for k, v in pairs(options) do
            if k == "do_reset" and v == "nil" then
                v = nil
            end
            __RandomCheating_Conf[k] = v
        end
    end
    local i = 0
    local prev_key = false
    local addr, bound, val
    local meses = {}
    local reset = function()
        i = 0
        savestate.loadslot(saveslot)
    end
    SET_LOOP("__RandomCheating", function()
        did_reset = false
        i = i + 1
        if __RandomCheating_Conf.enable_key_reseting then
            local k = DS.key.get(__RandomCheating_Conf.reset_key)
            if not k then prev_key = false
            elseif not prev_key then
                prev_key = true
                reset()
                return
            end
        end
        if i == __RandomCheating_Conf.reset_time then
            reset()
            return
        end
        local f = __RandomCheating_Conf.do_reset
        if f and f(i) then
            reset()
            return
        end
        local delay = __RandomCheating_Conf.delay
        if i == delay then
            addr = __RandomCheating_Conf.get_addr(i)
            bound = __RandomCheating_Conf.get_bound(i) - 1
            val = __RandomCheating_Conf.get_val(i)
            meses[#meses+1] = string.format("lib.fill_in(0x%08X, 0x%08X, 0x%02x)", addr, addr + bound, val)
            local maxlines = __RandomCheating_Conf.print_maxlines
            if #meses > maxlines then
                local new_tbl = {}
                for j = 1, maxlines do
                    new_tbl[j] = meses[j+1]
                end
                meses = new_tbl
            end
            CLS()
            print(table.concat(meses, "\n"))
        end
        if i >= delay then
            lib.fill_in(addr, addr + bound, val)
        end
    end)
end
setRandomCheating = _setRandomCheating

__util = {
    hex = to_hexstr,
    hexp = print_hexstr,
    within = _within,
    table_copy = _table_copy,
    stou8 = _stou8,
    stou16 = _stou16,
    stou32 = _stou32,
    htob = _htob,
    print_htob = print_htob,
    clamp = _clamp,
    clamp8 = _clamp8,
    clamp16 = _clamp16,
    clamp32 = _clamp32,
    random_set = _random_set,
    Set = _Set,
    pos_Morton = pos_Morton,
    pos_Raster = pos_Raster,
}
return __util
