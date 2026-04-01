ZVox = ZVox or {}

local _voxelGroupMaterialLUT = {}
function ZVox.SetVoxelGroupMaterial(group, mat)
	_voxelGroupMaterialLUT[group] = mat
end

function ZVox.GetVoxelGroupMaterialLUT()
	return _voxelGroupMaterialLUT
end


local voxelGroupDoCullingLUT = {}
function ZVox.SetVoxelGroupDoCulling(group, doCull)
	voxelGroupDoCullingLUT[group] = doCull and true or false
end

function ZVox.GetVoxelGroupNoCullLUT()
	return voxelGroupDoCullingLUT
end

local voxelGroupOpaqueLUT = {}
function ZVox.SetVoxelGroupOpaque(group, isOpaque)
	voxelGroupOpaqueLUT[group] = isOpaque and true or false
end

function ZVox.GetVoxelGroupOpaqueLUT()
	return voxelGroupOpaqueLUT
end


ZVox.SetVoxelGroupMaterial(ZVOX_VOXELGROUP_SOLID, ZVox.GetTextureAtlasMat())
ZVox.SetVoxelGroupDoCulling(ZVOX_VOXELGROUP_SOLID, true)
ZVox.SetVoxelGroupOpaque(ZVOX_VOXELGROUP_SOLID, true)

ZVox.SetVoxelGroupMaterial(ZVOX_VOXELGROUP_BINARY_TRANSPARENCY, ZVox.GetTextureAtlasMatAlphaTest())
ZVox.SetVoxelGroupDoCulling(ZVOX_VOXELGROUP_BINARY_TRANSPARENCY, false)

ZVox.SetVoxelGroupMaterial(ZVOX_VOXELGROUP_TRANSLUCENT, ZVox.GetTextureAtlasMat())
ZVox.SetVoxelGroupDoCulling(ZVOX_VOXELGROUP_TRANSLUCENT, true)

ZVox.SetVoxelGroupMaterial(ZVOX_VOXELGROUP_WATER, ZVox.GetTextureAtlasMat())
ZVox.SetVoxelGroupDoCulling(ZVOX_VOXELGROUP_WATER, true)



ZVox.NewSettingListener("zvox_internal_voxelgroup2_selfculling", "graphics_fast_leaves", function(newState)
	ZVox.SetVoxelGroupDoCulling(ZVOX_VOXELGROUP_BINARY_TRANSPARENCY, newState)

	-- Gah, laggy.
	--if ZVox.GetActiveUniverse() then
	--	ZVox.RemeshUniv(ZVox.GetActiveUniverse(), true)
	--end
end)
