ZVox = ZVox or {}

local function isTextureBorder(x, y)
	return (x == 0 or x == 15) or (y == 0 or y == 15)
end

local function normDistTo(x, y, tX, tY)
	local diffX = math.abs(x - tX)
	diffX = diffX / 16

	local diffY = math.abs(y - tY)
	diffY = diffY / 16

	return (diffX + diffY) / 2
end


function ZVox.ComputeCrystalTextures()
	ZVox.NewTexturePixelFunc("glass", function(x, y)
		if isTextureBorder(x, y) then
			local valRG = .7 + math.random() * .1
			local valB = .8 + math.random() * .2


			return valRG * 255, valRG * 255, valB * 255
		end

		local valRG = .75 + math.random() * .05
		local valB = .85 + math.random() * .1

		return valRG * 255, valRG * 255, valB * 255, 128 + 32 + (math.random() * 32)
	end)
	ZVox.TextureOp("glass", function()
		for x = 0, 16, 5 do
			for y = 0, 16, 5 do
				local oX = x
				local oY = y

				local length = math.random(2, 3)

				local valRG = .7 + math.random() * .1
				local valB = .8 + math.random() * .2

				surface.SetDrawColor(valRG * 255, valRG * 255, valB * 255)
				ZVox.BresenhamLine(oX, oY, oX + length, oY - length)
			end
		end
	end)


	ZVox.NewTexturePixelFunc("dark_glass", function(x, y)
		if isTextureBorder(x, y) then
			local valRGB = .2 + math.random() * .05

			return valRGB * 255, valRGB * 255, valRGB * 255
		end

		local valRGB = .25 + math.random() * .025
		return valRGB * 255, valRGB * 255, valRGB * 255, 235 + (math.random() * 16)
	end)
	ZVox.TextureOp("dark_glass", function()
		for x = 0, 16, 5 do
			for y = 0, 16, 5 do
				local oX = x
				local oY = y

				local length = math.random(2, 3)

				local valRGB = .2 + math.random() * .05

				surface.SetDrawColor(valRGB * 255, valRGB * 255, valRGB * 255)
				ZVox.BresenhamLine(oX, oY, oX + length, oY - length)
			end
		end
	end)

	ZVox.NewTexturePixelFunc("rainbow_glass", function(x, y)
		if isTextureBorder(x, y) then
			local valRGB = .8 + math.random() * .2

			return valRGB * 255, valRGB * 255, valRGB * 255, 255
		end

		local dY = y / 16

		local rVal = .8 + (math.random() * .2)
		rVal = rVal * 255

		local hsvCol = HSVToColor((dY * 360) % 360, 0.2, 1)


		local alpha = 200 + (math.random() * 20)
		return rVal * (hsvCol.r / 255), rVal * (hsvCol.g / 255), rVal * (hsvCol.b / 255), alpha
	end)

	ZVox.NewTexturePixelFunc("industrial_glass", function(x, y)
		if isTextureBorder(x, y) then
			local val = .9 + math.random() * .1

			local colR = 64
			local colG = 64
			local colB = 64

			if y == 15 or x == 15 then
				colR = colR + 32
				colG = colG + 32
				colB = colB + 32
			end

			return colR * val, colG * val, colB * val
		end

		local val = .6 + math.random() * .05

		return val * 255, val * 255, val * 255, 128 + (math.random() * 32)
	end)
	ZVox.TextureOp("industrial_glass", function()
		for x = 1, 13, 5 do
			for y = 3, 15, 5 do
				local oX = x
				local oY = y

				local length = math.random(2, 3)
				local length2 = math.random(1, 2)

				local val = .7 + math.random() * .2
				surface.SetDrawColor(val * 255, val * 255, val * 255)
				ZVox.BresenhamLine(oX, oY, oX + length, oY - length2)
			end
		end
	end)

	ZVox.NewTexturePixelFunc("plasma_glass", function(x, y)
		local dist = normDistTo(x, y, 12, 14)

		if isTextureBorder(x, y) then
			local valRGB = .65 + math.random() * .15

			dist = dist * .5

			local rCalc = valRGB * 255
			local gCalc = valRGB * 64
			local bCalc = valRGB * 240
			local aCalc = 235 + (math.random() * 20)

			rCalc = Lerp(dist, rCalc, 255)
			gCalc = Lerp(dist, gCalc, 255)
			bCalc = Lerp(dist, bCalc, 255)

			return rCalc, gCalc, bCalc, aCalc
		end

		local valRGB = .85 + math.random() * .15

		local rCalc = valRGB * 255
		local gCalc = valRGB * 64
		local bCalc = valRGB * 250
		local aCalc = 195 + (math.random() * 16)

		rCalc = Lerp(dist, rCalc, 255)
		gCalc = Lerp(dist, gCalc, 255)
		bCalc = Lerp(dist, bCalc, 255)
		--aCalc = Lerp(dist, aCalc, 255)

		return rCalc, gCalc, bCalc, aCalc
	end)


	ZVox.NewTexturePixelFunc("crystal", function(x, y)
		local val = .4 + (math.random() * .5)

		return math.max(val * 100, 88), math.max(val * 100, 42), math.max(val * 100, 255) -- why the max here trays :?
	end)
	ZVox.TextureHexWriteOp("crystal", {0x0, 0x7C1C, 0xC0, 0x7C00, 0x7F, 0x0, 0x7E, 0xFC00, 0x0, 0xE3FF, 0x0, 0xF8F, 0x0, 0xFC3E, 0x0, 0xF3F9}, 78, 59, 255)
	ZVox.TextureHexWriteOp("crystal", {0x7, 0xE00, 0xC, 0x0, 0xC000, 0xC0, 0x0, 0x6003, 0x0, 0x1E0, 0x0, 0xC, 0x6000, 0x0, 0x1C, 0x7800, 0x0}, 108, 89, 255)

	ZVox.NewTexturePixelFunc("clear_glass", function(x, y)
		--[[
		if isTextureBorder(x, y) then
			local val = .9 + math.random() * .1

			local colR = 196
			local colG = 196
			local colB = 196

			if y == 15 or x == 15 then
				colR = colR + 32
				colG = colG + 32
				colB = colB + 32
			end

			return colR * val, colG * val, colB * val, 128
		end
		]]--

		local valR = .8 + math.random() * .01
		local valG = .8 + math.random() * .025
		local valB = .8 + math.random() * .05

		return valR * 255, valG * 255, valB * 255, 96 + (math.random() * 32)
	end)
	ZVox.TextureOp("clear_glass", function()
		for x = 0, 16, 7 do
			for y = 0, 16, 7 do
				local oX = x + 2
				local oY = y - 2

				local length = math.random(2, 3)

				local valR = .8 + math.random() * .01
				local valG = .8 + math.random() * .025
				local valB = .8 + math.random() * .05

				surface.SetDrawColor(valR * 255, valG * 255, valB * 255, 255)
				ZVox.BresenhamLine(oX, oY, oX + length, oY - length)
			end
		end
	end)
end