ZVox = ZVox or {}

-- im lazy as fuuuuck
-- https://wiki.facepunch.com/gmod/surface.DrawPoly
local function drawOval(x, y, sX, sY, seg)
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * sX, y = y + math.cos( a ) * sY, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * sX, y = y + math.cos( a ) * sY, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local function resetStencil()
	render.ClearStencil()
	render.SetStencilEnable(false)
	render.SetStencilTestMask(255)
	render.SetStencilWriteMask(255)
	render.SetStencilReferenceValue(0)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
end


 -- this uses stencils which is abit eghh but who gaf this is aprilfools
local function drawHoleOval(x, y, sX, sY, seg)
	-- As THE stencil tutorial once said, Reset everything to known good
	resetStencil()

	render.SetStencilEnable(true)
	render.SetStencilReferenceValue(1)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)

	render.OverrideColorWriteEnable(true, false)
		drawOval(x, y, sX - 4, sY - 4, seg)
	render.OverrideColorWriteEnable(false, false)


	render.SetStencilReferenceValue(0)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	drawOval(x, y, sX, sY, seg)

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilEnable(false)
end


surface.CreateFont("FuckassUIFont", {
	font		= "Coolvetica",
	size		= 40,
	weight		= 2000,
})
surface.CreateFont("FuelLowFont", {
	font		= "Coolvetica",
	size		= 50,
	weight		= 2000,
})
surface.CreateFont("MoneyFont", {
	font		= "Coolvetica",
	size		= 60,
	weight		= 2000,
})

local colHullTextBG = Color(173, 38, 38)
local colHullTextFG = Color(249, 227, 227)
local function drawShadowCharHull(c, x, y)
	draw.SimpleText(c, "FuckassUIFont", x + 4, y + 2, colHullTextBG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(c, "FuckassUIFont", x, y, colHullTextFG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local colFuelTextBG = Color(54, 41, 52)
local colFuelTextFG = Color(220, 216, 97)
local function drawShadowCharFuel(c, x, y, col)
	draw.SimpleText(c, "FuckassUIFont", x + 4, y + 2, col and col or colFuelTextBG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(c, "FuckassUIFont", x, y, col and col or colFuelTextFG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function drawHullHealth()
	local baseX = 8
	local baseY = 44

	local baseW = 128
	local h_baseW = baseW / 2

	surface.SetDrawColor(102, 0, 0)
	draw.NoTexture()
	drawOval(baseX + h_baseW, baseY + 128, h_baseW, 16, 32)

	-- left bar
	surface.SetDrawColor(255, 164, 164)
	surface.DrawRect(baseX, (baseY + 128) - 128, 4, 128)

	-- right bar
	surface.SetDrawColor(255, 74, 74)
	surface.DrawRect(baseX + baseW - 4, (baseY + 128) - 128, 4, 128)

	-- top
	surface.SetDrawColor(254, 181, 181)
	draw.NoTexture()
	drawHoleOval(baseX + h_baseW, baseY, h_baseW, 16, 32)

	-- bar
	local healthDelta = ZVox.Health_GetHealthDelta()
	local vDelta = math.max(healthDelta - 0.02, 0)
	local smallhealthDeltaSz = math.min(healthDelta * (1 / 0.02), 1)

	surface.SetDrawColor(204, 32, 32)
	surface.DrawRect(baseX + 2, baseY + Lerp(vDelta, 126, 2), baseW - 4, Lerp(vDelta, 0, 126))
	-- bar bottom
	drawOval(baseX + h_baseW, baseY + 125, (h_baseW - 2) * smallhealthDeltaSz, 16 * smallhealthDeltaSz, 32)

	-- bar top
	surface.SetDrawColor(237, 117, 117)
	drawOval(baseX + h_baseW, baseY + Lerp(vDelta, 126, 2), (h_baseW - 2) * smallhealthDeltaSz, 16 * smallhealthDeltaSz, 32)


	-- glass
	resetStencil()
	render.SetStencilEnable(true)
	render.SetStencilReferenceValue(1)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)

	render.OverrideColorWriteEnable(true, false)
		surface.DrawRect(baseX + 2, baseY + 2, baseW - 4, 126)
		drawOval(baseX + h_baseW, baseY + 125, h_baseW - 2, 16, 32)
	render.OverrideColorWriteEnable(false, false)

	render.SetStencilReferenceValue(0)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	surface.SetDrawColor(255, 255, 255, 32)
	drawOval(baseX + h_baseW, baseY + 2, h_baseW - 2, 16, 32)

	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

	ZVox.RenderGradientSRGBHorizontal(baseX, baseY, h_baseW * .5, 196, 16, Color(255, 255, 255, 8), Color(255, 255, 255, 32))
	ZVox.RenderGradientSRGBHorizontal(baseX + (h_baseW * .5), baseY, h_baseW * 2, 196, 24, Color(255, 255, 255, 32), Color(255, 255, 255, 0))

	render.SetStencilEnable(false)

	local xTextOrigin = 48 + baseX
	local yTextOrigin = 66 + baseY
	drawShadowCharHull("H", xTextOrigin, yTextOrigin)
	drawShadowCharHull("u", xTextOrigin + 20, yTextOrigin + 1)
	drawShadowCharHull("l", xTextOrigin + 32, yTextOrigin)
	drawShadowCharHull("l", xTextOrigin + 40, yTextOrigin - 2)
end

local function drawFuel()
	local baseX = 16 + 128
	local baseY = 44

	local baseW = 74
	local h_baseW = baseW / 2

	surface.SetDrawColor(102, 0, 0)
	draw.NoTexture()
	drawOval(baseX + h_baseW, baseY + 128, h_baseW, 16, 32)

	-- left bar
	surface.SetDrawColor(206, 139, 0)
	surface.DrawRect(baseX, (baseY + 128) - 128, 4, 128)

	-- right bar
	surface.SetDrawColor(153, 102, 0)
	surface.DrawRect(baseX + baseW - 4, (baseY + 128) - 128, 4, 128)

	-- top
	surface.SetDrawColor(181, 150, 67)
	draw.NoTexture()
	drawHoleOval(baseX + h_baseW, baseY, h_baseW, 16, 32)

	-- bar
	local fuelDelta = ZVox.Fuel_GetPlayerFuelDelta()
	local vDelta = math.max(fuelDelta - 0.02, 0)
	local smallFuelDeltaSz = math.min(fuelDelta * (1 / 0.02), 1)

	vDelta = math.floor(vDelta * 100) / 100
	smallFuelDeltaSz = math.floor(smallFuelDeltaSz * 10) / 10

	surface.SetDrawColor(109, 83, 48)

	surface.DrawRect(baseX + 2, baseY + Lerp(vDelta, 126, 2), baseW - 4, Lerp(vDelta, 0, 126))
	-- bar bottom
	drawOval(baseX + h_baseW, baseY + 125, (h_baseW - 2) * smallFuelDeltaSz, 16 * smallFuelDeltaSz, 32)


	-- bar top
	surface.SetDrawColor(137, 130, 90)
	drawOval(baseX + h_baseW, baseY + Lerp(vDelta, 126, 2), (h_baseW - 2) * smallFuelDeltaSz, 16 * smallFuelDeltaSz, 32)

	-- glass
	resetStencil()
	render.SetStencilEnable(true)
	render.SetStencilReferenceValue(1)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)

	render.OverrideColorWriteEnable(true, false)
		surface.DrawRect(baseX + 2, baseY + 2, baseW - 4, 126)
		drawOval(baseX + h_baseW, baseY + 125, h_baseW - 2, 16, 32)
	render.OverrideColorWriteEnable(false, false)

	render.SetStencilReferenceValue(0)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	surface.SetDrawColor(255, 255, 255, 32)
	drawOval(baseX + h_baseW, baseY + 2, h_baseW - 2, 16, 32)


	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

	--ZVox.RenderGradientSRGBHorizontal(baseX, baseY, h_baseW, 196, 16, Color(255, 255, 255, 8), Color(255, 255, 255, 24))
	--ZVox.RenderGradientSRGBHorizontal(baseX + h_baseW, baseY, h_baseW, 196, 16, Color(255, 255, 255, 24), Color(255, 255, 255, 8))
	ZVox.RenderGradientSRGBHorizontal(baseX, baseY, h_baseW * .5, 196, 16, Color(255, 255, 255, 8), Color(255, 255, 255, 32))
	ZVox.RenderGradientSRGBHorizontal(baseX + (h_baseW * .5), baseY, h_baseW * 2, 196, 24, Color(255, 255, 255, 32), Color(255, 255, 255, 0))

	render.SetStencilEnable(false)

	local xTextOrigin = 14 + baseX
	local yTextOrigin = 66 + baseY
	drawShadowCharFuel("F", xTextOrigin, yTextOrigin)
	drawShadowCharFuel("u", xTextOrigin + 16, yTextOrigin + 2)
	drawShadowCharFuel("e", xTextOrigin + 34, yTextOrigin + 2)
	drawShadowCharFuel("l", xTextOrigin + 46, yTextOrigin)

	drawShadowCharFuel("-F", baseX + baseW + 16, baseY + 4)
	drawShadowCharFuel("-E", baseX + baseW + 16, baseY + 124)
end


local colMin = Color(255, 0, 0)
local colMax = Color(255, 255, 0)
local function drawLowFuel()
	local fuelDelta = ZVox.Fuel_GetPlayerFuelDelta()
	if fuelDelta >= 0.125 then
		return
	end

	local lerpTime = (CurTime() * 4) % 1
	local msg = "FUEL LOW"
	if fuelDelta <= 0.05 then
		msg = "FUEL CRITICAL !"
		lerpTime = (CurTime() * 8) % 1
	end

	local colLerp = ZVox.LerpColor(lerpTime, colMin, colMax)
	draw.SimpleText(msg, "FuelLowFont", 256 + 32, 128 + 16, colLerp, TEXT_ALIGN_TOP, TEXT_ALIGN_LEFT)

end


local minedPopupLen = 2
local minedPopups = {}
function ZVox.AddMinedPopup(name, col)
	minedPopups[#minedPopups + 1] = {
		["msg"] = name,
		["die"] = CurTime() + minedPopupLen,
		["oX"] = (math.random() - .5) * 256,
		["oY"] = (math.random() - .5) * 64,
		["col"] = col
	}
end


local colLerp = Color(0, 255, 0)
local function drawMinedPopup()
	local toKill = {}

	for i = 1, #minedPopups do
		local popup = minedPopups[i]
		local dieTime = popup["die"]

		if CurTime() > dieTime then
			toKill[#toKill + 1] = i
		end
		local popupDelta = 1 - ((dieTime - CurTime()) / minedPopupLen)

		local alphaDelta = math.max(popupDelta - .5, 0) * 2

		colLerp:SetUnpacked(255, 255, alphaDelta * 255, (1 - alphaDelta) * 255)

		local colGet = popup["col"]
		if colGet then
			colLerp:SetUnpacked(colGet.r, colGet.g, colGet.b, (1 - alphaDelta) * 255)
		end


		local oX = popup["oX"]
		local oY = popup["oY"]

		draw.SimpleText(popup["msg"], "FuelLowFont", ScrW() * .5 + oX, (ScrH() * .5) - (popupDelta * (ScrH() * .5)) + oY, colLerp, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	end

	if #toKill <= 0 then
		return
	end

	for i = #toKill, 1, -1 do
		local popupIdx = toKill[i]
		table.remove(minedPopups, popupIdx)
	end
end

local colAltitudeBG = Color(102, 0, 0)
local colAltitudeFG = Color(253, 235, 107)
local function drawAltitude()
	local plyPos = ZVox.GetPlayerInterpolatedPos()
	local posZ = plyPos[3]
	posZ = posZ - 993
	posZ = posZ * 12
	posZ = math.floor(posZ)

	draw.SimpleText(posZ .. " ft.", "FuelLowFont", 16 + 4, 208 + 4, colAltitudeBG, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText(posZ .. " ft.", "FuelLowFont", 16, 208, colAltitudeFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

local colMoneyBG = Color(0, 0, 51)
local colMoneyFG = Color(255, 203, 0)
local function drawMoney()
	local moneyStr = "$ " .. tostring(ZVox.Money_GetCurrentMoney())
	draw.SimpleText(moneyStr, "MoneyFont", (ScrW() * .5) + 4, 16 + 4, colMoneyBG, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText(moneyStr, "MoneyFont", ScrW() * .5, 16, colMoneyFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end


function ZVox.RenderUI()
	drawHullHealth()
	drawFuel()
	drawLowFuel()
	drawMinedPopup()
	drawAltitude()
	drawMoney()
end



local explosionLen = 0
local explosionEnd = CurTime()
function ZVox.PushExplosionFX(len)
	explosionLen = len
	explosionEnd = CurTime() + len
end


function ZVox.RenderExplosionFX()
	local delta = (explosionEnd - CurTime()) / explosionLen
	if delta <= 0 then
		return
	end

	local invDelta = 1 - delta
	local preWhiteLerp = math.ease.OutQuad(invDelta)

	local whiteDelta = math.ease.InQuad(delta)



	surface.SetDrawColor(255, Lerp(preWhiteLerp, 255, 128), Lerp(preWhiteLerp, 255, whiteDelta * 32), whiteDelta * 96)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end