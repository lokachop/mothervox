ZVox = ZVox or {}

-- this file's a fucking mess
-- yes i should restructure the parts to be a table with all of the relevant info rather than 5000 LUTs
-- no i don't have enough time it is 25/03/2026 and i want testing going by the weekend
-- the ending isn't even fucking done yet
-- and i have a fuckass html/css exam tomorrow
-- i'll take charge of this entire situation.
-- god damn it.
-- good news the html/css exam went well

local maxPartLevels = {
	[MV_PART_DRILL] = 6,
	[MV_PART_HULL] = 6,
	[MV_PART_ENGINE] = 6,
	[MV_PART_FUEL_TANK] = 6,
	[MV_PART_RADIATOR] = 5,
	[MV_PART_STORAGE_BAY] = 5,
	[MV_PART_SENSOR	] = 5,
}
function ZVox.Upgrades_GetMaxLevelForPart(part)
	return maxPartLevels[part] or 0
end


ZVox.CurrentPartLevels = ZVox.CurrentPartLevels or {
	[MV_PART_DRILL] = 0,
	[MV_PART_HULL] = 0,
	[MV_PART_ENGINE] = 0,
	[MV_PART_FUEL_TANK] = 0,
	[MV_PART_RADIATOR] = 0,
	[MV_PART_STORAGE_BAY] = 0,
	[MV_PART_SENSOR] = 0,
}

function ZVox.Upgrades_GetPartLevel(part)
	return ZVox.CurrentPartLevels[part]
end

function ZVox.Upgrades_SetPartLevel(part, lvl)
	if not ZVox.CurrentPartLevels[part] then
		return
	end

	ZVox.CurrentPartLevels[part] = lvl
end

function ZVox.Upgrades_UpgradePart(part, lvl)
	local max = ZVox.Upgrades_GetMaxLevelForPart(part)
	if lvl > max then
		return false
	end

	local currLevel = ZVox.Upgrades_GetPartLevel(part)
	if currLevel >= lvl then
		return false
	end
	ZVox.CurrentPartLevels[part] = lvl

	-- certain parts need to do stuff
	if part == MV_PART_HULL then
		ZVox.Health_SetHealth(ZVox.Upgrades_GetMaxHullHealth())
	elseif part == MV_PART_FUEL_TANK then
		ZVox.Fuel_SetFuel(ZVox.Upgrades_GetMaxFuelLevel())
	end


	return true
end

-- parts being
local partNameLUT = {
	[MV_PART_DRILL] = {
		[0] = "Stock Drill",
		[1] = "Silver Drill",
		[2] = "Gold Drill",
		[3] = "Depleted Uranium Drill",
		[4] = "Diamond Drill",
		[5] = "Voidinium Drill",
		[6] = "Temporalium Drill",
	},

	[MV_PART_HULL] = {
		[0] = "Stock Hull",
		[1] = "Copper Hull",
		[2] = "Iron Hull",
		[3] = "Silver Hull",
		[4] = "Diamond Hull",
		[5] = "Voidinium Hull",
		[6] = "Energy-Temporalium Hull",
	},

	[MV_PART_ENGINE] = {
		[0] = "Stock Engine",
		[1] = "Improved Engine",
		[2] = "Boosted Engine",
		[3] = "Turbo Boosted Engine",
		[4] = "Sports Engine",
		[5] = "Voidinium Engine",
		[6] = "V16 Jag Engine",
	},

	[MV_PART_FUEL_TANK] = {
		[0] = "Stock Tank",
		[1] = "Dual Tank",
		[2] = "Triple Tank",
		[3] = "Gigantic Tank",
		[4] = "Titanic Tank",
		[5] = "Cryo Compression Tank",
		[6] = "Bluespace Compression Tank",
	},

	[MV_PART_RADIATOR] = {
		[0] = "Stock Fan",
		[1] = "Improved Fan",
		[2] = "Dual Fans",
		[3] = "Single Turbine",
		[4] = "Dual Turbines",
		[5] = "Cryokinesis Turbine",
	},

	[MV_PART_STORAGE_BAY] = {
		[0] = "Stock Bay",
		[1] = "Medium Bay",
		[2] = "Huge Bay",
		[3] = "Gigantic Bay",
		[4] = "Titanic Bay",
		[5] = "Dimensional Pocket Bay",
	},

	[MV_PART_SENSOR] = {
		[0] = "Stock Scanner",
		[1] = "Enhanced Scanner",
		[2] = "Microradium Scanner",
		[3] = "Tuned Scanner",
		[4] = "Voidinium-Doped Scanner",
		[5] = "Temporalium Scanner Array",
	}
}
function ZVox.Upgrades_GetPartName(part, tier)
	if not partNameLUT[part] then
		return "Unknown Part?"
	end

	return partNameLUT[part][tier] or "Unknown Part?"
end

local partCosts = {
	[0] = 0,
	[1] = 750,
	[2] = 2000,
	[3] = 5000,
	[4] = 20000,
	[5] = 100000,
	[6] = 500000,
}
function ZVox.Upgrades_GetCostForPartLevel(level)
	return partCosts[level] or 0
end

local partDescLUT = {
	[MV_PART_DRILL] = {
		[0] = "20 ft/s",
		[1] = "28 ft/s",
		[2] = "40 ft/s",
		[3] = "50 ft/s",
		[4] = "70 ft/s",
		[5] = "95 ft/s",
		[6] = "120 ft/s",
	},

	[MV_PART_HULL] = {
		[0] = "10 Health",
		[1] = "17 Health",
		[2] = "30 Health",
		[3] = "50 Health",
		[4] = "80 Health",
		[5] = "120 Health",
		[6] = "180 Health",
	},

	[MV_PART_ENGINE] = {
		[0] = "150 HorsePower",
		[1] = "160 HorsePower",
		[2] = "170 HorsePower",
		[3] = "180 HorsePower",
		[4] = "190 HorsePower",
		[5] = "200 HorsePower",
		[6] = "210 HorsePower",
	},

	[MV_PART_FUEL_TANK] = {
		[0] = "10 Liters",
		[1] = "15 Liters",
		[2] = "25 Liters",
		[3] = "40 Liters",
		[4] = "60 Liters",
		[5] = "100 Liters",
		[6] = "150 Liters",
	},

	[MV_PART_RADIATOR] = {
		[0] = "5% Effective",
		[1] = "10% Effective",
		[2] = "25% Effective",
		[3] = "40% Effective",
		[4] = "60% Effective",
		[5] = "80% Effective",
	},

	[MV_PART_STORAGE_BAY] = {
		[0] = "10 Cu ft.",
		[1] = "15 Cu ft.",
		[2] = "25 Cu ft.",
		[3] = "40 Cu ft.",
		[4] = "70 Cu ft.",
		[5] = "120 Cu ft.",
	},

	[MV_PART_SENSOR] = {
		[0] = "2 range, 1 / s",
		[1] = "3 range, 1 / s",
		[2] = "3 range, 2 / s",
		[3] = "4 range, 2 / s",
		[4] = "5 range, 4 / s",
		[5] = "7 range, 4 / s",
	}
}
function ZVox.Upgrades_GetPartDesc(part, tier)
	if not partDescLUT[part] then
		return "N/A?"
	end

	return partDescLUT[part][tier] or "N/A?"
end

local nullMat = Material("mothervox/icon/part/null.png", "nocull ignorez")

local partIconLUT = {
	[MV_PART_DRILL] = {
		[0] = Material("mothervox/icon/part/drill/t0.png", "nocull ignorez"),
		[1] = Material("mothervox/icon/part/drill/t1.png", "nocull ignorez"),
		[2] = Material("mothervox/icon/part/drill/t2.png", "nocull ignorez"),
		[3] = Material("mothervox/icon/part/drill/t3.png", "nocull ignorez"),
		[4] = Material("mothervox/icon/part/drill/t4.png", "nocull ignorez"),
		[5] = Material("mothervox/icon/part/drill/t5.png", "nocull ignorez"),
		[6] = Material("mothervox/icon/part/drill/t6.png", "nocull ignorez"),
	},

	[MV_PART_HULL] = {
		[0] = Material("mothervox/icon/part/hull/t0.png", "nocull ignorez"),
		[1] = Material("mothervox/icon/part/hull/t1.png", "nocull ignorez"),
		[2] = Material("mothervox/icon/part/hull/t2.png", "nocull ignorez"),
		[3] = Material("mothervox/icon/part/hull/t3.png", "nocull ignorez"),
		[4] = Material("mothervox/icon/part/hull/t4.png", "nocull ignorez"),
		[5] = Material("mothervox/icon/part/hull/t5.png", "nocull ignorez"),
		[6] = Material("mothervox/icon/part/hull/t6.png", "nocull ignorez"),
	},

	[MV_PART_ENGINE] = {
		[0] = Material("mothervox/icon/part/engine/t0.png", "nocull ignorez"),
		[1] = Material("mothervox/icon/part/engine/t1.png", "nocull ignorez"),
		[2] = Material("mothervox/icon/part/engine/t2.png", "nocull ignorez"),
		[3] = Material("mothervox/icon/part/engine/t3.png", "nocull ignorez"),
		[4] = Material("mothervox/icon/part/engine/t4.png", "nocull ignorez"),
		[5] = Material("mothervox/icon/part/engine/t5.png", "nocull ignorez"),
		[6] = Material("mothervox/icon/part/engine/t6.png", "nocull ignorez"),
	},

	[MV_PART_FUEL_TANK] = {
		[0] = Material("mothervox/icon/part/fueltank/t0.png", "nocull ignorez"),
		[1] = Material("mothervox/icon/part/fueltank/t1.png", "nocull ignorez"),
		[2] = Material("mothervox/icon/part/fueltank/t2.png", "nocull ignorez"),
		[3] = Material("mothervox/icon/part/fueltank/t3.png", "nocull ignorez"),
		[4] = Material("mothervox/icon/part/fueltank/t4.png", "nocull ignorez"),
		[5] = Material("mothervox/icon/part/fueltank/t5.png", "nocull ignorez"),
		[6] = Material("mothervox/icon/part/fueltank/t6.png", "nocull ignorez"),
	},

	[MV_PART_RADIATOR] = {
		[0] = Material("mothervox/icon/part/radiator/t0.png", "nocull ignorez"),
		[1] = Material("mothervox/icon/part/radiator/t1.png", "nocull ignorez"),
		[2] = Material("mothervox/icon/part/radiator/t2.png", "nocull ignorez"),
		[3] = Material("mothervox/icon/part/radiator/t3.png", "nocull ignorez"),
		[4] = Material("mothervox/icon/part/radiator/t4.png", "nocull ignorez"),
		[5] = Material("mothervox/icon/part/radiator/t5.png", "nocull ignorez"),
	},

	[MV_PART_STORAGE_BAY] = {
		[0] = Material("mothervox/icon/part/storage_bay/t0.png", "nocull ignorez"),
		[1] = Material("mothervox/icon/part/storage_bay/t1.png", "nocull ignorez"),
		[2] = Material("mothervox/icon/part/storage_bay/t2.png", "nocull ignorez"),
		[3] = Material("mothervox/icon/part/storage_bay/t3.png", "nocull ignorez"),
		[4] = Material("mothervox/icon/part/storage_bay/t4.png", "nocull ignorez"),
		[5] = Material("mothervox/icon/part/storage_bay/t5.png", "nocull ignorez"),
	},

	[MV_PART_SENSOR] = {
		[0] = Material("mothervox/icon/part/sensor/t0.png", "nocull ignorez"),
		[1] = Material("mothervox/icon/part/sensor/t1.png", "nocull ignorez"),
		[2] = Material("mothervox/icon/part/sensor/t2.png", "nocull ignorez"),
		[3] = Material("mothervox/icon/part/sensor/t3.png", "nocull ignorez"),
		[4] = Material("mothervox/icon/part/sensor/t4.png", "nocull ignorez"),
		[5] = Material("mothervox/icon/part/sensor/t5.png", "nocull ignorez"),
	}
}
function ZVox.Upgrades_GetPartIcon(part, tier)
	if not partIconLUT[part] then
		return nullMat
	end

	return partIconLUT[part][tier] or nullMat
end