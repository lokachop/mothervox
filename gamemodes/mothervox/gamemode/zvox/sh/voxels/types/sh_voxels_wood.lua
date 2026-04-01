ZVox = ZVox or {}

-- oak
ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)
ZVox.SimpleVoxelLogRot({
	["name"] = "oak_log",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:oak_log", -- +X
		[2] = "zvox:oak_log", -- -X
		[3] = "zvox:oak_log", -- +Y
		[4] = "zvox:oak_log", -- -Y
		[5] = "zvox:oak_log_top", -- +Z
		[6] = "zvox:oak_log_top", -- -Z
	},
	["tex"] = "zvox:oak_log",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["sound"] = ZVOX_MAT_WOOD,
})

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_BUILDINGBLOCKS)
ZVox.SimpleVoxel("oak_planks", ZVOX_MAT_WOOD)

ZVox.SimpleVoxelSlab({
	["name"] = "oak_planks_slab",
	["tex"] = "zvox:oak_planks",
	["sound"] = ZVOX_MAT_WOOD,
	["voxelstateparams"] = {
		["solidName"] = "zvox:oak_planks",
	},
})

ZVox.SimpleVoxelStairs({
	["name"] = "oak_planks_stair",
	["tex"] = "zvox:oak_planks",
	["sound"] = ZVOX_MAT_WOOD,
})

-- birch
ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)
ZVox.SimpleVoxelLogRot({
	["name"] = "birch_log",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:birch_log", -- +X
		[2] = "zvox:birch_log", -- -X
		[3] = "zvox:birch_log", -- +Y
		[4] = "zvox:birch_log", -- -Y
		[5] = "zvox:birch_log_top", -- +Z
		[6] = "zvox:birch_log_top", -- -Z
	},
	["tex"] = "zvox:birch_log",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["sound"] = ZVOX_MAT_WOOD,
})

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_BUILDINGBLOCKS)
ZVox.SimpleVoxel("birch_planks", ZVOX_MAT_WOOD)

ZVox.SimpleVoxelSlab({
	["name"] = "birch_planks_slab",
	["tex"] = "zvox:birch_planks",
	["sound"] = ZVOX_MAT_WOOD,
	["voxelstateparams"] = {
		["solidName"] = "zvox:birch_planks",
	},
})

ZVox.SimpleVoxelStairs({
	["name"] = "birch_planks_stair",
	["tex"] = "zvox:birch_planks",
	["sound"] = ZVOX_MAT_WOOD,
})

-- pine
ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)
ZVox.SimpleVoxelLogRot({
	["name"] = "pine_log",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:pine_log", -- +X
		[2] = "zvox:pine_log", -- -X
		[3] = "zvox:pine_log", -- +Y
		[4] = "zvox:pine_log", -- -Y
		[5] = "zvox:pine_log_top", -- +Z
		[6] = "zvox:pine_log_top", -- -Z
	},
	["tex"] = "zvox:pine_log",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["sound"] = ZVOX_MAT_WOOD,
})

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_BUILDINGBLOCKS)
ZVox.SimpleVoxel("pine_planks", ZVOX_MAT_WOOD)

ZVox.SimpleVoxelSlab({
	["name"] = "pine_planks_slab",
	["tex"] = "zvox:pine_planks",
	["sound"] = ZVOX_MAT_WOOD,
	["voxelstateparams"] = {
		["solidName"] = "zvox:pine_planks",
	},
})

ZVox.SimpleVoxelStairs({
	["name"] = "pine_planks_stair",
	["tex"] = "zvox:pine_planks",
	["sound"] = ZVOX_MAT_WOOD,
})

-- mintwood
ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)
ZVox.SimpleVoxelLogRot({
	["name"] = "mintwood_log",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:mintwood_log", -- +X
		[2] = "zvox:mintwood_log", -- -X
		[3] = "zvox:mintwood_log", -- +Y
		[4] = "zvox:mintwood_log", -- -Y
		[5] = "zvox:mintwood_log_top", -- +Z
		[6] = "zvox:mintwood_log_top", -- -Z
	},
	["tex"] = "zvox:mintwood_log",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["sound"] = ZVOX_MAT_WOOD,
})

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_BUILDINGBLOCKS)
ZVox.SimpleVoxel("mintwood_planks", ZVOX_MAT_WOOD)

ZVox.SimpleVoxelSlab({
	["name"] = "mintwood_planks_slab",
	["tex"] = "zvox:mintwood_planks",
	["sound"] = ZVOX_MAT_WOOD,
	["voxelstateparams"] = {
		["solidName"] = "zvox:mintwood_planks",
	},
})

ZVox.SimpleVoxelStairs({
	["name"] = "mintwood_planks_stair",
	["tex"] = "zvox:mintwood_planks",
	["sound"] = ZVOX_MAT_WOOD,
})

-- crimwood
ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)
ZVox.SimpleVoxelLogRot({
	["name"] = "crimwood_log",
	["visible"] = true,
	["solid"] = true,
	["multitex"] = {
		[1] = "zvox:crimwood_log", -- +X
		[2] = "zvox:crimwood_log", -- -X
		[3] = "zvox:crimwood_log", -- +Y
		[4] = "zvox:crimwood_log", -- -Y
		[5] = "zvox:crimwood_log_top", -- +Z
		[6] = "zvox:crimwood_log_top", -- -Z
	},
	["tex"] = "zvox:crimwood_log",
	["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
	["sound"] = ZVOX_MAT_WOOD,
})

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_BUILDINGBLOCKS)
ZVox.SimpleVoxel("crimwood_planks", ZVOX_MAT_WOOD)

ZVox.SimpleVoxelSlab({
	["name"] = "crimwood_planks_slab",
	["tex"] = "zvox:crimwood_planks",
	["sound"] = ZVOX_MAT_WOOD,
	["voxelstateparams"] = {
		["solidName"] = "zvox:crimwood_planks",
	},
})

ZVox.SimpleVoxelStairs({
	["name"] = "crimwood_planks_stair",
	["tex"] = "zvox:crimwood_planks",
	["sound"] = ZVOX_MAT_WOOD,
})


ZVox.SimpleVoxel("crate", ZVOX_MAT_WOOD)