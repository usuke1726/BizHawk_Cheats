
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
array_copy = _table_copy



---@generic T
---@generic U
---@param arr T[]
---@param func fun(value: T, key: int, arr: T[]): U
---@return U[]
local function map(arr, func)
    local ret = {}
    for key, value in pairs(arr) do
        ret[key] = func(value, key, arr)
    end
    return ret
end
---@generic T
---@param arr T[]
---@param func fun(value: T, key: int, arr: T[]): bool
---@return T[]
local function filter(arr, func)
    local ret = {}
    for key, value in pairs(arr) do
        if func(value, key, arr) then
            ret[key] = value
        end
    end
    return ret
end
__map = map
__filter = map
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

__util = {
    hex = to_hexstr,
    hexp = print_hexstr,
    within = _within,
    table_copy = _table_copy,
    map = map,
    filter = filter,
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
}
return __util
