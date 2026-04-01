ZVox = ZVox or {}

local drillSpeedLUT = {
	[0] = 20,
	[1] = 28,
	[2] = 40,
	[3] = 50,
	[4] = 70,
	[5] = 95,
	[6] = 120,
}

-- t0 = 20ft/s
-- t1 = 28ft/s
-- t2 = 40ft/s
-- t3 = 50ft/s
-- t4 = 70ft/s
-- t5 = 95ft/s
-- t6 = 120ft/s
function ZVox.Upgrades_GetDrillTimeWait()
	local currDrillLevel = drillSpeedLUT[ZVox.Upgrades_GetPartLevel(MV_PART_DRILL)]

	return (20 / currDrillLevel) * 0.75
end