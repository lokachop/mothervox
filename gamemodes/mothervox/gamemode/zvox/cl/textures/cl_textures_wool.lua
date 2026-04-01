ZVox = ZVox or {}

local math = math
local math_sin = math.sin
local math_rad = math.rad
local math_abs = math.abs


local function woolTex(name, r, g, b)
	ZVox.NewTexturePixelFunc(name, function(x, y)
		local dCenter = 8 + (math_sin(math_rad((y / 9) * 360 * 2)) * 4)

		local xDelta = (math_abs((((x * 6) + dCenter) % 16) - 8) / 8)

		local val = (xDelta * .6) + .4

		return val * r, val * g, val * b
	end)
end

function ZVox.ComputeWoolTextures()
	-- tones
	woolTex("white_wool", 255, 255, 255)
	woolTex("light_gray_wool", 190, 190, 190)
	woolTex("gray_wool", 130, 130, 130)
	woolTex("dark_gray_wool", 85, 85, 85)
	woolTex("black_wool", 40, 40, 40)

	-- colour
	woolTex("voidinium_wool", 255, 0, 85)
	woolTex("red_wool", 255, 60, 60)
	woolTex("brown_wool", 139, 69, 19)
	woolTex("orange_wool", 255, 130, 30)
	woolTex("yellow_wool", 255, 220, 70)
	woolTex("light_green_wool", 160, 255, 60)
	woolTex("green_wool", 60, 220, 60)
	woolTex("blueish_green_wool", 0, 180, 125)
	woolTex("cyan_wool", 0, 130, 130)
	woolTex("light_blue_wool", 50, 200, 255)
	woolTex("blue_wool", 75, 100, 255)
	woolTex("indigo_wool", 125, 100, 255)
	woolTex("violet_wool", 137, 75, 227)
	woolTex("purple_wool", 150, 50, 200)
	woolTex("pink_wool", 255, 75, 180)
end