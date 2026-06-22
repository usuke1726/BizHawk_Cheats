
package.path = os.getenv("BizHawk_ULibPath") .. package.path
lib = require "lib"

while true do
    lib.main()
    emu.frameadvance()
end
