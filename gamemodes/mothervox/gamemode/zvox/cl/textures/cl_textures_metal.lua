ZVox = ZVox or {}

local math = math
local math_abs = math.abs

local thickLineCount = 2
local function thickLine(x, y, eX, eY, startAlp, endAlp)
	for i = 0, thickLineCount do
		local delta = i / thickLineCount


		local alpha = Lerp(delta, startAlp, endAlp)

		surface.SetDrawColor(0, 0, 0, alpha)
		surface.DrawLine(x + i, y, eX + i, eY)
	end
end

local function inrange(x, a, b)
	return x >= a and x < b
end

local function isTextureBorder_Width(x, y, width)
	width = width or 1
	return (inrange(x, 0, width) or inrange(x, 16 - width, 16)) or (inrange(y, 0, width) or inrange(y, 16 - width, 16))
end



function ZVox.SheetMetalOp(name, alphaStart, alphaEnd)
	ZVox.TextureOp(name, function()
		for i = 0, 16, 4 do
			local idx = i

			thickLine(idx, 0, idx, 16, alphaStart, alphaEnd)
		end

		surface.SetDrawColor(0, 0, 0, alphaStart)

		local distX, distY = 1, 1
		surface.DrawRect(     distX,      distY, 1, 1)
		surface.DrawRect(15 - distX,      distY, 1, 1)
		surface.DrawRect(     distX, 15 - distY, 1, 1)
		surface.DrawRect(15 - distX, 15 - distY, 1, 1)
	end)
end

--
-- Shiny Metal Blocks
--
local _SUNDIR = Vector(0.215, 1, -4)
_SUNDIR:Normalize()

local function c_mul(c, mul)
	return Color(c.r * mul, c.g * mul, c.b * mul)
end

function ZVox.MetallicBlockTextureGenners(name, colours)
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
	local sR = subtractive[1]
	local sG = subtractive[2]
	local sB = subtractive[3]


	ZVox.NewTexturePixelFunc(name .. "_top", function(x, y)
		-- generate a normal and do lighting
		local x1 = x + 14
		local y1 = y + 12 --y + 4

		local xC = x1 / 16
		local yC = y1 / 16

		local _mul = .25
		local spxX = ZVox.Simplex2D(xC * _mul, yC * _mul)

		local val = (math.random() * 2) - 1
		val = val * .25

		local norm = Vector(spxX * 2, val, 1)
		norm:Normalize()

		local dot = -_SUNDIR:Dot(norm)
		dot = 1 - dot
		dot = math.min(math.max(dot, 0), 1)

		-- dot is to lerp
		local colHigh = cHighest
		local colLow = cHigher
		local colLerp = ZVox.NiceLerpColor(dot, colLow, colHigh)

		return colLerp.r, colLerp.g, colLerp.b
	end)

	ZVox.BevelPixelFuncOp(name .. "_top", function(x, y)
		local cR, cG, cB = cHigher.r - sR, cHigher.g - sG, cHigher.b - sB
		local val = .8 + math.random() * .2

		return cR, cG, cB, val * 255
	end)



	local sideGradMetal = {
		{["e"] =  0, ["c"] = cHigher}, -- e marks where it ends, lerps from the previous value
		{["e"] =  .45, ["c"] = cHigh},
		{["e"] =  .65, ["c"] = cLow},
		{["e"] =  1, ["c"] = cLower},
	}

	ZVox.NewTexturePixelFunc(name .. "_side", function(x, y)
		local yc = y

		local nsAdd = ZVox.Simplex2D(x * .1, 73476)
		nsAdd = (nsAdd + 1) * .5
		nsAdd = nsAdd * 2

		yc = (yc + nsAdd)

		local yD = yc / 16
		yD = math.min(yD, 1)

		local cR, cG, cB = ZVox.GetColorAtGradientPoint(yD, sideGradMetal)
		return cR, cG, cB
	end)


	local sideGradBorderMetal = {
		{["e"] =  0, ["c"] = c_mul(cHigh, .85)}, -- e marks where it ends, lerps from the previous value
		{["e"] =  .3, ["c"] = c_mul(cHigher, .85)},
		{["e"] =  .55, ["c"] = c_mul(cLow, .85)},
		{["e"] =  1, ["c"] = c_mul(cLower, .85)},
	}
	ZVox.BevelPixelFuncOp(name .. "_side", function(x, y)
		local yc = y

		local nsAdd = ZVox.Simplex2D(x * .1, 73476)
		nsAdd = (nsAdd + 1) * .5
		nsAdd = nsAdd * 3

		yc = (yc + nsAdd)
		local yD = yc / 16
		yD = math.min(yD, 1)

		local cR, cG, cB = ZVox.GetColorAtGradientPoint(yD, sideGradBorderMetal)
		return cR, cG, cB
	end)


	ZVox.NewTexturePixelFunc(name .. "_bottom", function(x, y)
		-- generate a normal and do lighting
		local x1 = x + 14
		local y1 = y + 12 --y + 4


		local xC = x1 / 16
		local yC = y1 / 16

		local _mul = .25
		local spxX = ZVox.Simplex2D(xC * _mul, yC * _mul)

		local val = (math.random() * 2) - 1
		val = val * .25

		local norm = Vector(spxX * 2, val, 1)
		norm:Normalize()

		local dot = -_SUNDIR:Dot(norm)
		dot = 1 - dot
		dot = math.min(math.max(dot, 0), 1)

		-- dot is to lerp
		local colHigh = cLow
		local colLow = cLower
		local colLerp = ZVox.NiceLerpColor(dot, colLow, colHigh)

		return colLerp.r, colLerp.g, colLerp.b
	end)
	ZVox.BevelPixelFuncOp(name .. "_bottom", function(x, y)
		local cR, cG, cB = cLower.r - sR, cLower.g - sG, cLower.b - sB
		local val = .8 + math.random() * .2

		return cR, cG, cB, val * 255
	end)
end

local function normDistTo(x, y, tX, tY)
	local diffX = math.abs(x - tX)
	diffX = diffX / 16

	local diffY = math.abs(y - tY)
	diffY = diffY / 16

	return (diffX + diffY) / 2
end

function ZVox.CasingBlockTextureGen(name, colours)
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

	ZVox.NewTexturePixelFunc(name .. "_casing", function(x, y)
		local delta = normDistTo(x, y, 0, 0)


		-- dot is to lerp
		local colHigh = cHighest
		local colLow = cLow
		local colLerp = ZVox.LerpColor(delta, colHigh, colLow)

		return colLerp.r, colLerp.g, colLerp.b
	end)

	ZVox.TextureHexMaskOp(name .. "_casing", {0xffff, 0x8001, 0xa425, 0x8001, 0x8001, 0xa005, 0x8001, 0x8001, 0x8001, 0x8001, 0xa005, 0x8001, 0x8001, 0xa425, 0x8001, 0xffff, }, function(x, y)
		local delta = normDistTo(x, y, 0, 0)

		local colHigh = cHighest
		local colLow = cLow
		local colLerp = ZVox.LerpColor(delta, colHigh, colLow)

		return colLerp.r - sR, colLerp.g - sG, colLerp.b - sB
	end)
end


local function frameGenner(name, r, g, b)
	ZVox.NewTexturePixelFunc(name, function(x, y)
		local mul = .9 + math.random() * .1

		if isTextureBorder_Width(x, y, 2) then
			if y == 1 or y == 15 then
				mul = mul * .8
			end


			if inrange(y, 2, 14) and (x == 1 or x == 14) then
				mul = mul * .85
			end

			return r * mul, g * mul, b * mul
		end

		-- /
		local xyDist = math.abs(x - y)
		if xyDist < 2 then
			local diff = (x - y) + 1
			diff = diff / 2

			mul = mul * .8 + (diff * .2)

			return r * mul, g * mul, b * mul
		end
		if xyDist < 3 then
			return r * 0.65, g * 0.65, b * 0.65
		end


		-- \
		xyDist = math.abs(x - (15 - y))
		if xyDist < 2 then
			local diff = (x - (15 - y)) + 1
			diff = diff / 2
			diff = 1 - diff

			mul = mul * .7 + (diff * .3)

			return r * mul, g * mul, b * mul
		end

		if xyDist < 3 then
			return r * .58, g * .58, b * .58
		end

		return 0, 0, 0, 0
	end)
end


function ZVox.ComputeMetalTextures()
	ZVox.MetallicBlockTextureGenners("gold", {
		["highest"] = Color(250, 250, 170),
		["higher"] = Color(198, 164, 38),
		["high"] = Color(204, 202, 88),
		["low"] = Color(175, 103, 18),
		["lower"] = Color(157, 82, 20),

		["subtractive"] = {16, 16, 16},
	})

	ZVox.CasingBlockTextureGen("gold", {
		["highest"] = Color(250, 250, 170),
		["higher"] = Color(198, 164, 38),
		["high"] = Color(204, 202, 88),
		["low"] = Color(175, 103, 18),
		["lower"] = Color(157, 82, 20),

		["subtractive"] = {16, 16, 16},
	})

	--
	-- Metal
	--
	ZVox.MetallicBlockTextureGenners("metal", {
		["highest"] = Color(267, 267, 320),
		["higher"] = Color(212, 212, 255),
		["high"] = Color(262, 262, 314),
		["low"] = Color(156, 156, 188),
		["lower"] = Color(105, 105, 126),

		["subtractive"] = {24, 24, 24},
	})

	ZVox.CasingBlockTextureGen("metal", {
		["highest"] = Color(267, 267, 320),
		["higher"] = Color(212, 212, 255),
		["high"] = Color(262, 262, 314),
		["low"] = Color(156, 156, 188),
		["lower"] = Color(105, 105, 126),

		["subtractive"] = {24, 24, 24},
	})


	--
	-- Steel
	--
	ZVox.MetallicBlockTextureGenners("steel", {
		["highest"] = Color(157, 157, 220),
		["higher"] = Color(92, 92, 115),
		["high"] = Color(162, 162, 184),
		["low"] = Color(76, 76, 88),
		["lower"] = Color(65, 65, 76),

		["subtractive"] = {24, 24, 24},
	})

	ZVox.CasingBlockTextureGen("steel", {
		["highest"] = Color(187, 187, 220),
		["higher"] = Color(92, 92, 115),
		["high"] = Color(162, 162, 184),
		["low"] = Color(76, 76, 88),
		["lower"] = Color(65, 65, 76),

		["subtractive"] = {24, 24, 24},
	})


	-- 
	-- Diamond
	-- 
	ZVox.MetallicBlockTextureGenners("diamond", {
		["highest"] = Color(224, 255, 255),
		["higher"] = Color(38, 164, 198),
		["high"] = Color(88, 202, 204),
		["low"] = Color(18, 103, 175),
		["lower"] = Color(20, 82, 157),

		["subtractive"] = {16, 16, 16},
	})

	ZVox.CasingBlockTextureGen("diamond", {
		["highest"] = Color(224, 255, 255),
		["higher"] = Color(38, 164, 198),
		["high"] = Color(88, 202, 204),
		["low"] = Color(18, 103, 175),
		["lower"] = Color(20, 82, 157),

		["subtractive"] = {16, 16, 16},
	})

	--
	-- Voidinium
	--
	ZVox.MetallicBlockTextureGenners("voidinium", {
		["highest"] = Color(255, 0, 68),
		["higher"] = Color(175, 11, 55),
		["high"] = Color(205, 0, 55),
		["low"] = Color(109, 10, 37),
		["lower"] = Color(75, 8, 26),

		["subtractive"] = {16, 16, 16},
	})

	ZVox.CasingBlockTextureGen("voidinium", {
		["highest"] = Color(255, 0, 68),
		["higher"] = Color(175, 11, 55),
		["high"] = Color(205, 0, 55),
		["low"] = Color(109, 10, 37),
		["lower"] = Color(75, 8, 26),

		["subtractive"] = {16, 16, 16},
	})

	--
	-- Uranium
	--
	ZVox.MetallicBlockTextureGenners("uranium", {
		["highest"] = Color(30, 255, 60),
		["higher"] = Color(50, 218, 50),
		["high"] = Color(43, 255, 43),
		["low"] = Color(24, 121, 24),
		["lower"] = Color(17, 83, 17),

		["subtractive"] = {16, 16, 16},
	})

	ZVox.CasingBlockTextureGen("uranium", {
		["highest"] = Color(30, 255, 60),
		["higher"] = Color(50, 218, 50),
		["high"] = Color(43, 255, 43),
		["low"] = Color(24, 121, 24),
		["lower"] = Color(17, 83, 17),

		["subtractive"] = {16, 16, 16},
	})


	--
	-- Osmium
	--
	ZVox.MetallicBlockTextureGenners("osmium", {
		["highest"] = Color(30, 60, 255),
		["higher"] = Color(50, 50, 218),
		["high"] = Color(43, 43, 255),
		["low"] = Color(24, 24, 121),
		["lower"] = Color(17, 17, 83),

		["subtractive"] = {16, 16, 16},
	})

	ZVox.CasingBlockTextureGen("osmium", {
		["highest"] = Color(30, 60, 255),
		["higher"] = Color(50, 50, 218),
		["high"] = Color(43, 43, 255),
		["low"] = Color(24, 24, 121),
		["lower"] = Color(17, 17, 83),

		["subtractive"] = {16, 16, 16},
	})

	--
	-- Sheet Metal
	--
	ZVox.NewTexturePixelFunc("metal_sheetmetal", function(x, y)
		local mul = .9 + math.random() * .1

		return 220 * mul, 220 * mul, 220 * mul
	end)
	ZVox.SheetMetalOp("metal_sheetmetal", 128, 32)
	frameGenner("metal_frame", 220, 220, 220)

	ZVox.NewTexturePixelFunc("steel_sheetmetal", function(x, y)
		local mul = .9 + math.random() * .1

		return 96 * mul, 96 * mul, 96 * mul
	end)
	ZVox.SheetMetalOp("steel_sheetmetal", 128, 32)
	frameGenner("steel_frame", 96, 96, 96)

	ZVox.NewTexturePixelFunc("gold_sheetmetal", function(x, y)
		local mul = .9 + math.random() * .1

		return 196 * mul, 196 * mul, 64 * mul
	end)
	ZVox.SheetMetalOp("gold_sheetmetal", 128, 32)
	frameGenner("gold_frame", 196, 196, 64)

	ZVox.NewTexturePixelFunc("copper_sheetmetal", function(x, y)
		local mul = .9 + math.random() * .1

		return 220 * mul, 130 * mul, 51 * mul
	end)
	ZVox.SheetMetalOp("copper_sheetmetal", 128, 32)
	frameGenner("copper_frame", 220, 130, 51)

	ZVox.NewTexturePixelFunc("oxidized_copper_sheetmetal", function(x, y)
		local mul = .9 + math.random() * .1

		return 88 * mul, 175 * mul, 145 * mul
	end)
	ZVox.SheetMetalOp("oxidized_copper_sheetmetal", 128, 32)
	frameGenner("oxidized_copper_frame", 88, 175, 145)

	ZVox.NewTexturePixelFunc("uranium_sheetmetal", function(x, y)
		local mul = .9 + math.random() * .1

		return 125 * mul, 145 * mul, 115 * mul
	end)
	ZVox.SheetMetalOp("uranium_sheetmetal", 128, 32)
	frameGenner("uranium_frame", 125, 145, 115)

	ZVox.NewTexturePixelFunc("voidinium_sheetmetal", function(x, y)
		local mul = .9 + math.random() * .1

		return 205 * mul, 0 * mul, 55 * mul
	end)
	ZVox.SheetMetalOp("voidinium_sheetmetal", 128, 32)
	frameGenner("voidinium_frame", 205, 0, 55)

	ZVox.NewTexturePixelFunc("osmium_sheetmetal", function(x, y)
		local mul = .9 + math.random() * .1

		return 43 * mul, 43 * mul, 255 * mul
	end)
	ZVox.SheetMetalOp("osmium_sheetmetal", 128, 32)
	frameGenner("osmium_frame", 43, 43, 255)

end