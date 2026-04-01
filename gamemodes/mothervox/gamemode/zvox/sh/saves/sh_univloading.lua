ZVox = ZVox or {}

-- TODO: this is dumb, should be moved over to SV

local function getOmitForPlayersInUniverse(univTargetName)
	if not SERVER then
		return player.GetAll()
	end

	local omitted = {}
	for k, v in ipairs(player.GetAll()) do -- cripple all
		if not v._zvox_enabled then
			omitted[#omitted + 1] = v
			continue
		end

		if ZVox.SV_GetPlayerZVoxUniverse(v) ~= univTargetName then
			omitted[#omitted + 1] = v
			continue
		end

		v._zvox_enabled = false
	end

	return omitted
end


local function emitFullUpdate(univTargetName)
	local omitted = getOmitForPlayersInUniverse(univTargetName)

	net.Start("zvox_senduniverse_refresh")
		net.WriteString(univTargetName)
	net.SendOmit(omitted)
end

function ZVox.CheckIfSaveExists(name)
	local filePath = "zvox/saves/" .. name .. ".dat"

	return file.Exists(filePath, "DATA")
end

function ZVox.LoadUniverse(fPtr, dstName)
	local magic = fPtr:Read(4)
	if magic ~= "ZVOX" then
		ZVox.PrintFatal("Cannot load \"" .. dstName .. "\"!, magic number doesn't match")
		fPtr:Close()
		return
	end

	local revision = fPtr:ReadByte()
	local dec = ZVOX_DECODER_LIST[revision]
	if not dec then
		ZVox.PrintFatal("Cannot load \"" .. dstName .. "\"!, no decoder for revision #" .. tostring(revision))
		fPtr:Close()
		return
	end

	local ret = dec.decodeFunc(fPtr, dstName)
	if ret ~= ZVOX_DECODE_OK then
		ZVox.PrintFatal("Cannot load \"" .. dstName .. "\"!, decoder fatal error")
		fPtr:Close()
		return
	end

	-- emit a full update to all connected clients if server
	if SERVER then
		emitFullUpdate(dstName)
	end

	fPtr:Close()
end

function ZVox.LoadUniverseFromSave(name, dstName)
	local filePath = "zvox/saves/" .. name .. ".dat"
	if not file.Exists(filePath, "DATA") then
		ZVox.PrintError("Attempting to load save \"" .. name .. "\" which doesn't exist!")
		return
	end

	local fPtr = file.Open(filePath, "rb", "DATA")
	ZVox.LoadUniverse(fPtr, dstName)
end


function ZVox.UnloadUniverse(name)
	local univObj = ZVox.GetUniverseByName(name)
	if not univObj then
		return
	end

	ZVox.SaveUniverse(univObj)
	ZVox.ForceProgressiveSaveUniverse(name)

	if SERVER then -- kick them out
		local omitted = getOmitForPlayersInUniverse(name)
		net.Start("zvox_senduniverse_unload")
			net.WriteString(name)
		net.SendOmit(omitted)
	end


	ZVox.DeleteUniverseFromRegistry(name)
end

-- hii if you're a dev i allow you to uncomment this and dick around with it
--[[
if SERVER then
	concommand.Add("zvox_load_universe_from_save", function(ply, cmd, args)
		if not ply:IsSuperAdmin() then
			ZVox.CommandErrorNotify(ply, "You're not a SuperAdmin!")
			return
		end

		local univTargetName = args[1]
		if not univTargetName then
			ZVox.CommandErrorNotify(ply, "zvox_load_universe_from_save <univTargetName> <saveName>")
			return
		end

		local saveName = args[2]
		if not saveName then
			ZVox.CommandErrorNotify(ply, "zvox_load_universe_from_save <univTargetName> <saveName>")
			return
		end

		ZVox.LoadUniverseFromSave(saveName, univTargetName)
	end)
end
]]--