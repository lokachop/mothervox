ZVox = ZVox or {}
local DECODER = {
	["name"] = "ZVox:DecodeV1",
}


local math = math
local math_floor = math.floor


local function readLenString(fPtr)
	local len = fPtr:ReadULong()
	return fPtr:Read(len)
end

local function decUniverseParameters(fPtr, univObj)
	local univName = readLenString(fPtr) -- pointless atm

	local cSizeX = fPtr:ReadULong()
	local cSizeY = fPtr:ReadULong()
	ZVox.SetUniverseChunkSize(univObj, cSizeX, cSizeY, cSizeY)

	local tintR = fPtr:ReadDouble()
	local tintG = fPtr:ReadDouble()
	local tintB = fPtr:ReadDouble()

	local tint = Vector(math.min(tintR, 1), math.min(tintG, 1), math.min(tintB, 1))
	ZVox.SetUniverseWorldTint(univObj, tint)


	local gradients = {}
	local gradientCount = fPtr:ReadUShort()
	for i = 1, gradientCount do
		local eScalar = fPtr:ReadDouble()

		local colR = fPtr:ReadByte()
		local colG = fPtr:ReadByte()
		local colB = fPtr:ReadByte()

		gradients[#gradients + 1] = {
			["e"] = eScalar,
			["c"] = Color(colR, colG, colB)
		}
	end
end

local function decConversionLUT(fPtr, univObj)
	-- this returns a ID-ID LUT for conversion, used later
	local count = fPtr:ReadUShort()

	local convLUT = {}
	for i = 0, count do
		local idOrigin = fPtr:ReadByte()
		local nameOrigin = readLenString(fPtr)

		convLUT[idOrigin] = ZVox.GetVoxelID(nameOrigin)
	end

	return convLUT
end

local function decChunkData(fPtr, univObj, convLUT)
	local dataLen = fPtr:ReadULong()
	local dataComp = fPtr:Read(dataLen)

	local dataDec = ZVox.OLD_DeSerializeChunkVoxelData(util.Decompress(dataComp))

	-- Translate for mismatch
	for i = 0, #dataDec do
		dataDec[i] = convLUT[dataDec[i]] or 1 -- hardcoded "error" voxel
	end

	return dataDec
end

local function worldgenAir()
	return "zvox:air"
end

local function preConvert(univObj)
	-- convert to the new Z inclusive method
	local cSizeX = univObj["chunkSizeX"]
	local cSizeY = univObj["chunkSizeY"]
	local cSizeZ = univObj["chunkSizeY"]

	-- init empty cuhnks first
	for i = 0, (cSizeX * cSizeY * cSizeZ) - 1 do
		local chunk = ZVox.NewChunk(i)
		ZVox.SetChunkUniv(chunk, univObj)
		ZVox.ChunkPerformWorldGenCustom(chunk, worldgenAir)

		univObj["chunks"][i] = chunk
	end
end

local function convertChunkData(idx, data, univObj)
	local cSizeX = univObj["chunkSizeX"]
	local cSizeY = univObj["chunkSizeY"]

	local cX = (idx % cSizeX) * 8
	local cY = (math_floor(idx / cSizeX) % cSizeY) * 8

	for j = 0, #data do
		local val = data[j]

		local xC = j % 8 + cX
		local yC = math_floor(j / 8) % 8 + cY
		local zC = math_floor(j / 64) % 128


		ZVox.SetBlockAtPos(univObj, xC, yC, zC, val)
	end
end

local function decodeV1(fPtr, univTargetName)
	local univObj = ZVox.NewUniverse(univTargetName)
	decUniverseParameters(fPtr, univObj)

	local convLUT = decConversionLUT(fPtr, univObj)


	-- convert to the new Z inclusive method
	preConvert(univObj)

	local cSizeX = univObj["chunkSizeX"]
	local cSizeY = univObj["chunkSizeY"]

	-- these saves were chunksize 8x8x128
	for i = 0, (cSizeX * cSizeY) - 1 do
		local data = decChunkData(fPtr, univObj, convLUT)

		convertChunkData(i, data, univObj)
	end


	local magicOK = fPtr:Read(4)
	if magicOK ~= "__OK" then
		ZVox.PrintFatal("Final magic doesn't match __OK, stuff has gone wrong...")
		return ZVOX_DECODE_ERR
	end
	return ZVOX_DECODE_OK
end

DECODER["decodeFunc"] = decodeV1
ZVOX_DECODER_LIST[1] = DECODER