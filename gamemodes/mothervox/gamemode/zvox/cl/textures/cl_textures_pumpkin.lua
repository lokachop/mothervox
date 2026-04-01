ZVox = ZVox or {}

local function decLimit(v, mul)
	return math.floor(v * mul) / mul
end

function ZVox.TextureOpPumpkinBase(name)
	ZVox.TextureOpPixelFunc(name, function(x, y)
		local spx = ZVox.Simplex2D(x, y * .1)
		spx = (spx + 1) * .5
		spx = decLimit(spx, 4)

		local valR = (227 - 25) + (spx * 25)
		local valG = (144 - 28) + (spx * 28)
		local valB = (29 - 10) + (spx * 10)

		return valR, valG, valB
	end)
	ZVox.TextureOp(name, function()
		surface.SetDrawColor(160, 90, 11)

		surface.DrawLine(0, 0, 0, 16)
		-- wides
		surface.DrawLine(0, 0, 2, 0)
		surface.DrawLine(0, 15, 2, 15)


		surface.DrawLine(3, 0, 4,16)
		-- wides
		surface.DrawLine(3, 0, 5, 0)
		surface.DrawLine(4,15, 6,15)


		surface.DrawLine(8, 0, 7,16)
		-- wides
		surface.DrawLine(8, 0, 6, 0)
		surface.DrawLine(7,15, 9,15)
		surface.DrawLine(7,14, 9,14)


		surface.DrawLine(11, 0,12,14)
		-- wides
		surface.DrawLine(11, 0, 9, 0)
		surface.DrawLine(12,14,10,14)
		surface.DrawLine(11,15, 9,15)


		surface.DrawLine(15, 0,15,16)
		-- wides
		surface.DrawLine(15,15,13,15)
		surface.DrawLine(15, 0,13, 0)
	end)
end


function ZVox.ComputePumpkinTextures()
	ZVox.NewTexturePixelFunc("pumpkin", function(x, y)
		return 255, 0, 0
	end)
	ZVox.TextureOpPumpkinBase("pumpkin")

	ZVox.NewTexturePixelFunc("pumpkin_roof", function(x, y)
		local spx = ZVox.Simplex2D(x, y)
		spx = (spx + 1) * .5
		spx = decLimit(spx, 4)

		local valR = (227 - 25) + (spx * 25)
		local valG = (144 - 28) + (spx * 28)
		local valB = (29 - 10) + (spx * 10)

		return valR, valG, valB
	end)
	ZVox.TextureOp("pumpkin_roof", function()
		surface.SetDrawColor(160, 90, 11)
		local itr = 12
		for i = 1, itr do
			local delta = (i - 1) / (itr - 1)

			local degMul = 360

			local degsRad = math.rad(delta * degMul)

			local addX = math.sin(degsRad) * 16
			local addY = math.cos(degsRad) * 16
			local shiftX = 9
			local shiftY = 7

			surface.DrawLine(shiftX, shiftY, shiftX + addX, shiftY + addY)
		end

		surface.DrawLine(0, 0, 16, 0)
		surface.DrawLine(0, 0, 0, 16)

		surface.DrawLine(0, 15, 16, 15)
		surface.DrawLine(15, 0, 15, 15)


		surface.SetDrawColor(227, 170, 0)
		surface.DrawLine(8, 8, 8 + 3, 8 - 3)

		surface.SetDrawColor(183, 134, 0)
		surface.DrawLine(8, 7, 8 + 2, 7 - 2)
		surface.DrawLine(9, 8, 9 + 2, 8 - 2)

		surface.SetDrawColor(61, 44, 0)
		surface.DrawLine(7, 7, 7 + 3, 7 - 3)
		surface.DrawLine(9, 9, 9 + 3, 9 - 3)

		surface.DrawLine(9, 5, 9 + 2, 5)

		surface.DrawLine(11, 7, 11, 7 - 2)
	end)


	ZVox.NewTexturePixelFunc("pumpkin_face_tray", function(x, y)
		return 255, 0, 0
	end)
	ZVox.TextureOpPumpkinBase("pumpkin_face_tray")
	ZVox.TextureHexWriteOp("pumpkin_face_tray", {0x0000,0x0008,0x0008,0x0038,0x0838,0x1938,0x1928,0x1B20,0x0B21,0xCA21,0xD013,0xD017,0xF55F,0x7FFE,0x3FFC,0x1FF8,}, 68, 19, 0)

	ZVox.NewTexturePixelFunc("pumpkin_face_scary", function(x, y)
		return 255, 0, 0
	end)
	ZVox.TextureOpPumpkinBase("pumpkin_face_scary")
	ZVox.TextureHexWriteOp("pumpkin_face_scary", {0x0, 0x0, 0x0, 0x828, 0x3c3c, 0x1018, 0x0, 0x0, 0x0, 0x740, 0x5ff4, 0x7ffe, 0x3dfc, 0x704e, 0x2008, 0x0, }, 68, 19, 0)


	ZVox.NewTexturePixelFunc("pumpkin_face_loka", function(x, y)
		return 255, 0, 0
	end)
	ZVox.TextureOpPumpkinBase("pumpkin_face_loka")
	ZVox.TextureHexWriteOp("pumpkin_face_loka", {0x0000,0x1010,0x3830,0x1818,0x3838,0x1838,0x1070,0x1870,0x0C60,0x1C30,0x0000,0x206A,0x3BFE,0x7FB6,0x4C04,0x0000,}, 68, 19, 0)


	ZVox.NewTexturePixelFunc("pumpkin_face_man_tray", function(x, y)
		return 255, 0, 0
	end)
	ZVox.TextureOpPumpkinBase("pumpkin_face_man_tray")
	ZVox.TextureHexWriteOp("pumpkin_face_man_tray", {0x0000,0x0000,0xFC7E,0x06C0,0x0000,0xFC7E,0xB2B2,0x0000,0x0000,0x0000,0x000C,0x2008,0x1FE8,0x0008,0x0000,0x0000,}, 68, 19, 0)
end
