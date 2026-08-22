
---@alias int integer
---@alias bool boolean
---@alias u8 int
---@alias u16 int
---@alias u32 int
---@alias s8 int
---@alias s16 int
---@alias s32 int

local pathlib = require "path"
local mem = require "mem"
local util = require "util"
local array_lib = require "array"
local repl = require "REPL"
local timer = require "timer"
local irume = require "irume"
local _sjis = require "sjis"
local ds_button = require "ds_button"
local recorder = require "recording"
local image_lib = require "image"

---@type fun()?
loop = nil

---@type table<int | string, fun()>
local loop_callbacks = {}
local loop_callbacks_last_id = 0

---@param id int | string
---@param callback fun()
local function _set_loop(id, callback)
    loop_callbacks[id] = callback
end
---@param id int | string
---@param callback fun(): fun()
local function _xset_loop(id, callback)
    loop_callbacks[id] = callback()
end
SET_LOOP = _set_loop
XSET_LOOP = _xset_loop

---@return int
local function _find_id()
    local id = loop_callbacks_last_id
    while true do
        id = id + 1
        if not loop_callbacks[id] then
            loop_callbacks_last_id = id
            return id
        end
    end
end
---@param callback fun()
---@return int
local function _add_loop(callback)
    local id = _find_id()
    loop_callbacks[id] = callback
    return id
end
ADD_LOOP = _add_loop
---@param callback fun(): fun()
---@return int
local function _xadd_loop(callback)
    local id = _find_id()
    loop_callbacks[id] = callback()
    return id
end
XADD_LOOP = _xadd_loop
---@param id int | string
local function _delete_loop(id)
    loop_callbacks[id] = nil
end
DELETE_LOOP = _delete_loop
local function _clear_loop()
    loop_callbacks = {}
end
CLEAR_LOOP = _clear_loop

local function main()
    repl.main_loop()
    timer.__update()
    irume.__update()
    if loop and type(loop) == "function" then
        success, mes = pcall(loop)
        if not success then print(mes) loop = nil end
    end
    for id, fun in pairs(loop_callbacks) do
        if fun then
            success, mes = pcall(fun)
            if not success then print(mes) loop_callbacks[id] = nil end
        end
    end
end

local _ds = {
    key = ds_button,
}
DS = _ds

return {
    path = pathlib,
    ds = _ds,
    main = main,
    util = util,
    array = array_lib,
    mem = mem,
    timer = timer,
    irume = irume,
    sjis = _sjis,
    image = image_lib,
    recorder = recorder,
    fill_in = mem.fill_in,
    fill_inr = mem.fill_inr,
    fill_in_arr = mem.fill_in_arr,
    romfill_in_arr = mem.romfill_in_arr,
    warr = mem.warr,
    romwarr = mem.romwarr,
    rarr = mem.rarr,
    romrarr = mem.romrarr,
    hex = util.hex,
    hexp = util.hexp,
    stou8 = util.stou8,
    stou16 = util.stou16,
    stou32 = util.stou32,
    htob = util.htob,
    within = util.within,
    table_copy = util.table_copy,
    mfilter8 = mem.mfilter8,
    mfilter16 = mem.mfilter16,
    mfilter32 = mem.mfilter32,
    replace8 = mem.replace8,
    replace16 = mem.replace16,
    replace32 = mem.replace32,
    replace8r = mem.replace8r,
    replace16r = mem.replace16r,
    replace32r = mem.replace32r,
    find = mem.find,
    findr = mem.findr,
    find_all = mem.find_all,
    find_allr = mem.find_allr,
    at = mem.at,
    romat = mem.romat,
    range = mem.range,
    romrange = mem.romrange,
    pos = {
        Morton = util.pos_Morton,
        Raster = util.pos_Raster,
    },
}
