ZVox = ZVox or {}

ZVox.DeclareNewPlusDataSerializer("boolean", {
	["copy"] = function(data)
		return data
	end,
	["write"] = function(data, fBuff)
		ZVox.FB_WriteBool(fBuff, data)
	end,
	["read"] = function(fBuff)
		return ZVox.FB_ReadBool(fBuff)
	end,
})

ZVox.DeclareNewPlusDataSerializer("number", {
	["copy"] = function(data)
		return data
	end,
	["write"] = function(data, fBuff)
		ZVox.FB_WriteDouble(fBuff, data)
	end,
	["read"] = function(fBuff)
		return ZVox.FB_ReadDouble(fBuff)
	end,
})

ZVox.DeclareNewPlusDataSerializer("vector", {
	["copy"] = function(data)
		return data * 1
	end,
	["write"] = function(data, fBuff)
		ZVox.FB_WriteDouble(fBuff, data[1])
		ZVox.FB_WriteDouble(fBuff, data[2])
		ZVox.FB_WriteDouble(fBuff, data[3])
	end,
	["read"] = function(fBuff)
		local vObj = Vector()
		vObj[1] = ZVox.FB_ReadDouble(fBuff)
		vObj[2] = ZVox.FB_ReadDouble(fBuff)
		vObj[3] = ZVox.FB_ReadDouble(fBuff)

		return vObj
	end,
})

ZVox.DeclareNewPlusDataSerializer("string", {
	["copy"] = function(data)
		return data
	end,
	["write"] = function(data, fBuff)
		ZVox.FB_WriteULong(fBuff, #data)
		ZVox.FB_Write(fBuff, data)
	end,
	["read"] = function(fBuff)
		local len = ZVox.FB_ReadULong(fBuff)
		return ZVox.FB_Read(fBuff, len)
	end,
})

ZVox.DeclareNewPlusDataSerializer("custom:skycolour", {
	["copy"] = function(data)
		local skyColObj = {}

		local colCount = #data
		for i = 1, colCount do
			local grad = data[i]

			local eScalar = grad.e
			local col = grad.c

			skyColObj[i] = {
				["e"] = eScalar,
				["c"] = Color(col.r, col.g, col.b)
			}
		end

		return skyColObj
	end,
	["write"] = function(data, fBuff)
		local colCount = #data
		ZVox.FB_WriteUShort(fBuff, colCount)
		for i = 1, colCount do
			local grad = data[i]
			local eScalar = grad.e
			ZVox.FB_WriteDouble(fBuff, eScalar)

			-- now write color as unsigned 8 bit int
			local col = grad.c
			ZVox.FB_WriteByte(fBuff, math.min(math.floor(col.r), 255))
			ZVox.FB_WriteByte(fBuff, math.min(math.floor(col.g), 255))
			ZVox.FB_WriteByte(fBuff, math.min(math.floor(col.b), 255))
		end
	end,
	["read"] = function(fBuff)
		local skyColObj = {}

		local colCount = ZVox.FB_ReadUShort(fBuff)
		for i = 1, colCount do
			local entry = {}
			local eScalar = ZVox.FB_ReadDouble(fBuff)

			local cR = ZVox.FB_ReadByte(fBuff)
			local cG = ZVox.FB_ReadByte(fBuff)
			local cB = ZVox.FB_ReadByte(fBuff)

			entry.e = eScalar
			entry.c = Color(cR, cG, cB)

			skyColObj[#skyColObj + 1] = entry
		end

		return skyColObj
	end,
})

-- skycolour gradient
ZVox.DeclareNewPlusData("skycolour", {
	["default"] = {
		{["e"] =  0, ["c"] = Color(75, 125, 200)}, -- e marks where it ends, lerps from the previous value
		{["e"] = .4, ["c"] = Color(150, 175, 255)},
		{["e"] = .5, ["c"] = Color(200, 220, 255)},
		{["e"] =  1, ["c"] = Color(24, 32, 64)},
	},

	["serialtype"] = "custom:skycolour",
})
function ZVox.SetUniverseSkyGradient(univ, skyGradient)
	ZVox.SetUniversePlusDataValue(univ, "skycolour", skyGradient)
end
function ZVox.GetUniverseSkyGradient(univ)
	return ZVox.GetUniversePlusDataValue(univ, "skycolour")
end



ZVox.DeclareNewPlusData("spawnpoint", {
	["default"] = Vector(48.5, 64.5, 64),
	["serialtype"] = "vector",
})
function ZVox.SetUniverseSpawnPoint(univ, pos)
	ZVox.SetUniversePlusDataValue(univ, "spawnpoint", pos)
end
function ZVox.GetUniverseSpawnPoint(univ)
	return ZVox.GetUniversePlusDataValue(univ, "spawnpoint")
end


-- world tinting for darkness
ZVox.DeclareNewPlusData("worldtint", {
	["default"] = Vector(1, 1, 1),
	["serialtype"] = "vector",
})
function ZVox.SetUniverseWorldTint(univ, tint)
	ZVox.SetUniversePlusDataValue(univ, "worldtint", tint)
end
function ZVox.GetUniverseWorldTint(univ)
	return ZVox.GetUniversePlusDataValue(univ, "worldtint")
end


-- time is in unixtime
-- 1hr = 3600
-- 24hr = 86400
-- 12hr = 43200
-- 6hr = 21600
ZVox.DeclareNewPlusData("time", {
	["default"] = 21600,
	["serialtype"] = "number",
})
function ZVox.SetUniverseTime(univ, time)
	ZVox.SetUniversePlusDataValue(univ, "time", time)
end
function ZVox.GetUniverseTime(univ)
	return ZVox.GetUniversePlusDataValue(univ, "time")
end

-- whether to do day and night or not
ZVox.DeclareNewPlusData("do_day_and_night", {
	["default"] = false,
	["serialtype"] = "boolean",
})
function ZVox.SetUniverseDoDayAndNight(univ, do_dnc)
	ZVox.SetUniversePlusDataValue(univ, "do_day_and_night", do_dnc)
end
function ZVox.GetUniverseDoDayAndNight(univ)
	return ZVox.GetUniversePlusDataValue(univ, "do_day_and_night")
end



ZVox.DeclareNewPlusData("weather", {
	["default"] = ZVOX_WEATHER_CLEAR,
	["serialtype"] = "number",
})
function ZVox.SetUniverseWeather(univ, weather)
	ZVox.SetUniversePlusDataValue(univ, "weather", weather)
end
function ZVox.GetUniverseWeather(univ)
	return ZVox.GetUniversePlusDataValue(univ, "weather")
end


-- owner of the universe, steamid64, 0 is server
ZVox.DeclareNewPlusData("owner", {
	["default"] = "-1",
	["serialtype"] = "string",
})
function ZVox.SetUniverseOwnerSID(univ, ownerSID)
	ZVox.SetUniversePlusDataValue(univ, "owner", ownerSID)
end
function ZVox.GetUniverseOwnerSID(univ)
	return ZVox.GetUniversePlusDataValue(univ, "owner")
end


-- whether to render bounds or not
ZVox.DeclareNewPlusData("render_bounds", {
	["default"] = true,
	["serialtype"] = "boolean",
})
function ZVox.SetUniverseRenderBounds(univ, do_bounds)
	ZVox.SetUniversePlusDataValue(univ, "render_bounds", do_bounds)
end
function ZVox.GetUniverseRenderBounds(univ)
	return ZVox.GetUniversePlusDataValue(univ, "render_bounds")
end

-- whether to render clouds or not
ZVox.DeclareNewPlusData("render_clouds", {
	["default"] = true,
	["serialtype"] = "boolean",
})
function ZVox.SetUniverseRenderClouds(univ, do_clouds)
	ZVox.SetUniversePlusDataValue(univ, "render_clouds", do_clouds)
end
function ZVox.GetUniverseRenderClouds(univ)
	return ZVox.GetUniversePlusDataValue(univ, "render_clouds")
end

-- whether to render the sun or not
ZVox.DeclareNewPlusData("render_sun", {
	["default"] = true,
	["serialtype"] = "boolean",
})
function ZVox.SetUniverseRenderSun(univ, do_sun)
	ZVox.SetUniversePlusDataValue(univ, "render_sun", do_sun)
end
function ZVox.GetUniverseRenderSun(univ)
	return ZVox.GetUniversePlusDataValue(univ, "render_sun")
end

-- whether to render the sun or not
ZVox.DeclareNewPlusData("render_moon", {
	["default"] = true,
	["serialtype"] = "boolean",
})
function ZVox.SetUniverseRenderMoon(univ, do_moon)
	ZVox.SetUniversePlusDataValue(univ, "render_moon", do_moon)
end
function ZVox.GetUniverseRenderMoon(univ)
	return ZVox.GetUniversePlusDataValue(univ, "render_moon")
end