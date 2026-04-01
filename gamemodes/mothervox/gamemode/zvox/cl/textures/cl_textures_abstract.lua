ZVox = ZVox or {}

local math = math
local math_random = math.random


local function isTextureBorder(x, y)
	return (x == 0 or x == 15) or (y == 0 or y == 15)
end

local function inrange(x, a, b)
	return x >= a and x <= b
end

local function inrange_exclusive(x, a, b)
	return x >= a and x < b
end

local function inbox(x, y, bX, bY, bW, bH)
	return inrange(x, bX, bX + bW) and inrange(y, bY, bY + bH)
end

local function localizedDelta(x, min, max)
	return (x - min) / (max - min)
end

local function glassLerp(mix, glass, r, g, b)
	return Lerp(mix, r, glass),  Lerp(mix, g, glass),  Lerp(mix, b, glass)
end

local function normDistTo(x, y, tX, tY)
	local diffX = math.abs(x - tX)
	diffX = diffX / 16

	local diffY = math.abs(y - tY)
	diffY = diffY / 16

	return (diffX + diffY) / 2
end

local function casingBlockTextureGen(name, colours)
	local cHigh = colours["high"]
	local cLow = colours["low"]

	local cLower = colours["lower"]
	if not cLower then
		cLower = Color(cLow.r - 32, cLow.g - 32, cLow.b - 32)
	end

	local cHigher = colours["higher"]
	if not cHigher then
		cHigher = Color(cHigh.r + 32, cHigh.g + 32, cHigh.b + 32)
	end

	local cHighest = colours["highest"]
	if not cHighest then
		cHighest = Color(cHigh.r + 100, cHigh.g + 100, cHigh.b + 100)
	end

	local subtractive = colours["subtractive"] or {32, 32, 32}
	local sR = subtractive[1] * 2
	local sG = subtractive[2] * 2
	local sB = subtractive[3] * 2

	ZVox.TextureOpPixelFunc(name, function(x, y)
		local delta = normDistTo(x, y, 0, 0)


		-- dot is to lerp
		local colHigh = cHighest
		local colLow = cLow
		local colLerp = ZVox.LerpColor(delta, colHigh, colLow)

		return colLerp.r, colLerp.g, colLerp.b
	end)

	ZVox.TextureHexMaskOp(name, {0xffff, 0x8001, 0xa425, 0x8001, 0x8001, 0xa005, 0x8001, 0x8001, 0x8001, 0x8001, 0xa005, 0x8001, 0x8001, 0xa425, 0x8001, 0xffff, }, function(x, y)
		local delta = normDistTo(x, y, 0, 0)

		local colHigh = cHighest
		local colLow = cLow
		local colLerp = ZVox.LerpColor(delta, colHigh, colLow)

		return colLerp.r - sR, colLerp.g - sG, colLerp.b - sB
	end)
end

local function isTextureBorder_Width(x, y, width)
	width = width or 1
	return (inrange_exclusive(x, 0, width) or inrange_exclusive(x, 16 - width, 16)) or (inrange_exclusive(y, 0, width) or inrange_exclusive(y, 16 - width, 16))
end

local function textLine(seed, yOffset)
	if yOffset > 14 or yOffset < 1 then
		return
	end

	local xAccum = 2
	for i = 1, 16 do
		if xAccum >= 13 then
			break
		end

		local wideCalc = util.SharedRandom("lineCalc_" .. seed, 1, 8, i * 324634)
		wideCalc = math.floor(wideCalc)

		local newX = xAccum + wideCalc
		newX = math.min(newX, 14)

		local colVal = .6 + util.SharedRandom("colVal_" .. seed, 0, 1, i * 542343) * .4
		surface.SetDrawColor(128 * colVal, 196 * colVal, 255 * colVal)
		surface.DrawLine(xAccum, yOffset, newX, yOffset)

		xAccum = newX + 1
	end
end

surface.CreateFont("ZVOXBigText", {
	font = "Arial",
	size = 30,
	weight = 10,
	antialias = false,
})

surface.CreateFont("ZVOXMedText", {
	font = "Arial",
	size = 14,
	weight = 400,
	antialias = false,
})

surface.CreateFont("ZVOXTinyText", {
	font = "Arial",
	size = 8,
	weight = 400,
	antialias = false,
})

surface.CreateFont("ZVOXSmallerText", {
	font = "Lucida Console",
	size = 9,
	weight = 400,
	antialias = false,
})

function ZVox.ComputeAbstractTextures()

	ZVox.NewTexturePixelFunc("xor", function(x, y)
		local xorVal = bit.bxor(x, y) * 16
		return xorVal, xorVal, xorVal
	end)

	ZVox.NewTexturePixelFunc("abstract1", function(x, y)
		local val = .7 + (math_random() * .3)

		return val * 128, val * 128, val * 128
	end)

	ZVox.TextureOp("abstract1", function()
		local gray1 = Color(96, 96, 96)
		local gray2 = Color(64, 64, 64)
		local gray3 = Color(140, 140, 140)

		draw.SimpleText("X", "ZVOXBigText",  1, 8, gray2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("X", "ZVOXBigText", -1, 8, gray3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("X", "ZVOXBigText",  0, 8, gray1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText("X", "ZVOXBigText",  9, 8, gray2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("X", "ZVOXBigText",  7, 8, gray3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("X", "ZVOXBigText",  8, 8, gray1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText("X", "ZVOXBigText", 17, 8, gray2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("X", "ZVOXBigText", 15, 8, gray3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("X", "ZVOXBigText", 16, 8, gray1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)

	ZVox.NewTexturePixelFunc("abstract2", function(x, y)
		local val = .9 + (math_random() * .1)

		return val * 170, val * 160, val * 196
	end)

	ZVox.TextureOp("abstract2", function()
		local c0 = Color(180, 160, 210)
		local c1 = Color(200, 180, 230)
		local c2 = Color(220, 200, 250)

		for x = 0, 16, 8 do
			for y = 0, 16, 8 do
				draw.SimpleText("X", "ZVOXTinyText",  x - 1, y, c0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("X", "ZVOXTinyText",  x + 1, y, c2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("X", "ZVOXTinyText",  x, y, c1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end)

	ZVox.NewTexturePixelFunc("abstract3", function(x, y)
		local val = .9 + math_random() * .1

		x = x % 8
		y = y % 8

		if ( x + 2 > y and y + 2 > x ) or ( x - y > 6 ) or ( y - x > 6 ) then
			return 20 * val, 15 * val, 10 * val
		end

		return 220 * val, 180 * val, 20 * val
	end)

	ZVox.NewTexturePixelFunc("abstract4", function(x, y)
		local val = .9 + (math_random() * .1)

		return val * 64, val * 120, val * 160
	end)

	ZVox.TextureOp("abstract4", function()
		local c1 = Color(160, 160, 160)

		for x = 0, 16, 8 do
			for y = 0, 16, 8 do
				draw.SimpleText("\\", "ZVOXSmallerText",  x, y, c1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("\\", "ZVOXSmallerText",  x + 1, y, c1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end)

	ZVox.NewTexture("smile", function()
		render.Clear(128, 128, 64, 255)
	end)
	-- dwarf fortress to fix inconsistencies due to fonts
	ZVox.TextureHexWriteOp("smile", {0x0, 0x0, 0x0, 0x0, 0x7E0, 0xC30, 0x810, 0xA50, 0x810, 0xBD0, 0x990, 0xC30, 0x7E0, 0x0, 0x0, 0x0}, 255, 255, 255)
	ZVox.TextureHexWriteOp("smile", {0x0, 0x0, 0x0, 0xFF0, 0x1818, 0x13C8, 0x17E8, 0x15A8, 0x17E8, 0x1428, 0x1668, 0x13C8, 0x1818, 0xFF0, 0x0, 0x0}, 0, 0, 0)


	ZVox.NewTexturePixelFunc("abstract5", function(x, y)
		local xD = x / 15
		local yD = y / 15

		local scl = 6
		local val = ZVox.Worley2D(xD * scl, yD * scl, 5234, function(v1, v2)
			local l1 = math.abs(v1[1] - v2[1])
			local l2 = math.abs(v1[2] - v2[2])

			l1 = math.sqrt(l1)
			l2 = math.sqrt(l2)

			return math.max((l1 + l2) - (math.random() * .15), 0)
		end, .3)
		val = 1 - val

		return val * 80, val * 160, val * 255
	end)
	ZVox.TextureOp("abstract5", function()
		render.BlurRenderTarget(render.GetRenderTarget(), 2, 2, 4)
	end)


	ZVox.NewTexturePixelFunc("abstract6", function(x, y)
		local xD = x / 15
		local yD = y / 15

		local scl = 6
		local val1 = ZVox.Worley2D(xD * scl, yD * scl, 5234, function(v1, v2)
			local l1 = math.abs(v1[1] - v2[1])
			local l2 = math.abs(v1[2] - v2[2])

			l1 = math.sqrt(l1)
			l2 = math.sqrt(l2)

			return math.max((l1 + l2) - (math.random() * .15), 0)
		end, .5)
		val1 = 1 - val1

		scl = 4
		local val2 = ZVox.Worley2D(xD * scl, yD * scl, 353247, function(v1, v2)
			local l1 = math.abs(v1[1] - v2[1])
			local l2 = math.abs(v1[2] - v2[2])

			l1 = math.sqrt(l1)
			l2 = math.sqrt(l2)

			return math.max((l1 + l2) - (math.random() * .2), 0)
		end, .5)
		val2 = 1 - val2

		local val = val1--val1 + val2


		local valR = val * 220
		local valG = val * 200
		local valB = val * 240

		local baseR = 204
		local baseG = 124
		local baseB = 246

		return math.min(baseR + valR, 255), math.min(baseG + valG, 255), math.min(baseB + valB, 255)
	end)


	-- ArtficialBakingTrays present
	--Present sides (KMS)
	ZVox.NewTexturePixelFunc("present_side_red", function(x, y)
		return 255, 88, 88
	end)
	ZVox.TextureHexWriteOp("present_side_red", {0x1668, 0x581A, 0x1A58, 0xE007, 0x6BD6, 0x83C1, 0xAC35, 0x8DB1, 0x8DB1, 0xAC35, 0x83C1, 0x6BD6, 0xE007, 0x1A58, 0x581A, 0x1668}, 255, 122, 122)
	ZVox.TextureHexWriteOp("present_side_red", {0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, }, 255, 255, 255)


	--Present top (KMS)
	ZVox.NewTexturePixelFunc("present_top_red", function(x, y)
		return 255, 88, 88
	end)
	--Snowflake design
	ZVox.TextureHexWriteOp("present_top_red", {0x1668, 0x581A, 0x1A58, 0xE007, 0x6BD6, 0x83C1, 0xAC35, 0x8DB1, 0x8DB1, 0xAC35, 0x83C1, 0x6BD6, 0xE007, 0x1A58, 0x581A, 0x1668}, 255, 122, 122)
	--Plus formation
	ZVox.TextureHexWriteOp("present_top_red", {0x3C0, 0x180, 0x180, 0x180, 0x180, 0x180, 0x8181, 0xFFFF, 0xFFFF, 0x8181, 0x180, 0x180, 0x180, 0x180, 0x180, 0x3C0}, 255, 255, 255)
	--Bow design
	ZVox.TextureHexWriteOp("present_top_red", {0x0, 0x0, 0x381C, 0x2424, 0x2244, 0x1248, 0xE70, 0x180, 0x180, 0xE70, 0x1248, 0x2244, 0x2424, 0x381C, 0x0, 0x0}, 255, 255, 255)

	--Present bottom (KMS)
	ZVox.NewTexturePixelFunc("present_bottom_red", function(x, y)
		return 255, 88, 88
	end)
	ZVox.TextureHexWriteOp("present_bottom_red", {0x1668, 0x581A, 0x1A58, 0xE007, 0x6BD6, 0x83C1, 0xAC35, 0x8DB1, 0x8DB1, 0xAC35, 0x83C1, 0x6BD6, 0xE007, 0x1A58, 0x581A, 0x1668}, 255, 122, 122)
	ZVox.TextureHexWriteOp("present_bottom_red", {0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, 0x3C0, }, 255, 255, 255)



	ZVox.NewTexturePixelFunc("present_side_green", function(x, y)
		if x > 5 and x < 10 then
			if (x + y) % 2 == 0 then
				return 220, 220, 220
			end

			return 255, 255, 255
		end


		local xor = bit.bxor(x, y)
		if (xor % 3) == 0 then
			return 32, 128, 48
		else
			return 64, 196, 96
		end
	end)

	ZVox.NewTexturePixelFunc("present_top_green", function(x, y)
		if x > 5 and x < 10 then
			if (x + y) % 2 == 0 then
				return 220, 220, 220
			end

			return 255, 255, 255
		end

		if y > 5 and y < 10 then
			if (x + y) % 2 == 0 then
				return 220, 220, 220
			end

			return 255, 255, 255
		end


		local xor = bit.bxor(x, y)
		if (xor % 3) == 0 then
			return 32, 128, 48
		else
			return 64, 196, 96
		end
	end)

	ZVox.TextureHexWriteOp("present_top_green", {0x0, 0x0, 0x0, 0x0, 0xc30, 0x1248, 0x1248, 0x1188, 0xdb0, 0x240, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, }, 16, 16, 16)
	ZVox.TextureHexWriteOp("present_top_green", {0x0, 0x0, 0x0, 0xc30, 0x1248, 0x1248, 0x1188, 0xdb0, 0x240, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, }, 140, 140, 140)


	ZVox.NewTexturePixelFunc("present_bottom_green", function(x, y)
		if x > 5 and x < 10 then
			if (x + y) % 2 == 0 then
				return 220, 220, 220
			end

			return 255, 255, 255
		end

		if y > 5 and y < 10 then
			if (x + y) % 2 == 0 then
				return 220, 220, 220
			end

			return 255, 255, 255
		end

		local xor = bit.bxor(x, y)
		if (xor % 3) == 0 then
			return 32, 128, 48
		else
			return 64, 196, 96
		end
	end)



	-- ss13 space
	ZVox.NewTexturePixelFunc("abstract7", function(x, y)
		return 21, 21, 21
	end)
	ZVox.TextureOp("abstract7", function()
		local redMul = 0.6
		local greenMul = 1
		local blueMul = 1.4



		local v = (.1 + math.random() * .1) * 255
		surface.SetDrawColor(v * redMul, v * greenMul, v * blueMul)
		surface.DrawRect(0, 1, 1, 1)

		v = (.2 + math.random() * .1) * 255
		surface.SetDrawColor(v * redMul, v * greenMul, v * blueMul)
		surface.DrawRect(7, 10, 1, 1)
		surface.DrawRect(11, 6, 1, 1)


		v = (.3 + math.random() * .2) * 255
		surface.SetDrawColor(v * redMul, v * greenMul, v * blueMul)

		surface.DrawRect(7, 14, 1, 1)
		surface.DrawRect(14, 12, 1, 1)
		surface.DrawRect(15, 4, 1, 1)
		surface.DrawRect(0, 6, 1, 1)
		surface.DrawRect(0, 10, 1, 1)
		surface.DrawRect(5, 5, 1, 1)


		v = (.65 + math.random() * .1) * 255
		surface.SetDrawColor(v * redMul, v * greenMul, v * blueMul)
		surface.DrawRect(3, 13, 1, 1) -- star1
		surface.DrawRect(8, 2, 1, 1) -- star2

		v = (.45 + math.random() * .1) * 255
		surface.SetDrawColor(v * redMul, v * greenMul, v * blueMul)
		-- star1
		surface.DrawRect(2, 13, 1, 1)
		surface.DrawRect(4, 13, 1, 1)
		surface.DrawRect(3, 12, 1, 1)
		surface.DrawRect(3, 14, 1, 1)

		-- star2
		surface.DrawRect(7, 2, 1, 1)
		surface.DrawRect(9, 2, 1, 1)
		surface.DrawRect(8, 1, 1, 1)
		surface.DrawRect(8, 3, 1, 1)


		v = (.25 + math.random() * .1) * 255
		surface.SetDrawColor(v * redMul, v * greenMul, v * blueMul)
		-- star2
		surface.DrawRect(6, 2, 1, 1)
		surface.DrawRect(10, 2, 1, 1)
		surface.DrawRect(8, 4, 1, 1)
		surface.DrawRect(8, 0, 1, 1)
	end)
	ZVox.SetTextureEmissive("abstract7", true)



	ZVox.NewTextureAnimated("noise", {
		["frames"] = 4,
		["speed"] = 0.2,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			local val = math.random() * 255

			return val, val, val
		end)
	end)

	ZVox.NewTextureAnimated("colourful", {
		["frames"] = 16,
		["speed"] = 0.1,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			if isTextureBorder(x, y) then
				local val = .8 + ZVox.ConsistentRandom() * .2

				return val * 255, val * 255, val * 255
			end

			local oX = 8
			local oY = 8

			local rX = x + (math.random() * .1)
			local rY = y + (math.random() * .1)

			local dist = math.DistanceSqr(rX, rY, oX, oY)
			local distDelta = dist / 98

			local rads = math.atan2(
				oY - rY,
				rX - oX
			)

			local deg = math.deg(rads) + (delta * 360)
			deg = deg + 180

			deg = (deg + (distDelta * (360 * .5)))
			deg = deg % 360

			local col = HSVToColor(deg, 1, 1)

			return col.r, col.g, col.b
		end)
	end)

	local bgGrad = {
		{["e"] =  0, ["c"] = Color(80, 64, 120)},

		{["e"] =  .25, ["c"] = Color(0, 0, 0)},
		{["e"] =  .25, ["c"] = Color(0, 0, 0)},
		{["e"] =  .75, ["c"] = Color(0, 0, 0)},
		{["e"] =  .75, ["c"] = Color(0, 0, 0)},

		{["e"] =  1, ["c"] = Color(80, 64, 120)},
	}

	ZVox.NewTextureAnimated("sine_line", {
		["frames"] = 16,
		["speed"] = 0.1,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			local xD = x / 16

			local cosCalc = (xD * 360 * 4) + delta * 360 * 3
			local cosVal = math.sin(math.rad(cosCalc))

			local sinCalc = (xD * 360) + delta * 360
			local sinVal = math.sin(math.rad(sinCalc))
			sinVal = sinVal + (cosVal * .625)

			sinVal = sinVal * 1.25
			sinVal = sinVal + 7.5

			local sz = 2.5
			local inrangeSine = inrange(y, sinVal - sz, sinVal + sz)
			if not inrangeSine then
				local nsAdd = ((math.random() - .5) * 2) * .025

				local yD = y / 15
				local r, g, b = ZVox.GetColorAtGradientPoint(yD + nsAdd, bgGrad, true)
				return r, g, b
			else
				local deltaSin = (y - sinVal)
				deltaSin = math.abs(deltaSin) / sz
				deltaSin = 1 - deltaSin
				deltaSin = deltaSin

				return (deltaSin * deltaSin) * 164, 96 * deltaSin, 255 * deltaSin
			end
		end)
	end)
	ZVox.SetTextureEmissive("sine_line", true)

	ZVox.NewTextureAnimated("sine_line_top", {
		["frames"] = 8,
		["speed"] = 0.1,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			local flashVal = (math.sin(delta * math.pi) + 1) * .5

			local dist = math.DistanceSqr(x, y, 7.5, 7.5) / (7.5 * 7.5)

			local rDist = .25
			local distInv = 1 - (dist + (math.random() * rDist))

			local val = 1 + flashVal + distInv
			local vR = math.min(80 * val, 255)
			local vG = math.min(64 * val, 255)
			local vB = math.min(120 * val, 255)

			if isTextureBorder(x, y) then
				local much = .7
				return Lerp(much, vR, 80), Lerp(much, vG, 64), Lerp(much, vB, 120)
			else
				return vR, vG, vB
			end
		end)
	end)
	ZVox.SetTextureEmissive("sine_line_top", true)




	local cSrc = Color(165, 173, 201)
	local cDst = Color(87 , 91 , 106)
	-- A familiar machine, can't quite put my finger as to where it comes from...
	ZVox.NewTexturePixelFunc("familiar_machine_hull", function(x, y)
		if isTextureBorder(x, y) then
			local dist = normDistTo(x, y, 15, 0)
			dist = dist + (math.random() * .01)

			local col = ZVox.LerpColor(dist, cSrc, cDst)

			return col.r, col.g, col.b
		end

		local dist = normDistTo(x, y, 0, 0)
		dist = dist + (math.random() * .01)


		local col = ZVox.LerpColor(dist, cSrc, cDst)
		return col.r, col.g, col.b
	end)

	ZVox.NewTexturePixelFunc("familiar_machine_front", function(x, y)
		if isTextureBorder(x, y) then
			local dist = normDistTo(x, y, 15, 0)
			dist = dist + (math.random() * .01)

			local col = ZVox.LerpColor(dist, cSrc, cDst)

			return col.r, col.g, col.b
		end

		local dist = normDistTo(x, y, 0, 0)
		dist = dist + (math.random() * .01)


		local col = ZVox.LerpColor(dist, cSrc, cDst)
		return col.r, col.g, col.b
	end)

	ZVox.TextureHexWriteMultiOp("familiar_machine_front", {
		{Color(71 , 71 , 71 ), {0x0, 0x0, 0x3870,0x2040,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,}},
		{Color(51 , 51 , 51 ), {0x0, 0x0, 0x60c,0x0,0x2040,0x2040,0x3c40,0x2040,0x2000,0x2000,0x0,0x0,0x3ff8,0x2000,0x0,0x0,}},
		{Color(128, 128, 128), {0x0, 0x0, 0x0, 0x1800,0x1010,0x28,0x10,0x28,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,}},
		{Color(0  , 0  , 0  ), {0x0, 0x0, 0x0, 0x430,0xc00,0x1c00,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,}},
		{Color(25 , 29 , 29 ), {0x0, 0x0, 0x0, 0x204,0x204,0x204,0x204,0x204,0x27c,0x228,0x3fe8,0x8,0x4,0x1ffc,0x0,0x0,}},
		{Color(0  , 128, 0  ), {0x0, 0x0, 0x0, 0x8,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,}},
		{Color(192, 192, 192), {0x0, 0x0, 0x0, 0x0, 0x28,0x10,0x28,0x10,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,}},
		{Color(255, 255, 255), {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1800,0x1000,0x0,0x0,0x0,0x0,0x0,0x0,0x0,}},
		{Color(255, 0  , 0  ), {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x400,0xc00,0x1c00,0x0,0x0,0x0,0x0,0x0,0x0,}},
	})


	ZVox.NewTexturePixelFunc("familiar_machine_top", function(x, y)
		if isTextureBorder(x, y) then
			local dist = normDistTo(x, y, 15, 0)
			dist = dist + (math.random() * .01)

			local col = ZVox.LerpColor(dist, cSrc, cDst)

			return col.r, col.g, col.b
		end

		local dist = normDistTo(x, y, 0, 0)
		dist = dist + (math.random() * .01)


		local col = ZVox.LerpColor(dist, cSrc, cDst)
		return col.r, col.g, col.b
	end)

	ZVox.TextureHexWriteMultiOp("familiar_machine_top", {
		{Color(71 , 71 , 71 ), {0x0, 0x0, 0x1e38,0x3020,0x1020,0x20,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,}},
		{Color(51 , 51 , 51 ), {0x0, 0x0, 0x104,0x184,0x104,0x3004,0x1024,0x3024,0x24,0x20,0xe0,0x120,0xe0,0x100,0x0,0x0,}},
		{Color(255, 144, 0  ), {0x0, 0x0, 0x0, 0xa00,0x400,0xa00,0x400,0xa00,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,}},
		{Color(255, 255, 0  ), {0x0, 0x0, 0x0, 0x400,0x0,0x400,0x0,0x400,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,}},
		{Color(124, 128, 132), {0x0, 0x0, 0x0, 0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x0,0x0,0x0,}},
		{Color(255, 0  , 0  ), {0x0, 0x0, 0x0, 0x0, 0xa00,0x0,0xa00,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,}},
		{Color(25 , 29 , 29 ), {0x0, 0x0, 0x0, 0x0, 0x0, 0x180,0x100,0x180,0x1f00,0x4,0x4,0x4,0x4,0x3c,0x0,0x0,}},
	})


	ZVox.NewTextureAnimated("fan", {
		["frames"] = 8,
		["speed"] = 0.05,
	}, function(name, delta, frame)
		casingBlockTextureGen(name, {
			["highest"] = Color(267, 267, 320),
			["higher"] = Color(212, 212, 255),
			["high"] = Color(262, 262, 314),
			["low"] = Color(156, 156, 188),
			["lower"] = Color(105, 105, 126),

			["subtractive"] = {24, 24, 24},
		})

		ZVox.TextureOpPixelFunc(name, function(x, y)
			local xD = (x + .5) / 16
			local yD = (y + .5) / 16

			local cDist = math.Distance(xD, yD, .5, .5)

			if cDist < .35 then
				local val = .3 + math.random() * .05
				val = val * 9.5

				val = val
				val = val * 255
				val = val * cDist
				val = val / 255

				local deltaCalc = normDistTo(x, y, 0, 0)
				local colLerp = ZVox.LerpColor(deltaCalc, Color(32, 32, 54), Color(46, 46, 68))


				return colLerp.r * val, colLerp.g * val, colLerp.b * val
			end


			if cDist < .4 then
				local deltaCalc = normDistTo(x, y, 0, 0)

				local colLerp = ZVox.LerpColor(deltaCalc, Color(32, 32, 54), Color(46, 46, 68))

				return colLerp.r, colLerp.g, colLerp.b
			end

			if cDist < .45 then
				local val = .8 + ZVox.ConsistentRandom() * .2

				return 105 * val, 105 * val, 126 * val
			end

			return
		end)


		ZVox.TextureOp(name, function()
			local mtxRot = Matrix()
			mtxRot:Translate(Vector(8, 8, 0))
			mtxRot:Rotate(Angle(0, delta * 180, 0))


			local colDark = 148
			local colBright = 196

			cam.PushModelMatrix(mtxRot, true)
				-- horizontal
				surface.SetDrawColor(colDark, colDark, colDark)
				surface.DrawRect(0, -1, 5, 1)
				surface.DrawRect(-5, 0, 5, 1)

				surface.SetDrawColor(colBright, colBright, colBright)
				surface.DrawRect(0, 0, 5, 1)
				surface.DrawRect(-5, -1, 5, 1)


				-- vertical
				surface.SetDrawColor(colBright, colBright, colBright)
				surface.DrawRect(-1, 0, 1, 5)
				surface.DrawRect( 0, -5, 1, 5)

				surface.SetDrawColor(colDark, colDark, colDark)
				surface.DrawRect( 0, 0, 1, 5)
				surface.DrawRect(-1, -5, 1, 5)
			cam.PopModelMatrix()


			surface.SetDrawColor(160, 196, 220)
			surface.DrawRect(7, 7, 2, 2)
		end)


		ZVox.TextureOpPixelFunc(name, function(x, y)
			local xD = (x + .5) / 16
			local yD = (y + .5) / 16

			local cDist = math.Distance(xD, yD, .5, .5)


			if cDist < .45 and (y % 3) == 0 then
				local val = .8 + ZVox.ConsistentRandom() * .2

				return 105 * val, 105 * val, 126 * val
			end

			return
		end)
	end)



	ZVox.NewTextureAnimated("monitor_front", {
		["frames"] = 16,
		["speed"] = 0.2,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			if isTextureBorder_Width(x, y, 1) then
				local deltaCalc = normDistTo(x, y, 0, 0)

				local colLerp = ZVox.LerpColor(deltaCalc, Color(267, 267, 320), Color(156, 156, 188))

				return colLerp.r - 48, colLerp.g - 48, colLerp.b - 48
			end

			local val = .9 + math.random() * .1

			return 24 * val, 32 * val, 64 * val
		end)

		ZVox.TextureOp(name, function()
			local offY = frame

			for i = 1, 8 do
				local yIdx = ((i * 2) - offY) % 16

				textLine(i, yIdx)
			end
		end)
	end)
	ZVox.SetTextureEmissive("monitor_front", true)

	ZVox.NewTextureAnimated("monitor_front_noise", {
		["frames"] = 16,
		["speed"] = 0.2,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			if isTextureBorder_Width(x, y, 1) then
				local deltaCalc = normDistTo(x, y, 0, 0)

				local colLerp = ZVox.LerpColor(deltaCalc, Color(267, 267, 320), Color(156, 156, 188))

				return colLerp.r - 48, colLerp.g - 48, colLerp.b - 48
			end

			local val = .1 + math.random() * .25
			val = val * 255

			return val, val, val
		end)
	end)
	ZVox.SetTextureEmissive("monitor_front_noise", true)

	ZVox.NewTextureAnimated("monitor_front_warn", {
		["frames"] = 16,
		["speed"] = 0.2,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			if isTextureBorder_Width(x, y, 1) then
				local deltaCalc = normDistTo(x, y, 0, 0)

				local colLerp = ZVox.LerpColor(deltaCalc, Color(267, 267, 320), Color(156, 156, 188))

				return colLerp.r - 48, colLerp.g - 48, colLerp.b - 48
			end

			local val = .9 + math.random() * .1

			return 64 * val, 48 * val, 24 * val
		end)

		if delta < .5 then
			ZVox.TextureHexWriteOp(name, {0x0, 0x0, 0x180, 0x240, 0x240, 0x420, 0x5a0, 0x5a0, 0x990, 0x990, 0x1008, 0x1188, 0x2004, 0x3ffc, 0x0, 0x0, }, 255, 196, 32)
			ZVox.TextureHexWriteOp(name, {0x0, 0x180, 0x240, 0x5a0, 0x5a0, 0xbd0, 0xa50, 0xa50, 0x1668, 0x1668, 0x2994, 0x2a54, 0x5ffa, 0x4002, 0x3ffc, 0x0, }, 255 * .25, 196 * .25, 32 * .25)
			ZVox.TextureHexWriteOp(name, {0x0, 0x0, 0x240, 0x180, 0x420, 0x240, 0x240, 0xa50, 0x420, 0x1008, 0x990, 0x2004, 0x1188, 0x0, 0x0, 0x0, }, 255 * .3, 196 * .3, 32 * .3)
			ZVox.TextureHexWriteOp(name, {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1008, 0x0, 0x0, 0x0, }, 255 * .325, 196 * .325, 32 * .325)
		end
	end)
	ZVox.SetTextureEmissive("monitor_front_warn", true)



	-- SM colour list
	local smPalette = {
		Color(152, 96, 13),
		Color(213, 159, 34),
		Color(238, 201, 52),
		Color(244, 244, 124),
		Color(243, 243, 243)
	}

	ZVox.NewTextureAnimated("supermatter", {
		["frames"] = 16,
		["speed"] = 0.1,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)

			local deltaSin = math.sin(delta * math.pi)

			--local val = util.SharedRandom("supermatter", 0, .6, x + (y * 16))
			local val = ZVox.Worley2D(x * 48 * 2, y * 32 * 2, 3242)

			val = val * .75

			val = val + deltaSin * .2 + (math.random() * .05)

			local paletteEntryIdx = (val * #smPalette)
			paletteEntryIdx = math.floor(paletteEntryIdx) + 1

			local paletteCol = smPalette[paletteEntryIdx]

			return paletteCol.r, paletteCol.g, paletteCol.b

			--return 255 * val, 255 * val, 64 * val
		end)
	end)
	ZVox.SetTextureEmissive("supermatter", true)



	local sunVec = Vector(-.25, .25, 2.5)
	sunVec:Normalize()
	local sunVec2 = Vector(-.2, .2, 2.5)
	sunVec2:Normalize()
	ZVox.NewTexturePixelFunc("gelatin", function(x, y)
		local dX = (x - 7.5) / 7.5
		local dY = (y - 7.5) / 7.5
		local sz = 0.3 --0.325

		dX = dX * sz
		dY = dY * sz

		--local nVec = Vector(normX, normY, 1)
		--nVec:Normalize()
		if false then
			local d = Vector(dX, dY):Distance2D(Vector(0, 0))
			d = 1 - d
			d = math.min(math.max(d, 0), 0.75)

			return d * 255, d * 255, d * 255
		end


		-- InOutExpo
		-- InOutQuint
		-- InOutQuad
		local dist = 0.2
		local norm = ZVox.NormalFromNoiseFunc(function(nX, nY)
			local d = Vector(nX, nY):Distance2D(Vector(0, 0))
			d = 1 - d
			d = math.min(math.max(d, 0), 0.7)

			return d
		end, dX, dY, dist, false, 0.5, math.ease.InOutQuad)

		if false then
			return (norm[1] + 1) * 127, (norm[2] + 1) * 127, (norm[3] + 1) * 127
		end

		local sunDot = norm:Dot(sunVec)
		--sunDot = (sunDot * .975) + (math.random() * .025)
		sunDot = sunDot ^ 8
		--sunDot = sunDot * .55
		sunDot = sunDot / (1 - .1)
		sunDot = sunDot + .1
		--sunDot = math.min(sunDot, 1)

		local sunSpec = norm:Dot(sunVec2)
		sunSpec = sunSpec ^ 256
		sunSpec = sunSpec * 64

		return math.min((235 * sunDot) + sunSpec, 255), math.min((128 * sunDot) + sunSpec, 255), math.min((128 * sunDot) + sunSpec, 255)
	end)


	ZVox.NewTexturePixelFunc("tnt_side", function(x, y)
		-- TNT/dynamite side
		if (y >= 5 and y <= 10) then
			local val = 200 + (ZVox.ValueNoise2D(16 + x * .7, y * .5)) * 30
			return val, val, val
		end

		x = x % 4
		local shade = y == 0 and .85 or 1
		shade = shade - x * .1
		return 255 * shade, 40 * shade, 0

	end)
	ZVox.TextureHexWriteOp("tnt_side", {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x3a5c, 0x1348, 0x12c8, 0x1248, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, }, 32, 24, 16)



	ZVox.NewTexturePixelFunc("tnt_top", function(x, y)
		-- TNT/dynamite top/bottom
		x = x % 4
		local shade = (y % 4 == 0) and .8 or 1
		shade = shade - x * .1
		return 255 * shade, 40 * shade, 0
	end)

	ZVox.TextureOp("tnt_top", function()
		for y = 0, 4 do
			for x = 0, 4 do
				local xC = x * 4
				local yC = y * 4

				xC = xC + 1
				yC = yC + 1

				local val = .8 + math.random() * .2

				val = 160 * val
				surface.SetDrawColor(val, val, val)

				surface.DrawRect(xC, yC, 2, 2)
			end
		end



		for y = 0, 4, 2 do
			for x = 0, 4, 2 do
				local xC = x * 4
				local yC = y * 4

				xC = xC - 2
				yC = yC - 2

				if xC > 8 then
					xC = xC - 1
				end
				if yC > 8 then
					yC = yC - 1
				end

				surface.SetDrawColor(64, 64, 64)
				surface.DrawLine(xC + 1, yC + 1, 8.5, 8.5)
			end
		end
	end)
	ZVox.TextureHexWriteOp("tnt_top", {0x0, 0x380, 0xc40, 0x1000, 0x1080, 0x1710, 0x13a0, 0xfe0, 0x7f0, 0x1c0, 0x520, 0x0, 0x0, 0x0, 0x0, 0x0, }, 16, 16, 16)


	ZVox.NewTexturePixelFunc("tnt_bottom", function(x, y)
		-- TNT/dynamite top/bottom
		x = x % 4
		local shade = (y % 4 == 0) and .8 or 1
		shade = shade - x * .1
		return 255 * shade, 40 * shade, 0
	end)

	ZVox.NewTextureAnimated("mothervox_shop_ore", {
		["frames"] = 4,
		["speed"] = 0.05,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			if isTextureBorder(x, y) then
				local val = .8 + ZVox.ConsistentRandom() * .05

				if (x + y) % 2 == 0 then
					return val * 140, val * 120, val * 20
				end

				return val * 20, val * 20, val * 20
			end

			if y > 3 then
				local ySub = (y - 3) / (14 - 3)
				ySub = ySub * 5


				if (x < ySub) or x > (15 - ySub) then
					local xDiff = 0
					if x < ySub then
						xDiff = (x - ySub) / ySub
						xDiff = 1 - xDiff
					else
						xDiff = (ySub - ((15 - ySub) - x)) / ySub
					end

					local val = .8 + ZVox.ConsistentRandom() * .05

					val = (val * .8) - (xDiff * .2)

					return val * 110, val * 110, val * 110
				end
			end

			local val = .95 + ZVox.ConsistentRandom() * .1

			local atan_d1 = (math.deg(math.atan2(1 - x, 8 - y)) + 180) / 360
			atan_d1 = atan_d1 + (delta / 8)
			atan_d1 = atan_d1 % 1

			local dist_sub_d1 = ((atan_d1 * 128) % 16) / 16
			dist_sub_d1 = dist_sub_d1 * 3

			local d1 = math.Distance(x, y, 1, 8)
			if d1 < (7.5 - dist_sub_d1) then
				if d1 < 1.2 then
					return 0, 0, 0
				end

				local dDelta = (d1 / (7.5 - dist_sub_d1))
				dDelta = dDelta ^ 3
				dDelta = 1 - dDelta
				local sawVal = .6 + (dDelta * .4)

				return sawVal * 120, sawVal * 140, sawVal * 255
			end

			local atan_d2 = (math.deg(math.atan2(14 - x, 8 - y)) + 180) / 360
			atan_d2 = atan_d2 - (delta / 8)
			atan_d2 = atan_d2 % 1

			local dist_sub_d2 = ((atan_d2 * 128) % 16) / 16
			dist_sub_d2 = dist_sub_d2 * 3

			local d2 = math.Distance(x, y, 14, 8)
			if d2 < (7.5 - dist_sub_d2) then
				if d2 < 1.2 then
					return 0, 0, 0
				end

				local dDelta = (d2 / (7.5 - dist_sub_d2))
				dDelta = dDelta ^ 3
				dDelta = 1 - dDelta
				local sawVal = .6 + (dDelta * .4)

				return sawVal * 120, sawVal * 140, sawVal * 255
			end

			return val * 64, val * 64, val * 64
		end)
	end)
	ZVox.SetTextureEmissive("mothervox_shop_ore", true)


	ZVox.NewTextureAnimated("mothervox_shop_fuel", {
		["frames"] = 4,
		["speed"] = 0.2,
	}, function(name, delta, frame)
		local glassPerc = .6


		ZVox.TextureOpPixelFunc(name, function(x, y)
			if isTextureBorder(x, y) then
				local val = .8 + ZVox.ConsistentRandom() * .05

				if (x + y) % 2 == 0 then
					return val * 20, val * 140, val * 60
				end

				return val * 20, val * 20, val * 20
			end

			if inbox(x, y, 1, 1, 4, 8) then
				if y == 1 or y == 1 + 8 then
					local val = .8 + ZVox.ConsistentRandom() * .2
					val = val * 64

					return val, val, val
				end

				local xD = localizedDelta(x, 1, 1 + 4)
				xD = (.5 - math.abs(xD - .5)) * 2
				xD = math.max(xD, .1)
				xD = math.ease.OutExpo(xD)

				local glassVal = .75 + (xD * .2) + (ZVox.ConsistentRandom() * .05)
				glassVal = glassVal * 128

				local waterVal = .8 + math.random() * .2

				if (y - 1) > 2 then
					return Lerp(glassPerc, waterVal * 255, glassVal), Lerp(glassPerc, waterVal * 96, glassVal), Lerp(glassPerc, waterVal * 16, glassVal)
				end

				return glassVal, glassVal, glassVal
			end

			if inbox(x, y, 1, 9, 4, 5) then
				if y == 9 or y == 9 + 5 then
					local val = .8 + ZVox.ConsistentRandom() * .2
					val = val * 64

					return val, val, val
				end

				local xD = localizedDelta(x, 1, 1 + 4)
				xD = (.5 - math.abs(xD - .5)) * 2
				xD = math.max(xD, .1)
				xD = math.ease.OutExpo(xD)

				local glassVal = .75 + (xD * .2) + (ZVox.ConsistentRandom() * .05)
				glassVal = glassVal * 128

				local waterVal = .8 + math.random() * .2

				if (y - 9) > 1 then
					return Lerp(glassPerc, waterVal * 255, glassVal), Lerp(glassPerc, waterVal * 16, glassVal), Lerp(glassPerc, waterVal * 96, glassVal)
				end

				return glassVal, glassVal, glassVal
			end

			if inbox(x, y, 7, 1, 6, 13) then
				if y == 1 or y == 1 + 13 then
					local val = .8 + ZVox.ConsistentRandom() * .2
					val = val * 64

					return val, val, val
				end

				local xD = localizedDelta(x, 7, 7 + 6)
				xD = (.5 - math.abs(xD - .5)) * 2
				xD = math.max(xD, .1)
				xD = math.ease.OutExpo(xD)

				local glassVal = .75 + (xD * .2) + (ZVox.ConsistentRandom() * .05)
				glassVal = glassVal * 128

				local waterVal = .8 + math.random() * .2

				if (y - 1) > 3 then
					return Lerp(glassPerc, waterVal * 64, glassVal), Lerp(glassPerc, waterVal * 255, glassVal), Lerp(glassPerc, waterVal * 196, glassVal)
				end

				return glassVal, glassVal, glassVal
			end


			local val = .95 + ZVox.ConsistentRandom() * .1
			return val * 32, val * 32, val * 32
		end)
	end)
	ZVox.SetTextureEmissive("mothervox_shop_fuel", true)

	local function gearShaper(x)
		if x < .25 then
			return x * (1 / .25)
		end
		if x >= .25 and x <= .75 then
			return 1
		end
		if x > .75 then
			return (1 - x) * (1 / .25)
		end
	end

	local function gear(x, y, delta, oX, oY, sz, innerSz, gearToothSize, dirFlip, r, g, b)
		local atanVal = (math.deg(math.atan2(oX - x, oY - y)) + 180) / 360
		atanVal = atanVal + ((delta / 4) * (dirFlip and 1 or -1))
		atanVal = atanVal % 1

		local distSub = (atanVal * 8) % 1
		distSub = gearShaper(distSub)
		distSub = 1 - distSub
		distSub = math.min(distSub, .5)

		distSub = distSub * gearToothSize

		local dist = math.Distance(x, y, oX, oY)
		if dist < (sz - distSub) then
			if dist < innerSz then
				return
			end

			return r, g, b
		end
	end

	-- glxgears my beloved
	ZVox.NewTextureAnimated("mothervox_shop_parts", {
		["frames"] = 8,
		["speed"] = 0.1,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			if isTextureBorder(x, y) then
				local val = .8 + ZVox.ConsistentRandom() * .05

				if (x + y) % 2 == 0 then
					return val * 20, val * 40, val * 220
				end

				return val * 20, val * 20, val * 20
			end

			local val = .95 + ZVox.ConsistentRandom() * .1
			local glassMix = 0.6
			local glassVal = .85 + ZVox.ConsistentRandom() * .15
			glassVal = glassVal * 140

			local r, g, b

			r, g, b = gear(
			x, y, delta,
			3, 1,
			5, 2.5, 3, true,
			48, 48, 242)
			if r and g and b then
				return glassLerp(glassMix, glassVal, r, g, b)
			end

			r, g, b = gear(
			x, y, delta,
			5, 10,
			7, 1.5, 4, false,
			143, 24, 0)
			if r and g and b then
				return glassLerp(glassMix, glassVal, r, g, b)
			end

			r, g, b = gear(
			x, y, delta,
			14, 8,
			5, 1.25, 3, true,
			0, 193, 48)
			if r and g and b then
				return glassLerp(glassMix, glassVal, r, g, b)
			end

			return glassLerp(glassMix, glassVal, val * 24, val * 24, val * 24)
		end)

		ZVox.TextureOp(name, function()
		for x = 1, 16, 5 do
			for y = -1, 16, 5 do
				local oX = x
				local oY = y

				local length = math.floor(2 + (ZVox:ConsistentRandom() * 2))

				local valRG = .7 + ZVox:ConsistentRandom() * .1
				local valB = .8 + math.random() * .2

				surface.SetDrawColor(valRG * 255, valRG * 255, valB * 255)
				ZVox.BresenhamLine(oX, oY, oX + length, oY - length)
			end
		end
		end)
	end)
	ZVox.SetTextureEmissive("mothervox_shop_parts", true)


	ZVox.NewTextureAnimated("mothervox_shop_consumables", {
		["frames"] = 16,
		["speed"] = 0.15,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			local niceDelta = (.5 - math.abs(delta - .5)) * 2
			if isTextureBorder(x, y) then
				local val = .8 + ZVox.ConsistentRandom() * .05

				if (x + y) % 2 == 0 then
					return val * 220, val * 40, val * 20
				end

				return val * 20, val * 20, val * 20
			end

			local glassMix = 0.6
			local glassVal = .85 + ZVox.ConsistentRandom() * .15
			glassVal = glassVal * 140


			local pistonVal = .95 + ZVox.ConsistentRandom() * .05
			local backgroundVal = .8 + ZVox.ConsistentRandom() * .2
			local pistonValHammer = .8 + ZVox.ConsistentRandom() * .2

			-- conveyor
			if y > 10 then
				if (y > 11) and (y < 14) then

					if (x % 3) > 0 then
						--if (x + y + frame) % 2 == 0 then
						--	return 96, 96, 96
						--end

						local frameIdx = (frame + math.floor(x / 3)) % 4
						if frameIdx == 0 then
							if ((x % 3) == 1) and (y == 12) then
								return glassLerp(glassMix, glassVal, 96, 96, 96)
							end
						elseif frameIdx == 1 then
							if ((x % 3) == 2) and (y == 12) then
								return glassLerp(glassMix, glassVal, 96, 96, 96)
							end
						elseif frameIdx == 2 then
							if ((x % 3) == 2) and (y == 13) then
								return glassLerp(glassMix, glassVal, 96, 96, 96)
							end
						elseif frameIdx == 3 then
							if ((x % 3) == 1) and (y == 13) then
								return glassLerp(glassMix, glassVal, 96, 96, 96)
							end
						end

						return glassLerp(glassMix, glassVal, 84, 84, 84)
					end

					return glassLerp(glassMix, glassVal, 64, 64, 64)
				end

				if y > 13 then
					if (math.floor((x + frame) / 2) % 2) > 0 then
						return glassLerp(glassMix, glassVal, 48, 48, 48)
					end
				else
					if (math.floor((x - frame) / 2) % 2) > 0 then
						return glassLerp(glassMix, glassVal, 48, 48, 48)
					end
				end

				return glassLerp(glassMix, glassVal, 32, 32, 32)
			end

			local pistonDelta = math.ease.InExpo(niceDelta)


			-- piston
			if inbox(x, y, 6.5, 1, 2, 3 + math.floor(pistonDelta * 3)) then
				if (x + y + math.floor(pistonDelta * 4)) % 2 == 0 then
					return glassLerp(glassMix, glassVal, pistonVal * 128, pistonVal * 128, pistonVal * 128)
				end

				return glassLerp(glassMix, glassVal, pistonVal * 148, pistonVal * 148, pistonVal * 148)
			end

			if inbox(x, y, 4.5, 5 + math.floor(pistonDelta * 3), 6, 1) then
				return glassLerp(glassMix, glassVal, pistonValHammer * 64, pistonValHammer * 64, pistonValHammer * 64)
			end

			local boxSquashed = false

			if delta > .5 then
				boxSquashed = true
			end

			--if x > 9 then
			--	boxSquashed = true
			--end

			-- the box that we stamp
			if inbox(x, y, -3 + math.floor(delta * 19), 8 + (boxSquashed and 2 or 0), 3, boxSquashed and 0.5 or 2) then
				local yD = y - 8
				if boxSquashed then
					yD = yD / 1
					return glassLerp(glassMix, glassVal, 240, 196, 48)
				end

				yD = yD / 2
				return glassLerp(glassMix, glassVal, Lerp(yD, 255, 240), Lerp(yD, 96, 196), Lerp(yD, 32, 48))
			end


			return glassLerp(glassMix, glassVal, backgroundVal * 64, backgroundVal * 32, backgroundVal * 100)
		end)

		ZVox.TextureOp(name, function()
			for x = 3, 16, 8 do
				for y = -3, 16, 8 do
					local oX = x
					local oY = y

					local length = math.floor(2 + (ZVox:ConsistentRandom() * 2))

					local valRG = .7 + ZVox:ConsistentRandom() * .1
					local valB = .8 + math.random() * .2

					surface.SetDrawColor(valRG * 255, valRG * 255, valB * 255)
					ZVox.BresenhamLine(oX, oY, oX + length, oY - length)
				end
			end
		end)
	end)
	ZVox.SetTextureEmissive("mothervox_shop_consumables", true)
end