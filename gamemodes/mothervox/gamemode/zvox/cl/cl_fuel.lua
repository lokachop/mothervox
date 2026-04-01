ZVox = ZVox or {}

-- t0 = 10
-- t1 = 15
-- t2 = 25
-- t3 = 40
-- t4 = 60
-- t5 = 100
-- t6 = 150
local currFuel = ZVox.Upgrades_GetMaxFuelLevel()

function ZVox.Fuel_GetPlayerFuelDelta()
	return currFuel / ZVox.Upgrades_GetMaxFuelLevel()
end


function ZVox.Fuel_GetPlayerFuel()
	return currFuel
end

function ZVox.Fuel_GetPlayerMaxFuel()
	return ZVox.Upgrades_GetMaxFuelLevel()
end

function ZVox.Fuel_GetMaxFuelCanBuy()
	return ZVox.Upgrades_GetMaxFuelLevel() - currFuel
end

function ZVox.Fuel_GainFuel(amount)
	currFuel = math.min(currFuel + amount, ZVox.Upgrades_GetMaxFuelLevel())
end

function ZVox.Fuel_SetFuel(amount)
	currFuel = math.min(amount, ZVox.Upgrades_GetMaxFuelLevel())
end

local function onFuelRunOut()
	ZVox.Health_TakeDamage(1000)
end


local nextLowFuelAlert = CurTime()
local function playLowFuelAlert()
	if CurTime() < nextLowFuelAlert then
		return
	end

	nextLowFuelAlert = CurTime() + .65
	surface.PlaySound("mothervox/sfx/vehicle/fuel_low.wav")
end

local function playCriticalFuelAlert()
	if CurTime() < nextLowFuelAlert then
		return
	end

	nextLowFuelAlert = CurTime() + .25
	surface.PlaySound("mothervox/sfx/vehicle/fuel_low.wav")
end


function ZVox.Fuel_PlayerFuelThink()
	if ZVox.GetGamePaused() then
		return
	end

	if ZVox.Health_GetHealthDelta() <= 0 then
		return
	end

	local dt = FrameTime()

	-- idle sub
	currFuel = currFuel - (dt * 0.068)

	-- velocity sub
	local plyVelC = ZVox.GetPlayerVel() * 1
	plyVelC[3] = math.max(plyVelC[3], 0)

	local plyVelL = plyVelC:Length()
	local velLDelta = math.min(plyVelL / 6, 1)
	currFuel = currFuel - (velLDelta * 0.00068)

	currFuel = math.max(currFuel, 0)

	if currFuel <= 0 then
		onFuelRunOut()
		return
	end

	if ZVox.Fuel_GetPlayerFuelDelta() < 0.05 then
		playCriticalFuelAlert()
	elseif ZVox.Fuel_GetPlayerFuelDelta() < 0.125 then
		playLowFuelAlert()
	end
end