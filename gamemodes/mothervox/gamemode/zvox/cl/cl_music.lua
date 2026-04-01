ZVox = ZVox or {}


ZVox.ActiveSongStream = ZVox.ActiveSongStream
function ZVox.SetActiveSong(path)
	if IsValid(ZVox.ActiveSongStream) then
		ZVox.ActiveSongStream:Stop()
	end

	if not path or path == "" then
		return
	end

	ZVox.PrintInfo("Playing song \"" .. path .. "\"")

	sound.PlayFile(path, "noplay noblock", function(station, errCode, errString)
		if IsValid(station) then
			ZVox.ActiveSongStream = station
			station:EnableLooping(true)
			station:SetPlaybackRate(1)
			station:SetVolume(ZVOX_MUSIC_VOLUME / 100)
			station:Play()
		else
			ZVox.PrintError("background song error #" .. tostring(errCode) .. ": " .. tostring(errString))
		end
	end)
end

function ZVox.UpdateSongVolume()
	if not IsValid(ZVox.ActiveSongStream) then
		return
	end

	if ZVox.ActiveSongStream:GetState() ~= GMOD_CHANNEL_PLAYING then
		return
	end

	ZVox.ActiveSongStream:SetVolume(ZVOX_MUSIC_VOLUME / 100)
end