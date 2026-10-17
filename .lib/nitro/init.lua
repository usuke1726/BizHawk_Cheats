
require "Nitro/util"
local anim_lib = require "Nitro/animation"
local model_lib = require "Nitro/model"

Nitro = {
    read_JNT0 = anim_lib.read_JNT0,
    read_MDL0 = model_lib.read_MDL0,
    find_JNT0 = anim_lib.find_JNT0,
    find_MDL0 = model_lib.find_MDL0,
}

return Nitro
