ZVox = ZVox or {}

local scannerRangeLUT = {
	[0] = 2,
	[1] = 3,
	[2] = 3,
	[3] = 4,
	[4] = 5,
	[5] = 7,
}
function ZVox.Upgrades_GetScannerRange()
	return scannerRangeLUT[ZVox.Upgrades_GetPartLevel(MV_PART_SENSOR)] or 2
end

local scannerIntervalLUT = {
	[0] = 1,
	[1] = 1,
	[2] = 2,
	[3] = 2,
	[4] = 4,
	[5] = 4,
}
function ZVox.Upgrades_GetScannerInterval()
	return scannerIntervalLUT[ZVox.Upgrades_GetPartLevel(MV_PART_SENSOR)] or 1
end