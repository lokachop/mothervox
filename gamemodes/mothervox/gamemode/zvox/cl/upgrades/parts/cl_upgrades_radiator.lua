ZVox = ZVox or {}


local radiatorMulLUT = {
	[0] = 0.05,
	[1] = 0.10,
	[2] = 0.25,
	[3] = 0.40,
	[4] = 0.60,
	[5] = 0.80
}

function ZVox.Upgrades_GetRadiatorDamageMul()
	local radDelta = radiatorMulLUT[ZVox.Upgrades_GetPartLevel(MV_PART_RADIATOR)]
	return (1 - radDelta)
end