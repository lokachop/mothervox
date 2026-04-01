ZVox = ZVox or {}

local colBlue = Color(64, 196, 255)
local nextCan = 0
ZVox.NewControlListener("item_fuel_tank", "fueltank_use", function()
	if ZVox.GetState() ~= ZVOX_STATE_INGAME then
		return
	end

	if ZVox.GetGamePaused() then
		return
	end

	local currCount = ZVox.Consumable_GetCurrentCount(MV_CONSUMABLE_FUEL_TANK)
	if currCount <= 0 then
		return
	end

	if nextCan > CurTime() then
		return
	end
	nextCan = CurTime() + 1.25


	surface.PlaySound("mothervox/sfx/consumables/fueltank.wav")
	ZVox.AddMinedPopup("Used Reserve Fuel Tank", colBlue)
	ZVox.Fuel_GainFuel(25)
	ZVox.Consumable_SpendConsumable(MV_CONSUMABLE_FUEL_TANK)
end)