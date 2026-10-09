
---@class DataPos_int
---@field v int
---@field addr int

---@class DataPos_string
---@field v string
---@field addr int

---@param v int
---@param addr int
---@return DataPos_int
---@overload fun(v: string, addr: int): DataPos_string
local function DataPos(v, addr)
    return {v = v, addr = addr}
end
---@param arr int[]
---@return string
local function read_ascii(arr)
    local s = ""
    for i = 1, #arr do
        local v = arr[i]
        if v == 0 then break end
        s = s .. string.char(v)
    end
    return s
end


---@class MemReader
---@field i int
local MemReader = {}

---@param num int
---@return int ...
---@overload fun(self: MemReader): int
function MemReader:r(num)
    if not num then local v = r8(self.i) self.i = self.i + 1 return v end
    local ret = {}
    for i = 1, num do
        ret[i] = r8(self.i + i - 1)
    end
    self.i = self.i + num
    return table.unpack(ret)
end
---LEで取得する
---@return int
function MemReader:r16()
    local v = 0 for i = 0, 1 do v = v | (self:r() << (8*i)) end return v
end
function MemReader:d16()
    local addr = self.i
    return DataPos(self:r16(), addr)
end
---LEで取得する
---@return int
function MemReader:r32()
    local v = 0 for i = 0, 3 do v = v | (self:r() << (8*i)) end return v
end
function MemReader:d32()
    local addr = self.i
    return DataPos(self:r32(), addr)
end
---BEで取得する
---@return int
function MemReader:R16()
    local v = 0 for _ = 0, 1 do v = (v << 8) | self:r() end return v
end
function MemReader:D16()
    local addr = self.i
    return DataPos(self:R16(), addr)
end
---BEで取得する
---@return int
function MemReader:R32()
    local v = 0 for _ = 0, 3 do v = (v << 8) | self:r() end return v
end
function MemReader:D32()
    local addr = self.i
    return DataPos(self:R32(), addr)
end
---@param begin int
---@return MemReader
local function newMemReader(begin)
    return setmetatable({i = begin}, {__index = MemReader})
end

---@class NameList_u32
---@field head_addr int
---@field dummy int
---@field count int
---@field size int
---@field header_size int
---@field header_v1 int
---@field header_v2 int
---@field header_vs int
---@field element_size int
---@field data_section_size int
---@field data DataPos_int[]
---@field names DataPos_string[]


---@param mem MemReader
---@return NameList_u32?
local function GetNameList_u32(mem)
    local head_addr = mem.i
    local dummy, count = mem:r(2)
    local size = mem:r16()
    local subheader_size = mem:r16()
    local header_v1 = mem:r16()
    local header_v2 = mem:r32()
    local header_vs = {}
    for i = 1, count do header_vs[i] = mem:r32() end
    local element_size = mem:r16()
    if element_size ~= 4 then
        print(string.format("element is not u32 (element_size: %d) (at 0x%08X)", element_size, head_addr))
        return
    end
    local data_section_size = mem:r16()
    local data = {}
    local names = {}
    for i = 1, count do
        local addr = mem.i
        data[i] = DataPos(mem:r32(), addr)
    end
    for i = 1, count do
        local addr = mem.i
        names[i] = DataPos(read_ascii({mem:r(16)}), addr)
    end
    return {
        head_addr = head_addr,
        dummy = dummy,
        count = count,
        size = size,
        header_size = subheader_size,
        header_v1 = header_v1,
        header_v2 = header_v2,
        header_vs = header_vs,
        element_size = element_size,
        data_section_size = data_section_size,
        data = data,
        names = names,
    }
end

___nitro_lib = {
    newMemReader = newMemReader,
    DataPos = DataPos,
    read_ascii = read_ascii,
    GetNameList_u32 = GetNameList_u32,
}
