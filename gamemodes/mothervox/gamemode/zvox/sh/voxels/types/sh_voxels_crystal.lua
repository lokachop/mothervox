ZVox = ZVox or {}

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_BUILDINGBLOCKS)

local function simpleGlass(name)
	ZVox.NewVoxel({
		["name"] = name,
		["visible"] = true,
		["solid"] = true,
		["multitex"] = false,
		["opaque"] = true,
		["tex"] = ZVox.NAMESPACES_NamespaceConvert(name),
		["voxelgroup"] = ZVOX_VOXELGROUP_TRANSLUCENT,
		["voxelstatetype"] = VOXELSTATE_TYPE_NONE,
		["sound"] = ZVOX_MAT_GLASS,
		["collisiongroup"] = ZVOX_COLLISION_GROUP_GLASS,
	})
end

simpleGlass("glass")
simpleGlass("dark_glass")
simpleGlass("rainbow_glass")
simpleGlass("industrial_glass")
simpleGlass("plasma_glass")
simpleGlass("clear_glass")

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_NATURE)
ZVox.SimpleVoxel("crystal", ZVOX_MAT_GLASS)
ZVox.SimpleVoxelSlab({
	["name"] = "crystal_slab",
	["tex"] = "zvox:crystal",
	["sound"] = ZVOX_MAT_GLASS,
	["voxelstateparams"] = {
		["solidName"] = "zvox:crystal",
	},
})