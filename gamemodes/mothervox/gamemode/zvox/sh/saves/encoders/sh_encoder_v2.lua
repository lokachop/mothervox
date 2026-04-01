ZVox = ZVox or {}
local ENCODER = {
	["name"] = "ZVox:EncodeV2",
	["progressive"] = true,
}

if not file.Exists("zvox/temp/", "DATA") then
	file.CreateDir("zvox/temp/")
end

local voxelInfoRegistry = ZVox.GetVoxelRegistry()
if ZVOX_ENCODER_MAXVERSION < 2 then
	ZVOX_ENCODER_MAXVERSION = 2
end


local function writeLenString(fBuff, stringWrite)
	ZVox.FB_WriteULong(fBuff, #stringWrite)
	ZVox.FB_Write(fBuff, stringWrite)
end


-- writes universe params and plusdata
local function writeUnivParams(univObj, fBuff)
	local name = univObj["name"]
	writeLenString(fBuff, name)

	-- write chunk size and chunk count
	-- chunksz first
	-- this way we can warn if it doesn't equal and perhaps later on convert
	ZVox.FB_WriteUShort(fBuff, ZVOX_CHUNKSIZE_X)
	ZVox.FB_WriteUShort(fBuff, ZVOX_CHUNKSIZE_Y)
	ZVox.FB_WriteUShort(fBuff, ZVOX_CHUNKSIZE_Z)

	-- chunk counts
	ZVox.FB_WriteUShort(fBuff, univObj["chunkSizeX"])
	ZVox.FB_WriteUShort(fBuff, univObj["chunkSizeY"])
	ZVox.FB_WriteUShort(fBuff, univObj["chunkSizeZ"])


	-- now we write plusdata
	local pData = ZVox.SerializeUniversePlusData(univObj)
	ZVox.FB_WriteULong(fBuff, #pData)
	ZVox.FB_Write(fBuff, pData)
end


local function writeConversionLUT(fBuff)
	local count = #voxelInfoRegistry

	ZVox.FB_WriteULong(fBuff, count)
	for i = 0, count do
		local voxNfo = voxelInfoRegistry[i]

		ZVox.FB_WriteUShort(fBuff, i)
		writeLenString(fBuff, voxNfo.name)
	end
end


local function writeChunk(fBuff, chunk)
	local voxelData = ZVox.OLD_SerializeChunkVoxelData(chunk["voxelData"])
	ZVox.FB_WriteULong(fBuff, #voxelData)
	ZVox.FB_Write(fBuff, voxelData)
	voxelData = nil -- garbage collect

	-- voxelstate now
	local voxelState = ZVox.OLD_SerializeChunkVoxelData(chunk["voxelState"])
	ZVox.FB_WriteULong(fBuff, #voxelState)
	ZVox.FB_Write(fBuff, voxelState)
	voxelState = nil -- garbage collect
end


-- Encoder V2
-- this shit is progressive so remember to return 
local CHUNK_ITERATIONS = 16 * 2
local function encodeV2(fPtr, univObj, persistData)
	if not persistData["fBuff"] then
		persistData["fBuff"] = ZVox.FB_NewFileBuffer()
	end
	local fBuff = persistData["fBuff"]

	if not persistData["univParams"] then
		writeUnivParams(univObj, fBuff)
		persistData["univParams"] = true

		return ZVOX_PROGRESSIVE_ENCODE_CONTINUE
	end

	if not persistData["convLUT"] then
		writeConversionLUT(fBuff)
		persistData["convLUT"] = true

		return ZVOX_PROGRESSIVE_ENCODE_CONTINUE
	end

	local cSizeX = univObj["chunkSizeX"]
	local cSizeY = univObj["chunkSizeY"]
	local cSizeZ = univObj["chunkSizeZ"]
	local maxChunks = ((cSizeX * cSizeY * cSizeZ) - 1)


	if not persistData["lastChunk"] then
		persistData["lastChunk"] = 0
	end
	local lastChunk = persistData["lastChunk"]


	if lastChunk < maxChunks then
		local chunks = univObj["chunks"]
		local goalChunk = math.min(maxChunks, lastChunk + CHUNK_ITERATIONS)
		for i = lastChunk, goalChunk do
			local chunk = chunks[i]
			writeChunk(fBuff, chunk)
		end
		persistData["lastChunk"] = goalChunk + 1

		return ZVOX_PROGRESSIVE_ENCODE_CONTINUE
	end

	-- compress and write to file
	-- TODO: fix lagspike here
	local cont = util.Compress(ZVox.FB_GetContents(fBuff))

	fPtr:WriteULong(#cont) -- this has a 4gb limit, beware! :)
	fPtr:Write(cont)

	fPtr:Write("__OK")
	fPtr:Close()

	ZVox.FB_Close(fBuff) -- clean up

	return ZVOX_PROGRESSIVE_ENCODE_FINISHED
end

ENCODER["encodeFunc"] = encodeV2
ZVOX_ENCODER_LIST[2] = ENCODER