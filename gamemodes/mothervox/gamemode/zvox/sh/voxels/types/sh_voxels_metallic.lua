ZVox = ZVox or {}

ZVox.PushVoxelCategory(ZVOX_VOXELCATEGORY_METALLIC)
local function newMetalBlockVoxel(name)
	ZVox.NewVoxel({
		["name"] = name,
		["visible"] = true,
		["solid"] = true,
		["multitex"] = {
			[1] = "zvox:" .. name .. "_side"  , -- +X
			[2] = "zvox:" .. name .. "_side"  , -- -X
			[3] = "zvox:" .. name .. "_side"  , -- +Y
			[4] = "zvox:" .. name .. "_side"  , -- -Y
			[5] = "zvox:" .. name .. "_top"   , -- +Z
			[6] = "zvox:" .. name .. "_bottom", -- -Z
		},
		["tex"] = "zvox:" .. name .. "_side",
		["voxelgroup"] = ZVOX_VOXELGROUP_SOLID,
		["sound"] = ZVOX_MAT_METAL,
		["voxelmodel"] = "zvox:cube_dir",
	})
end

newMetalBlockVoxel("gold")
newMetalBlockVoxel("metal")
newMetalBlockVoxel("steel")
newMetalBlockVoxel("diamond")
newMetalBlockVoxel("voidinium")
newMetalBlockVoxel("uranium")
newMetalBlockVoxel("osmium")
-- ADD OSMIUM


ZVox.SimpleVoxel("gold_casing", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("metal_casing", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("steel_casing", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("diamond_casing", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("voidinium_casing", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("uranium_casing", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("osmium_casing", ZVOX_MAT_METAL)


ZVox.SimpleVoxel("metal_sheetmetal", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("steel_sheetmetal", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("gold_sheetmetal", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("copper_sheetmetal", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("oxidized_copper_sheetmetal", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("uranium_sheetmetal", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("voidinium_sheetmetal", ZVOX_MAT_METAL)
ZVox.SimpleVoxel("osmium_sheetmetal", ZVOX_MAT_METAL)


ZVox.SimpleVoxel("metal_frame", ZVOX_MAT_METAL, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)
ZVox.SimpleVoxel("steel_frame", ZVOX_MAT_METAL, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)
ZVox.SimpleVoxel("gold_frame", ZVOX_MAT_METAL, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)
ZVox.SimpleVoxel("copper_frame", ZVOX_MAT_METAL, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)
ZVox.SimpleVoxel("oxidized_copper_frame", ZVOX_MAT_METAL, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)
ZVox.SimpleVoxel("uranium_frame", ZVOX_MAT_METAL, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)
ZVox.SimpleVoxel("voidinium_frame", ZVOX_MAT_METAL, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)
ZVox.SimpleVoxel("osmium_frame", ZVOX_MAT_METAL, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)
