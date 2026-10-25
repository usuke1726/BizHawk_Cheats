
---@class ValueDataBase
---@field v number
---@field hex int
---@operator add(number): ValueDataBase
---@operator sub(number): ValueDataBase
---@operator div(number): ValueDataBase
---@operator mul(number): ValueDataBase
---@operator unm:ValueDataBase
---@field LE fun(self: ValueDataBase): int[]
---@field BE fun(self: ValueDataBase): int[]

---@param obj ValueDataBase | number
local function get_int(obj)
    if type(obj) == "number" then return math.floor(obj)
    else return obj.v
    end
end

---@class TypeU32 : ValueDataBase
local TypeU32 = {}
---@param v int
---@return ValueDataBase
local function TypeU32_new(v) v = v % 0x100000000 return setmetatable({v = v, hex = v}, {__index = TypeU32, __add = TypeU32.__add, __sub = TypeU32.__sub, __mul = TypeU32.__mul, __div = TypeU32.__div, __unm = TypeU32.__unm}) end
function TypeU32.__add(t1, t2) return TypeU32_new(get_int(t1) + get_int(t2)) end
function TypeU32.__sub(t1, t2) return TypeU32_new(get_int(t1) - get_int(t2)) end
function TypeU32.__mul(t1, t2) return TypeU32_new(get_int(t1) * get_int(t2)) end
function TypeU32.__div(t1, t2) return TypeU32_new(get_int(t1) // get_int(t2)) end
---@param t1 FixedFloat
function TypeU32.__unm(t1) return TypeU32_new(-t1.v) end
function TypeU32:LE() local r,v = {},self.hex for i = 1, 4 do r[i] = v & 0xff v = v >> 8 end return r end
function TypeU32:BE() local r,v = {},self.hex for i = 4, 1, -1 do r[i] = v & 0xff v = v >> 8 end return r end

---@class TypeU16 : ValueDataBase
local TypeU16 = {}
---@param v int
---@return ValueDataBase
local function TypeU16_new(v) v = v % 0x10000 return setmetatable({v = v, hex = v}, {__index = TypeU16, __add = TypeU16.__add, __sub = TypeU16.__sub, __mul = TypeU16.__mul, __div = TypeU16.__div, __unm = TypeU16.__unm}) end
function TypeU16.__add(t1, t2) return TypeU16_new(get_int(t1) + get_int(t2)) end
function TypeU16.__sub(t1, t2) return TypeU16_new(get_int(t1) - get_int(t2)) end
function TypeU16.__mul(t1, t2) return TypeU16_new(get_int(t1) * get_int(t2)) end
function TypeU16.__div(t1, t2) return TypeU16_new(get_int(t1) // get_int(t2)) end
---@param t1 FixedFloat
function TypeU16.__unm(t1) return TypeU16_new(-t1.v) end
function TypeU16:LE() local r,v = {},self.hex for i = 1, 2 do r[i] = v & 0xff v = v >> 8 end return r end
function TypeU16:BE() local r,v = {},self.hex for i = 2, 1, -1 do r[i] = v & 0xff v = v >> 8 end return r end

---@class TypeU8 : ValueDataBase
local TypeU8 = {}
---@param v int
---@return ValueDataBase
local function TypeU8_new(v) v = v % 0x100 return setmetatable({v = v, hex = v}, {__index = TypeU8, __add = TypeU8.__add, __sub = TypeU8.__sub, __mul = TypeU8.__mul, __div = TypeU8.__div, __unm = TypeU8.__unm}) end
function TypeU8.__add(t1, t2) return TypeU8_new(get_int(t1) + get_int(t2)) end
function TypeU8.__sub(t1, t2) return TypeU8_new(get_int(t1) - get_int(t2)) end
function TypeU8.__mul(t1, t2) return TypeU8_new(get_int(t1) * get_int(t2)) end
function TypeU8.__div(t1, t2) return TypeU8_new(get_int(t1) // get_int(t2)) end
---@param t1 FixedFloat
function TypeU8.__unm(t1) return TypeU8_new(-t1.v) end
function TypeU8:LE() return {self.hex} end
function TypeU8:BE() return {self.hex} end

---@class FixedFloat : ValueDataBase
---@field y int
---@field z int
local FixedFloat = {}

---@param t1 any
---@param t2 any
---@return number, number, int, int
local function FixedFloat_extract(t1, t2)
    if type(t1) == "number" then
        local _t = (t2--[[@as FixedFloat]])
        return t1, _t.v, _t.y, _t.z
    else
        local _t = (t1--[[@as FixedFloat]])
        return _t.v, t2, _t.y, _t.z
    end
end

---@param v number
---@param y int
---@param z int
---@return ValueDataBase
local function FixedFloat_new(v, y, z)
    assert(y > 0 and z > 0, "y or z is negative")
    return setmetatable({
        v = v,
        hex = fixFloatToInt(v, y, z),
        y = y, z = z,
    }, {
        __index = FixedFloat,
__add = FixedFloat.__add, __sub = FixedFloat.__sub, __mul = FixedFloat.__mul, __div = FixedFloat.__div, __unm = FixedFloat.__unm
    })
end

function FixedFloat.__add(t1, t2)
    local v1, v2, _y, _z = FixedFloat_extract(t1, t2)
    return FixedFloat_new(v1+v2, _y, _z)
end
function FixedFloat.__sub(t1, t2)
    local v1, v2, _y, _z = FixedFloat_extract(t1, t2)
    return FixedFloat_new(v1-v2, _y, _z)
end
function FixedFloat.__mul(t1, t2)
    local v1, v2, _y, _z = FixedFloat_extract(t1, t2)
    return FixedFloat_new(v1*v2, _y, _z)
end
function FixedFloat.__div(t1, t2)
    local v1, v2, _y, _z = FixedFloat_extract(t1, t2)
    return FixedFloat_new(v1/v2, _y, _z)
end
---@param t1 FixedFloat
function FixedFloat.__unm(t1)
    return FixedFloat_new(-t1.v, t1.y, t1.z)
end
---@package
function FixedFloat:_n()
    local len = self.y+self.z+1
    if len % 8 ~= 0 then
        error(string.format("bit length is not power of 2 (len: %d)", len))
    end
    return len // 8
end
function FixedFloat:LE() local r,v,n = {},self.hex,self:_n() for i = 1, n do r[i] = v & 0xff v = v >> 8 end return r end
function FixedFloat:BE() local r,v,n = {},self.hex,self:_n() for i = n, 1, -1 do r[i] = v & 0xff v = v >> 8 end return r end

___nitro_values = {
    FixedFloat = FixedFloat_new,
    U32 = TypeU32_new,
    U16 = TypeU16_new,
    U8 = TypeU8_new,
}
