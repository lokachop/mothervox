ZVox = ZVox or {}
-- perform colourlerps in OKLab as it is 99999x nicer to lerp in than regular colourspace
-- directly ripped off from PoNR

local _cbrt_const = 1 / 3
local function colorToOKLab(c)
	local r = c.r / 255
	local g = c.g / 255
	local b = c.b / 255
	local a = c.a / 255

	local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
	local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
	local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

	local l_ = l ^ _cbrt_const --cbrt(l)
	local m_ = m ^ _cbrt_const --cbrt(m)
	local s_ = s ^ _cbrt_const --cbrt(s)

	return {
		0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
		1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
		0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_,
		a
	}
end

local function OKLabToColor(lab)
	local l_ = lab[1] + 0.3963377774 * lab[2] + 0.2158037573 * lab[3]
	local m_ = lab[1] - 0.1055613458 * lab[2] - 0.0638541728 * lab[3]
	local s_ = lab[1] - 0.0894841775 * lab[2] - 1.2914855480 * lab[3]

	local l = l_ * l_ * l_
	local m = m_ * m_ * m_
	local s = s_ * s_ * s_

	return Color(
		( 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s) * 255,
		(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s) * 255,
		(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s) * 255,
		lab[4] * 255
	)
end

function ZVox.ColorToOKLab(c)
	return colorToOKLab(c)
end

function ZVox.OKLabToColor(lab)
	return OKLabToColor(lab)
end

local function lerpOKLab(t, a, b)
	return {
		Lerp(t, a[1], b[1]),
		Lerp(t, a[2], b[2]),
		Lerp(t, a[3], b[3]),
		Lerp(t, a[4], b[4]),
	}
end

local function lerpColor(t, a, b)
	return Color(
		Lerp(t, a.r, b.r),
		Lerp(t, a.g, b.g),
		Lerp(t, a.b, b.b),
		Lerp(t, a.a, b.a)
	)
end


function ZVox.LerpColor(t, a, b)
	return lerpColor(t, a, b)
end

function ZVox.NiceLerpColor(t, a, b)
	local OKLabA = colorToOKLab(a)
	local OKLabB = colorToOKLab(b)

	local OKLabLerp = lerpOKLab(t, OKLabA, OKLabB)

	return OKLabToColor(OKLabLerp)
end


function ZVox.GetColorAtGradientPoint(t, gradient, noNice)
	if #gradient == 1 then -- flat colour fast
		local col = gradient[1]["c"]
		return col.r, col.g, col.b
	end

	-- find closest entry

	local closestMax = 1
	for i = 1, #gradient do
		local entry = gradient[i]

		local endPos = entry["e"]
		if t > endPos then
			continue
		end

		closestMax = i
		break
	end

	-- now find the previous
	local closestMin = closestMax - 1


	-- read entries

	local entryMin = gradient[closestMin]
	local entryMax = gradient[closestMax]
	local closestMaxCol = entryMax["c"]

	if not entryMin then
		return closestMaxCol.r, closestMaxCol.g, closestMaxCol.b
	end

	if not entryMax then
		return 255, 0, 0
	end

	local closestMinEnd = entryMin["e"]
	local closestMaxEnd = entryMax["e"]

	local closestMinCol = entryMin["c"]



	local deltaCol = (t - closestMinEnd) / (closestMaxEnd - closestMinEnd)

	if noNice then
		local col = ZVox.LerpColor(math.max(math.min(deltaCol, 1), 0), closestMinCol, closestMaxCol)
		col.r = math.abs(col.r)
		col.g = math.abs(col.g)
		col.b = math.abs(col.b)

		return col.r, col.g, col.b
	else
		local col = ZVox.NiceLerpColor(math.max(math.min(deltaCol, 1), 0), closestMinCol, closestMaxCol)
		col.r = math.abs(col.r)
		col.g = math.abs(col.g)
		col.b = math.abs(col.b)

		return col.r, col.g, col.b
	end
end