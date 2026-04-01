ZVox = ZVox or {}

-- Grand9K Pixel
-- By Jayvee D. Enaguas (Grand Chaos)
-- Licensed under Creative Commons (CC-BY-SA 3.0)
-- (c) Grand Chaos Productions. Some Rights Reserved.
-- Credits obtained from https://www.dafont.com/grand9k-pixel.font
local miniData = "XQAAAQA4AwAAAAAAAABzoDwFkgIV2YVjs9Q0NgMfqVxUqB9zJlaCZ1Hgkwxu4tkj8Q2MOhEZ7LsuUdr71xPoQ53PtqmHakNyCAYzkElkMW3WkZikJBu6Fqtdz6thBzpJPSvJIzNWr/M+zDE+yK2Fxa4bDcZ9a3xU0/smA7DqM0CpD7GPPA6XrZvxKYM1/l0fzyBT3+Ty1+re54BzIooLncbJj0qyci3IiPjXjqpOQ6JR6v2wpHboqLkYDlLB3guONywUBruPR+/pQy7HDmmfOh3pd8+0GwPP+C4vmWtM2D9+z10RD/WicxNcg0iZB6aapbtfTatDUKMm3TsQzfqOZrp8uQiKq6yxts5GoGwZdIqNvyoKw0/uUN0pVmdDZWOnVmzHbgODtvmydXKNDJhqf7lHBGhVPupRzNQGZdE1S/i9K0GyxJ5HVrbERr0G+sDDXZfZKwjatG/J8sDhksm/IqABntQ1bZV0yjKbL7ZqTe/QdtoUwsU7m5Vk+FQyq9J9Ni6Gb1piKtwDe9DF0NSvs46ugau5miMkgovFyjUAAA=="
local charArr = util.Decompress(util.Base64Decode(miniData))

local fontData = {}
for i = 1, #charArr do
	fontData[i] = string.byte(charArr and charArr[i] or 0xff)
end

local fontDataCharSpacing = 8

local fontDataCharW = 8
local fontDataCharH = 8

local fontWidths = {} -- calc from the font

local spacingAddFontW = math.floor(#fontData / 8) * 2
local fontW = #fontData + spacingAddFontW
local fontH = 10




local charW = 10
local charH = 10

local finalHash = fontW .. "x" .. fontH

local rtFont = GetRenderTarget("zvox_cfont_" .. finalHash .. "_rt", fontW, fontH)
local matFont = CreateMaterial("zvox_cfont_" .. finalHash .. "_mat", "UnlitGeneric", {
	["$basetexture"] = rtFont:GetName(),
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
})


local function getPointOccupied(x, y)
	local columnData = fontData[x + 1]
	if not columnData then
		return false
	end

	local bitGet = bit.band(columnData, 2^y)
	if bitGet == 0 then
		return false
	end


	return true
end

local function drawCharOffset(char, xOrigin, yOrigin)
	local accumFontWidth = 0
	local charGet = char

	local oW, oH = ScrW(), ScrH()
	for x = 0, fontDataCharW - 1 do
		local xCheck = (charGet * fontDataCharSpacing) + x

		local haveDrawn = false
		for y = 0, fontDataCharH do
			local occupied = getPointOccupied(xCheck, y)

			if not occupied then
				continue
			end

			haveDrawn = true

			render.SetViewPort(x + xOrigin, y + yOrigin, 1, 1)
			render.Clear(255, 255, 255, 255)
		end

		if haveDrawn then
			accumFontWidth = accumFontWidth + 1
		end
	end

	fontWidths[charGet + 31] = accumFontWidth
	render.SetViewPort(0, 0, oW, oH)
end



ZVox.RenderOnRT(rtFont, function()
	render.Clear(0, 0, 0, 0)

	for i = 0, (127 - 31) do
		local offX = i
		offX = offX * 10
		offX = offX + 1

		local offY = 1

		drawCharOffset(i, offX, offY)
	end
end)


local function isFilled(x, y)
	local _, _, _, a = render.ReadPixel(x, y)
	if not a then
		return false
	end

	return a > 240
end

local function isBordering(x, y)
	if isFilled(x - 1, y - 1) then return true end
	if isFilled(x    , y - 1) then return true end
	if isFilled(x + 1, y - 1) then return true end

	if isFilled(x - 1, y    ) then return true end
	if isFilled(x + 1, y    ) then return true end

	if isFilled(x - 1, y + 1) then return true end
	if isFilled(x    , y + 1) then return true end
	if isFilled(x + 1, y + 1) then return true end

	return false
end


-- border operator
ZVox.RenderOnRT(rtFont, function()
	render.CapturePixels()

	local oW, oH = ScrW(), ScrH()
	for i = 0, (fontW * fontH) - 1 do
		local xc = i % fontW
		local yc = math.floor(i / fontW)

		if isFilled(xc, yc) then
			continue
		end

		if not isBordering(xc, yc) then
			continue
		end

		render.SetViewPort(xc, yc, 1, 1)
		render.Clear(0, 0, 0, 255)
	end
	render.SetViewPort(0, 0, oW, oH)
end)



fontWidths[string.byte(" ")] = 2
fontWidths[string.byte("-")] = 5
fontWidths[string.byte("\"")] = 3

local function fontMeshBuilder_getCharSize()
	return 1 / (fontW / charW), 1
end


local function fontMeshBuilder_getCharWidth(char)
	local asciiNum = string.byte(char)
	if not asciiNum then
		return charW
	end

	local wEntry = fontWidths[asciiNum]
	if not wEntry then
		return charW
	end

	return wEntry
end

local function fontMeshBuilder_charToUV(char)
	local asciiNum = string.byte(char)
	if not asciiNum then
		return 0, 0
	end

	if asciiNum > 127 then
		return 0, 0
	end


	-- offset over by 31
	-- the first letter is an error symbol, so we do 31 so space matches up
	asciiNum = asciiNum - 31
	--asciiNum = asciiNum + 1

	-- mul by charW
	--asciiNum = asciiNum * charW

	-- now we get that divided by the width
	local uOffset = asciiNum / (fontW / charW)

	--asciiNum / (127 - 32)

	return uOffset, 0
end

local charSzU, charSzV = fontMeshBuilder_getCharSize()
local function fontMeshBuilder_pushChar(char, x, y, szX, szY, cR, cG, cB, cA)
	local u, v = fontMeshBuilder_charToUV(char)
	--local szU, szV = fontMeshBuilder_getCharSize()

	mesh.Color(cR, cG, cB, cA)
	mesh.TexCoord(0, u, v)
	mesh.Position(x, y, 0)
	mesh.AdvanceVertex()

	mesh.Color(cR, cG, cB, cA)
	mesh.TexCoord(0, u + charSzU, v)
	mesh.Position(x + szX, y, 0)
	mesh.AdvanceVertex()

	mesh.Color(cR, cG, cB, cA)
	mesh.TexCoord(0, u + charSzU, v + charSzV)
	mesh.Position(x + szX, y + szY, 0)
	mesh.AdvanceVertex()

	mesh.Color(cR, cG, cB, cA)
	mesh.TexCoord(0, u, v + charSzV)
	mesh.Position(x, y + szY, 0)
	mesh.AdvanceVertex()
end


local TEXT_PAD = 1
function ZVox.GetTextWidth(text, scl, padding)
	scl = scl or 1
	padding = padding or (TEXT_PAD * scl)

	if ZVOX_USE_LEGACY_FONT_RENDERING then
		return #text * (7 * (scl - 1))
	end

	local wC = 0
	for i = 1, #text do
		local char = text[i]

		local charWidthGet = fontMeshBuilder_getCharWidth(char)
		wC = wC + (charWidthGet * scl) + padding
	end

	return wC
end

function ZVox.GetNewTextWidth(text, scl, padding)
	scl = scl or 1
	padding = padding or (TEXT_PAD * scl)

	local wC = 0
	for i = 1, #text do
		local char = text[i]

		local charWidthGet = fontMeshBuilder_getCharWidth(char)
		wC = wC + (charWidthGet * scl) + padding
	end

	return wC
end

local alnLUT = {
	[TEXT_ALIGN_LEFT] = 0,
	[TEXT_ALIGN_CENTER] = .5,
	[TEXT_ALIGN_RIGHT] = 1,

	[TEXT_ALIGN_TOP] = 0,
	[TEXT_ALIGN_BOTTOM] = 1,
}


local c_white = Color(255, 255, 255)
local wfMat = Material("editor/wireframe")
local MAX_PRIMITIVES = 32768 / 4
function ZVox.DrawNewTextEx(text, x, y, col, alX, alY, scl, padding) -- TODO: make this more hardcrash resistant <- rubat made IMesh not hardcrash, yay!
	x = x or 0
	y = y or 0
	col = col or c_white
	alX = alX or TEXT_ALIGN_LEFT
	alY = alY or TEXT_ALIGN_TOP
	scl = scl or 1
	padding = padding or (TEXT_PAD * scl)


	local charSzW = charW * scl
	local charSzH = charH * scl

	local tW = ZVox.GetTextWidth(text, scl, padding)
	local tH = charSzH


	local offX = alnLUT[alX] or 0
	local offY = alnLUT[alY] or 0

	offX = offX * tW
	offY = offY * tH


	x = x - offX
	y = y - offY

	--surface.SetDrawColor(96, 16, 8, 128)
	--surface.DrawRect(x, y, tW, tH)


	local primCount = #text -- we're doing quads
	if primCount <= 0 then
		return
	end

	if primCount > MAX_PRIMITIVES then
		ZVox.PrintError("Attempting to render text \"" .. text .. "\" with more than " .. MAX_PRIMITIVES .. " characters!")
		ZVox.PrintError("FIXME; Implement a multi-mesh system!!")
		return
	end

	render.SetMaterial(matFont)
	--render.SetMaterial(wfMat)

	mesh.Begin(MATERIAL_QUADS, primCount)
	local cR = col.r
	local cG = col.g
	local cB = col.b
	local cA = col.a

	local xC = x
	for i = 1, #text do
		local char = text[i]

		local charWidthGet = fontMeshBuilder_getCharWidth(char)

		fontMeshBuilder_pushChar(char, xC, y, charSzW, charSzH, cR, cG, cB, cA)
		xC = xC + (charWidthGet * scl) + padding
	end
	mesh.End()


	return tW, tH
end

if system.IsLinux() then -- i'm on linux, make font more readable
	surface.CreateFont("ZVoxRetroText", {
		font = "Courier-New.ttf",
		size = 15,
		weight = 400,
		antialias = true,
		outline = true,
	})
	surface.CreateFont("ZVoxRetroTextBackDrop", {
		font = "Courier-New.ttf",
		size = 15,
		weight = 400,
		blursize = 2,
		antialias = false,
		outline = true,
	})	
else
	surface.CreateFont("ZVoxRetroText", {
		font = "Courier New",
		size = 14,
		weight = 400,
		antialias = false,
		outline = true,
	})
	surface.CreateFont("ZVoxRetroTextBackDrop", {
		font = "Courier New",
		size = 14,
		weight = 400,
		blursize = 2,
		antialias = false,
		outline = true,
	})
end

local c_white = Color(255, 255, 255)
local c_shadow = Color(0, 0, 0)
local retroMatrix = Matrix()
local retroVecRef = Vector(0, 0, 0)
function ZVox.DrawRetroTextEx(panel, str, x, y, col, alX, alY, sz, shadow)
	sz = sz or 2

	local ox, oy = 0, 0
	if panel and IsValid(panel) then
		ox, oy = panel:LocalToScreen(0, 0)
	end

	if ZVOX_USE_LEGACY_FONT_RENDERING then
		sz = math.max(sz - 1, 1)

		retroMatrix:Identity()

		retroVecRef[1] = ox
		retroVecRef[2] = oy
		retroMatrix:Translate(retroVecRef)

		retroVecRef[1] = sz
		retroVecRef[2] = sz
		retroMatrix:Scale(retroVecRef)

		retroVecRef[1] = -ox
		retroVecRef[2] = -oy
		retroMatrix:Translate(retroVecRef)

		render.PushFilterMag(TEXFILTER.POINT)
		render.PushFilterMin(TEXFILTER.POINT)
		cam.PushModelMatrix(retroMatrix, true)
			if shadow then
				draw.SimpleText(str, "ZVoxRetroTextBackDrop", (x / sz) + 1, (y / sz) + 1, c_shadow, alX or TEXT_ALIGN_LEFT, alY or TEXT_ALIGN_TOP)
			end

			local szX, szY = draw.SimpleText(str, "ZVoxRetroText", x / sz, y / sz, col or c_white, alX or TEXT_ALIGN_LEFT, alY or TEXT_ALIGN_TOP)
		cam.PopModelMatrix()
		render.PopFilterMin()
		render.PopFilterMag()

		return szX * sz, szY * sz
	end

	render.PushFilterMag(TEXFILTER.POINT)
	render.PushFilterMin(TEXFILTER.POINT)
		if shadow then
			--ZVox.DrawNewTextEx(str, x + ox + (1 * sz), y + oy + (1 * sz), c_shadow, alX, alY, sz)
		end

		local szX, szY = ZVox.DrawNewTextEx(str, x + ox, y + oy, col, alX, alY, sz)
	render.PopFilterMin()
	render.PopFilterMag()

	return szX, szY
end

function ZVox.DrawRetroText(panel, str, x, y, col, alX, alY, sz)
	return ZVox.DrawRetroTextEx(panel, str, x, y, col, alX, alY, sz, false)
end

function ZVox.DrawRetroTextShadowed(panel, str, x, y, col, alX, alY, sz)
	return ZVox.DrawRetroTextEx(panel, str, x, y, col, alX, alY, sz, true)
end
