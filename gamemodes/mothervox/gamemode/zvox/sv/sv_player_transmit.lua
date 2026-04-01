ZVox = ZVox or {}

ZVox.PersistentSIDToUniverseLUT = ZVox.PersistentSIDToUniverseLUT or {}
local sIDToUniverseLUT = ZVox.PersistentSIDToUniverseLUT

ZVox.PersistentActivePlayerLUT = ZVox.PersistentActivePlayerLUT or {}
local activePlayerLUT = ZVox.PersistentActivePlayerLUT
local function newPlayer(sID, universeName)
	if not activePlayerLUT[universeName] then
		activePlayerLUT[universeName] = {}
	end


	if activePlayerLUT[universeName][sID] then
		return
	end

	local univObj = ZVox.GetUniverseByName(universeName)
	if not univObj then
		return
	end
	local spawnPos = ZVox.GetUniverseSpawnPoint(univObj) * 1

	local physObj = ZVox.PHYSICS_NewPhysicsObject({
		["pos"] = spawnPos,
		["scl"] = Vector(.6, .6, 1.8),
		["stepSize"] = 0.5,
	})
	ZVox.PHYSICS_SetPhysicsObjectUniverse(physObj, univObj)


	sIDToUniverseLUT[sID] = universeName
	activePlayerLUT[universeName][sID] = {
		["sID"]  = sID,
		["skinTag"] = {},
		["physObj"] = physObj,
		["pos"]  = spawnPos,
		["rot"]  = 0,
		["rotP"] = 0,
	}
end

function ZVox.SV_GetNetworkPlayerFromSID(sID)
	local universeName = sIDToUniverseLUT[sID]
	if not universeName then
		return
	end

	local plyReg = activePlayerLUT[universeName][sID]
	if not plyReg then
		return
	end

	return plyReg
end

function ZVox.SV_UpdatePlayer(sID, pos, rot, rotP)
	local universeName = sIDToUniverseLUT[sID]
	if not universeName then
		return
	end

	local plyReg = activePlayerLUT[universeName][sID]
	if not plyReg then
		return
	end

	plyReg.rot  = rot
	plyReg.rotP = rotP
	plyReg.pos:Set(pos)
end

function ZVox.SV_GetPlayerSkinTag(ply)
	if not IsValid(ply) then
		return
	end

	if not ply._zvox_enabled then
		return
	end

	local netPly = ZVox.SV_GetNetworkPlayerFromSID(ply:SteamID64())
	if not netPly then
		return
	end

	return netPly.skinTag
end

function ZVox.BroadcastConnectedPlayers(sID, universeName)
	if not sID then
		return
	end

	local ply = player.GetBySteamID64(sID)
	if not IsValid(ply) then
		return
	end

	local activePlayers = activePlayerLUT[universeName]

	-- TODO: rewrite to be sequential array
	local plys = {}
	for k, v in pairs(activePlayers) do
		plys[#plys + 1] = k
	end


	local plyCount = #plys
	net.Start("zvox_sendactiveplayers")
		net.WriteUInt(plyCount, 8)
		for i = 1, plyCount do
			local sIDThis = plys[i]
			local plyInfo = activePlayers[sIDThis]
			net.WriteUInt64(sIDThis)
			ZVox.NET_WriteSkinTag(plyInfo.skinTag)
		end
	net.Send(ply)
end



function ZVox.SV_PlayerConnect(sID, universeName)
	if not sID then
		return
	end

	local ply = player.GetBySteamID64(sID)
	if not IsValid(ply) then
		return
	end

	ZVox.PrintInfo("Player connected \"" .. ply:Nick() .. "\"")

	if not activePlayerLUT[universeName] then
		activePlayerLUT[universeName] = {}
	end

	if activePlayerLUT[universeName][sID] then
		return
	end

	newPlayer(sID, universeName)


	local omit = ZVox.SV_GetNetOmitForUniverse(universeName, ply)
	net.Start("zvox_playerconnect")
		net.WriteUInt64(sID)
	net.SendOmit(omit)
end


function ZVox.SV_PlayerDisconnect(sID)
	local universeName = sIDToUniverseLUT[sID]
	if not universeName then
		return
	end

	local ply = player.GetBySteamID64(sID)
	local omit = ZVox.SV_GetNetOmitForUniverse(universeName, ply)
	net.Start("zvox_playerdisconnect")
		net.WriteUInt64(sID)
	net.SendOmit(omit)

	activePlayerLUT[universeName][sID] = nil
end


local function broadcastPlayerUpdatesForUniv(universeName)
	local activePlayers = activePlayerLUT[universeName]

	local plys = {}
	for k, v in pairs(activePlayers) do
		plys[#plys + 1] = k
	end

	local omit = ZVox.SV_GetNetOmitForUniverse(universeName)
	local plyCount = #plys
	net.Start("zvox_emitplayerupdates", true)
	net.WriteUInt(plyCount, 8)
	for i = 1, plyCount do
		local sID = plys[i]
		local plyInfo = activePlayers[sID]

		net.WriteUInt64(sID)
		net.WriteVector(plyInfo.pos)
		net.WriteFloat(plyInfo.rot)
		net.WriteFloat(plyInfo.rotP)
	end
	net.SendOmit(omit)
end


local nextPlyUpdate = CurTime() + ZVOX_PLAYERSTATUS_UPDATE_WAIT
function ZVox.BroadcastPlayerUpdates()
	if CurTime() <= nextPlyUpdate then
		return
	end

	nextPlyUpdate = CurTime() + ZVOX_PLAYERSTATUS_UPDATE_WAIT


	for k, v in pairs(activePlayerLUT) do
		broadcastPlayerUpdatesForUniv(k)
	end
end



gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "ZVoxPlayerDisconnect", function(data)
	local sID32 = data.networkid

	local sID = util.SteamIDTo64(sID32)
	ZVox.SV_PlayerDisconnect(sID)
end)