ZVox = ZVox or {}

local screenShakeEnd = 0
local screenShakeIntensity = 0
local screenShakeLen = 0
function ZVox.DoScreenShake(int, len)
	screenShakeIntensity = int
	screenShakeLen = len

	screenShakeEnd = CurTime() + len
end

local shakeX = 0
local shakeY = 0
function ZVox.GetScreenShake()
	if not ZVOX_DO_SCREEN_SHAKE then
		return 0, 0
	end

	return shakeX, shakeY
end

local cX, cY = 0, 0
local tX, tY = 0, 0
local lerpTime = 0.05
local nextLerp = 0
function ZVox.ScreenShakeThink()


	if CurTime() > screenShakeEnd then
		shakeX = 0
		shakeY = 0

		return
	end
	local fullDelta = (screenShakeEnd - CurTime()) / screenShakeLen


	if CurTime() > nextLerp then
		cX = tX
		cY = tY

		tX = (math.random() - .5) * 2 * screenShakeIntensity
		tY = (math.random() - .5) * 2 * screenShakeIntensity

		nextLerp = CurTime() + lerpTime
	end


	local lerpDelta = (nextLerp - CurTime()) / lerpTime
	lerpDelta = 1 - lerpDelta

	shakeX = Lerp(lerpDelta, cX, tX) * fullDelta
	shakeY = Lerp(lerpDelta, cY, tY) * fullDelta
end