ZVox = ZVox or {}

-- t0 = 10
-- t1 = 17
-- t2 = 30
-- t3 = 50
-- t4 = 80
-- t5 = 120
-- t6 = 180
local maxHullHealthLUT = {
	[0] = 10,
	[1] = 17,
	[2] = 30,
	[3] = 50,
	[4] = 80,
	[5] = 120,
	[6] = 180,
}

function ZVox.Upgrades_GetMaxHullHealth()
	return maxHullHealthLUT[ZVox.Upgrades_GetPartLevel(MV_PART_HULL)] or 10
end