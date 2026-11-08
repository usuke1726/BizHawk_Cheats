
---@class DataPos
---@field v ValueDataBase
---@field addr int

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
---@overload fun(v: ValueDataBase, addr: int): DataPos
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
    return DataPos(___nitro_values.U16(self:r16()), addr)
end
---@param y int
---@param z int
function MemReader:f16(y, z)
    assert(y + z + 1 == 16, "1 + y + z ~= 16")
    local addr = self.i
    return DataPos(___nitro_values.FixedFloat(self:r16(), y, z), addr)
end
---LEで取得する
---@return int
function MemReader:r32()
    local v = 0 for i = 0, 3 do v = v | (self:r() << (8*i)) end return v
end
function MemReader:d32()
    local addr = self.i
    return DataPos(___nitro_values.U32(self:r32()), addr)
end
---@param y int
---@param z int
function MemReader:f32(y, z)
    assert(y + z + 1 == 32, "1 + y + z ~= 32")
    local addr = self.i
    return DataPos(___nitro_values.FixedFloat(self:r32(), y, z), addr)
end
---BEで取得する
---@return int
function MemReader:R16()
    local v = 0 for _ = 0, 1 do v = (v << 8) | self:r() end return v
end
function MemReader:D16()
    local addr = self.i
    return DataPos(___nitro_values.U16(self:R16()), addr)
end
---@param y int
---@param z int
function MemReader:F16(y, z)
    assert(y + z + 1 == 16, "1 + y + z ~= 16")
    local addr = self.i
    return DataPos(___nitro_values.FixedFloat(self:R16(), y, z), addr)
end
---BEで取得する
---@return int
function MemReader:R32()
    local v = 0 for _ = 0, 3 do v = (v << 8) | self:r() end return v
end
function MemReader:D32()
    local addr = self.i
    return DataPos(___nitro_values.U32(self:R32()), addr)
end
---@param y int
---@param z int
function MemReader:F32(y, z)
    assert(y + z + 1 == 32, "1 + y + z ~= 32")
    local addr = self.i
    return DataPos(___nitro_values.FixedFloat(self:R32(), y, z), addr)
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

---@class Bound3Dobj
---@field xmin number
---@field xmax number
---@field ymin number
---@field ymax number
---@field zmin number
---@field zmax number
---@field protected xgiven bool
---@field protected ygiven bool
---@field protected zgiven bool
local Bound3Dobj = {}

---@param x? number
---@param y? number
---@param z? number
function Bound3Dobj:push(x, y, z)
    if x then
        self.xmin = math.min(self.xmin, x)
        self.xmax = math.max(self.xmax, x)
        self.xgiven = true
    end
    if y then
        self.ymin = math.min(self.ymin, y)
        self.ymax = math.max(self.ymax, y)
        self.ygiven = true
    end
    if z then
        self.zmin = math.min(self.zmin, z)
        self.zmax = math.max(self.zmax, z)
        self.zgiven = true
    end
end
---@param x number
---@return number
function Bound3Dobj:xinv(x) return invlerp(x, self.xmin, self.xmax) end
---@param y number
---@return number
function Bound3Dobj:yinv(y) return invlerp(y, self.ymin, self.ymax) end
---@param z number
---@return number
function Bound3Dobj:zinv(z) return invlerp(z, self.zmin, self.zmax) end
---@param x number
---@return number
function Bound3Dobj:xlerp(x) return lerp(self.xmin, self.xmax, x) end
---@param y number
---@return number
function Bound3Dobj:ylerp(y) return lerp(self.ymin, self.ymax, y) end
---@param z number
---@return number
function Bound3Dobj:zlerp(z) return lerp(self.zmin, self.zmax, z) end
local function Bound3Dobj_pr(label, min, max, given)
    if given then
        print(string.format("%s: [%f -- %f]", label, min, max))
    else
        print(string.format("%s: Not given", label))
    end
end
function Bound3Dobj:print()
    Bound3Dobj_pr("x", self.xmin, self.xmax, self.xgiven)
    Bound3Dobj_pr("y", self.ymin, self.ymax, self.ygiven)
    Bound3Dobj_pr("z", self.zmin, self.zmax, self.zgiven)
end

---@param bound? number
---@return Bound3Dobj
local function Bound3D(bound)
    bound = bound or 1000000000
    return setmetatable({
        xmin = bound, xmax = -bound,
        ymin = bound, ymax = -bound,
        zmin = bound, zmax = -bound,
        xgiven = false, ygiven = false, zgiven = false,
    }, {__index = Bound3Dobj})
end

___nitro_lib = {
    newMemReader = newMemReader,
    DataPos = DataPos,
    read_ascii = read_ascii,
    GetNameList_u32 = GetNameList_u32,
    Bound3D = Bound3D,
}
