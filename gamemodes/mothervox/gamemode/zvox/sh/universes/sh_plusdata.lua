ZVox = ZVox or {}

local _serializers = {}
function ZVox.DeclareNewPlusDataSerializer(name, data)
	_serializers[name] = data
end

function ZVox.GetPlusSerializer(name)
	return _serializers[name]
end

local _plusDatas = {}
local _plusDataNameToID = {}

function ZVox.GetPlusDataByID(id)
	return _plusDatas[id]
end

function ZVox.GetPlusDataByName(name)
	local id = _plusDataNameToID[name]
	if not id then
		return
	end

	return _plusDatas[id]
end


local _lastID = 0
function ZVox.GetPlusDataCount()
	return _lastID
end

function ZVox.DeclareNewPlusData(name, params)
	_lastID = _lastID + 1

	_plusDataNameToID[name] = _lastID

	_plusDatas[_lastID] = params
	_plusDatas[_lastID].name = name
end


function ZVox.GetDefaultPlusDataTable()
	local tbl = {}
	for i = 1, _lastID do
		local pData = _plusDatas[i]
		local name = pData.name
		local serialType = pData.serialtype

		local serializer = _serializers[serialType]
		if not serializer then
			ZVox.PrintFatal("PlusData \"" .. name .. "\" utilizes non-existing serializer \"" .. serialType .. "\"!")
			continue
		end

		tbl[name] = serializer.copy(pData.default)
	end
	return tbl
end

-- syncs plusdata to clients as the server
if SERVER then
	function ZVox.SV_UpdatePlusData(univ, name, val)
		if not univ then
			return
		end

		local pDataID = _plusDataNameToID[name]
		if not pDataID then
			ZVox.PrintError("Failure syncing plusdata, name \"" .. name .. "\" has no pDataID!")
			return
		end

		local pDataEntry = _plusDatas[pDataID]
		if not pDataEntry then
			ZVox.PrintError("Failure syncing plusdata, name \"" .. name .. "\" has no pDataEntry!")
			return
		end

		local fbWriter = ZVox.FB_NewFileBuffer()

		local serialType = pDataEntry.serialtype
		local serializer = _serializers[serialType]

		local fine, err = pcall(serializer.write, val, fbWriter)
		if not fine then
			ZVox.PrintError("PlusData Serializer error for \"" .. name .. "\" with type \"" .. serialType .. "\"")
			ZVox.PrintError(err)
			return
		end


		local contComp = util.Compress(ZVox.FB_GetContents(fbWriter))

		local netOmit = ZVox.SV_GetNetOmitForUniverse(univ.name)
		net.Start("zvox_sync_univ_plusdata")
			net.WriteString(univ.name)
			net.WriteString(name)

			net.WriteUInt(#contComp, 32)
			net.WriteData(contComp)
		net.SendOmit(netOmit)
	end

end


-- don't use this directly, please implement methods that call it
-- refer to plusdata/sh_plusdata_default.lua for reference on how to do it
function ZVox.SetUniversePlusDataValue(univ, name, value)
	if not univ then
		return
	end

	--if not univ["plusdata"][name] then -- commented cuz we need to be able to set new entries for dev
	--	return
	--end

	univ["plusdata"][name] = value

	if SERVER then
		ZVox.SV_UpdatePlusData(univ, name, value)
	end
end

-- don't use this one directly either
function ZVox.GetUniversePlusDataValue(univ, name)
	return univ["plusdata"][name]
end


function ZVox.SerializeUniversePlusData(univ)
	if not univ then
		return
	end

	local plusData = univ["plusdata"]
	if not plusData then
		ZVox.PrintFatal("Universe \"" .. univ.name .. "\" has no plusData!")
		return
	end



	local pDataFB = ZVox.FB_NewFileBuffer()

	ZVox.FB_Write(pDataFB, "PDA2")
	ZVox.FB_WriteULong(pDataFB, _lastID) -- then ID count

	local serialedFB = ZVox.FB_NewFileBuffer()
	local serialedData
	for i = 1, _lastID do
		local registryEntry = _plusDatas[i]

		local name = registryEntry.name
		local data = plusData[name]
		if data == nil then -- this was fucking awful
			ZVox.PrintFatal("data == nil when serializing PData, this is bad!")
			continue
		end

		-- magic first
		ZVox.FB_Write(pDataFB, "PDEN") -- PDEN -- PData ENtry
		ZVox.FB_WriteString(pDataFB, name)

		local serialType = registryEntry.serialtype
		local serializer = _serializers[serialType]
		if not serializer then
			ZVox.PrintError("PlusData \"" .. name .. "\" utilizes non-existing serializer \"" .. serialType .. "\"!")
			continue
		end

		ZVox.FB_Clear(serialedFB)
		local fine, err = pcall(serializer.write, data, serialedFB)
		if not fine then
			ZVox.PrintError("PlusData Serializer error for \"" .. name .. "\" with type \"" .. serialType .. "\"")
			ZVox.PrintError(err)
			continue
		end
		serialedData = ZVox.FB_GetContents(serialedFB)

		ZVox.FB_WriteULong(pDataFB, #serialedData)
		ZVox.FB_Write(pDataFB, serialedData)
	end


	-- return compressed blob
	local cont = ZVox.FB_GetContents(pDataFB)
	ZVox.FB_Close(pDataFB)

	return util.Compress(cont)
end

function ZVox.DeSerializeUniversePlusData(cont)
	local plusDataTable = {}
	local dComp = util.Decompress(cont)

	local pDataFB = ZVox.FB_NewFileBufferFromData(dComp)
	-- read magic first 
	local initialMagic = ZVox.FB_Read(pDataFB, 4)
	if initialMagic ~= "PDA2" then
		ZVox.PrintError("Error deserializing PData!, initial magic doesn't match")
		ZVox.PrintError("Probably an older version?")
		ZVox.FB_Close(pDataFB)
		return
	end


	local entryCount = ZVox.FB_ReadULong(pDataFB)
	ZVox.PrintDebug("PData entry count; ", entryCount)
	for i = 1, entryCount do
		-- read magic first
		local magic = ZVox.FB_Read(pDataFB, 4)

		if magic ~= "PDEN" then
			ZVox.PrintFatal("Error deserializing PData!, magic doesn't match for entry #" .. tostring(i))
			ZVox.PrintFatal("Read; " .. tostring(magic))
			ZVox.FB_Close(pDataFB)
			return
		end
		local name = ZVox.FB_ReadString(pDataFB)


		local entryID = _plusDataNameToID[name]
		if not entryID then
			ZVox.PrintFatal("No plusdata entryID with name \"" .. name .. "\"!")
			-- skip forward the length
			local lenSkip = ZVox.FB_ReadULong(pDataFB)
			ZVox.FB_Skip(pDataFB, lenSkip)
			continue
		end

		-- decode now
		-- read len and skip
		ZVox.FB_ReadULong(pDataFB) -- len, we don't care here
		local registryEntry = _plusDatas[entryID]
		local serialType = registryEntry.serialtype
		local serializer = _serializers[serialType]
		if not serializer then
			ZVox.PrintError("PlusData \"" .. name .. "\" utilizes non-existing serializer \"" .. serialType .. "\"!")
			continue
		end

		plusDataTable[name] = serializer.read(pDataFB)
	end

	-- now set defaults we could be missing
	for i = 1, _lastID do
		local pData = _plusDatas[i]
		local name = pData.name
		if plusDataTable[name] then
			continue
		end
		ZVox.PrintInfo("Injecting missing PData \"" .. name .. "\"!")

		local serialType = pData.serialtype
		local serializer = _serializers[serialType]
		if not serializer then
			ZVox.PrintError("PlusData \"" .. name .. "\" utilizes non-existing serializer \"" .. serialType .. "\"!")
			continue
		end

		plusDataTable[name] = serializer.copy(pData.default)
	end

	return plusDataTable
end