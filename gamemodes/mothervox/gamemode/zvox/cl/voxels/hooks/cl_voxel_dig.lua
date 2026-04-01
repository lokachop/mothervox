ZVox = ZVox or {}

local onDigRegistry = {}
function ZVox.GetVoxelOnDigRegistry()
	return onDigRegistry

end

function ZVox.SetVoxelOnDig(voxName, func)
	onDigRegistry[voxName] = func
end


ZVox.DugBlocksTotal = ZVox.DugBlocksTotal or 0
function ZVox.CallVoxelOnDig(voxName)
	ZVox.DugBlocksTotal = ZVox.DugBlocksTotal + 1

	local funcGet = onDigRegistry[voxName]
	if not funcGet then
		return false
	end

	return funcGet()
end