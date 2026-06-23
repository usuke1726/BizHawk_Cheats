
_irume_active = false
---@package
---@type fun()?
_irume_func = nil

local function _update()
    if (not _irume_active) then return end
    if (not _irume_func) then return end
    _irume_func()
end
---イルーム処理を開始する
---@param get_callback fun() : fun()?
---@param timeout? int
local function start_irume(get_callback, timeout)
    if timeout then
        __timer.setTimeout(timeout, function()
            start_irume(get_callback, nil)
        end)
        return
    end
    _irume_active = true
    _irume_func = get_callback()
end
---イルーム処理を停止(あるいは終了)する。(再開は`restart_irume`)
---@param timeout? int
local function stop_irume(timeout)
    if timeout then
        __timer.setTimeout(timeout, function()
            stop_irume(nil)
        end)
        return
    end
    _irume_active = false
end
---イルーム処理を再開する。
---@param timeout? int
local function restart_irume(timeout)
    if timeout then
        __timer.setTimeout(timeout, function()
            restart_irume(nil)
        end)
    end
    _irume_active = true
end

local entry = 0
local _track_size = 0
---@type table<string, int>
local registered = {}

---サウンドアドレスの先頭アドレスを指定する
---@param addr int
local function set_entry(addr)
    entry = addr
end

---1トラックのバイトサイズを指定する
---@param size int
local function set_track_size(size)
    _track_size = size
end

---トラックのメモリ情報を追加する
---@param id string
---@param offset int
local function register(id, offset)
    registered[id] = offset
end
---トラックのメモリ情報を削除する
---@param id string
local function unregister(id) registered[id] = nil end

---@param entry_addr int サウンド領域の先頭アドレス
---@param track_size int 1トラックのバイトサイズ
---@param regs ([string, int])[] メモリ情報(`[id: string, offset: int]`)
local function setup_track(entry_addr, track_size, regs)
    set_entry(entry_addr)
    set_track_size(track_size)
    for _, v in pairs(regs) do
        registered[v[1]] = v[2]
    end
end

---@alias CacheId int | string

---@class TrackObj
---@field protected _head int
---@field protected _registered_caches table<string, AtObj>
---@field protected _caches table<CacheId, AtObj>
---@field protected _tmp_id int
---@field protected _track int
local TrackObj = {}

---@param num int
---@return TrackObj
local function track(num)
    assert(entry > 0, "entry address is not set")
    assert(_track_size > 0, "track size is not set")
    local head_addr = entry + _track_size * (num - 1)
    ---@type table<string, AtObj>
    local registered_caches = {}
    for k, offset in pairs(registered) do
        registered_caches[k] = __mem_lib.at(head_addr + offset)
    end
    return setmetatable({
        _head = head_addr,
        _registered_caches = registered_caches,
        _caches = {},
        _tmp_id = 0,
        _track = num,
    }, {
        __index = TrackObj,
    })
end
---@param num_start int
---@param num_end int
---@param callback? fun(obj: TrackObj, i: int): TrackObj
---@return TrackObj[]
---@overload fun(nums: int[], callback?: fun(obj: TrackObj, i: int): TrackObj): TrackObj[]
local function tracks(num_start, num_end, callback)
    local nums = {}
    local ret = {}
    ---@type fun(obj: TrackObj, i: int): TrackObj
    local c = function(obj, i) return obj end
    if type(num_end) == "number" then
        for i = num_start, num_end do
            nums[#nums+1] = i
        end
        if callback then c = callback end
    else
        assert(type(num_start) == "table", "1st argument must be an array")
        nums = num_start
        if num_end and type(num_end) == "function" then
            c = num_end
        end
    end
    for _, i in pairs(nums) do
        ret[#ret+1] = c(track(i), i)
    end
    return ret
end

---トラック内の使用するメモリを登録する。
---@param offset int
---@param id CacheId
---@return TrackObj self
function TrackObj:use(offset, id)
    local t = type(id)
    if t ~= "string" and t ~= "number" then
        self._tmp_id = self._tmp_id + 1
        id = self._tmp_id
    end
    self._caches[id] = __mem_lib.at(self._head + offset)
    return self
end

---@param id string
---@return AtObj
function TrackObj:reg(id)
    return assert(self._registered_caches[id], "unknown reg: " .. id)
end

---@param id CacheId
---@return AtObj
function TrackObj:get_mem(id)
    local m = self._caches[id]
    if m then return m end
    error("invalid id: " .. id)
end

---登録済みのメモリをread
---@param id CacheId
---@return int
function TrackObj:r8(id) return self:get_mem(id):r8() end
---登録済みのメモリを**Little Endianで**read
---@param id CacheId
---@return int
function TrackObj:r16(id) return self:get_mem(id):r16() end
---登録済みのメモリを**Little Endianで**read
---@param id CacheId
---@return int
function TrackObj:r32(id) return self:get_mem(id):r32() end
---登録済みのメモリにwrite
---@param id CacheId
---@param value int
---@return TrackObj self
function TrackObj:w8(id, value) self:get_mem(id):w8(value) return self end
---登録済みのメモリに**Little Endianで**write
---@param id CacheId
---@param value int
---@return TrackObj self
function TrackObj:w16(id, value) self:get_mem(id):w16(value) return self end
---登録済みのメモリに**Little Endianで**write
---@param id CacheId
---@param value int
---@return TrackObj self
function TrackObj:w32(id, value) self:get_mem(id):w32(value) return self end
---登録済みのメモリにadd
---@param id CacheId
---@param value int
---@param min_? int
---@param max_? int
---@return TrackObj self
function TrackObj:add8(id, value, min_, max_) self:get_mem(id):add8(value, min_, max_) return self end
---登録済みのメモリに**Little Endian**でadd
---@param id CacheId
---@param value int
---@param min_? int
---@param max_? int
---@return TrackObj self
function TrackObj:add16(id, value, min_, max_) self:get_mem(id):add16(value, min_, max_) return self end
---登録済みのメモリに**Little Endian**でadd
---@param id CacheId
---@param value int
---@param min_? int
---@param max_? int
---@return TrackObj self
function TrackObj:add32(id, value, min_, max_) self:get_mem(id):add32(value, min_, max_) return self end
---登録済みのメモリを先頭として与えられたバイト列を書き込む。
---@param id CacheId
---@param bytes int[]
---@return TrackObj self
function TrackObj:warr(id, bytes) self:get_mem(id):warr(bytes) return self end


__irume_lib = {
    __update = _update,
    set_entry = set_entry,
    set_track_size = set_track_size,
    register = register,
    unregister = unregister,
    setup_track = setup_track,
    start = start_irume,
    stop = stop_irume,
    restart = restart_irume,
    track = track,
    tracks = tracks,
}
return __irume_lib
