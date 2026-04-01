ZVox = ZVox or {}

-- returns if we should place on the block we hit rather than we hit + hitnormal
local function placeOverrideFunc(selfID)
	local eyeTrace = ZVox.GetEyeTrace()
	local hitID = eyeTrace.VoxelID

	if selfID ~= hitID then
		return false
	end

	local hitState = eyeTrace.VoxelState
	local normZ = eyeTrace.Normal[3]

	if math.abs(normZ) < .1 then
		return false
	end


	if normZ < -.8 and hitState == VOXELSTATE_SLAB_LOWER then
		return false
	end

	if normZ > .8 and hitState == VOXELSTATE_SLAB_UPPER then
		return false
	end

	local solidName = ZVox.GetVoxelStateParam(selfID, "solidName") or "zvox:error"

	return true, solidName
end

-- TODO: rename this shit to a proper name=
local function placeOverrideReplacerFunc(selfID, selfState, targetID, targetState)
	if selfID ~= targetID then
		return false
	end

	if targetState == selfState then
		return false
	end

	local solidName = ZVox.GetVoxelStateParam(selfID, "solidName") or "zvox:error"
	return true, solidName
end



local function placeFunc(x, y, z)
	local eyeTrace = ZVox.GetEyeTrace()

	local normZ = eyeTrace.Normal[3]

	if math.abs(normZ) > .1 then
		if normZ > .5 then
			return VOXELSTATE_SLAB_LOWER
		end
		if normZ < -.5 then
			return VOXELSTATE_SLAB_UPPER
		end
	end


	local hitZ = eyeTrace.HitPos[3]
	local zFract = hitZ - math.floor(hitZ)

	if zFract > .5 then
		return VOXELSTATE_SLAB_UPPER
	else
		return VOXELSTATE_SLAB_LOWER
	end
end

ZVox.DeclareVoxelStateTypeOperator(VOXELSTATE_TYPE_SLAB, {
	["placeOverrideFunc"] = placeOverrideFunc,
	["placeOverrideReplacerFunc"] = placeOverrideReplacerFunc,
	["placeFunc"] = placeFunc,
})