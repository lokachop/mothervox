ZVox = ZVox or {}

-- local player place
-- this returns what voxelstate to use
local dirs = {
	[0] = VOXELSTATE_ROTATION_X_PLUS,
	[1] = VOXELSTATE_ROTATION_Y_PLUS,
	[2] = VOXELSTATE_ROTATION_X_MINUS,
	[3] = VOXELSTATE_ROTATION_Y_MINUS,
}

local TEMP_dirsToNames = {
	[VOXELSTATE_ROTATION_X_PLUS] = "VOXELSTATE_ROTATION_X_PLUS",
	[VOXELSTATE_ROTATION_Y_PLUS] = "VOXELSTATE_ROTATION_Y_PLUS",
	[VOXELSTATE_ROTATION_X_MINUS] = "VOXELSTATE_ROTATION_X_MINUS",
	[VOXELSTATE_ROTATION_Y_MINUS] = "VOXELSTATE_ROTATION_Y_MINUS",
}

local function round(x)
	return math.floor(x + .5)
end

local function placeFunc(x, y, z)
	local camDir = LocalPlayer():EyeAngles():Forward()

	local angle = math.deg(math.atan2(camDir[2], camDir[1])) + 180

	angle = angle / 360
	angle = round(angle * 4) % 4

	return dirs[angle]
end

ZVox.DeclareVoxelStateTypeOperator(VOXELSTATE_TYPE_ZROT, {
	["placeFunc"] = placeFunc,
})