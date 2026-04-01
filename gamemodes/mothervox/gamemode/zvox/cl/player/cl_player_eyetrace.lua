ZVox = ZVox or {}

local _eyeTrace = {
	["Hit"]  = false,
	["Side"] = 0,
	["Dist"] = 0,
	["HitPos"] = Vector(0, 0, 0),
	["Normal"] = Vector(0, 0, 0),
	["VoxelID"] = 1,
	["HitMapPos"] = Vector(0, 0, 0),
}


local eyeTraceTemp = Vector()
function ZVox.ComputeEyeTrace()
	local dir = LocalPlayer():GetAimVector()
	local steps = 96
	eyeTraceTemp:Set(ZVox.GetPlayerInterpolatedCamera())
	_eyeTrace = ZVox.RaycastWorld(ZVox.GetActiveUniverse(), eyeTraceTemp, dir, steps, false, ZVOX_COLLISION_GROUP_ALL_BUT_WATER)
end

function ZVox.GetEyeTrace()
	return _eyeTrace
end