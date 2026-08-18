
---@generic T
---@param arr T[]
---@return T[]
local function copy(arr)
    local ret = {}
    for i, v in pairs(arr) do ret[i] = v end
    return ret
end

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
            table.insert(ret, value)
        end
    end
    return ret
end

---`arr`をコピーし、sortしたものを返却する。
---@generic T
---@param arr T[]
---@param comp? fun(a: T, b: T): bool `a`が`b`より「小さい」か否かを返却
---@return T[]
local function sorted(arr, comp)
    local ret = table_copy(arr)
    table.sort(ret, comp)
    return ret
end

---`arr`を`n`個にコピーして結合したものを返却する。
---@generic T
---@param arr T[]
---@param n int
---@return T[]
local function rep(arr, n)
    local ret = {}
    for i = 1, n do
        for _, v in pairs(arr) do
            table.insert(ret, v)
        end
    end
    return ret
end

---`st`から`st+n-1`までの`n`個の順列を生成する。
---@param n? int
---@param st? int default: `1`
---@return int[]
local function seq(n, st)
    st = st or 1
    n = math.max(0, n or 0)
    local ret = {}
    for i = 0, n-1 do ret[i+1] = st+i end
    return ret
end

---配列の配列をすべてconcatする
---@generic T
---@param arrs T[][]
---@return T[]
local function flat(arrs)
    local ret = {}
    for _, arr in pairs(arrs) do
        for _, v in pairs(arr) do
            table.insert(ret, v)
        end
    end
    return ret
end

---2つの配列を結合する
---@generic T
---@param arr1 T[]
---@param arr2 T[]
---@return T[]
local function concat(arr1, arr2)
    return flat({arr1, arr2})
end

---(破壊的変更)`arr`の`pos`位置に`added`配列を挿入する
---@generic T
---@param arr int[]
---@param added int[]
---@param pos? int
local function insert_array(arr, added, pos)
    local n = #pos
    pos = pos or (n + 1)
    if pos < 0 then pos = pos % n + 1
    elseif pos == 0 then pos = 1
    end
    for i = 1, #added do
        table.insert(arr, pos+i-1, added[i])
    end
end

---配列の`[st, ed)`部分を抽出する。 (添字は0始まり)
---@generic T
---@param arr T[]
---@param st int
---@param ed? int non-inclusive
---@return T[]
local function slice(arr, st, ed)
    local n = #arr
    local ret = {}
    st = st % n
    if (not ed) or ed >= n then ed = n
    else ed = ed % n
    end
    for i = st, ed-1 do
        ret[#ret+1] = arr[i + 1]
    end
    return ret
end

local _arrayLib = {
    copy = copy,
    map = map,
    filter = filter,
    sorted = sorted,
    rep = rep,
    flat = flat,
    concat = concat,
    seq = seq,
    insert_array = insert_array,
    slice = slice,
}
Array = _arrayLib
__map = map
__filter = filter
__sorted = sorted

return _arrayLib
