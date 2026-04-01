ZVox = ZVox or {}

local math = math
local math_abs = math.abs
local math_random = math.random


local sunVec = Vector(.4, .4, 2.5)
sunVec:Normalize()
function ZVox.OreTextureOp(name, cR, cG, cB, spec, specMul)
	specMul = specMul or 1
	ZVox.TextureOpPixelFunc(name, function(x, y)
		local edgeDist = math.max(math.abs(x - 7.5), math.abs(y - 7.5))
		edgeDist = edgeDist / 7.5
		edgeDist = edgeDist ^ 4

		if edgeDist >= 1 then
			return
		end

		local xOff = 34.546
		local yOff = 14.5

		local sclX = 1.6
		local sclY = 6.7
		local xC = x / 16
		local yC = y / 16

		local xSample = xOff + xC * sclX
		local ySample = yOff + yC * sclY
		local spxVal = ZVox.Simplex2D(xSample, ySample)
		spxVal = (spxVal + 1) * .5
		local perc = .6
		local truPerc = perc + (edgeDist * (1 - perc))
		if spxVal < truPerc then
			return
		end

		local norm = ZVox.NormalFromNoiseFunc(ZVox.Simplex2D, xSample, ySample, .025, true, 8)
		local sunDot = norm:Dot(sunVec)
		sunDot = (sunDot * .975) + (math.random() * .025)
		sunDot = sunDot ^ spec
		sunDot = sunDot * specMul

		local diff = (spxVal - perc) / perc
		diff = diff * 8
		diff = math.min(diff, 1)

		--local rCalc = (norm[1] + 1) * 127
		--local gCalc = (norm[2] + 1) * 127
		--local bCalc = (norm[3] + 1) * 127
		local rCalc = cR + (sunDot * 255)
		local gCalc = cG + (sunDot * 255)
		local bCalc = cB + (sunDot * 255)

		local aCalc = diff

		return math.min(rCalc, 255), math.min(gCalc, 255), math.min(bCalc, 255), aCalc * 255
	end)
end

function ZVox.NewOreTexture(name, cR, cG, cB, spec, specMul)
	ZVox.NewTexturePixelFunc(name, function(x, y)
		if .02 > ZVox.ConsistentRandom() then
			local val = .7 + ZVox.ConsistentRandom() * .3
			return 100 * val, 100 * val, 100 * val
		end

		local val = .5 + (ZVox.ConsistentRandom() * .5)

		return val * 128, val * 80, val * 40
	end)

	ZVox.OreTextureOp(name, cR, cG, cB, spec, specMul)
end

function ZVox.ComputeStoneTextures()
	ZVox.NewTexturePixelFunc("stone", function(x, y)
		local val = .5 + ZVox.Simplex2D(1 + x * .25, 1 + y) * .5
		val = .4 + val * .15 + math.random() * .05

		return val * 255, val * 255, val * 255
	end)

	ZVox.NewOreTexture("coal_ore", 12, 12, 12, 16, .4)
	ZVox.NewOreTexture("copper_ore", 156, 48, 12, 24, .8)
	
	ZVox.NewOreTexture("iron_ore", 156, 136, 120, 32, .4)
	ZVox.NewOreTexture("silver_ore", 156, 156, 188, 48, 1)

	ZVox.NewOreTexture("gold_ore", 198, 164, 38, 52, 1.5)
	ZVox.NewOreTexture("diamond_ore", 88, 202, 204, 72, 4)
	ZVox.NewOreTexture("uranium_ore", 24, 121, 24, 16, .2)

	ZVox.NewTextureAnimated("temporalium_ore", {
		["frames"] = 16,
		["speed"] = 0.2,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			if .02 > ZVox.ConsistentRandom() then
				local val = .7 + ZVox.ConsistentRandom() * .3
				return 100 * val, 100 * val, 100 * val
			end

			local val = .5 + (ZVox.ConsistentRandom() * .5)

			return val * 128, val * 80, val * 40
		end)


		ZVox.TextureOpPixelFunc(name, function(x, y)
			local edgeDist = math.max(math.abs(x - 7.5), math.abs(y - 7.5))
			edgeDist = edgeDist / 7.5
			edgeDist = edgeDist ^ 4

			if edgeDist >= 1 then
				return
			end

			local xOff = 34.546
			local yOff = 14.5

			local sclX = 2.6
			local sclY = 3.2
			local xC = x / 16
			local yC = y / 16

			local xSample = xOff + xC * sclX
			local ySample = yOff + yC * sclY
			local spxVal = ZVox.Simplex2D(xSample, ySample)
			spxVal = (spxVal + 1) * .5
			local perc = .4
			local truPerc = perc + (edgeDist * (1 - perc))
			if spxVal < truPerc then
				return
			end
			
			local xS = x * 0.14
			local yS = y * 0.14

			local deltaNice = .5 - math.abs(delta - .5)
			local spx = ZVox.Worley3D(xS, yS, deltaNice * 4)
			spx = spx

			local baseR, baseG, baseB = 48, 32, 96
			baseR = baseR + (spx * 128)
			baseG = baseG + (spx * 32)
			baseB = baseB + (spx * 255)


			if math_random() > .85 then
				baseR = baseR + 64
				baseG = baseG + 32
				baseB = baseB + 64
			end

			baseR = math.min(baseR, 255)
			baseG = math.min(baseG, 255)
			baseB = math.min(baseB, 255)


			return baseR, baseG, baseB
		end)
	end)
	ZVox.SetTextureEmissive("temporalium_ore", true)

	ZVox.NewTexturePixelFunc("bedrock", function(x, y)
		local val = .5 + ZVox.Simplex2D(1 + x * .25, 1 + y) * .5
		val = val + math.random() * .1
		val = .1 + ( val ^ 3 * .3 )

		return val * 255, val * 255, val * 255
	end)

	ZVox.NewTexturePixelFunc("etherealstone", function(x, y)
		local val = .8 + ZVox.Simplex2D(1 + x * .1, 1 + y * .4) * .2
		val = val + math.random() * .1
		val = .1 + ( val ^ 4 * .3 )

		return val * 220, val * 140, val * 240
	end)
	ZVox.NewOreTexture("voidinium_ore", 255, 0, 68, 32, 1.5)

	local function smallCircleDistFunc(p1, p2)
		return (p1 - p2):Length() * 1.15
	end

	local sunVec2 = Vector(-.4, -.3, 2.5)
	sunVec2:Normalize()
	ZVox.NewTexturePixelFunc("cobble", function(x, y)
		local xOff = 44.8
		local yOff = 62.9

		local sclX = 3.6
		local sclY = 3.3
		local xC = x / 16
		local yC = y / 16



		local xSample = xOff + xC * sclX
		local ySample = yOff + yC * sclY
		local noiseVal = ZVox.Worley2D(xSample, ySample)
		noiseVal = 1 - noiseVal
		local val = ZVox.Worley2D(xSample, ySample, 0, smallCircleDistFunc, 1)
		val = 1 - val

		if false then
			return val * 255, val * 255, val * 255
		end

		-- InOutExpo
		-- InOutQuint
		-- InOutQuad
		local norm = ZVox.NormalFromNoiseFunc(function(nX, nY)
			return ZVox.Worley2D(nX, nY, 0, smallCircleDistFunc, 1)
		end, xSample, ySample, .05, false, 4, math.ease.InOutQuad)
		if false then
			return (norm[1] + 1) * 127, (norm[2] + 1) * 127, (norm[3] + 1) * 127
		end


		local sunDot = norm:Dot(sunVec2)
		sunDot = (sunDot * .975) + (math.random() * .025)
		sunDot = sunDot ^ 2
		sunDot = sunDot * .55
		--sunDot = math.max(math.min(sunDot, 1), .2)

		local sunDot2 = norm:Dot(sunVec2)
		sunDot2 = (sunDot2 * .975) + (math.random() * .025)
		sunDot2 = sunDot2 ^ 24
		sunDot2 = sunDot2 * .2

		local out = math.min(sunDot + sunDot2, 1) * 255
		--out = math.min(math.max())

		return out, out, out
	end)

	ZVox.NewTexturePixelFunc("tile", function(x, y)
		local checkCase1 = (x < 8 and y < 8)
		local checkCase2 = (y > 7 and x > 7)
		local isCheck = checkCase1 or checkCase2

		local noise = .8 + (math_random() * .2)

		if isCheck then
			return noise * 140, noise * 140, noise * 140
		else
			return noise * 196, noise * 196, noise * 196
		end
	end)
	ZVox.BevelOp("tile", 64, 64, 64, 96)

	ZVox.NewTexturePixelFunc("dark_tile", function(x, y)
		local checkCase1 = (x < 8 and y < 8)
		local checkCase2 = (y > 7 and x > 7)
		local isCheck = checkCase1 or checkCase2

		local noise = .8 + (math_random() * .2)

		if isCheck then
			return noise * 40, noise * 40, noise * 40
		else
			return noise * 74, noise * 74, noise * 74
		end
	end)
	ZVox.BevelOp("dark_tile", 24, 24, 24, 96)

	ZVox.NewTexturePixelFunc("pillar", function(x, y)
		local val = .9 + (math_random() * .1)

		return val * 250, val * 250, val * 250
	end)

	ZVox.TextureOp("pillar", function()
		for x = 1, 16, 4 do
			surface.SetDrawColor(210, 210, 210)
			surface.DrawRect(x, 0, 1, 16)

			surface.SetDrawColor(190, 190, 190)
			surface.DrawRect(x + 1, 0, 1, 16)
		end
	end)

	ZVox.NewTexturePixelFunc("pillar_top", function(x, y)
		local val = .9 + (math_random() * .1)

		return val * 200, val * 200, val * 200
	end)

	ZVox.BevelOp("pillar_top", 20, 20, 20, 96)


	ZVox.NewTexturePixelFunc("marble", function(x, y)
		local dist = 0.5
		local normal =  ZVox.NormalFromNoiseFunc(ZVox.Simplex2D, x * .2, y * .2, dist, true)

		normal[1] = normal[1]
		normal[2] = normal[2]
		normal:Normalize()

		local normalDot = normal:Dot(Vector(0.35, 0.6, 8):GetNormalized())

		normalDot = normalDot ^ 32
		normalDot = normalDot * .5

		local fVal = 1 - normalDot
		return fVal * 255, fVal * 255, fVal * 255
	end)
end
