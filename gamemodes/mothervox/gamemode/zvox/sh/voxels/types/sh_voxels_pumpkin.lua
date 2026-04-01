ZVox = ZVox or {}

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)

local function newPumpkin(name, face)
	ZVox.NewVoxel({
		["name"] = name,
		["visible"] = true,
		["solid"] = true,
		["multitex"] = {
			[1] = face, -- +X
			[2] = "zvox:pumpkin", -- -X
			[3] = "zvox:pumpkin", -- +Y
			[4] = "zvox:pumpkin", -- -Y
			[5] = "zvox:pumpkin_roof", -- +Z
			[6] = "zvox:pumpkin_roof", -- -Z
		},
		["tex"] = "zvox:pumpkin",
		["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
		["voxelstatetype"] = VOXELSTATE_TYPE_ZROT,
		["sound"] = ZVOX_MAT_WOOD,

		["voxelmodel"] = "zvox:zrot_x_plus",
		["voxelmodeltable"] = {
			[0] = "zvox:zrot_x_plus",
			[1] = "zvox:zrot_x_minus",
			[2] = "zvox:zrot_y_plus",
			[3] = "zvox:zrot_y_minus",
		},
	})
end

newPumpkin("pumpkin", "zvox:pumpkin")
newPumpkin("pumpkin_trays", "zvox:pumpkin_face_tray")
newPumpkin("pumpkin_scary", "zvox:pumpkin_face_scary")
newPumpkin("pumpkin_loka", "zvox:pumpkin_face_loka")
newPumpkin("pumpkin_man", "zvox:pumpkin_face_man_tray")