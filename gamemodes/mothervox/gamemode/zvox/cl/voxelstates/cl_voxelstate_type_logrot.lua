ZVox = ZVox or {}

local function placeFunc()
	local eyeTrace = ZVox.GetEyeTrace()
	local norm = eyeTrace.Normal

	if math.abs(norm[1]) > 0 then
		return VOXELSTATE_LOGROT_X
	elseif math.abs(norm[2]) > 0 then
		return VOXELSTATE_LOGROT_Y
	else
		return VOXELSTATE_LOGROT_Z
	end


	return 0x0
end

ZVox.DeclareVoxelStateTypeOperator(VOXELSTATE_TYPE_LOGROT, {
	["placeFunc"] = placeFunc,
})