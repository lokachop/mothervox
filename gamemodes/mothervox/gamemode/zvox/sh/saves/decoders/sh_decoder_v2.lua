ZVox = ZVox or {}
local DECODER = {
	["name"] = "ZVox:DecodeV2",
}


local function readLenString(fBuff)
	return ZVox.FB_Read(fBuff, ZVox.FB_ReadULong(fBuff))
end

local function decodeUniverseParameters(fBuff, univObj)
	local name = readLenString(fBuff)

	local cSizeX_Global = ZVox.FB_ReadUShort(fBuff)
	if cSizeX_Global ~= ZVOX_CHUNKSIZE_X then
		ZVox.PrintFatal("World has different ZVOX_CHUNKSIZE_X!")
		ZVox.PrintFatal("TODO: implement conversion")
	end

	local cSizeY_Global = ZVox.FB_ReadUShort(fBuff)
	if cSizeY_Global ~= ZVOX_CHUNKSIZE_Y then
		ZVox.PrintFatal("World has different ZVOX_CHUNKSIZE_Y!")
		ZVox.PrintFatal("TODO: implement conversion")
	end

	local cSizeZ_Global = ZVox.FB_ReadUShort(fBuff)
	if cSizeZ_Global ~= ZVOX_CHUNKSIZE_Z then
		ZVox.PrintFatal("World has different ZVOX_CHUNKSIZE_Z!")
		ZVox.PrintFatal("TODO: implement conversion")
	end

	local cSizeX = ZVox.FB_ReadUShort(fBuff)
	local cSizeY = ZVox.FB_ReadUShort(fBuff)
	local cSizeZ = ZVox.FB_ReadUShort(fBuff)
	ZVox.SetUniverseChunkSize(univObj, cSizeX, cSizeY, cSizeZ)

	local pDataLen = ZVox.FB_ReadULong(fBuff)
	local pDataBlob = ZVox.FB_Read(fBuff, pDataLen)
	local pData = ZVox.DeSerializeUniversePlusData(pDataBlob)
	if not pData then
		ZVox.PrintError("World has malformed pData (probably the broken v1!) defaulting to the default data!")
		pData = ZVox.GetDefaultPlusDataTable()
	end

	ZVox.RawSetUniversePlusDataTable(univObj, pData)
end

local removedVoxelConversionLUT = ZVox.GetConversionTable()
local function decodeConversionLUT(fBuff, univObj)
	local convLUT = {}
	local count = ZVox.FB_ReadULong(fBuff)

	for i = 0, count do
		local idOrigin = ZVox.FB_ReadUShort(fBuff)
		local nameOrigin = readLenString(fBuff)

		if not ZVox.NAMESPACES_IsStringNamespace(nameOrigin) then
			nameOrigin = ZVox.NAMESPACES_NamespaceConvertLegacy(nameOrigin)
		end

		local translatedName = removedVoxelConversionLUT[nameOrigin]
		if translatedName then
			convLUT[idOrigin] = ZVox.GetVoxelID(translatedName)
			continue
		end

		convLUT[idOrigin] = ZVox.GetVoxelID(nameOrigin)
	end

	return convLUT
end

local function decodeChunk(idx, fBuff, univObj, convLUT)
	local chunk = ZVox.NewChunk(idx)


	local voxelDataSerialLen = ZVox.FB_ReadULong(fBuff)
	local voxelDataSerial = ZVox.FB_Read(fBuff, voxelDataSerialLen)
	local voxelData = ZVox.OLD_DeSerializeChunkVoxelData(voxelDataSerial)

	-- convert voxeldata to current IDs
	for i = 0, #voxelData do
		voxelData[i] = convLUT[voxelData[i]] or 1 -- hardcoded "error" voxel
	end
	chunk["voxelData"] = voxelData

	local voxelStateSerialLen = ZVox.FB_ReadULong(fBuff)
	local voxelStateSerial = ZVox.FB_Read(fBuff, voxelStateSerialLen)
	local voxelState = ZVox.OLD_DeSerializeChunkVoxelData(voxelStateSerial)
	chunk["voxelState"] = voxelState

	return chunk
end


local function decodeV2(fPtr, univTargetName)
	local univObj = ZVox.NewUniverse(univTargetName)

	local fBuffComp = util.Decompress(fPtr:Read(fPtr:ReadULong()))
	local magicEnd = fPtr:Read(4)
	if magicEnd ~= "__OK" then
		return ZVOX_DECODE_ERR
	end

	local fBuff = ZVox.FB_NewFileBufferFromData(fBuffComp)
	decodeUniverseParameters(fBuff, univObj)


	local convLUT = decodeConversionLUT(fBuff, univObj)

	local cSizeX = univObj["chunkSizeX"]
	local cSizeY = univObj["chunkSizeY"]
	local cSizeZ = univObj["chunkSizeZ"]
	local maxChunks = ((cSizeX * cSizeY * cSizeZ) - 1)

	for i = 0, maxChunks do
		local chunk = decodeChunk(i, fBuff, univObj, convLUT)

		univObj["chunks"][i] = chunk
	end

	ZVox.FB_Close(fBuff) -- clean up

	return ZVOX_DECODE_OK
end

DECODER["decodeFunc"] = decodeV2
ZVOX_DECODER_LIST[2] = DECODER