
local newMemReader, GetNameList_u32 = ___nitro_lib.newMemReader, ___nitro_lib.GetNameList_u32

---@class BoneDataFlags
---@field t bool
---@field rm bool
---@field s bool
---@field rp bool
---@field form int
---@field neg_one bool
---@field neg_c bool
---@field neg_d bool

---@class BoneData
---@field flags BoneDataFlags
---@field m0 DataPos_int
---@field tr_x DataPos_int
---@field tr_y DataPos_int
---@field tr_z DataPos_int
---@field a DataPos_int
---@field b DataPos_int
---@field ms DataPos_int[]
---@field sc_x DataPos_int
---@field sc_y DataPos_int
---@field sc_z DataPos_int

---@param begin int
---@return BoneData
local function get_Bone(begin)
    local mem = newMemReader(begin)
    local flags = mem:r16()
    local flags_d = {
        t = (flags & 0x1) ~= 0,
        rm = (flags & 0x2) ~= 0,
        s = (flags & 0x4) ~= 0,
        rp = (flags & 0x8) ~= 0,
        form = (flags & 0xf0) >> 4,
        neg_one = (flags & 0x100) ~= 0,
        neg_c = (flags & 0x200) ~= 0,
        neg_d = (flags & 0x400) ~= 0,
    }
    local m0 = mem:d16()
    local tr_x, tr_y, tr_z, a, b, ms, sc_x, sc_y, sc_z
    if not flags_d.t then
        tr_x = mem:D32()
        tr_y = mem:D32()
        tr_z = mem:D32()
    end
    if flags_d.rp then
        a = mem:D16()
        b = mem:D16()
    elseif not flags_d.rm then
        ms = {}
        for i = 1, 8 do
            ms[i] = mem:D16()
        end
    end
    if not flags_d.s then
        sc_x = mem:D32()
        sc_y = mem:D32()
        sc_z = mem:D32()
    end
    return {
        flags = flags_d,
        m0 = m0,
        tr_x = tr_x,
        tr_y = tr_y,
        tr_z = tr_z,
        a = a,
        b = b,
        ms = ms,
        sc_x = sc_x,
        sc_y = sc_y,
        sc_z = sc_z,
    }
end

---@param begin int
---@param bone_idx int
---@param w Writer
---@param addrs_bone int[]
local function read_Bone(begin, bone_idx, w, addrs_bone)
    w:wl(string.format((
        "\n### Bone %d at 0x%08X"
    ), bone_idx, begin
    ))
    local _printed = false
    local bone = get_Bone(begin)
    if not bone.flags.t then
        w:wl(string.format("[TR] %08X %08X %08X", bone.tr_x.addr, bone.tr_y.addr, bone.tr_z.addr))
        table.insert(addrs_bone, bone.tr_x.addr)
        table.insert(addrs_bone, bone.tr_y.addr)
        table.insert(addrs_bone, bone.tr_z.addr)
        _printed = true
    end
    if bone.flags.rp then
        w:wl(string.format("[Rot] %08X %08X", bone.a.addr, bone.b.addr))
        table.insert(addrs_bone, bone.a.addr)
        table.insert(addrs_bone, bone.b.addr)
        _printed = true
    elseif not bone.flags.rm then
        w:wl(string.format((
            "[RotMat]\n" ..
            "  [ %08X  %08X  %08X ]\n" ..
            "  [ %08X  %08X  %08X ]\n" ..
            "  [ %08X  %08X  %08X ]"
        ), bone.m0.addr, bone.ms[3].addr, bone.ms[6].addr,
        bone.ms[1].addr, bone.ms[4].addr, bone.ms[7].addr,
        bone.ms[2].addr, bone.ms[5].addr, bone.ms[8].addr
        ))
        table.insert(addrs_bone, bone.m0.addr)
        for i = 1, 8 do
            table.insert(addrs_bone, bone.ms[i].addr)
        end
        _printed = true
    end
    if not bone.flags.s then
        w:wl(string.format("[SCL] %08X %08X %08X", bone.sc_x.addr, bone.sc_y.addr, bone.sc_z.addr))
        table.insert(addrs_bone, bone.sc_x.addr)
        table.insert(addrs_bone, bone.sc_y.addr)
        table.insert(addrs_bone, bone.sc_z.addr)
        _printed = true
    end
    if not _printed then
        w:wl("[Nothing]")
    end
end

---@alias AddrsMeshRange {begin: int, iend: int}

---@param begin int
---@param mesh_idx int
---@param w Writer
---@param addrs_mesh AddrsMeshRange[]
local function read_Mesh(begin, mesh_idx, w, addrs_mesh)
    local mem = newMemReader(begin)
    local dummy = mem:r16()
    local size = mem:r16()
    local unknown = mem:r32()
    local cmds_off = mem:r32()
    local cmds_len = mem:r32()
    local cmds_begin, cmds_iend = begin + cmds_off, begin + cmds_off + cmds_len - 1
    w:wl(string.format((
        "\n### Mesh %d at 0x%08X\n  - size: %d\n" ..
        "  - cmds => %08X -- %08X"
    ), mesh_idx, begin, size, cmds_begin, cmds_iend
    ))
    table.insert(addrs_mesh, {begin = cmds_begin, iend = cmds_iend})
end

---@param begin int
---@param mat_idx int
---@param w Writer
---@param addrs_mat int[]
local function read_Material(begin, mat_idx, w, addrs_mat)
    local mem = newMemReader(begin)
    local dummy = mem:r16()
    local size = mem:r16()

    local dif_amb = mem:D32()
    local spe_emi = mem:D32()
    local polygon_attr = mem:D32()
    local unknown1 = mem:r32()
    local teximage_params = mem:D32()

    local unknown2 = mem:r32()
    local unknown3 = mem:r32()

    local texture_width = mem:d16()
    local texture_height = mem:d16()
    w:wl(string.format((
        "\n#### Material %d (size: 0x%X)\n" ..
        "  - (w%08X, h%08X) = (%d, %d)" ..
        "  - dif_amb => %08X"
    ), mat_idx, size,
        texture_width.addr, texture_height.addr,
        texture_width.v, texture_height.v,
        dif_amb.addr
    ))
    table.insert(addrs_mat, texture_width.addr)
    table.insert(addrs_mat, texture_height.addr)
end

---@param begin int
---@param w Writer
---@param addrs_mat int[]
local function read_MaterialList(begin, w, addrs_mat)
    local mem = newMemReader(begin)
    local texture_pairings_off = mem:r16()
    local palette_pairings_off = mem:r16()
    local materialList = GetNameList_u32(mem)
    if not materialList then return end
    w:wl(string.format((
        "\n\n### MaterialList\n" ..
        "  - texture_pairings => %08X" ..
        "  - palette_pairings => %08X" ..
        "  - %d Materials"
    ), begin + texture_pairings_off, begin + palette_pairings_off, materialList.count))
    for i = 1, materialList.count do
        local offset = materialList.data[i].v
        read_Material(begin + offset, i, w, addrs_mat)
    end
end

---@param begin int
---@param model_idx int
---@param w Writer
---@param addrs_mat int[]
---@param addrs_bone int[]
---@param addrs_mesh AddrsMeshRange[]
local function read_Model(begin, model_idx, w, addrs_mat, addrs_bone, addrs_mesh)
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
    local boneList_head = mem.i
    local boneList = GetNameList_u32(mem)
    if not boneList then return end
    local meshList_head = begin + meshes_off
    local meshList = GetNameList_u32(newMemReader(meshList_head))
    if not meshList then return end
    local materialList_head = begin + materials_off
    w:wl(string.format((
        "\n## Model %d\n  - range 0x%08X -- 0x%08X\n" ..
        "  - %d bone_mats, %d materials, %d meshes\n" ..
        "  - render_cmds => 0x%08X\n  - materials => 0x%08X\n  - meshes => 0x%08X\n  - inv_binds => 0x%08X\n" ..
        "  - %d verts, %d polys, %d tris, %d quads\n\n" ..
        "  - %d Bones, %d Meshes"
    ), model_idx, begin, begin + filesize,
        num_bone_matrices, num_materials, num_meshes,
        begin + render_cmds_off, materialList_head, meshList_head, begin + inv_binds_off,
        num_verts, num_polys, num_tris, num_quads,
        boneList.count, meshList.count
    ))
    for i = 1, boneList.count do
        local offset = boneList.data[i].v
        read_Bone(boneList_head + offset, i, w, addrs_bone)
    end
    w:wl("\n")
    for i = 1, meshList.count do
        local offset = meshList.data[i].v
        read_Mesh(meshList_head + offset, i, w, addrs_mesh)
    end
    read_MaterialList(materialList_head, w, addrs_mat)
end

---@alias MDL0ReadResult { addrs_mat: int[], addrs_bone: int[], addrs_mesh: AddrsMeshRange[] }

---モデルデータの情報をダンプする
--- - https://github.com/scurest/nsbmd_docs/blob/master/nsbmd_docs.txt#L164
---@param begin int `"MDL0"`があるアドレス
---@param writer_query? string | bool | Writer ファイル名(`string`)または標準出力(`bool?`)
---@return MDL0ReadResult
local function read_MDL0(begin, writer_query)
    local w = lib.path.w(writer_query)
    local mem = newMemReader(begin)
    local stamp = string.char(mem:r(4))
    local empty_res = {addrs_mat = {}, addrs_bone = {}, addrs_mesh = {}}
    if stamp ~= "MDL0" then
        local _b = btos({string.byte(stamp, 1, #stamp)})
        w:wl(string.format("wrong addr: \"MDL0\" is not contained at 0x%08X (value: %s)", begin, _b))
        w:close()
        return empty_res
    end
    local filesize = mem:r32()
    local models = GetNameList_u32(mem)
    if not models then
        w:close()
        return empty_res
    end
    w:wl(string.format("# MDL0\n  - range: 0x%08X -- 0x%08X (bound: 0x%X)\n  - %d Model%s\n", begin, begin + filesize, filesize, models.count, (models.count > 1 and "s" or "") ))
    local addrs_mat, addrs_bone, addrs_mesh = {}, {}, {}
    for i = 1, models.count do
        local offset = models.data[i].v
        if i > 1 then
            w:wl("\n\n=====================================\n")
        end
        read_Model(begin + offset, i, w, addrs_mat, addrs_bone, addrs_mesh)
    end
    w:close()
    return {
        addrs_mat = addrs_mat,
        addrs_bone = addrs_bone,
        addrs_mesh = addrs_mesh,
    }
end

---@param begin? int
---@param inclusiveEnd? int
---@param silent? bool
---@return bool, int
local function find_MDL0(begin, inclusiveEnd, silent)
    begin = begin or 0x02000000
    inclusiveEnd = inclusiveEnd or (begin + 0x003fffff)
    return lib.find(begin, inclusiveEnd, ascii("MDL0"), 4, nil, silent)
end

return {
    read_MDL0 = read_MDL0,
    find_MDL0 = find_MDL0,
}
