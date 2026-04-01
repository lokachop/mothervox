ZVox = ZVox or {}


local fogStages = {}
local function addFogStage(z, r, g, b)
	fogStages[#fogStages + 1] = {
		["height"] = z,
		["r"] = r,
		["g"] = g,
		["b"] = b,
	}
end
addFogStage(10028, 48, 32, 16)
addFogStage(1028, 48, 32, 16)

addFogStage(993, 48, 32, 16)

addFogStage(990, 48 * .25, 32 * .25, 16 * .25)

addFogStage(950, 0, 0, 0)

addFogStage(750, 24, 48, 16)

addFogStage(550, 16, 24, 48)

addFogStage(350, 48, 24, 48)

addFogStage(200, 56, 0, 0)

addFogStage(150, 56, 26, 16)

addFogStage(100, 56, 46, 16)

addFogStage(50, 56, 35, 16)

addFogStage(0, 64, 0, 0)

addFogStage(-1000, 0, 0, 0)

local function getCurrentFogRGB()
	local currZ = ZVox.GetPlayerInterpolatedPos()[3]


	local maxGet = 0
	for i = 1, #fogStages do
		local stage = fogStages[i]
		local zGet = stage["height"]

		if currZ > zGet then
			continue
		end

		maxGet = math.max(maxGet, i)
	end

	if maxGet == 0 then
		return 48, 32, 16
	end

	local curr = fogStages[maxGet]
	local next = fogStages[maxGet + 1]
	if not next then
		return 48, 32, 16
	end

	local zDiff = curr["height"] - next["height"]
	local zDelta = (currZ - next["height"]) / zDiff
	zDelta = 1 - zDelta


	local rCalc = Lerp(zDelta, curr["r"], next["r"])
	local gCalc = Lerp(zDelta, curr["g"], next["g"])
	local bCalc = Lerp(zDelta, curr["b"], next["b"])

	return rCalc, gCalc, bCalc
end


function ZVox.BeginFog()
	local r, g, b = getCurrentFogRGB()

	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogColor(r, g, b)
	render.FogStart(-30)
	render.FogEnd(10)
	render.FogMaxDensity(0.95)
end


function ZVox.EndFog()
	render.FogMode(MATERIAL_FOG_NONE)
end