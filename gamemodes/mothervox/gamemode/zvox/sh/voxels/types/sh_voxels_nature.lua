ZVox = ZVox or {}

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)

ZVox.NewVoxel({
	["name"] = "grass",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:grass_side", -- +X
		[2] = "zvox:grass_side", -- -X
		[3] = "zvox:grass_side", -- +Y
		[4] = "zvox:grass_side", -- -Y
		[5] = "zvox:grass"     , -- +Z
		[6] = "zvox:dirt"      , -- -Z
	},
	["tex"] = "zvox:grass_side",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["sound"] = ZVOX_MAT_GRASS,
	["voxelmodel"] = "zvox:cube_randomrot_zplus",
})

ZVox.SimpleVoxel("dirt", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")
ZVox.SimpleVoxel("rock_dirt", ZVOX_MAT_STONE, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")
ZVox.SimpleVoxel("magma", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")