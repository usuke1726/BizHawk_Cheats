
---@class RecorderObj
---@field head int
---@field bound int
---@field key DS_Keys
---@field finished_just_now bool
---@field protected filepath? string
---@field protected recorded bool
---@field protected recording bool
---@field protected data int[][]
---@field protected data_i int
---@field protected _scan_each_byte bool
---@overload fun(): bool
local RecorderObj = {}

---@package
function RecorderObj:read()
    local d = {}
    if self._scan_each_byte then
        for i = 0, self.bound-1 do
            d[i+1] = r8(self.head + i)
        end
    else
        for i = 0, self.bound-1, 4 do
            d[i] = r32(self.head + i)
        end
    end
    return d
end

---@param i int
---@return int[]
function RecorderObj:bytes(i)
    if i > #self.data then return {} end
    local d = self.data[i]
    if self._scan_each_byte then return d end
    local ret = {}
    for j = 0, self.bound-1, 4 do
        local v = d[j]
        ret[j+1] = v & 0xff
        ret[j+2] = (v >> 8) & 0xff
        ret[j+3] = (v >> 16) & 0xff
        ret[j+4] = (v >> 24) & 0xff
    end
    return ret
end

local function format_byte(v)
    return string.format("%02X", v)
end

---@package
---@param i int
---@return string
function RecorderObj:bytes_str(i)
    if i > #self.data then error("out of bound") end
    local d = self.data[i]
    local ret = {}
    if self._scan_each_byte then
        for j = 0, self.bound-1 do
            ret[j+1] = format_byte(d[j+1])
        end
    else
        for j = 0, self.bound-1, 4 do
            local v = d[j]
            ret[j+1] = format_byte(v & 0xff)
            ret[j+2] = format_byte((v >> 8) & 0xff)
            ret[j+3] = format_byte((v >> 16) & 0xff)
            ret[j+4] = format_byte((v >> 24) & 0xff)
        end
    end
    local s = table.concat(ret, "")
    return s
end

---@return bool
function RecorderObj:update()
    self.finished_just_now = false
    if self.recorded then return false end
    local k = DS.key.get(self.key)
    if self.recording then
        if k then
            self.data_i = self.data_i + 1
            self.data[self.data_i] = self:read()
        else
            print("RECORD END")
            self.recorded = true
            self.recording = false
        end
    elseif k then
        print("RECORD START")
        self.recording = true
    end
    self.finished_just_now = self.recorded
    return self.finished_just_now
end

---@param filename? string
---@param silent? bool
---@return RecorderObj
function RecorderObj:file(filename, silent)
    filename = filename or "out.txt"
    self.filepath = __path_lib.output(filename)
    if not silent then
        print("SET Recorder output:\n  " .. self.filepath)
    end
    return self
end

---@param filename? string
function RecorderObj:save(filename)
    if not self.filepath then
        self:file(filename)
    end
    if not self.recorded then
        print("まだデータを取得し終わっていません")
        return
    end
    local lines = {}
    for i = 1, self.data_i do
        local s = "lib.htob(\"" .. self:bytes_str(i) .. "\"),"
        lines[i] = s
    end
    local text = "local DATA = {\n" .. table.concat(lines, "\n") .. "\n}"
    local file = io.open(self.filepath, "w")
    if file then
        file:write(text)
        file:flush()
        file:close()
    else error("ファイルオープンに失敗しました")
    end
end

---@param val bool?
---@return RecorderObj
function RecorderObj:scan_each_byte(val)
    if val == nil then val = true end
    self._scan_each_byte = val
    return self
end

---@return bool
function RecorderObj:finished()
    return self.recorded
end

---@param head int
---@param bound int
---@param key DS_Keys
---@return RecorderObj
local function _Recorder(head, bound, key)
    local _seb = false
    if bound & 0x3 ~= 0 then
        print("boundの下2bitが0でないので1byteごとの読み込みにします")
        _seb = true
    end
    return setmetatable({
        head = head,
        bound = bound,
        key = key,
        filepath = nil,
        recorded = false,
        recording = false,
        finished_just_now = false,
        _scan_each_byte = _seb,
        data = {},
        data_i = 0,
    }, {
        __index = RecorderObj,
        ---@param self RecorderObj
        __call = function(self)
            return self:update()
        end
    })
end

Recorder = _Recorder

return {
    new = _Recorder,
}
