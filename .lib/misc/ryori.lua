
---@class VT_Unit
---@field t string
---@field v1 int
---@field v2 int
---@field v3 int
---@field v4 int

local VT_options = {
    head = 0x023CA5E6
}

---@return VT_Unit[]
local function get_vt()
    local head = VT_options.head
    local i = head
    ---@type VT_Unit[]
    local ret = {}
    local mode = 0
    local function update_v(current, v)
        if not within(v, 0x30, 0x39) then
            error(string.format("invalid v value (not number character): %02X (at %08X)", v, i))
        end
        return current * 10 + (v - 0x30)
    end
    local function VT_init()
        return {t = "", v1 = 0, v2 = 0, v3 = 0, v4 = 0}
    end
    ---@type VT_Unit
    local tmp = VT_init()
    while true do
        local v = r8(i)
        if v == 0 then return ret end
        if v == 0x20 then
            mode = mode + 1
            assert(mode <= 4, "mode out of bound (must be <= 4)")
        elseif v == 0x0a then
            ret[#ret+1] = tmp
            tmp = VT_init()
            mode = 0
        elseif mode == 0 then
            tmp.t = tmp.t .. string.char(v)
        elseif mode == 1 then
            tmp.v1 = update_v(tmp.v1, v)
        elseif mode == 2 then
            tmp.v2 = update_v(tmp.v2, v)
        elseif mode == 3 then
            tmp.v3 = update_v(tmp.v3, v)
        elseif mode == 4 then
            tmp.v4 = update_v(tmp.v4, v)
        end
        i = i + 1
    end
end

---@param data VT_Unit[]
local function set_vt(data)
    local bytes = {}
    for i, v in pairs(data) do
        local _i = tostring(i)
        assert(v.v1 >= 0, _i .. ": v1 is negative")
        assert(v.v2 >= 0, _i .. ": v2 is negative")
        assert(v.v3 >= 0, _i .. ": v3 is negative")
        assert(v.v4 >= 0, _i .. ": v4 is negative")
        local t = string.format("%s %d %d %d %d\n", v.t, v.v1, v.v2, v.v3, v.v4)
        local b = { string.byte(t, 1, -1) }
        for _, _v in pairs(b) do
            table.insert(bytes, _v)
        end
    end
    local head = VT_options.head
    local n = #bytes
    lib.warr(head, bytes)
    local i = head + n
    while true do
        if r8(i) == 0 then return end
        w8(i, 0)
        i = i + 1
    end
end

---@param data VT_Unit[]
local function print_vt(data)
    for i, v in pairs(data) do
        local t = string.format("[%02d] \"%s\" (%d %d %d %d)", i, v.t, v.v1, v.v2, v.v3, v.v4)
        print(t)
    end
end

---@param data [string, int, int, int, int][]
---@return VT_Unit[]
local function vt(data)
    local ret = {}
    for _, v in pairs(data) do
        ret[#ret+1] = {
            t = v[1],
            v1 = v[2],
            v2 = v[3],
            v3 = v[4],
            v4 = v[5],
        }
    end
    return ret
end

return {
    options = VT_options,
    vt = vt,
    print_vt = print_vt,
    get_vt = get_vt,
    set_vt = set_vt,
}
