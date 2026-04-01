ZVox = ZVox or {}

-- t0 = 10
-- t1 = 15
-- t2 = 25
-- t3 = 40
-- t4 = 60
-- t5 = 100
-- t6 = 150
local maxFuelTierLUT = {
	[0] = 10,
	[1] = 15,
	[2] = 25,
	[3] = 40,
	[4] = 60,
	[5] = 100,
	[6] = 150,
}

function ZVox.Upgrades_GetMaxFuelLevel()
	return maxFuelTierLUT[ZVox.Upgrades_GetPartLevel(MV_PART_FUEL_TANK)] or 10
end