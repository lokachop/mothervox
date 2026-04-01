ZVox = ZVox or {}

local operators = {}
function ZVox.DeclareVoxelStateTypeOperator(voxelstateType, data)
	operators[voxelstateType] = data
end

function ZVox.GetVoxelStateOperatorRegistry()
	return operators
end

function ZVox.CallVoxelStatePlaceOverride(voxelstateType, ID)
	if not operators[voxelstateType] then
		return
	end

	local pFunc = operators[voxelstateType].placeOverrideFunc
	if not pFunc then
		return
	end

	return pFunc(ID)
end

-- TODO: rename this shit
function ZVox.CallVoxelStatePlaceOverrideReplacer(voxelstateType, selfID, selfState, otherID, otherState)
	if not operators[voxelstateType] then
		return
	end

	local pFunc = operators[voxelstateType].placeOverrideReplacerFunc
	if not pFunc then
		return
	end

	return pFunc(selfID, selfState, otherID, otherState)
end

function ZVox.CallVoxelStateOnPlace(voxelstateType, x, y, z)
	if not operators[voxelstateType] then
		return
	end

	local pFunc = operators[voxelstateType].placeFunc
	if not pFunc then
		return
	end

	return pFunc(x, y, z)
end