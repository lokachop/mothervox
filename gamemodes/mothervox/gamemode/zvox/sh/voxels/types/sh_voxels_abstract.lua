ZVox = ZVox or {}

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_ABSTRACT)
ZVox.SimpleVoxel("xor", ZVOX_MAT_METAL)

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_UNKNOWN)
ZVox.NewVoxel({
	["name"] = "dir_test",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:plus_x", -- +X
		[2] = "zvox:minus_x", -- -X
		[3] = "zvox:plus_y", -- +Y
		[4] = "zvox:minus_y", -- -Y
		[5] = "zvox:plus_z"     , -- +Z
		[6] = "zvox:minus_z"      , -- -Z
	},
	["tex"] = "zvox:xor",
	["sound"] = ZVOX_MAT_STONE,
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["voxelmodel"] = "zvox:cube_dir"
})
ZVox.SimpleVoxelSlab({
	["name"] = "dir_test_slab",
	["multitex"] = {
		[1] = "zvox:plus_x" , -- +X
		[2] = "zvox:minus_x", -- -X
		[3] = "zvox:plus_y" , -- +Y
		[4] = "zvox:minus_y", -- -Y
		[5] = "zvox:plus_z" , -- +Z
		[6] = "zvox:minus_z", -- -Z
	},
	["tex"] = "zvox:xor",
	["sound"] = ZVOX_MAT_STONE,
	["voxelstateparams"] = {
		["solidName"] = "zvox:dir_test",
	},
})


ZVox.SimpleVoxelStairs({
	["name"] = "dir_test_stair",
	["sound"] = ZVOX_MAT_STONE,
	["multitex"] = {
		[1] = "zvox:plus_x" , -- +X
		[2] = "zvox:minus_x", -- -X
		[3] = "zvox:plus_y" , -- +Y
		[4] = "zvox:minus_y", -- -Y
		[5] = "zvox:plus_z" , -- +Z
		[6] = "zvox:minus_z", -- -Z
	},
	["tex"] = "zvox:xor",
})


ZVox.NewVoxel({
	["name"] = "nodraw",
	["visible"] = ZVOX_NODRAW_VISIBLE,
	["solid"] = true,
	["tex"] = "zvox:nodraw",
	["sound"] = ZVOX_MAT_STONE,
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
})

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_ABSTRACT)
ZVox.SimpleVoxel("smile", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("abstract1", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("abstract2", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("abstract3", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("abstract4", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("abstract5", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("abstract6", ZVOX_MAT_STONE)

ZVox.NewVoxel({
	["name"] = "abstract7",
	["visible"] = true,
	["solid"] = true,
	["tex"] = "zvox:abstract7",
	["sound"] = ZVOX_MAT_STONE,
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["emissive"] = 7,
})

ZVox.SimpleVoxel("noise", ZVOX_MAT_STONE)

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NUMBER)
for i = 0, 9 do
	ZVox.SimpleVoxel("num_" .. tostring(i), ZVOX_MAT_STONE)
end

for i = 97, 122 do
	ZVox.SimpleVoxel("char_" .. string.char(i), ZVOX_MAT_STONE)
end

ZVox.SimpleVoxel("char_plus", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("char_minus", ZVOX_MAT_STONE)

ZVox.SimpleVoxel("char_star", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("char_slash", ZVOX_MAT_STONE)

ZVox.SimpleVoxel("char_percent", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("char_equals", ZVOX_MAT_STONE)

ZVox.SimpleVoxel("char_colon", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("char_semicolon", ZVOX_MAT_STONE)

ZVox.SimpleVoxel("char_closed_parentheses", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("char_open_parentheses", ZVOX_MAT_STONE)

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_ABSTRACT)
ZVox.SimpleVoxel("colourful", ZVOX_MAT_STONE)

ZVox.NewVoxel({
	["name"] = "present_red",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:present_side_red"  , -- +X
		[2] = "zvox:present_side_red"  , -- -X
		[3] = "zvox:present_side_red"  , -- +Y
		[4] = "zvox:present_side_red"  , -- -Y
		[5] = "zvox:present_top_red"   , -- +Z
		[6] = "zvox:present_bottom_red", -- -Z
	},
	["tex"] = "zvox:present_side_red",
	["sound"] = ZVOX_MAT_CLOTH,
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["voxelmodel"] = "zvox:cube_dir",
})

ZVox.SimpleVoxelZRot({
	["name"] = "present_green",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:present_side_green"  , -- +X
		[2] = "zvox:present_side_green"  , -- -X
		[3] = "zvox:present_side_green"  , -- +Y
		[4] = "zvox:present_side_green"  , -- -Y
		[5] = "zvox:present_top_green"   , -- +Z
		[6] = "zvox:present_bottom_green", -- -Z
	},
	["tex"] = "zvox:present_side_green",
	["sound"] = ZVOX_MAT_CLOTH,
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["voxelstatetype"] = VOXELSTATE_TYPE_ZROT,
})


ZVox.SimpleVoxelLogRot({
	["name"] = "sine_line",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:sine_line", -- +X
		[2] = "zvox:sine_line", -- -X
		[3] = "zvox:sine_line", -- +Y
		[4] = "zvox:sine_line", -- -Y
		[5] = "zvox:sine_line_top", -- +Z
		[6] = "zvox:sine_line_top", -- -Z
	},
	["tex"] = "zvox:sine_line",
	["sound"] = ZVOX_MAT_METAL,
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["emissive"] = 15,
})


ZVox.SimpleVoxelZRot({
	["name"] = "familiar_machine",
	["multitex"] = {
		[1] = "zvox:familiar_machine_front", -- +X
		[2] = "zvox:familiar_machine_hull", -- -X
		[3] = "zvox:familiar_machine_hull", -- +Y
		[4] = "zvox:familiar_machine_hull", -- -Y
		[5] = "zvox:familiar_machine_top", -- +Z
		[6] = "zvox:familiar_machine_hull", -- -Z
	},
	["tex"] = "zvox:familiar_machine_hull",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["voxelstatetype"] = VOXELSTATE_TYPE_ZROT,
	["sound"] = ZVOX_MAT_METAL,
})


ZVox.SimpleVoxel("fan", ZVOX_MAT_METAL)


ZVox.SimpleVoxelZRot({
	["name"] = "monitor",
	["multitex"] = {
		[1] = "zvox:monitor_front", -- +X
		[2] = "zvox:metal_casing", -- -X
		[3] = "zvox:metal_casing", -- +Y
		[4] = "zvox:metal_casing", -- -Y
		[5] = "zvox:metal_casing", -- +Z
		[6] = "zvox:metal_casing", -- -Z
	},
	["tex"] = "zvox:metal_casing",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["voxelstatetype"] = VOXELSTATE_TYPE_ZROT,
	["sound"] = ZVOX_MAT_METAL,
})

ZVox.SimpleVoxelZRot({
	["name"] = "monitor_noise",
	["multitex"] = {
		[1] = "zvox:monitor_front_noise", -- +X
		[2] = "zvox:metal_casing", -- -X
		[3] = "zvox:metal_casing", -- +Y
		[4] = "zvox:metal_casing", -- -Y
		[5] = "zvox:metal_casing", -- +Z
		[6] = "zvox:metal_casing", -- -Z
	},
	["tex"] = "zvox:metal_casing",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["voxelstatetype"] = VOXELSTATE_TYPE_ZROT,
	["sound"] = ZVOX_MAT_METAL,
})

ZVox.SimpleVoxelZRot({
	["name"] = "monitor_warn",
	["multitex"] = {
		[1] = "zvox:monitor_front_warn", -- +X
		[2] = "zvox:metal_casing", -- -X
		[3] = "zvox:metal_casing", -- +Y
		[4] = "zvox:metal_casing", -- -Y
		[5] = "zvox:metal_casing", -- +Z
		[6] = "zvox:metal_casing", -- -Z
	},
	["tex"] = "zvox:metal_casing",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["voxelstatetype"] = VOXELSTATE_TYPE_ZROT,
	["sound"] = ZVOX_MAT_METAL,
})


ZVox.NewVoxel({
	["name"] = "supermatter",
	["visible"] = true,
	["solid"] = true,
	["tex"] = "zvox:supermatter",
	["sound"] = ZVOX_MAT_GLASS,
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["emissive"] = 15,
})

ZVox.SimpleVoxel("gelatin", ZVOX_MAT_SNOW)

ZVox.NewVoxel({
	["name"] = "tnt",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:tnt_side", -- +X
		[2] = "zvox:tnt_side", -- -X
		[3] = "zvox:tnt_side", -- +Y
		[4] = "zvox:tnt_side", -- -Y
		[5] = "zvox:tnt_top", -- +Z
		[6] = "zvox:tnt_bottom", -- -Z
	},
	["tex"] = "zvox:tnt_side",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["sound"] = ZVOX_MAT_GRASS,
	["voxelmodel"] = "zvox:cube_dir",
})

ZVox.SimpleVoxel("mothervox_shop_ore", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("mothervox_shop_fuel", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("mothervox_shop_parts", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("mothervox_shop_consumables", ZVOX_MAT_METAL)


ZVox.NewVoxel({
	["name"] = "unobtainalum",
	["visible"] = true,
	["solid"] = true,
	["tex"] = "zvox:unobtainalum",
	["sound"] = ZVOX_MAT_GLASS,
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
})