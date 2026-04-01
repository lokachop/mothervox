ZVox = ZVox or {}

local accumR, accumG, accumB, accumA = 0, 0, 0, 0
local function pushSurfColour()
	local cGet = surface.GetDrawColor()
	accumR, accumG, accumB, accumA = cGet.r, cGet.g, cGet.b, cGet.a
end

local function lineLow(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	local yi = 1
	if dy < 0 then
		yi = -1
		dy = -dy
	end

	local D = (2 * dy) - dx
	local y = y1

	local oW, oH = ScrW(), ScrH()

	for x = x1, x2 do
		render.SetViewPort(x, y, 1, 1)
		render.Clear(accumR, accumG, accumB, accumA)

		if D > 0 then
			y = y + yi
			D = D + (2 * (dy - dx))
		else
			D = D + 2 * dy
		end
	end

	render.SetViewPort(0, 0, oW, oH)
end

local function lineHigh(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	local xi = 1
	if dx < 0 then
		xi = -1
		dx = -dx
	end
	local D = (2 * dx) - dy
	local x = x1

	local oW, oH = ScrW(), ScrH()

	for y = y1, y2 do
		render.SetViewPort(x, y, 1, 1)
		render.Clear(accumR, accumG, accumB, accumA)

		if D > 0 then
			x = x + xi
			D = D + (2 * (dx - dy))
		else
			D = D + 2 * dx
		end

	end

	render.SetViewPort(0, 0, oW, oH)
end


-- https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
-- util render funcs to get consistency with textures
function ZVox.BresenhamLine(x1, y1, x2, y2)
	local oX = 0
	if ZVOX_RENDERING_ANIMATED_TEXTURE then
		oX = ZVOX_RENDERING_ANIMATED_TEXTURE_FRAME * 16
	end

	pushSurfColour()

	x1 = math.floor(x1 + oX)
	y1 = math.floor(y1)

	x2 = math.floor(x2 + oX)
	y2 = math.floor(y2)


	if math.abs(y2 - y1) < math.abs(x2 - x1) then
		if x1 > x2 then
			lineLow(x2, y2, x1, y1)
		else
			lineLow(x1, y1, x2, y2)
		end
	else
		if y1 > y2 then
			lineHigh(x2, y2, x1, y1)
		else
			lineHigh(x1, y1, x2, y2)
		end
	end
end