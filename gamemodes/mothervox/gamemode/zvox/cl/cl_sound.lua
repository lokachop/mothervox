ZVox = ZVox or {}
local voxInfoRegistry = ZVox.GetVoxelRegistry()

function ZVox.GetVoxelSound(voxid)
	local voxel = voxInfoRegistry[voxid]
	return voxel and voxel.sound or ZVOX_MAT_STONE
end

local currPropellerState = false
function ZVox.Sound_TrySwitchPropellerState(newState)
	if newState == currPropellerState then
		return
	end

	currPropellerState = newState

	if newState then
		surface.PlaySound("mothervox/sfx/vehicle/transform_out.wav")
	else
		surface.PlaySound("mothervox/sfx/vehicle/transform_in.wav")
	end
end

ZVox.PropellerStream = ZVox.PropellerStream
local function beginPropellerStream()
	if IsValid(ZVox.PropellerStream) then
		ZVox.PropellerStream:Stop()
	end

	sound.PlayFile("sound/mothervox/sfx/vehicle/rotor.wav", "noplay noblock", function(station, errCode, errString)
		if IsValid(station) then
			ZVox.PropellerStream = station
			station:EnableLooping(true)
			station:SetPlaybackRate(1)
			station:SetVolume(ZVOX_VEHICLE_VOLUME / 100)
		else
			ZVox.PrintError("propeller sound error #" .. tostring(errCode) .. ": " .. tostring(errString))
		end
	end)
end

ZVox.EngineStream = ZVox.EngineStream
local function beginEngineStream()
	if IsValid(ZVox.EngineStream) then
		ZVox.EngineStream:Stop()
	end

	sound.PlayFile("sound/mothervox/sfx/vehicle/engine.wav", "noplay noblock", function(station, errCode, errString)
		if IsValid(station) then
			ZVox.EngineStream = station
			station:EnableLooping(true)
			station:SetPlaybackRate(1)
			station:SetVolume(ZVOX_VEHICLE_VOLUME / 100)
			station:Play()
		else
			ZVox.PrintError("engine sound error #" .. tostring(errCode) .. ": " .. tostring(errString))
		end
	end)
end

function ZVox.Sound_BeginVehicleSounds()
	--beginPropellerStream()
	--beginEngineStream()
end

function ZVox.Sound_EndVehicleSounds()
	if IsValid(ZVox.PropellerStream) then
		ZVox.PropellerStream:Stop()
	end

	if IsValid(ZVox.EngineStream) then
		ZVox.EngineStream:Stop()
	end
end

local function propSoundThink()
	local propEnabled = not ZVox.GetPlayerGrounded()

	if not propEnabled then
		if IsValid(ZVox.PropellerStream) and ZVox.PropellerStream:GetState() == GMOD_CHANNEL_PLAYING then
			ZVox.PropellerStream:Pause()
		end
		return
	end


	if not IsValid(ZVox.PropellerStream) then
		beginPropellerStream()
	end

	if not IsValid(ZVox.PropellerStream) then
		return
	end

	if ZVox.PropellerStream:GetState() ~= GMOD_CHANNEL_PLAYING then
		ZVox.PropellerStream:Play()
	end

	-- set rate bsaed on vert. speed
	local plyVelZ = ZVox.GetPlayerVel()[3]
	plyVelZ = plyVelZ + 16
	plyVelZ = plyVelZ / 26

	local pitch = 60 + (plyVelZ * 60)

	if IsValid(ZVox.PropellerStream) then
		ZVox.PropellerStream:SetPlaybackRate(pitch / 100)
	end
end


local function engineSoundThink()
	if not IsValid(ZVox.EngineStream) or (ZVox.EngineStream:GetState() == GMOD_CHANNEL_STOPPED) then
		beginEngineStream()
	end


	local plyVelC = ZVox.GetPlayerVel() * 1
	plyVelC[3] = math.max(plyVelC[3], 0)

	local plyVelL = plyVelC:Length()
	local velLDelta = math.min(plyVelL / 6, 1)

	local pitch = 100 + (velLDelta * 50)

	if IsValid(ZVox.EngineStream) then
		ZVox.EngineStream:SetPlaybackRate(pitch / 100)
	end
end


local isDigging = false
local nextSnd = 0
local function digSoundThink()
	if not isDigging then
		return
	end

	if CurTime() < nextSnd then
		return
	end

	local pitchAdd = (math.random() * 6)
	local pitch = 100 + pitchAdd
	local pitchAddDelta = 1 - (pitchAdd / 6)
	nextSnd = CurTime() + (.4 + (pitchAddDelta * .1))
	sound.Play("mothervox/sfx/vehicle/drill_short.wav", ZVox.GetPlayerInterpolatedPos(), 0, 100 + math.random() * 6, pitch)
end

function ZVox.Sound_VehicleSoundThink()
	propSoundThink()
	engineSoundThink()
	digSoundThink()
end


function ZVox.Sound_BeginDigSound()
	isDigging = true
end

function ZVox.Sound_EndDigSound()
	isDigging = false
end


function ZVox.UpdateVehicleVolume()
	if IsValid(ZVox.PropellerStream) then
		ZVox.PropellerStream:SetVolume(ZVOX_VEHICLE_VOLUME / 100)
	end

	if IsValid(ZVox.EngineStream) then
		ZVox.EngineStream:SetVolume(ZVOX_VEHICLE_VOLUME / 100)
	end
end