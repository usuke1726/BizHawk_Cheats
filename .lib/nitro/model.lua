
local newMemReader, GetNameList_u32 = ___nitro_lib.newMemReader, ___nitro_lib.GetNameList_u32

---@param begin int
local function get_Bone(begin)
    local mem = newMemReader(begin)
    local flags = mem:r16()
    local flags_d = {
        t = (flags & 0x1) ~= 0,
        rm = (flags & 0x2) ~= 0,
        s = (flags & 0x4) ~= 0,
        rp = (flags & 0x8) ~= 0,
        form = flags & 0xf0,
        neg_one = (flags & 0x100) ~= 0,
        neg_c = (flags & 0x200) ~= 0,
        neg_d = (flags & 0x400) ~= 0,
    }
    local m0 = mem:r16()
    local tr_x, tr_y, tr_z, a, b, ms, sc_x, sc_y, sc_z
    if flags_d.t then
        tr_x = mem:D32()
        tr_y = mem:D32()
        tr_z = mem:D32()
    end
end

---@param begin int
---@param bone_idx int
---@param w Writer
local function read_Bone(begin, bone_idx, w)
    -- TODO: より細かい情報を取得して出力
    w:wl(string.format((
        "### Bone %d at 0x%08X\n"
    ), bone_idx, begin
    ))
end

---@param begin int
---@param model_idx int
---@param w Writer
local function read_Model(begin, model_idx, w)
    local mem = newMemReader(begin)
    local filesize = mem:r32()
    local render_cmds_off = mem:r32()
    local materials_off = mem:r32()
    local meshes_off = mem:r32()
    local inv_binds_off = mem:r32()

    local unknown1 = mem:r(3)
    local num_bone_matrices = mem:r()
    local num_materials = mem:r()
    local num_meshes = mem:r()
    local unknown2 = mem:r(2)

    local up_scale = mem:r32()
    local down_scale = mem:r32()

    local num_verts = mem:r16()
    local num_polys = mem:r16()
    local num_tris = mem:r16()
    local num_quads = mem:r16()

    local bb_xm = mem:r16()
    local bb_ym = mem:r16()
    local bb_zm = mem:r16()
    local bb_xM = mem:r16()
    local bb_yM = mem:r16()
    local bb_zM = mem:r16()
    local BoundingBox = {
        x_min = bb_xm,
        y_min = bb_ym,
        z_min = bb_zm,
        x_max = bb_xM,
        y_max = bb_yM,
        z_max = bb_zM,
    }
    local unknown3 = mem:r(8)
    local boneList = GetNameList_u32(mem)
    if not boneList then return end
    w:wl(string.format((
        "## Model %d\n  - range 0x%08X -- 0x%08X\n" ..
        "  - %d bone_mats, %d materials, %d meshes\n" ..
        "  - render_cmds => 0x%08X\n  - materials => 0x%08X\n  - meshes => 0x%08X\n  - inv_binds => 0x%08X\n" ..
        "  - %d verts, %d polys, %d tris, %d quads\n\n" ..
        "  - %d Bones:"
    ), model_idx, begin, begin + filesize,
        num_bone_matrices, num_materials, num_meshes,
        begin + render_cmds_off, begin + materials_off, begin + meshes_off, begin + inv_binds_off,
        num_verts, num_polys, num_tris, num_quads,
        boneList.count
    ))
    for i = 1, boneList.count do
        local offset = boneList.data[i].v
        read_Bone(begin + offset, i, w)
    end
end

---モデルデータの情報をダンプする
--- - https://github.com/scurest/nsbmd_docs/blob/master/nsbmd_docs.txt#L164
---@param begin int
---@param writer_query? string | bool
local function read_MDL0(begin, writer_query)
    local w = lib.path.w(writer_query)
    local mem = newMemReader(begin)
    local stamp = string.char(mem:r(4))
    if stamp ~= "MDL0" then
        local _b = btos({string.byte(stamp, 1, #stamp)})
        w:wl(string.format("wrong addr: \"MDL0\" is not contained at 0x%08X (value: %s)", begin, _b))
        w:close()
        return
    end
    local filesize = mem:r32()
    local models = GetNameList_u32(mem)
    if not models then
        w:close()
        return
    end
    w:wl(string.format("# MDL0\n  - range: 0x%08X -- 0x%08X (bound: 0x%X)\n  - %d Model%s\n", begin, begin + filesize, filesize, models.count, (models.count > 1 and "s" or "") ))
    for i = 1, models.count do
        local offset = models.data[i].v
        read_Model(begin + offset, i, w)
    end
    w:close()
end

return {
    read_MDL0 = read_MDL0
}
