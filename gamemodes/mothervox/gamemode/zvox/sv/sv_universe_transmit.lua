ZVox = ZVox or {}

local universeTransmitRegistry = {}
local universeTransmitStack = {}

function ZVox.CancelUniverseTransmission(ply, univ)
	if not IsValid(ply) then
		return
	end

	if not ply._zvox_univ_transmitting then
		return
	end

	ply._zvox_univ_transmitting = false

	local sID = ply:SteamID64()

	universeTransmitRegistry[sID] = nil
end

function ZVox.BeginUniverseTransmission(ply, univ)
	if not IsValid(ply) then
		return
	end

	ply._zvox_univ_transmitting = true

	local sID = ply:SteamID64()

	if universeTransmitRegistry[sID] then
		return
	end

	ZVox.PrintInfo("Begin transmit for player \"" .. ply:Name() .. "\"")

	universeTransmitRegistry[sID] = {
		["startTransmit"] = CurTime(),
		["targetUniv"] = univ,
		["currChunk"] = 0,
		["totalChunks"] = 0,
		["nextTransmit"] = 0,
	}

	local cSizeX = univ["chunkSizeX"]
	local cSizeY = univ["chunkSizeY"]
	local cSizeZ = univ["chunkSizeZ"]

	universeTransmitRegistry[sID].totalChunks = cSizeX * cSizeY * cSizeZ

	-- first we send the univ params here
	net.Start("zvox_senduniverse")
		net.WriteString(univ["name"]) -- Name

		net.WriteUInt(cSizeX, 16) -- ChunkSizeX
		net.WriteUInt(cSizeY, 16) -- ChunkSizeY
		net.WriteUInt(cSizeZ, 16) -- ChunkSizeZ

		-- now send plusData
		local pData = ZVox.SerializeUniversePlusData(univ)
		local pDataLen = #pData

		net.WriteUInt(pDataLen, 32)
		net.WriteData(pData, pDataLen)
	net.Send(ply)

	universeTransmitStack[#universeTransmitStack + 1] = sID
end

function ZVox.FinishChunkTransmission(sID)
	-- delay by transmission delay
	--timer.Simple(CHUNK_TRANSMIT_WAIT * 2, function()
		local reg = universeTransmitRegistry[sID]
		if not reg then
			return
		end

		local ply = player.GetBySteamID64(sID)
		if not ply then
			return
		end

		ply._zvox_univ_transmitting = false

		-- now we transfer the changeBuffer
		ZVox.FinishUniverseTransmission(sID)
	--end)
end

function ZVox.FinishUniverseTransmission(sID)
	universeTransmitRegistry[sID] = nil

	local ply = player.GetBySteamID64(sID)
	if not ply then
		return
	end

	net.Start("zvox_senduniverse_complete")
	net.Send(ply)

	ZVox.BroadcastConnectedPlayers(sID, ZVox.SV_GetPlayerZVoxUniverse(ply))
end


local function transmitOp(reg, sID)
	local ply = player.GetBySteamID64(sID)
	if not ply then
		ZVox.PrintInfo("No player to send, Halting!")
		ZVox.FinishUniverseTransmission(sID)
		return
	end

	local targetUniv = reg["targetUniv"]
	if not targetUniv then
		ZVox.PrintInfo("Univ to send doesn't exist, Halting!")
		ZVox.FinishUniverseTransmission(sID)
		return
	end

	local _FINISHED = false

	local totalChunks = reg["totalChunks"]
	local currChunk = reg["currChunk"]


	local accumSz = 0
	local chunksToSend = {}
	local chunksLeft = totalChunks - currChunk

	if chunksLeft <= 0 then
		_FINISHED = true
	end

	local baseIdx = currChunk
	for i = 1, chunksLeft do
		if accumSz >= ZVOX_CHUNK_TRANSMIT_MAX_BUFFER_SIZE then
			break
		end

		local chunkToSend = targetUniv["chunks"][currChunk]
		if not chunkToSend then
			print("no chunk, ending, currChunk: ", currChunk)
			_FINISHED = true
			break
		end

		local vData = ZVox.SerializeChunkVoxelData(chunkToSend.voxelData)
		local vState = ZVox.SerializeChunkVoxelData(chunkToSend.voxelState)

		accumSz = accumSz + #vData
		accumSz = accumSz + #vState

		chunksToSend[#chunksToSend + 1] = {vData, vState}

		currChunk = currChunk + 1
	end

	reg["currChunk"] = currChunk

	ZVox.TransmitChunks(chunksToSend, ply, baseIdx)

	if _FINISHED then
		ZVox.PrintInfo("Done sending world!")
		ZVox.FinishChunkTransmission(sID)
	end
end

function ZVox.UniverseTransmitThink()
	if #universeTransmitStack <= 0 then
		return
	end

	local toPurge = {}
	for i = 1, #universeTransmitStack do
		local sID = universeTransmitStack[i]
		local reg = universeTransmitRegistry[sID]
		if not reg then
			toPurge[#toPurge + 1] = i
			continue
		end

		if reg.nextTransmit > CurTime() then
			continue
		end

		reg.nextTransmit = CurTime() + CHUNK_TRANSMIT_WAIT

		transmitOp(reg, sID)
	end

	if #toPurge <= 0 then
		return
	end

	for i = #toPurge, 1, -1 do
		local contPurge = toPurge[i]
		table.remove(universeTransmitStack, contPurge)
	end
end

-- TODO: func to sync plusdata (ex. buildmode perms)