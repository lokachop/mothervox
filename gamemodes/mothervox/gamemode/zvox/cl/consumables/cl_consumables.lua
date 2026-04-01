ZVox = ZVox or {}

ZVox.ExplodedBlocksTotal = ZVox.ExplodedBlocksTotal or 0
ZVox.ExplodedMineralsTotal = ZVox.ExplodedMineralsTotal or 0

local nullMat = Material("mothervox/icon/part/null.png", "nocull ignorez")
local consumableData = {
	[MV_CONSUMABLE_FUEL_TANK] = {
		["name"] = "Reserve Fuel Tank",
		["cost"] = 2000,
		["keybind"] = "item_fuel_tank",
		["desc"] = "<32,195,28>Portable backup -\n<32,195,28>refills up to 25 \n<32,195,28>Liters \n<32,195,28>instantaneously.",
		["icon"] = Material("mothervox/icon/consumable/tank.png", "nocull ignorez"),
	},

	[MV_CONSUMABLE_NANOBOTS] = {
		["name"] = "Hull Repair Nanobots",
		["cost"] = 7500,
		["keybind"] = "item_nanobots",
		["desc"] = "<32,195,28>Repairs a maximum of \n<32,195,28>30 Damage anytime, \n<32,195,28>anywhere.",
		["icon"] = Material("mothervox/icon/consumable/nanobots.png", "nocull ignorez"),
	},

	[MV_CONSUMABLE_DYNAMITE] = {
		["name"] = "Dynamite",
		["cost"] = 2000,
		["keybind"] = "item_dynamite",
		["desc"] = "<32,195,28>Blasts clear a small\n<32,195,28>area around your pod.",
		["icon"] = Material("mothervox/icon/consumable/dynamite.png", "nocull ignorez"),
	},

	[MV_CONSUMABLE_C4] = {
		["name"] = "Plastic Explosives",
		["cost"] = 5000,
		["keybind"] = "item_c4",
		["desc"] = "<32,195,28>Creates an enormous\n<32,195,28>explosion, clearing a\n<32,195,28>large area around\n<32,195,28>your pod.",
		["icon"] = Material("mothervox/icon/consumable/c4.png", "nocull ignorez"),
	},

	[MV_CONSUMABLE_QUANTUM_TELE] = {
		["name"] = "Quantum Teleporter",
		["cost"] = 2000,
		["keybind"] = "item_quantum_tele",
		["desc"] = "<32,195,28>Teleports you \n<32,195,28>somewhere above \n<32,195,28>surface level. \n<32,195,28>(results may vary)",
		["icon"] = Material("mothervox/icon/consumable/quantum_tele.png", "nocull ignorez"),
	},

	[MV_CONSUMABLE_MATTER_TRANSMITTER] = {
		["name"] = "Matter Transmitter",
		["cost"] = 10000,
		["keybind"] = "item_matter_transmitter",
		["desc"] = "<32,195,28>Safely and accurately \n<32,195,28>returns you above \n<32,195,28>ground.",
		["icon"] = Material("mothervox/icon/consumable/matter_trans.png", "nocull ignorez"),
	},
}

ZVox.CurrentConsumables = ZVox.CurrentConsumables or {
	[MV_CONSUMABLE_FUEL_TANK] = 0,
	[MV_CONSUMABLE_NANOBOTS] = 0,
	[MV_CONSUMABLE_DYNAMITE] = 0,
	[MV_CONSUMABLE_C4] = 0,
	[MV_CONSUMABLE_QUANTUM_TELE] = 0,
	[MV_CONSUMABLE_MATTER_TRANSMITTER] = 0,
}

function ZVox.Consumable_AddConsumable(id, count)
	if not id then
		return
	end

	count = count or 1

	local currCount = ZVox.CurrentConsumables[id]
	if not currCount then
		return
	end

	ZVox.CurrentConsumables[id] = currCount + count
end

function ZVox.Consumable_SetConsumableCount(id, count)
	ZVox.CurrentConsumables[id] = count
end

function ZVox.Consumable_SpendConsumable(id)
	if not id then
		return false
	end

	local currCount = ZVox.CurrentConsumables[id]
	if not currCount then
		return false
	end

	if currCount <= 0 then
		return false
	end

	ZVox.CurrentConsumables[id] = math.max(currCount - 1, 0)

	return true
end

function ZVox.Consumable_GetCurrentCount(id)
	if not id then
		return 0
	end

	return ZVox.CurrentConsumables[id] or 0
end

function ZVox.Consumable_GetName(id)
	if not id then
		return "Invalid ID."
	end

	local entry = consumableData[id]
	if not entry then
		return "I Dunno =/"
	end

	return entry.name or "No name? =|"
end

function ZVox.Consumable_GetCost(id)
	if not id then
		return 0
	end

	local entry = consumableData[id]
	if not entry then
		return 0
	end

	return entry.cost or 0
end

function ZVox.Consumable_GetKeybind(id)
	if not id then
		return "invalid_keybind_bad"
	end

	local entry = consumableData[id]
	if not entry then
		return "invalid_keybind_bad"
	end

	return entry.keybind or "invalid_keybind_bad"
end

function ZVox.Consumable_GetDescription(id)
	if not id then
		return "<255,0,0>The ID is null."
	end

	local entry = consumableData[id]
	if not entry then
		return "<255,0,0>The consumable <0,0,255>#" .. tostring(id) .. " \n<255,0,0>Doesn't exist."
	end

	return entry.desc or "<255,128,0>Guh?... =("
end

function ZVox.Consumable_GetIcon(id)
	if not id then
		return nullMat
	end

	local entry = consumableData[id]
	if not entry then
		return nullMat
	end

	return entry.icon or nullMat
end