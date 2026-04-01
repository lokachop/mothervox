ZVox = ZVox or {}

-- t0 = 10 Cu ft. (7 items)
-- t1 = 15 Cu ft.
-- t2 = 25 Cu ft.
-- t3 = 40 Cu ft.
-- t4 = 70 Cu ft.
-- t5 = 120 Cu ft.
local storageLevelLUT = {
	[0] = 10,
	[1] = 15,
	[2] = 25,
	[3] = 40,
	[4] = 70,
	[5] = 120,
}

function ZVox.Upgrades_GetStorageMaxCount()
	return (storageLevelLUT[ZVox.Upgrades_GetPartLevel(MV_PART_STORAGE_BAY)] / 10) * 7
end