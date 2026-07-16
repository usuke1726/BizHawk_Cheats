
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

return {
    filterObj = filterObj,
}
