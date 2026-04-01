ZVox = ZVox or {}

local math = math
local math_random = math.random


---------------
-- Operators --
---------------

function ZVox.BigBrickOp(name, r, g, b, a)
	ZVox.TextureOp(name, function()
		surface.SetDrawColor(r, g, b, a)
		surface.DrawRect(15, 0, 1, 7)
		surface.DrawRect(0, 7, 16, 1)

		surface.DrawRect(7, 8, 1, 7)
		surface.DrawRect(0, 15, 16, 1)
	end)
end

function ZVox.SmallBrickOp(name, darkenColAlpha, mortalColAlpha)
	ZVox.TextureOp(name, function()
		surface.SetDrawColor(darkenColAlpha[1], darkenColAlpha[2], darkenColAlpha[3], darkenColAlpha[4])

		surface.DrawRect(0 , 1, 3, 2)
		surface.DrawRect(5 , 1, 6, 2)
		surface.DrawRect(13, 1, 3, 2)

		surface.DrawRect(1 , 5, 6, 2)
		surface.DrawRect(9 , 5, 6, 2)

		surface.DrawRect(0 , 9, 3, 2)
		surface.DrawRect(5 , 9, 6, 2)
		surface.DrawRect(13, 9, 3, 2)

		surface.DrawRect(1 ,13, 6, 2)
		surface.DrawRect(9 ,13, 6, 2)


		-- Mortar
		surface.SetDrawColor(mortalColAlpha[1], mortalColAlpha[2], mortalColAlpha[3], mortalColAlpha[4])
		surface.DrawRect(0, 3, 16, 1)
		surface.DrawRect(0, 7, 16, 1)
		surface.DrawRect(0,11, 16, 1)
		surface.DrawRect(0,15, 16, 1)

		surface.DrawRect(3 , 0, 1, 4)
		surface.DrawRect(11, 0, 1, 4)
		surface.DrawRect(7 , 4, 1, 4)
		surface.DrawRect(15, 4, 1, 4)
		surface.DrawRect(3 , 8, 1, 4)
		surface.DrawRect(11, 8, 1, 4)
		surface.DrawRect(7 ,12, 1, 4)
		surface.DrawRect(15,12, 1, 4)
	end)
end



--------------
-- Textures --
--------------
function ZVox.ComputeBrickTextures()
	ZVox.NewTexturePixelFunc("bricks", function(x, y)
		local valR = (.9 + math_random() * .1) * 200
		local valG = (.9 + math_random() * .1) * 70
		local valB = (.9 + math_random() * .1) * 20

		return valR, valG, valB
	end)
	ZVox.SmallBrickOp("bricks", {0, 0, 0, 60}, {255, 255, 255, 80})


	ZVox.NewTexturePixelFunc("brown_bricks", function(x, y)
		local val = (.9 + math_random() * .1)

		return val * 138, val * 115, val * 107
	end)
	ZVox.SmallBrickOp("brown_bricks", {0, 0, 0, 60}, {255, 255, 255, 40})


	ZVox.NewTexturePixelFunc("stone_bricks", function(x, y)
		local val = .45 + (math_random() * .1)
		return val * 255, val * 255, val * 255
	end)
	ZVox.BigBrickOp("stone_bricks", 0, 0, 0, 125)

	ZVox.NewTexturePixelFunc("etherealstone_bricks", function(x, y)
		local val = .9 + ZVox.Simplex2D(1 + x * .1, 1 + y * .4) * .1
		val = val + math.random() * .1
		val = .1 + ( val ^ 2 * .3 )

		return val * 220, val * 140, val * 240
	end)
	ZVox.BigBrickOp("etherealstone_bricks", 0, 0, 0, 125)
end