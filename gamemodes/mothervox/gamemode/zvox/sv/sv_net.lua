ZVox = ZVox or {}

-- UNIVERSES
-- cl -> sv
util.AddNetworkString("zvox_requestuniverse")
util.AddNetworkString("zvox_leaveuniverse")
-- sv -> cl
util.AddNetworkString("zvox_senduniverse")
util.AddNetworkString("zvox_sendchunks")
util.AddNetworkString("zvox_senduniverse_complete")
util.AddNetworkString("zvox_senduniverse_refresh")
util.AddNetworkString("zvox_senduniverse_unload")


-- PLUSDATA
util.AddNetworkString("zvox_sync_univ_plusdata")




-- UNIVERSES, REGISTRY
-- cl -> sv
util.AddNetworkString("zvox_requestuniverse_registry")
-- sv -> cl
util.AddNetworkString("zvox_senduniverse_registry")


-- ACTIONS
-- cl -> sv
util.AddNetworkString("zvox_sendplayeraction")
-- sv -> cl
util.AddNetworkString("zvox_sendaction")


-- PLY UPDATES
-- cl -> sv
util.AddNetworkString("zvox_sendplayerupdate")
-- sv -> cl
util.AddNetworkString("zvox_invalidatemovement")
util.AddNetworkString("zvox_emitplayerupdates")
util.AddNetworkString("zvox_sendactiveplayers")
util.AddNetworkString("zvox_playerconnect")
util.AddNetworkString("zvox_playerdisconnect")


-- SKIN UPLOADING
-- cl -> sv
util.AddNetworkString("zvox_send_skin")
-- sv -> cl
util.AddNetworkString("zvox_emit_skin")


-- UNIVERSE MANAGEMENT
-- cl -> sv
util.AddNetworkString("zvox_request_save_listing")
util.AddNetworkString("zvox_request_universe_load")
util.AddNetworkString("zvox_request_universe_deletion")
-- sv -> cl
util.AddNetworkString("zvox_send_save_listing")


util.AddNetworkString("mothervox_regenerate_world")
util.AddNetworkString("mothervox_save_world")

local rateLimitRegistry = {}
local function ratelimit(ply, name, wait)
	if not rateLimitRegistry[ply] then
		rateLimitRegistry[ply] = {}
	end


	local val = rateLimitRegistry[ply][name] or 0
	if CurTime() > val then
		rateLimitRegistry[ply][name] = CurTime() + wait
		return false
	end

	return true
end


net.Receive("zvox_requestuniverse", function(len, ply)
	if not IsValid(ply) then
		return
	end

	if ratelimit(ply, "zvox_requestuniverse", 2) then -- 2s between universe requests
		return
	end


	local univName = net.ReadString()
	if not univName then
		return
	end

	if ZVox.PrintLevel <= PRINTLEVEL_DEV then
		ZVox.PrintInfo(ply:Nick() .. " requesting universe \"" .. univName .. "\"")
	end

	local univObj = ZVox.GetUniverseByName(univName)
	if not univObj then
		ZVox.PrintInfo("No universe named \"" .. univName .. "\" aborting!")
		return
	end

	if ZVox.SV_GetPlayerZVoxUniverse(ply) ~= nil then
		ZVox.SV_PlayerDisconnect(ply:SteamID64())
		ZVox.CancelUniverseTransmission(ply)
		ply._zvox_enabled = false
	end

	ply._zvox_enabled = true
	ply._zvox_universe = univName
	ZVox.BeginUniverseTransmission(ply, univObj)
	ZVox.SV_PlayerConnect(ply:SteamID64(), univName)
end)

net.Receive("zvox_sendplayeraction", function(len, ply)
	if not IsValid(ply) then
		return
	end

	local act = ZVox.NET_ReadAction()

	ZVox.SV_ExecuteAction(ply, act)
end)


net.Receive("zvox_sendplayerupdate", function(len, ply)
	if not IsValid(ply) then
		return
	end

	local sID = ply:SteamID64()
	local pos = net.ReadVector()
	if not pos then
		return
	end

	local rot = net.ReadFloat()
	if not rot then
		return
	end

	local rotP = net.ReadFloat()
	if not rotP then
		return
	end

	ZVox.SV_UpdatePlayer(sID, pos, rot, rotP)
end)


-- TODO: add RATE LIMITING
local univReg = ZVox.GetUniverseRegistry()
local sortFunc = function(a, b)
	return a < b
end

local _sortedList = {}
net.Receive("zvox_requestuniverse_registry", function(len, ply)
	if not IsValid(ply) then
		return
	end

	if ratelimit(ply, "zvox_request_universe_registry", 1) then -- 1s between requesting it
		return
	end

	for i = 1, #_sortedList do -- clear it
		_sortedList[i] = nil
	end


	local itr = 0
	for k, v in pairs(univReg) do
		itr = itr + 1
		_sortedList[itr] = k
	end

	table.sort(_sortedList, sortFunc)

	ZVox.SV_RecomputeUniversePlayerCounts()

	-- send it back, now sorted
	local count = #_sortedList
	net.Start("zvox_senduniverse_registry")
	net.WriteUInt(count, 16)
	for i = 1, count do
		local val = _sortedList[i]

		local plyCount = ZVox.SV_GetUniversePlayerCount(val)

		-- order is like this
		-- name
		-- desc
		-- plycount (16 bit)
		-- maxplycount (16 bit)
		net.WriteString(val)
		net.WriteString("This universe has no description!")
		net.WriteUInt(plyCount, 16)
		net.WriteUInt(128, 16) -- TODO: properly implement max playercount!
	end
	net.Send(ply)
end)


net.Receive("zvox_leaveuniverse", function(len, ply)
	if not IsValid(ply) then
		return
	end

	if not ZVox.SV_GetPlayerZVoxActive(ply) then
		return
	end
	ply._zvox_enabled = false

	ZVox.SV_PlayerDisconnect(ply:SteamID64())
end)

net.Receive("zvox_request_save_listing", function(len, ply)
	if not IsValid(ply) then
		return
	end

	if ratelimit(ply, "zvox_request_save_listing", 2) then
		return
	end

	local listing = ZVox.SV_GetUnloadedSaveListing()
	local listCount = #listing

	local fBuffSend = ZVox.FB_NewFileBuffer()

	ZVox.FB_WriteUShort(fBuffSend, listCount)
	for i = 1, listCount do
		local entry = listing[i]
		ZVox.FB_WriteUShort(fBuffSend, #entry)
		ZVox.FB_Write(fBuffSend, entry)
	end

	local buffData = ZVox.FB_GetContents(fBuffSend)
	ZVox.FB_Close(fBuffSend)

	net.Start("zvox_send_save_listing")
		net.WriteData(util.Compress(buffData))
	net.Send(ply)
end)

net.Receive("mothervox_regenerate_world", function(len, ply)
	if not ply:IsSuperAdmin() then
		return
	end

	ZVox.RegenerateWorld()
end)

-- attempt to fix a stupid crash
-- sometimes zvox likes to hardcrash while breaking blocks
-- im gonna blame the save system
net.Receive("mothervox_save_world", function(len, ply)
	if not ply:IsSuperAdmin() then
		return
	end

	ZVox.SaveUniverse(ZVox.GetUniverseByName("mothervox"), "mothervox")
	ZVox.ForceProgressiveSaveUniverse("mothervox")
end)