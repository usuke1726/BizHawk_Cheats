
---@class ImageFilterObj
---@field _vs int[]
---@field _width int?
---@field _height int?
---@field _addr_bound int?
---@field protected _ready bool
local ImageFilterObj = {}

---@package
function ImageFilterObj:update_ready()
    self._ready = (self._width ~= nil) and ((self._height ~= nil) or self._addr_bound ~= nil)
end

---@param width int
---@return ImageFilterObj
function ImageFilterObj:width(width)
    self._width = width
    self:update_ready()
    return self
end
---@param bound int
---@return ImageFilterObj
function ImageFilterObj:bound(bound)
    self._addr_bound = bound
    self:update_ready()
    return self
end
---@param height int
---@return ImageFilterObj
function ImageFilterObj:height(height)
    self._height = height
    self:update_ready()
    return self
end

---@param filter_func fun(x: int, y: int): int?, int?
---@return ImageFilterObj
function ImageFilterObj:go(filter_func)
    local v = {}
    local bound
    if self._addr_bound then
        bound = self._addr_bound
    elseif self._height then
        bound = self._width * self._height
    else
        error("[ImageFilterObj:save] Not ready")
    end
    local x, y = 0, 0
    for i = 0, bound-1 do
        local a, v2 = filter_func(x, y)
        if a then
            v[a] = v2
        end
        x = x + 1
        if x % self._width == 0 then
            x = 0
            y = y + 1
        end
    end
    local _used = {}
    for a, _ in pairs(v) do
        local _v = 0
        if not _used[a] then
            local _a = a & 0xfffffffc
            for j = 0, 3 do
                _used[_a+j] = true
                _v = _v | ((v[_a+j] or r8(_a+j)) << (8*j))
            end
            w32(_a, _v)
        end
    end
    return self
end

---VRAM上などのピクセルデータにフィルタリングをかけるオブジェクトを生成する。
---
---使用例：
--- ```lua
--- local W = 0x80
--- local function pos(x, y)
---     return lib.pos.Morton(x, y, 0x04, 0x20, 0x400) + 0x06214000
--- end
--- lib.image.filterObj()
--- :width(W):bound(0x6000)
--- :go(function(x, y)
---     local _x = math.round(x * 0.3) + (W // 2)
---     return pos(x, y), r8(pos(_x, y))
--- end)
--- ```
---@return ImageFilterObj
local function filterObj()
    return setmetatable({
        _ready = false,
        _vs = {},
        _width = nil,
        _height = nil,
        _addr_bound = nil,
    }, {
        __index = ImageFilterObj,
    })
end


---@class ImageFilterObj_HalfByte
---@field vs int[][]
---@field _width int?
---@field _height int?
---@field _reverse bool
---@field _get_addr fun(x: int, y: int): int
---@field protected _save_reversed bool
---@field protected _ready bool
local ImageFilterObj_HalfByte = {}


---@package
function ImageFilterObj_HalfByte:update_ready()
    self._ready = (self._width ~= nil) and (self._height ~= nil) and (self._get_addr ~= nil)
end
---@param width int
---@return ImageFilterObj_HalfByte
function ImageFilterObj_HalfByte:width(width)
    assert(width % 2 == 0)
    self._width = width
    self:update_ready()
    return self
end
---@param height int
---@return ImageFilterObj_HalfByte
function ImageFilterObj_HalfByte:height(height)
    self._height = height
    self:update_ready()
    return self
end
---1バイト内の2ピクセルの左右位置を反転させる。
---@param not_reverse bool?
---@return ImageFilterObj_HalfByte
function ImageFilterObj_HalfByte:reverse(not_reverse)
    self._reverse = not_reverse ~= false
    return self
end
--- `(x//2, y)`値からアドレスを返す関数を登録する。
---@param fun fun(x: int, y: int): int
---@return ImageFilterObj_HalfByte
function ImageFilterObj_HalfByte:addr(fun)
    self._get_addr = fun
    self:update_ready()
    return self
end
---@param immediately? bool 非`true`の場合は `go` するまでお預け
---@return ImageFilterObj_HalfByte
function ImageFilterObj_HalfByte:save(immediately)
    if not immediately then
        self._save_reversed = true
        return self
    end
    self._save_reversed = false
    if not self._ready then
        error("[ImageFilterObj:save] Not ready")
    end
    local vs = {}
    for y = 0, self._height-1 do
        local _v = {}
        for x = 0, self._width-1, 2 do
            local v = r8(self._get_addr(x//2, y))
            _v[x] = v >> 4
            _v[x+1] = v & 0xf
            if self._reverse then
                _v[x+1], _v[x] = _v[x], _v[x+1]
            end
        end
        vs[y] = _v
    end
    self.vs = vs
    return self
end

---@package
function ImageFilterObj_HalfByte:__read(x, y)
    local v = r8(self._get_addr(x//2, y))
    local even = x % 2 == 0
    if self._reverse then
        return (not even) and (v>>4) or (v&0xf)
    else
        return even and (v>>4) or (v&0xf)
    end
end

---@param filter_func fun(x: int, y: int, vs: int[][]): int?
---@return ImageFilterObj_HalfByte
function ImageFilterObj_HalfByte:go(filter_func)
    if not self._ready then
        error("[ImageFilterObj:save] Not ready")
    end
    if self._save_reversed then
        self:save(true)
    end
    local v = {}
    for y = 0, self._height-1 do
        for x = 0, self._width-1, 2 do
            local v1, v2
            v1 = filter_func(x, y, self.vs) or self:__read(x, y)
            v2 = filter_func(x+1, y, self.vs) or self:__read(x+1, y)
            v1 = v1 & 0xf
            v2 = v2 & 0xf
            local _v
            if self._reverse then
                _v = (v2 << 4) | v1
            else
                _v = (v1 << 4) | v2
            end
            v[self._get_addr(x//2, y)] = _v
        end
    end

    local _used = {}
    for a, _ in pairs(v) do
        local _v = 0
        if not _used[a] then
            local _a = a & 0xfffffffc
            for j = 0, 3 do
                _used[_a+j] = true
                _v = _v | ((v[_a+j] or r8(_a+j)) << (8*j))
            end
            w32(_a, _v)
        end
    end
    return self
end

---VRAM上などのピクセルデータにフィルタリングをかけるオブジェクト(ただし1バイト2ピクセル)を生成する。
---
---使用例：
--- ```lua
--- local function pos(x, y)
---     return lib.pos.Morton(x, y, 0x04, 0x20, 0x400) + 0x06214000
--- end
--- lib.image.filterObj_HalfByte()
--- :width(256):height(196):addr(pos)
--- -- :reverse() -- 2ピクセルの左右位置が逆の場合
--- :go(function(x, y, vs)
---     local _x, _y = y, x
---     return vs[_y][_x]
--- end)
--- ```
---@param no_autosave_first? bool
---@return ImageFilterObj_HalfByte
local function filterObj_HalfByte(no_autosave_first)
    local obj = setmetatable({
        _ready = false,
        vs = {},
        _width = nil,
        _height = nil,
        _get_addr = nil,
        _reverse = false,
        _save_reversed = false,
    }, {
        __index = ImageFilterObj_HalfByte,
    })
    if not no_autosave_first then
        obj:save(false)
    end
    return obj
end

---@class LZ77Lib
---@field silent bool
local lz77 = {
    silent = false
}

---@param addr int
---@param is_ram? bool
---@return int[] bytes
local function lz77_decompress(addr, is_ram)
    local function _r32(m)
        local v1 = m:r8() m:step()
        local v2 = m:r8() m:step()
        local v3 = m:r8() m:step()
        local v4 = m:r8() m:step()
        return (v1) | (v2 << 8) | (v3 << 16) | (v4 << 24)
    end
    local function _r16(m)
        local v1 = m:r8() m:step()
        local v2 = m:r8() m:step()
        return (v1) | (v2 << 8)
    end
    local m = is_ram and lib.at(addr) or lib.romat(addr)
    local header = _r32(m)
    if (header & 0xff) ~= 0x10 then
        error(string.format("WRONG ADDRESS (0x%08X):\n    compressed data must start with the byte 0x10", addr))
    end
    local length = header >> 8
    local buffer = {}
    local bytes_written = 0
    local read_length = 4
    while bytes_written < length do
        local flags = m:r8() m:step(1)
        read_length = read_length + 1
        for i = 0, 7 do
            if bytes_written >= length then break end
            if (flags & (0x80 >> i)) == 0 then
                bytes_written = bytes_written + 1
                buffer[bytes_written] = m:r8() m:step(1)
                read_length = read_length + 1
            else
                local value = _r16(m)
                read_length = read_length + 2
                local disp = ((value & 0xf) << 8) | (value >> 8)
                local n = (value >> 4) & 0xf
                for j = 0, n + 2 do
                    bytes_written = bytes_written + 1
                    buffer[bytes_written] = buffer[bytes_written-disp-1]
                end
            end
        end
    end
    if (not lz77.silent) then
        print(string.format("  compressed bytes length: 0x%x (%d)", read_length, read_length))
        print(string.format("decompressed bytes length: 0x%x (%d)", bytes_written, bytes_written))
        local size = #buffer
        print(string.format("buffer size: 0x%x (%d)", size, size))
    end
    return buffer
end

---@param bytes int[]
---@param offset int
---@param input_len int
---@param length int
---@package
local function token_with_length(bytes, offset, input_len, length)
    if offset + length > input_len then return 0 end
    for ptr = offset - 8, 0, -1 do
        local delta = ptr - offset
        local encoded_delta = -delta - 1
        if encoded_delta > 0xfff then return 0 end
        local match = true
        for i = 0, length - 1 do
            if bytes[ptr+i+1] ~= bytes[offset+i+1] then
                match = false
                break
            end
        end
        if match then return delta end
    end
    return 0
end

---@param bytes int[]
---@return int[]
local function lz77_compress(bytes)
    local bytes_written = 0
    local input_len = #bytes
    local header = (input_len << 8) | 0x10
    local out = {
        header & 0xff,
        (header >> 8) & 0xff,
        (header >> 16) & 0xff,
        (header >> 24) & 0xff,
    }
    local processed_len = 0
    local num_flag_bits = 0
    local last_flag_pos = 0
    local flags = 0
    while processed_len < input_len do
        if num_flag_bits == 0 then
            bytes_written = bytes_written + 1
            out[bytes_written + 4] = 0x37
            last_flag_pos = bytes_written
        end
        if token_with_length(bytes, processed_len, input_len, 3) ~= 0 then
            local token_size = 0
            local token_delta = 0
            for att = 3, 18 do
                local d = token_with_length(bytes, processed_len, input_len, att)
                if d ~= 0 then
                    token_size = att
                    token_delta = d
                else break
                end
            end
            local flipped_token_delta = -token_delta - 1
            bytes_written = bytes_written + 1
            out[bytes_written + 4] = (((token_size-3) & 0xf) << 4) | ((flipped_token_delta & 0xf00) >> 8)
            bytes_written = bytes_written + 1
            out[bytes_written + 4] = flipped_token_delta & 0xff
            processed_len = processed_len + token_size
            flags = flags | (0x80 >> num_flag_bits)
        else
            bytes_written = bytes_written + 1
            processed_len = processed_len + 1
            out[bytes_written + 4] = bytes[processed_len]
        end
        num_flag_bits = num_flag_bits + 1
        if num_flag_bits == 8 or processed_len >= input_len then
            num_flag_bits = 0
            out[last_flag_pos + 4] = flags
            flags = 0
        end
    end
    if (not lz77.silent) then
        print(string.format(" compressing bytes length: 0x%x (%d)", input_len, input_len))
        print(string.format("  compressed bytes length: 0x%x (%d)", bytes_written, bytes_written))
    end
    return out
end

lz77.decompress = lz77_decompress
lz77.compress = lz77_compress

return {
    filterObj = filterObj,
    filterObj_HalfByte = filterObj_HalfByte,
    lz77 = lz77,
}
