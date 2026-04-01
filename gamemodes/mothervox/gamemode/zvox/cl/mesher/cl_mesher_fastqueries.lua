ZVox = ZVox or {}

local math = math
local math_floor = math.floor

local _lastUniv = nil
function ZVox.FastQuery_SetUniverse(univ)
	if _lastUniv == univ then
		return
	end

	_lastUniv = univ
end


local _voxelGroupLUT = {}
function ZVox.FastQuery_GetVoxelGroupLUT()
	return _voxelGroupLUT
end

local _voxelOpaqueLUT = {}
function ZVox.FastQuery_GetVoxelOpaqueLUT()
	return _voxelOpaqueLUT
end

local _voxelModelTableLUT = {}
function ZVox.FastQuery_GetVoxelModelTableLUT()
	return _voxelModelTableLUT
end

local _voxelModelLUT = {}
function ZVox.FastQuery_GetVoxelModelLUT()
	return _voxelModelLUT
end


function ZVox.FastQuery_RecomputeLUTs()
	local voxelList = ZVox.GetVoxelRegistry()
	for i = 0, ZVox.GetVoxelCount() do
		local voxData = voxelList[i]

		_voxelGroupLUT[i] = voxData.voxelgroup
		_voxelOpaqueLUT[i] = voxData.opaque
		_voxelModelTableLUT[i] = voxData.voxelmodeltable
		_voxelModelLUT[i] = voxData.voxelmodel
	end
end

ZVox.FastQuery_RecomputeLUTs()