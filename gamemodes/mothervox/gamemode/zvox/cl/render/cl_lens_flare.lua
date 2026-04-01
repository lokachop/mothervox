ZVox = ZVox or {}

local lastSunVisible = 0
local sunVisibility = 0
local sunScreenPos = {["x"] = 0, ["y"] = 0}
function ZVox.ComputeLensFlareVisibility(univObj)
	if not ZVOX_DO_LENS_FLARE then
		return
	end


	local sunDir = ZVox.GetSunDir(univObj)
	local eyePos = ZVox.GetCamPos()

	local scrPosVec = eyePos + (sunDir * 8)
	sunScreenPos = scrPosVec:ToScreen()

	local fadeSpeed = 8
	sunVisibility = 1 - ((CurTime() * fadeSpeed) - (lastSunVisible * fadeSpeed))
	sunVisibility = math.min(math.max(sunVisibility, 0), 1)

	local eyeDir = ZVox.GetCamAng():Forward()
	local inten = (eyeDir:Dot(sunDir) - .7) * 3.333

	if inten <= 0 then
		sunVisibility = 0
		return
	end

	sunVisibility = sunVisibility * inten

	local tr = ZVox.RaycastWorld(univObj, eyePos, sunDir, 512, true, ZVOX_COLLISION_GROUP_SOLID)
	if tr.Hit then
		return
	end

	lastSunVisible = CurTime()
	sunVisibility = 1 * inten
end

local function lerpUnclamped(t, a, b)
	return a * (1 - t) + b * t
end

-- the materials
-- https://blackpawn.com/texts/lensflare/default.html
local function compute_r(x, y)
	local offset = 4
	local h_offset = offset * .5

	x = x - h_offset
	y = y - h_offset

	x = x + .5
	y = y + .5
	local R = 64 - offset

	local dX = x - R
	local dY = y - R
	return math.sqrt(dX * dX + dY * dY) / R
end

local function smoothstep(t, a, b)
	if t < a then
		return 0
	end

	if t >= b then
		return 1
	end

	t = (t - a) / (b - a)
	return (t * t) * (3 - 2 * t)
end


local _, matCircle1 = ZVox.NewRTMatPairPixelFunc("circle1_lensf", 128, 128, function(x, y)
	local r = compute_r(x, y)
	local val = 1 - r
	val = val * val

	val = val * (1 - smoothstep(r, 1 - .01, 1 + .01))

	val = val * 255
	return val, val, val
end)
local _, matCircle2 = ZVox.NewRTMatPairPixelFunc("circle2_lensf", 128, 128, function(x, y)
	local r = compute_r(x, y)

	local val = r * r
	val = val * val
	val = val * val * val

	val = math.ease.OutExpo(val)

	val = val * (1 - smoothstep(r, 1 - .01, 1 + .01))

	val = val * 255
	return val, val, val
end)
local _, matCircle3 = ZVox.NewRTMatPairPixelFunc("circle3_lensf", 128, 128, function(x, y)
	local r = compute_r(x, y)

	local val = r

	val = val * (1 - smoothstep(r, 1 - .01, 1 + .01))

	val = val * 255
	return val, val, val
end)
local _, matCircle4 = ZVox.NewRTMatPairPixelFunc("circle4_lensf", 128, 128, function(x, y)
	local r = compute_r(x, y)

	local val = 1 - math.abs(r - .9) / .1
	if (val < 0) then
		return 0, 0, 0, 0
	end
	val = val * val
	val = val * val

	val = val * (1 - smoothstep(r, 1 - .01, 1 + .01))

	val = val * 255
	return val, val, val
end)

local _, matCircle5 = ZVox.NewRTMatPair("circle5_lensf2", 256, 256, function()
	render.Clear(0, 0, 0, 255)
	local partStepCount = 128
	local partCount = 256

	render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_ADD)
	for i = 1, partCount do
		local ang = math.random() * 360
		ang = math.rad(ang)

		local dx = math.cos(ang)
		local dy = math.sin(ang)

		local fx = ScrW() * .5
		local fy = ScrH() * .5

		local alphaDist = .6 + (math.random() * .4)
		local alphaSubStep = 1 / partStepCount
		for j = 1, partStepCount do
			alphaDist = alphaDist - alphaSubStep
			if alphaDist <= 0 then
				break
			end

			local alphaMul = alphaDist * 64
			surface.SetDrawColor(alphaMul, alphaMul, alphaMul, 255)


			local partSize = 4
			local h_partSize = partSize * .5

			surface.DrawRect(fx - h_partSize, fy - h_partSize, partSize, partSize)

			fx = fx + dx
			fy = fy + dy
		end
	end
	render.OverrideBlend(false)


end)


local lensFlareSteps = {
	{
		["tex"] = matCircle2,
		["col"] = Color(165, 131, 67),
		["dist"] = 1.5,
		["size"] = 64 + 16,
	},
	{
		["tex"] = matCircle1,
		["col"] = Color(255, 200, 100),
		["dist"] = 1,
		["size"] = 256 + 128,
	},
	{
		["tex"] = matCircle4,
		["col"] = Color(138, 109, 56),
		["dist"] = 1,
		["size"] = 128,
	},
	{
		["tex"] = matCircle5,
		["col"] = Color(255, 200, 100),
		["dist"] = 1,
		["size"] = 256 + 64,
	},
	{
		["tex"] = matCircle3,
		["col"] = Color(147, 176, 255),
		["dist"] = .5,
		["size"] = 96 + 16,
	},
	{
		["tex"] = matCircle3,
		["col"] = Color(147, 176, 255),
		["dist"] = .45,
		["size"] = 64,
	},
	{
		["tex"] = matCircle2,
		["col"] = Color(138, 109, 56),
		["dist"] = -.2,
		["size"] = 128 + 16,
	},
	{
		["tex"] = matCircle2,
		["col"] = Color(138, 109, 56),
		["dist"] = -.5,
		["size"] = 256,
	},
}


function ZVox.RenderLensFlare()
	if not ZVOX_DO_LENS_FLARE then
		return
	end


	if sunVisibility <= 0 then
		return
	end

	local shakeX, shakeY = ZVox.GetScreenShake()

	local xPos = sunScreenPos.x + shakeX
	local yPos = sunScreenPos.y + shakeY

	local sW, sH = ScrW(), ScrH()
	if xPos < 0 or xPos > sW then
		return
	end

	if yPos < 0 or yPos > sH then
		return
	end

	local sHalfW = sW * .5
	local sHalfH = sH * .5

	local xRelative = xPos - sHalfW
	local yRelative = yPos - sHalfH

	render.PushFilterMag(TEXFILTER.LINEAR)
	render.PushFilterMin(TEXFILTER.LINEAR)
	render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD)
	for i = 1, #lensFlareSteps do
		local entry = lensFlareSteps[i]

		local dist = entry.dist
		local xCalc = xRelative * dist
		local yCalc = yRelative * dist

		local entryTex = entry.tex
		surface.SetMaterial(entryTex)

		local col = entry.col
		surface.SetDrawColor(col.r * sunVisibility, col.g * sunVisibility, col.b * sunVisibility)

		local rectSz = entry.size
		local h_rectSz = rectSz * .5
		surface.DrawTexturedRect(xCalc + sHalfW - h_rectSz, yCalc + sHalfH - h_rectSz, rectSz, rectSz)
	end
	render.OverrideBlend(false)
	render.PopFilterMin()
	render.PopFilterMag()
end