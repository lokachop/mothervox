ZVox = ZVox or {}

local activeReceiving = false
local activeReceivingUniverse = nil
net.Receive("zvox_senduniverse", function(len)
	local univName = net.ReadString()
	if not univName then
		return
	end

	local univCSizeX = net.ReadUInt(16)
	local univCSizeY = net.ReadUInt(16)
	local univCSizeZ = net.ReadUInt(16)

	local univObj = ZVox.NewUniverse(univName, {
		["chunkSizeX"] = univCSizeX,
		["chunkSizeY"] = univCSizeY,
		["chunkSizeZ"] = univCSizeZ,
	})

	-- decode pData
	local pDataLen = net.ReadUInt(32)
	local pDataBlob = net.ReadData(pDataLen)

	local pData = ZVox.DeSerializeUniversePlusData(pDataBlob)
	if not pData then
		ZVox.PrintFatal("Major error receiving universe PlusData, falling back to defaults...")
		ZVox.RawSetUniversePlusDataTable(univObj, ZVox.GetDefaultPlusDataTable())
	else
		ZVox.RawSetUniversePlusDataTable(univObj, pData)
	end


	activeReceivingUniverse = univObj

	activeReceiving = true
	ZVox.BeginActionBuffer(univObj)

	ZVox.BeginLoadScreen(univObj)
end)


net.Receive("zvox_sendchunks", function(len)
	local univ = activeReceivingUniverse
	if not univ then
		ZVox.PrintFatal("Error while receiving chunk data, activeReceivingUniverse doesn't exist!")
		return
	end

	local baseIndex = net.ReadUInt(32)
	local chunkCount = net.ReadUInt(32)

	for i = baseIndex, baseIndex + chunkCount do
		local idx = i --baseIndex + (i - 1)

		local chunk = ZVox.NewChunk(idx)
		ZVox.SetChunkUniv(chunk, univ)

		local dataLen = net.ReadUInt(32)
		local data = net.ReadData(dataLen)
		if not data then
			ZVox.PrintFatal("Error while receiving chunk data for chunk #" .. idx .. "!")
			return
		end

		chunk["voxelData"] = ZVox.DeSerializeChunkVoxelData(data)

		-- read voxelstate
		dataLen = net.ReadUInt(32)
		data = net.ReadData(dataLen)
		if not data then
			ZVox.PrintFatal("Error while receiving voxelState for chunk #" .. idx .. "!")
			return
		end

		chunk["voxelState"] = ZVox.DeSerializeChunkVoxelData(data)
		univ["chunks"][idx] = chunk
	end

	ZVox.AddLoadScreenChunks(chunkCount)
end)


net.Receive("zvox_senduniverse_complete", function(len)
	ZVox.PrintInfo("Done with receiving the universe!")
	activeReceiving = false
	ZVox.FlushActionBuffer()

	ZVox.ConnectToUniverse(activeReceivingUniverse)
end)

net.Receive("zvox_sendaction", function(len)
	local act = ZVox.NET_ReadAction()
	ZVox.IncInboundActions()

	if activeReceiving then
		ZVox.PushActionToActionBuffer(act)
	else
		ZVox.CL_ExecuteAction(act)
	end
end)


net.Receive("zvox_senduniverse_refresh", function(len)
	local univName = net.ReadString()

	ZVox.AttemptConnectionToUniverse(univName)
end)

net.Receive("zvox_senduniverse_registry", function(len)
	local count = net.ReadUInt(16)

	for i = 1, count do
		local univName = net.ReadString()
		local univDesc = net.ReadString()

		local univPlyCount = net.ReadUInt(16)
		local univMaxPlyCount = net.ReadUInt(16)

		ZVox.GUI_AddUniverseToUniverseList(univName, univDesc, -1, univPlyCount, univMaxPlyCount)
	end
end)


net.Receive("zvox_sync_univ_plusdata", function(len)
	local univName = net.ReadString()
	local univObj = ZVox.GetUniverseByName(univName)
	if not univObj then
		return
	end

	local plusDataName = net.ReadString()
	if not plusDataName then
		return
	end

	local dataLen = net.ReadUInt(32)
	local dataFB = net.ReadData(dataLen)
	if not dataFB then
		return
	end

	dataFB = util.Decompress(dataFB)
	if not dataFB then
		return
	end
	dataFB = ZVox.FB_NewFileBufferFromData(dataFB)


	local pDataEntry = ZVox.GetPlusDataByName(plusDataName)
	local serializer = ZVox.GetPlusSerializer(pDataEntry.serialtype)
	if not serializer then
		return
	end

	local value = serializer.read(dataFB)
	if value == nil then
		return
	end

	ZVox.SetUniversePlusDataValue(univObj, plusDataName, value)
end)


net.Receive("zvox_send_save_listing", function(len)
	local dataRead = net.ReadData(len)
	if not dataRead then
		return
	end

	dataRead = util.Decompress(dataRead)
	if not dataRead then
		return
	end


	local fBuffRead = ZVox.FB_NewFileBufferFromData(dataRead)

	local entryCount = ZVox.FB_ReadUShort(fBuffRead)
	for _ = 1, entryCount do
		local nameLen = ZVox.FB_ReadUShort(fBuffRead)
		local name = ZVox.FB_Read(fBuffRead, nameLen)

		ZVox.AddSaveToLoadUI(name)
	end
end)


net.Receive("zvox_senduniverse_unload", function(len)
	if ZVox.GetState() ~= ZVOX_STATE_INGAME then
		return
	end

	ZVox.DisconnectFromUniverse()
	ZVox.OpenAlertPanel({
		["width"] = 600,
		["height"] = 300,


		["header"] = "Disconnected from the universe!",
		["headerFontSize"] = 3,
		["headerColor"] = Color(255, 96, 96),

		["headerIcon"] = "warn",
		["headerIconScale"] = 3,
		["headerIconPad"] = 8,


		["text"] = "You were disconnected from the universe by the server\nThis usually means that someone unloaded the universe!",
		["textSize"] = 2,
		["textPadLeft"] = 8,
		["textPadTop"] = 8,
	})


	local univName = net.ReadString()
	if not univName then
		return
	end

	ZVox.DeleteUniverseFromRegistry(univName)
end)

net.Receive("zvox_invalidatemovement", function()
	if ZVox.GetState() ~= ZVOX_STATE_INGAME then
		return
	end

	local pos = net.ReadVector()
	if not pos then
		return
	end

	local vel = net.ReadVector()
	if not vel then
		return
	end

	ZVox.SetPlayerPos(pos)
	ZVox.SetPlayerVel(vel)
end)