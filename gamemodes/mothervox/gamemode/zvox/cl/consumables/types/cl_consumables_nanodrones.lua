ZVox = ZVox or {}

local colBlue = Color(64, 196, 255)
local nextCan = 0
ZVox.NewControlListener("item_nanobots", "nanobots_use", function()
	if ZVox.GetState() ~= ZVOX_STATE_INGAME then
		return
	end

	if ZVox.GetGamePaused() then
		return
	end

	local currCount = ZVox.Consumable_GetCurrentCount(MV_CONSUMABLE_NANOBOTS)
	if currCount <= 0 then
		return
	end

	if nextCan > CurTime() then
		return
	end
	nextCan = CurTime() + 1.25


	surface.PlaySound("mothervox/sfx/consumables/nanobots.wav")
	ZVox.AddMinedPopup("Used Hull Repair Nanobots", colBlue)
	ZVox.Health_GainHealth(30)
	ZVox.Consumable_SpendConsumable(MV_CONSUMABLE_NANOBOTS)
end)