ZVox = ZVox or {}
local ENCODER = {
	["name"] = "ZVox:EncodeV1",
	["progressive"] = false,
}


local voxelInfoRegistry = ZVox.GetVoxelRegistry()
file.CreateDir("zvox/temp/")


if ZVOX_ENCODER_MAXVERSION < 1 then
	ZVOX_ENCODER_MAXVERSION = 1
end


local function writeLenString(fPtr, stringWrite)
	fPtr:WriteULong(#stringWrite)
	fPtr:Write(stringWrite)
end


local function writeUniverseParameters(fPtr, univObj, fileName)
	-- Name
	local univName = univObj["name"]
	writeLenString(fPtr, univName)

	-- ChunkSize
	fPtr:WriteULong(univObj["chunkSizeX"])
	fPtr:WriteULong(univObj["chunkSizeY"])

	-- World tint
	local tint = univObj["worldcol"]
	fPtr:WriteDouble(tint[1])
	fPtr:WriteDouble(tint[2])
	fPtr:WriteDouble(tint[3])

	-- Sky gradients
	local gradient = univObj["skycol"]
	fPtr:WriteUShort(#gradient)
	for i = 1, #gradient do
		local grad = gradient[i]
		local eScalar = grad.e
		fPtr:WriteDouble(eScalar)

		local col = grad.c
		fPtr:WriteByte(math.min(math.floor(col.r), 255), 8)
		fPtr:WriteByte(math.min(math.floor(col.g), 255), 8)
		fPtr:WriteByte(math.min(math.floor(col.b), 255), 8)
	end
end

local function writeIndexConversionLUT(fPtr, univObj, fileName)
	local count = #voxelInfoRegistry

	fPtr:WriteUShort(count)
	for i = 0, count do
		local voxNfo = voxelInfoRegistry[i]

		fPtr:WriteByte(i)
		writeLenString(fPtr, voxNfo.name)
	end
end

local function writeChunk(fPtr, univObj, fileName, chunk)
	local data = util.Compress(ZVox.OLD_SerializeChunkVoxelData(chunk.voxelData))
	fPtr:WriteULong(#data)
	fPtr:Write(data)
end


-- Encoder V1
local function encodeV1(fPtr, univObj, fileName)
	--local fPtrTemp = file.Open("zvox/temp/enc1.dat", "wb", "DATA")
	--if not fPtrTemp then
	--	error("[ZVox Enc1] Couldn't open temporary file \"zvox/temp/enc1.dat\"! aborting!")
	--	return
	--end

	-- UnivParams
	writeUniverseParameters(fPtr, univObj, fileName)

	-- Index conversion LUT
	-- Used when decoding to translate for future updates / shifts
	writeIndexConversionLUT(fPtr, univObj, fileName)

	local cSizeX = univObj["chunkSizeX"]
	local cSizeY = univObj["chunkSizeY"]

	local chunks = univObj["chunks"]

	for i = 0, (cSizeX * cSizeY) - 1 do
		local chunk = chunks[i]

		writeChunk(fPtr, univObj, fileName, chunk)
	end

	fPtr:Write("__OK") -- append this as a magic that says file is written OK

	--fPtrTemp:Close()
	-- we done writing on our file, now copy it to the main file

	-- read and compress
	--fPtrTemp = file.Open("zvox/temp/enc1.dat", "rb", "DATA")
	--local comp = util.Compress(fPtrTemp:Read())
	--fPtr:WriteULong(#comp)
	--fPtr:Write(comp)


	return ZVOX_ENCODE_OK -- say that we are ok
end
ENCODER["encodeFunc"] = encodeV1

ZVOX_ENCODER_LIST[1] = ENCODER