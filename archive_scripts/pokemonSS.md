
# ポケモン ソウルシルバー

## オーディオ

アドレス `0x03E57B80`

時間: `0x2c`
ピッチ1: `0x1f`
ピッチ2: `0x18` (signed 2byte LE, 大体+0x40で半音)
ハットリ: `0x22` (signed 2byte LE、負だと音が上がる)
vib: `0x26` (1byte)
volume: `0x16` (signed 2byte LE)
pos: `0x34` (4byte LE)

## video25 ルギア一発撃破時のBGM

```lua

lib.irume.start(function()
    local head = 0x03E57B80
    local p2 = 0x18
    local vol = 0x16
    local as = {}
    local ps = {}
    local bound = 0x200
    for i = 0, 16 do
        as[i] = head + 0x40 * i
        ps[i] = bound
    end
    return function()
        for i, a in pairs(as) do
            if within(i, 12, 16) then
                -- 鳴き声と効果音がごちゃまぜ
                -- w16(a+vol, 0x40)
                ps[i] = (ps[i]-6) % (bound)
                w16(a+p2, ps[i])
            else
                ps[i] = (ps[i]-2) % (2*bound)
                w16(a+p2, ps[i]-bound)
            end
        end
    end
end)
```

## video25 ルギアだけを映す

```lua
local function set()
w16(0x023013F0, 1) -- ルギアのアニメーションを無効化して位置調整可能にする
-- ルギアの位置を調整(track[1][1]のSampleCurve)
w32(0x02307808, 0xc400)
w32(0x02307430, 0x6E000)
end

local function set_BG()
local res = Nitro.read_JNT0(0x0233D08C, 0)
for _, a in pairs(res.addrs_tr) do
    w32(a, 0x55555555) -- 単純に背景を消す
end
end

local by = 0xc400
local dy = 0x10000
local vy = ValueUpdater(1, by-dy, by+dy, VUO.addrand(-0x10, 0x10, dy//0x10)):w32(0x02307808)

-- x: 0x023060F8
-- y: 0x02307430
-- z: 0x02307808

local k = DS.key.lis("L")
function loop()
    vy()
    if k() then
        savestate.loadslot(9)
        lib.timer.setInterval(10, set_BG)
        lib.timer.setTimeout(12, set)
    end
end
```

## video25 ルギアじたばた


```lua

local res = Nitro.read_JNT0(0x023013BC, 0)
local f = FixFloatConverter(12, 19)
local vs = {}
for _, a in pairs(res.addrs_tr) do
    vs[a] = f:tof(r32(a))
end

SET_LOOP("move", function()
    for _, a in pairs(res.addrs_tr) do
        w32(a, f:toi(vs[a] + rand(-10,10) / 100))
    end
end)
```

## video25 トゥーンルギア

```lua
local MDL_addrs = {
0x0230C520, -- ルギア
0x02325EF4,
}
local vtx = MESH_LIB.VTX_16
local vtx_diff = MESH_LIB.VTX_DIFF
for _, addr in pairs(pick(MDL_addrs, {
range(1, 1)
})) do
local res = Nitro.read_MDL0(addr, 0)
local meshes = res.addrs_mesh
printf("%d meshes", #meshes)
for i, mesh in pairs(pick(meshes, {
range(1, 1) -- 2は下半身
})) do
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        local pos = vtx.read(addr)
        pos.x = pos.x*2
        pos.y = pos.y*3
        pos.z = pos.z*1
        vtx.write(addr, pos)
        return
    end
    if info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vtx_diff.read(addr)
        pos.x = pos.x - 0.01
        pos.y = pos.y - 0.01
        pos.z = pos.z - 0.01
        -- vtx_diff.write(addr, pos)
    end
end)
end
end

-- local JNT_addrs = {
--     -- 0x023013BC, -- ルギア
--     -- 0x0233824F,
--     -- 0x0233D08C, -- 背景
-- }
-- local update_Rugia = (function()
-- local res = Nitro.read_JNT0(0x023013BC, 0)
-- for _, a in pairs(res.addrs_tr) do
-- add32(a, rand(1, 0x1000)<<5)
-- end
-- end)()
```
