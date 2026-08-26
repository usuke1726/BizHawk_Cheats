
package.path = os.getenv("BizHawk_ULibPath") .. package.path
lib = require "lib"

local t = "video4"

CLS()

print("READY")

-- ===========================================
-- ===========================================
-- ===========================================

local _t = "./series/ryori/" .. t
package.loaded[_t] = nil
local f = require(_t)

lib.actions.remove_all()
lib.actions.register(t, lib.actions.KF.touch(160, 248, 45, 133), f)

while true do
    lib.main()
    emu.frameadvance()
end
