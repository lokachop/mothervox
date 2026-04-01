ZVox = ZVox or {}

function ZVox.GetDayAndNightTime()
	--return (CurTime() * 72) % 86400 -- 20 min days
	return (CurTime() * 72 * 16) % 86400 -- 20 min days

	--return (CurTime() * 1024 * 8) % 86400 -- fast

	--return 20000 -- day

	--return 60000 -- night
	--return 0
end

function ZVox.GetUniverseTrueTime(univ)
	local doDNC = ZVox.GetUniverseDoDayAndNight(univ)

	if doDNC then
		return ZVox.GetDayAndNightTime()
	else
		return ZVox.GetUniverseTime(univ)
	end
end

-- time is in unixtime
-- 1hr = 3600
-- 24hr = 86400
-- 12hr = 43200

-- 3hr = 10800
-- 16hr = 57600

local unixtime1Hour = 3600

local day_length = 15
local dayStdDiff = day_length - 12

local h_dayStdDiffUnixTime = dayStdDiff * .5 * unixtime1Hour
local dayLengthUnixTime = day_length * unixtime1Hour

local function calcSunDeltaFromTime(time)
	local dncTime = time--ZVox.GetDayAndNightTime()


	local delta = ((dncTime + h_dayStdDiffUnixTime) % 86400) / dayLengthUnixTime
	delta = delta - .5
	delta = math.abs(delta) * 2

	delta = 1 - delta
	delta = math.min(delta * 3, 1)
	delta = math.max(delta, 0)

	return delta
end

function ZVox.GetUniverseSunDelta(univ)
	return calcSunDeltaFromTime(ZVox.GetUniverseTrueTime(univ))
end


function ZVox.GetUniverseTrueWorldTint(univ)
	return ZVox.GetUniverseWorldTint(univ)
end


local tintVECSky = Vector(1, 1, .5)
local function calcDNCSkyTint(time)
	local sunDelta = calcSunDeltaFromTime(time)

	local valR = math.min(sunDelta * 2.5, 1)
	local valG = math.min(sunDelta * 1.8, 1)
	local valB = math.min(sunDelta * 1.1, 1)

	tintVECSky:SetUnpacked(valR, valG, valB)


	return tintVECSky
end


function ZVox.GetUniverseTrueSkyTint(univ)
	return calcDNCSkyTint(ZVox.GetUniverseTime(univ))
end

local matrixSunDir = Matrix()
local vecSunDir = Vector()
local angSunDir = Angle()
local sunDirUpTranslate = Vector(0, -16, 0)
function ZVox.GetSunDir(univ)
	vecSunDir:SetUnpacked(0, -1, 0)

	matrixSunDir:Identity()

	local time = ZVox.GetUniverseTrueTime(univ)
	local timeDelta = -(time / 86400)

	angSunDir:SetUnpacked(-15, 0, timeDelta * 360)
	matrixSunDir:Rotate(angSunDir)
	matrixSunDir:Translate(Vector(0, -.9, 0))

	local dir = matrixSunDir * vecSunDir
	dir:Normalize()

	return dir
end