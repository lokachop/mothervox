ZVox = ZVox or {}

function ZVox.NewTexturePlanks(name, colMain, colDark, borderWeight)
	ZVox.NewTexturePixelFunc(name, function(x, y)
		local spx = ZVox.Simplex2D(x * .2, y * .55)
		spx = (spx + 1) * .5

		if spx < .35 then
			return colDark[1], colDark[2], colDark[3]
		else
			return colMain[1], colMain[2], colMain[3]
		end
	end)

	ZVox.TextureOp(name, function()
		surface.SetDrawColor(0, 0, 0, borderWeight)
		surface.DrawRect(0, 15, 16, 1)
		surface.DrawRect(0, 11, 16, 1)
		surface.DrawRect(0, 7, 16, 1)
		surface.DrawRect(0, 3, 16, 1)

		surface.DrawRect(2, 13, 1, 1)
		surface.DrawRect(13, 12, 1, 1)

		surface.DrawRect(5, 8, 1, 1)
		surface.DrawRect(11, 9, 1, 1)

		surface.DrawRect(2, 5, 1, 1)
		surface.DrawRect(10, 6, 1, 1)
		surface.DrawRect(11, 4, 1, 1)

		surface.DrawRect(3, 1, 1, 1)
		surface.DrawRect(12, 2, 1, 1)
	end)
end

local function inrange(x, a, b)
	return x >= a and x < b
end

local function inCircle(x, y, cS)
	local inBox = inrange(x, 8 - cS, 8 + cS) and inrange(y, 8 - cS, 8 + cS)

	cS = cS - 1
	local inSmallerBox = inrange(x, 8 - cS, 8 + cS) and inrange(y, 8 - cS, 8 + cS)


	return inBox and not inSmallerBox
end

local function decLimit(v, mul)
	return math.floor(v * mul) / mul
end

local function isTextureBorder_Width(x, y, width)
	width = width or 1
	return (inrange(x, 0, width) or inrange(x, 16 - width, 16)) or (inrange(y, 0, width) or inrange(y, 16 - width, 16))
end

local function equalsSomewhat(x, y, range)
	return math.abs(x - y) < range
end


function ZVox.ComputeWoodTextures()
	ZVox.NewTexturePixelFunc("birch_log", function(x, y)
		local mx = math.abs(x - 7) + 32

		local spx = ZVox.Simplex2D(mx, y * .185)
		spx = (spx + 1) * .5
		local val = .85 + (spx * .15)

		return val * 255, val * 255, val * 255
	end)


	ZVox.TextureHexWriteOp("birch_log", {0x0, 0x0, 0x0, 0x900, 0x682, 0xc004, 0x8000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x3, 0x800c, 0x6030, 0x1000, }, 49, 49, 49)
	ZVox.TextureHexWriteOp("birch_log", {0x0, 0x0, 0x0, 0x600, 0x100, 0x3, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x3, 0x8003, 0x0, }, 38, 38, 38)
	ZVox.TextureHexWriteOp("birch_log", {0x8401, 0x0, 0x10, 0x1000, 0x3000, 0x0, 0x8, 0x4040, 0x6, 0x200, 0x8040, 0x70c, 0x0, 0x100, 0x0, 0x0, }, 207, 207, 207)


	ZVox.NewTexturePixelFunc("birch_log_top", function(x, y)
		for i = 1, 7 do
			if not inCircle(x, y, i) then
				continue
			end

			local iMod = (i % 3)
			iMod = math.min(iMod, 1)
			iMod = (math.random() * .2) + .6 + (iMod * .2)

			return 215 * iMod, 200 * iMod, 140 * iMod
		end


		if inCircle(x, y, 8) then
			local mx = math.abs(x - 7) + 32
			local val = .5 + ZVox.Simplex2D(mx, (y + x) * .25) * .5
			val = 1 - val ^ 5
			if .84 > val then val = val * .25 end

			return val * 255, val * 255, val * 255
		end
	end)


	ZVox.NewTexturePixelFunc("oak_log", function(x, y)
		local mx = math.abs(x - 7) + 32
		local val = (ZVox.Simplex2D(mx * .7, (y + x) * .1) + 1) * .5
		val = decLimit(val, 5)

		if .84 > val then
			val = val + .4
		end
		return val * 106, val * 85, val * 52
	end)

	ZVox.NewTexturePixelFunc("oak_log_top", function(x, y)
		for i = 1, 7 do
			if not inCircle(x, y, i) then
				continue
			end

			local iMod = (i % 3)
			iMod = math.min(iMod, 1)
			iMod = (math.random() * .2) + .6 + (iMod * .2)

			return 180 * iMod, 144 * iMod, 90 * iMod
		end


		if inCircle(x, y, 8) then
			local mx = math.abs(x - 7) + 32
			local val = (ZVox.Simplex2D(mx * .7, (y + x) * .1) + 1) * .5
			val = decLimit(val, 5)

			if .84 > val then
				val = val + .4
			end
			return val * 106, val * 85, val * 52
		end
	end)


	ZVox.NewTexturePlanks("oak_planks", {180, 144, 90}, {159, 132, 77}, 160)
	ZVox.NewTexturePlanks("birch_planks", {215, 200, 140}, {194, 188, 127}, 120)



	ZVox.NewTexturePixelFunc("pine_log", function(x, y)
		local mx = math.abs(x - 7) + 32
		local val = (ZVox.Simplex2D(mx * .7, (y + x) * .1) + 1) * .35
		val = decLimit(val, 5)

		if .84 > val then
			val = val + .4
		end

		val = val * .6

		return val * 106, val * 85, val * 52
	end)

	ZVox.NewTexturePixelFunc("pine_log_top", function(x, y)
		for i = 1, 7 do
			if not inCircle(x, y, i) then
				continue
			end

			local iMod = (i % 3)
			iMod = math.min(iMod, 1)
			iMod = (math.random() * .2) + .6 + (iMod * .2)

			return 100 * iMod, 84 * iMod, 60 * iMod
		end


		if inCircle(x, y, 8) then
			local mx = math.abs(x - 7) + 32
			local val = (ZVox.Simplex2D(mx * .7, (y + x) * .1) + 1) * .35
			val = decLimit(val, 5)

			if .84 > val then
				val = val + .4
			end
			val = val * .6
			return val * 106, val * 85, val * 52
		end
	end)

	ZVox.NewTexturePlanks("pine_planks", {100, 84, 60}, {88, 76, 52}, 120)


	-- mintwood
	ZVox.NewTexturePixelFunc("mintwood_log", function(x, y)
		local mx = math.abs(x - 7) + 32
		local val = (ZVox.Simplex2D(mx * .25, (y + x) * .1) + 1) * .35
		val = decLimit(val, 6)

		if .84 > val then
			val = val + .4
		end

		val = val * .8

		return val * 46, val * 125, val * 92
	end)

	ZVox.NewTexturePixelFunc("mintwood_log_top", function(x, y)
		for i = 1, 7 do
			if not inCircle(x, y, i) then
				continue
			end

			local iMod = (i % 3)
			iMod = math.min(iMod, 1)
			iMod = (math.random() * .2) + .6 + (iMod * .2)

			return 42 * iMod, 200 * iMod, 140 * iMod
		end


		if inCircle(x, y, 8) then
			local mx = math.abs(x - 7) + 32
			local val = (ZVox.Simplex2D(mx * .7, (y + x) * .1) + 1) * .35
			val = decLimit(val, 5)

			if .84 > val then
				val = val + .4
			end
			val = val * .6
			return val * 36, val * 115, val * 82
		end
	end)

	ZVox.NewTexturePlanks("mintwood_planks", {42, 200, 140}, {42, 188, 127}, 120)


	-- crimwood
	ZVox.NewTexturePixelFunc("crimwood_log", function(x, y)
		local mx = math.abs(x - 7) + 32
		local val = (ZVox.Simplex2D(mx * .925, (y + x) * .225) + 1) * .35
		val = decLimit(val, 6)

		if .84 > val then
			val = val + .3
		end

		val = val * .9

		return val * 145, val * 46, val * 36
	end)

	ZVox.NewTexturePixelFunc("crimwood_log_top", function(x, y)
		for i = 1, 7 do
			if not inCircle(x, y, i) then
				continue
			end

			local iMod = (i % 3)
			iMod = math.min(iMod, 1)
			iMod = (math.random() * .2) + .6 + (iMod * .2)

			return 200 * iMod, 75 * iMod, 65 * iMod
		end


		if inCircle(x, y, 8) then
			local mx = math.abs(x - 7) + 32
			local val = (ZVox.Simplex2D(mx * .925, (y + x) * .2) + 1) * .35
			val = decLimit(val, 6)

			if .84 > val then
				val = val + .3
			end

			val = val * .9

			return val * 145, val * 46, val * 36
		end
	end)

	ZVox.NewTexturePlanks("crimwood_planks", {200, 75, 65}, {187, 62, 52}, 120)


	ZVox.NewTexturePlanks("crate", {180, 144, 90}, {159, 132, 77}, 60)
	ZVox.TextureOpPixelFunc("crate", function(x, y)
		if isTextureBorder_Width(x, y, 2) then
			return 0, 0, 0, 220
		end

		-- \
		if equalsSomewhat(x, y, 2) then
			return 0, 0, 0, 180
		end
		-- /
		if equalsSomewhat(15-x, y, 2) then
			return 0, 0, 0, 180
		end
	end)
end