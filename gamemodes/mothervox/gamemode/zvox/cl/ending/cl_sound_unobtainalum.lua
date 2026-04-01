ZVox = ZVox or {}

local UNOBTAINALUM_POS = UNOBTAINALUM_POS

ZVox.UnobtainalumHumStream = ZVox.UnobtainalumHumStream
local temp = Vector()
local function startUnobtainalumStream()
	if IsValid(ZVox.UnobtainalumHumStream) then
		ZVox.UnobtainalumHumStream:Stop()
	end
	ZVox.PrintInfo("Hi!")
	--[[
	sound.PlayFile("sound/mothervox/sfx/misc/unobtainalum_hum_final.wav", "noplay noblock 3d", function(station, errCode, errString)
		if IsValid(station) then
			ZVox.PropellerStream = station
			station:EnableLooping(true)
			station:SetPlaybackRate(1)
			station:SetVolume(1)
			station:Set3DEnabled(true)
			station:SetPos(UNOBTAINALUM_POS + ZVOX_AUDIO_EAR_POS)
			station:Set3DFadeDistance(5, 100000)
			station:Play()
		else
			ZVox.PrintError("unobtainalum sound error #" .. tostring(errCode) .. ": " .. tostring(errString))
		end
	end)
	]]--

	temp:Set(UNOBTAINALUM_POS)
	temp:Mul(ZVOX_AUDIO_SOUND_SCALE)
	temp:Add(ZVOX_AUDIO_EAR_POS)
	temp[1] = temp[1] + ZVOX_AUDIO_SOUND_SCALE * .5
	temp[2] = temp[2] + ZVOX_AUDIO_SOUND_SCALE * .5
	temp[3] = temp[3] + ZVOX_AUDIO_SOUND_SCALE * .5


	sound.Play("mothervox/sfx/misc/unobtainalum_hum_final.wav", temp, 75, 100, 10)
end
function ZVox.UnobtainalumHumStart()
	startUnobtainalumStream()
end


function ZVox.UnobtainalumHumThink()
	if IsValid(ZVox.UnobtainalumHumStream) then
		startUnobtainalumStream()
	end

	if ZVox.UnobtainalumHumStream:GetState() ~= GMOD_CHANNEL_PLAYING then
		ZVox.UnobtainalumHumStream:Play()
	end
end