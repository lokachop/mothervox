ZVox = ZVox or {}


concommand.Add("zvox_recompute_atlas", function()
	ZVox.RecomputeTextureAtlas()
end)


if ZVOX_DEVMODE then
	concommand.Add("mothervox_debug_give_me_shit", function()
		if not ZVOX_DEVMODE then
			return
		end

		ZVox.Money_GainMoney(5120000)
		ZVox.Fuel_GainFuel(512000)
		ZVox.Health_SetHealth(512000)

		ZVox.Consumable_AddConsumable(MV_CONSUMABLE_C4, 32)
		ZVox.Consumable_AddConsumable(MV_CONSUMABLE_DYNAMITE, 32)
		ZVox.Consumable_AddConsumable(MV_CONSUMABLE_FUEL_TANK, 32)
		ZVox.Consumable_AddConsumable(MV_CONSUMABLE_MATTER_TRANSMITTER, 32)
		ZVox.Consumable_AddConsumable(MV_CONSUMABLE_NANOBOTS, 32)
		ZVox.Consumable_AddConsumable(MV_CONSUMABLE_QUANTUM_TELE, 32)
	end)

	concommand.Add("mothervox_debug_max_me_out", function()
		ZVox.Upgrades_SetPartLevel(MV_PART_DRILL, ZVox.Upgrades_GetMaxLevelForPart(MV_PART_DRILL))
		ZVox.Upgrades_SetPartLevel(MV_PART_HULL, ZVox.Upgrades_GetMaxLevelForPart(MV_PART_HULL))
		ZVox.Upgrades_SetPartLevel(MV_PART_ENGINE, ZVox.Upgrades_GetMaxLevelForPart(MV_PART_ENGINE))
		ZVox.Upgrades_SetPartLevel(MV_PART_FUEL_TANK, ZVox.Upgrades_GetMaxLevelForPart(MV_PART_FUEL_TANK))
		ZVox.Upgrades_SetPartLevel(MV_PART_RADIATOR, ZVox.Upgrades_GetMaxLevelForPart(MV_PART_RADIATOR))
		ZVox.Upgrades_SetPartLevel(MV_PART_STORAGE_BAY, ZVox.Upgrades_GetMaxLevelForPart(MV_PART_STORAGE_BAY))
		ZVox.Upgrades_SetPartLevel(MV_PART_SENSOR, ZVox.Upgrades_GetMaxLevelForPart(MV_PART_SENSOR))

		ZVox.Fuel_GainFuel(512000)
		ZVox.Health_SetHealth(512000)
	end)

	concommand.Add("mothervox_debug_reset_me_out", function()
		ZVox.Upgrades_SetPartLevel(MV_PART_DRILL, 0)
		ZVox.Upgrades_SetPartLevel(MV_PART_HULL, 0)
		ZVox.Upgrades_SetPartLevel(MV_PART_ENGINE, 0)
		ZVox.Upgrades_SetPartLevel(MV_PART_FUEL_TANK, 0)
		ZVox.Upgrades_SetPartLevel(MV_PART_RADIATOR, 0)
		ZVox.Upgrades_SetPartLevel(MV_PART_STORAGE_BAY, 0)
		ZVox.Upgrades_SetPartLevel(MV_PART_SENSOR, 0)


		ZVox.Fuel_GainFuel(512000)
		ZVox.Health_SetHealth(512000)

		ZVox.Consumable_SetConsumableCount(MV_CONSUMABLE_C4, 0)
		ZVox.Consumable_SetConsumableCount(MV_CONSUMABLE_DYNAMITE, 0)
		ZVox.Consumable_SetConsumableCount(MV_CONSUMABLE_FUEL_TANK, 0)
		ZVox.Consumable_SetConsumableCount(MV_CONSUMABLE_MATTER_TRANSMITTER, 0)
		ZVox.Consumable_SetConsumableCount(MV_CONSUMABLE_NANOBOTS, 0)
		ZVox.Consumable_SetConsumableCount(MV_CONSUMABLE_QUANTUM_TELE, 0)
		ZVox.Money_SetMoney(0)
	end)

	concommand.Add("mothervox_debug_warp_me_down", function()
		ZVox.SetPlayerPos(Vector(11.5, 10.5, 3.7))
	end)

	concommand.Add("mothervox_debug_warp_me_up", function()
		ZVox.SetPlayerPos(Vector(16, 16, 994))
	end)
end