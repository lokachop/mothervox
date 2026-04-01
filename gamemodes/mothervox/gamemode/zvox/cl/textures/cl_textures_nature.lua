ZVox = ZVox or {}

local math = math
local math_random = math.random


local function decLimit(v, mul)
	return math.floor(v * mul) / mul
end

local sunVec = Vector(-.4, -.6, 2.5)
sunVec:Normalize()
function ZVox.ComputeNatureTextures()
	ZVox.NewTexturePixelFunc("grass", function(x, y)
		local val = .7 + (math_random() * .3)

		return val * 56, val * 91, val * 29
	end)

	ZVox.NewTexturePixelFunc("grass_side", function(x, y)
		if y < 2.5 + (math_random() * 4) then
			local val = .7 + (math_random() * .3)

			return val * 56, val * 91, val * 29
		else
			if .02 > math_random() then
				local val = .7 + math_random() * .3
				return 100 * val, 100 * val, 100 * val
			end

			local val = .5 + (math_random() * .5)

			return val * 128, val * 80, val * 40
		end
	end)

	ZVox.NewTexturePixelFunc("dirt", function(x, y)
		if .02 > math_random() then
			local val = .7 + math_random() * .3
			return 100 * val, 100 * val, 100 * val
		end

		local val = .5 + (math_random() * .5)

		return val * 128, val * 80, val * 40
	end)


	ZVox.NewTexturePixelFunc("rock_dirt", function(x, y)

		local cdX = math.abs((x - 7.5) / 8) + (math_random() * .3)
		local cdY = math.abs((y - 7.5) / 8) + (math_random() * .3)

		local cdT = math.max(cdX, cdY) * 1.0

		local blend = (1 - cdT) * 3
		blend = math.min(blend, 1)

		local stoneVal = .7 + math_random() * .1
		stoneVal = stoneVal * 200
		local stoneR, stoneG, stoneB = stoneVal, stoneVal, stoneVal

		if .02 > math_random() then
			local val = .7 + math_random() * .3
			val = val * 100
			return Lerp(blend, val, stoneR), Lerp(blend, val, stoneG), Lerp(blend, val, stoneB)
		end

		local val = .5 + (math_random() * .5)

		return Lerp(blend, val * 128, stoneR), Lerp(blend, val * 80, stoneG), Lerp(blend, val * 40, stoneB)
	end)


	ZVox.NewTextureAnimated("magma", {
		["frames"] = 16,
		["speed"] = 0.1,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			local cr1 = ZVox.ConsistentRandom()
			local cr2 = ZVox.ConsistentRandom()


			local cdX = math.abs((x - 7.5) / 8) + (ZVox.ConsistentRandom() * .3)
			local cdY = math.abs((y - 7.5) / 8) + (ZVox.ConsistentRandom() * .3)

			local cdT = math.max(cdX, cdY) * 1.1

			local xS = x * 0.24
			local yS = y * 0.24

			local deltaNice = .5 - math.abs(delta - .5)
			local spx = ZVox.Worley3D(xS, yS, deltaNice * 2)
			spx = spx

			local blend = (1 - cdT) * 3
			blend = math.min(blend, 1)


			local lavaR, lavaG, lavaB = 255, 32 + (spx * 222), 24 + (spx * 40)

			if .02 > cr1 then
				local val = .7 + ZVox.ConsistentRandom() * .3
				return Lerp(blend, 100 * val, lavaR), Lerp(blend, 100 * val, lavaG), Lerp(blend, 100 * val, lavaB)
			end

			local val = .5 + (cr2 * .5)

			return Lerp(blend, val * 128, lavaR), Lerp(blend, val * 80, lavaG), Lerp(blend, val * 40, lavaB)
		end)
	end)
	ZVox.SetTextureEmissive("magma", true)


	ZVox.NewTextureAnimated("infuriating_citron", {
		["frames"] = 8,
		["speed"] = 0.1,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			local niceDelta = (.5 - math.abs(delta - .5)) * 2

			local dist = math.Distance(x, y, 7.5, 7.5)

			if dist < 6 then

				if y == 5 then
					if x > 3 and x < 12 and x ~= 7 and x ~= 8 then
						return 0, 0, 0
					end
				end


				if y > 7 and y < (12 - niceDelta * 3) then
					if dist < 3 and y > 8 then
						return 220, 220, 220
					end

					if dist < 4 then
						return 0, 0, 0
					end
				end

				return 255, 128, 32
			end

			return 0, x * 16, y * 16
		end)

		ZVox.TextureOp(name, function()
			surface.SetDrawColor(96, 255, 64)
			ZVox.BresenhamLine(8, 2, 10, 0)
		end)
	end)


	ZVox.NewTextureAnimated("unobtainalum", {
		["frames"] = 32,
		["speed"] = 0.1,
	}, function(name, delta, frame)
		ZVox.TextureOpPixelFunc(name, function(x, y)
			local niceDelta = 1 - (math.abs(.5 - delta) * 2)

			local xS = x * .25 + (y * .15 + niceDelta * 2)
			local yS = y * .225
			local spx = ZVox.Worley3D(xS, yS, niceDelta)
			spx = 1 - spx

			local hsvVal = HSVToColor(180 + (spx * 40), 0.9, 1)


			return hsvVal.r, hsvVal.g, hsvVal.b
		end)
	end)
	ZVox.SetTextureEmissive("unobtainalum", true)

end