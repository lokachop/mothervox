ZVox = ZVox or {}

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)

ZVox.SimpleVoxel("stone", ZVOX_MAT_STONE)

-- ores
ZVox.SimpleVoxel("coal_ore", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")
ZVox.SimpleVoxel("copper_ore", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")
ZVox.SimpleVoxel("iron_ore", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")
ZVox.SimpleVoxel("silver_ore", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")
ZVox.SimpleVoxel("gold_ore", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")
ZVox.SimpleVoxel("diamond_ore", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")
ZVox.SimpleVoxel("uranium_ore", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")
ZVox.SimpleVoxel("temporalium_ore", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")


ZVox.SimpleVoxel("cobble", ZVOX_MAT_STONE)

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_BUILDINGBLOCKS)

ZVox.SimpleVoxel("tile", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("dark_tile", ZVOX_MAT_STONE)

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)

ZVox.SimpleVoxel("bedrock", ZVOX_MAT_STONE)

-- voidinium is in etherealstone
ZVox.SimpleVoxel("etherealstone", ZVOX_MAT_ETHEREALSTONE)
ZVox.SimpleVoxel("voidinium_ore", ZVOX_MAT_GRAVEL, ZVOX_VOXELGROUP_SOLID, "zvox:cube_randomrot_all")


ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_BUILDINGBLOCKS)

ZVox.SimpleVoxel("stone_bricks", ZVOX_MAT_STONE)
ZVox.SimpleVoxelStairs({
	["name"] = "stone_bricks_stair",
	["tex"] = "zvox:stone_bricks",
	["sound"] = ZVOX_MAT_STONE,
})

ZVox.SimpleVoxelSlab({
	["name"] = "stone_bricks_slab",
	["tex"] = "zvox:stone_bricks",
	["sound"] = ZVOX_MAT_STONE,
	["voxelstateparams"] = {
		["solidName"] = "zvox:stone_bricks",
	},
})

ZVox.SimpleVoxel("etherealstone_bricks", ZVOX_MAT_ETHEREALSTONE)
ZVox.SimpleVoxelStairs({
	["name"] = "etherealstone_bricks_stair",
	["tex"] = "zvox:etherealstone_bricks",
	["sound"] = ZVOX_MAT_ETHEREALSTONE,
})

ZVox.SimpleVoxelSlab({
	["name"] = "etherealstone_bricks_slab",
	["tex"] = "zvox:etherealstone_bricks",
	["sound"] = ZVOX_MAT_ETHEREALSTONE,
	["voxelstateparams"] = {
		["solidName"] = "zvox:etherealstone_bricks",
	},
})

ZVox.SimpleVoxelLogRot({
	["name"] = "pillar",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:pillar", -- +X
		[2] = "zvox:pillar", -- -X
		[3] = "zvox:pillar", -- +Y
		[4] = "zvox:pillar", -- -Y
		[5] = "zvox:pillar_top", -- +Z
		[6] = "zvox:pillar_top", -- -Z
	},
	["tex"] = "zvox:pillar",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
})



ZVox.SimpleVoxelSlab({
	["name"] = "pillar_slab",
	["multitex"] = {
		[1] = "zvox:pillar", -- +X
		[2] = "zvox:pillar", -- -X
		[3] = "zvox:pillar", -- +Y
		[4] = "zvox:pillar", -- -Y
		[5] = "zvox:pillar_top", -- +Z
		[6] = "zvox:pillar_top", -- -Z
	},
	["tex"] = "zvox:pillar",
	["sound"] = ZVOX_MAT_STONE,
	["voxelstateparams"] = {
		["solidName"] = "zvox:pillar",
	},
})

ZVox.SimpleVoxel("bricks", ZVOX_MAT_STONE)
ZVox.SimpleVoxel("brown_bricks", ZVOX_MAT_STONE)

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)

ZVox.SimpleVoxel("marble", ZVOX_MAT_STONE)