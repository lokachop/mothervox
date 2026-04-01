ZVox = ZVox or {}

local onInteractRegistry = {}
function ZVox.GetVoxelOnInteractRegistry()
	return onInteractRegistry
end

function ZVox.SetVoxelOnInteract(voxName, func)
	onInteractRegistry[voxName] = func
end

function ZVox.IsVoxelInteractable(voxName)
	return onInteractRegistry[voxName] ~= nil
end

function ZVox.CallVoxelOnInteract(voxName)
	local funcGet = onInteractRegistry[voxName]
	if not funcGet then
		return false
	end

	return funcGet()
end