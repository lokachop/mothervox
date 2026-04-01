ZVox = ZVox or {}

local math = math
local math_floor = math.floor

-- EXPRESSINCLUDE
local voxInfoExpressRegistry = ZVox.GetExpressVoxelInfoRegistry()
local _EXPRESS_IDX_NAME 	        = ZVOX_EXPRESS_IDX_NAME
local _EXPRESS_IDX_VISIBLE          = ZVOX_EXPRESS_IDX_VISIBLE
local _EXPRESS_IDX_SOLID            = ZVOX_EXPRESS_IDX_SOLID
local _EXPRESS_IDX_MULTITEX         = ZVOX_EXPRESS_IDX_MULTITEX
local _EXPRESS_IDX_TEX              = ZVOX_EXPRESS_IDX_TEX
local _EXPRESS_IDX_VOXELGROUP       = ZVOX_EXPRESS_IDX_VOXELGROUP
local _EXPRESS_IDX_VOXELMODEL       = ZVOX_EXPRESS_IDX_VOXELMODEL
local _EXPRESS_IDX_VOXELMODEL_TABLE = ZVOX_EXPRESS_IDX_VOXELMODEL_TABLE
local _EXPRESS_IDX_EMISSIVE         = ZVOX_EXPRESS_IDX_EMISSIVE
local _EXPRESS_IDX_OPAQUE           = ZVOX_EXPRESS_IDX_OPAQUE
-- EXPRESSINCLUDE


local CULL_X_PLUS = 1
local CULL_X_MINUS = 2
local CULL_Y_PLUS = 4
local CULL_Y_MINUS = 8
local CULL_Z_PLUS = 16
local CULL_Z_MINUS = 32

local DIR_X_PLUS = 1
local DIR_X_MINUS = 2

local DIR_Y_PLUS = 3
local DIR_Y_MINUS = 4

local DIR_Z_PLUS = 5
local DIR_Z_MINUS = 6

-- block size of the chunks in ZVox, constant and won't change during runtime
-- 8x8x8 by default
-- this being 16x16x??? in minecraft
local C_SIZE_X = ZVOX_CHUNKSIZE_X
local C_SIZE_Y = ZVOX_CHUNKSIZE_Y
local C_SIZE_Z = ZVOX_CHUNKSIZE_Z
local C_SIZE_CONSTANT = ZVOX_CHUNKSIZE_X * ZVOX_CHUNKSIZE_Y

-- nº chunks in the universe per axis
-- main being 8x8x8
local univChunkSizeX = 8
local univChunkSizeY = 8
local univChunkSizeZ = 8
local univChunkSizeConstant = univChunkSizeX * univChunkSizeY

-- size of world in blocks
-- so main being 128x128x128
local blockSizeX = C_SIZE_X * univChunkSizeX
local blockSizeY = C_SIZE_Y * univChunkSizeY
local blockSizeZ = C_SIZE_Z * univChunkSizeZ
local blockSizeConstant = blockSizeX * blockSizeY
local function emitUnivChunkSizes(szX, szY, szZ)
	univChunkSizeX = szX
	univChunkSizeY = szY
	univChunkSizeZ = szZ
	univChunkSizeConstant = univChunkSizeX * univChunkSizeY

	-- recompute blocksize
	blockSizeX = C_SIZE_X * univChunkSizeX
	blockSizeY = C_SIZE_Y * univChunkSizeY
	blockSizeZ = C_SIZE_Z * univChunkSizeZ
	blockSizeConstant = blockSizeX * blockSizeY
end

local activeUnivChunks = nil
local function emitUniverse(univ)
	activeUnivChunks = univ["chunks"]
end

local INDEX_VOXELDATA = "voxelData"
local INDEX_VOXELSTATE = "voxelState"
local INDEX_VOXELCULLING = "cullingData"


-- checks if the plane _A fits inside the plane _B
-- this is used for culling
local function planeFitsInPlane(minX_A, minY_A, maxX_A, maxY_A, minX_B, minY_B, maxX_B, maxY_B)
	-- general case with fucked up shit
	--return ((minX_A >= minX_B) and (minX_A <= maxX_B)) and ((maxX_A >= minX_B) and (maxX_A <= maxX_B)) and ((minY_A >= minY_B) and (minY_A <= maxY_B)) and ((maxY_A >= minY_B) and (maxY_A <= maxY_B))

	-- works for our case
	return (minX_A >= minX_B) and (maxX_A <= maxX_B) and (minY_A >= minY_B) and (maxY_A <= maxY_B)
end

local voxelModelTableLUT = ZVox.FastQuery_GetVoxelModelTableLUT()
local voxelModelLUT = ZVox.FastQuery_GetVoxelModelLUT()
local voxelGroupLUT = ZVox.FastQuery_GetVoxelGroupLUT()

local function getVoxelModelAtPos(x, y, z)
	if x < 0 or y < 0 or z < 0 or x >= blockSizeX or y >= blockSizeY then
		return nil, true
	elseif z >= blockSizeZ then
		return
	end

	local chunkIdx = math_floor(x / C_SIZE_X) + (math_floor(y / C_SIZE_Y) * univChunkSizeX) + (math_floor(z / C_SIZE_Z) * univChunkSizeConstant)
	local chunk = activeUnivChunks[chunkIdx]
	if not chunk then
		return
	end

	local voxData = chunk[INDEX_VOXELDATA]
	if not voxData then
		return
	end

	local voxStateData = chunk[INDEX_VOXELSTATE]
	if not voxStateData then
		return
	end

	local blockIdx = (x % C_SIZE_X) + ((y % C_SIZE_Y) * C_SIZE_X) + ((z % C_SIZE_Z) * C_SIZE_CONSTANT)


	-- this is pretty complex we should simplify
	-- implement, then optimize!
	-- avoid premature optimization!
	local voxelID = voxData[blockIdx]
	if voxelID == 0 then
		return
	end

	local state = voxStateData[blockIdx]

	local vTable = voxelModelTableLUT[voxelID]
	if vTable and vTable[state] then
		return vTable[state], false, voxelGroupLUT[voxelID]
	end

	return voxelModelLUT[voxelID], false, voxelGroupLUT[voxelID]
end

local VOXEL_AIR = 0
local function getVoxelAtPos(x, y, z)
	if x < 0 or y < 0 or z < 0 or x >= blockSizeX or y >= blockSizeY or z >= blockSizeZ then
		return VOXEL_AIR
	end

	local chunkIdx = math_floor(x / C_SIZE_X) + (math_floor(y / C_SIZE_Y) * univChunkSizeX) + (math_floor(z / C_SIZE_Z) * univChunkSizeConstant)
	local chunk = activeUnivChunks[chunkIdx]
	if not chunk then
		return
	end

	local voxData = chunk[INDEX_VOXELDATA]
	if not voxData then
		return
	end

	local blockIdx = (x % C_SIZE_X) + ((y % C_SIZE_Y) * C_SIZE_X) + ((z % C_SIZE_Z) * C_SIZE_CONSTANT)

	return voxData[blockIdx]
end


local targetCullingTable = nil
local targetIndex = nil
local targetValue = 0
local function setCullingCoordinate(x, y, z)
	local chunkIdx = math_floor(x / C_SIZE_X) + (math_floor(y / C_SIZE_Y) * univChunkSizeX) + (math_floor(z / C_SIZE_Z) * univChunkSizeConstant)
	local chunk = activeUnivChunks[chunkIdx]
	if not chunk then
		return
	end

	local cullData = chunk[INDEX_VOXELCULLING]
	if not cullData then
		return
	end

	targetValue = 0
	targetCullingTable = cullData
	targetIndex = (x % C_SIZE_X) + ((y % C_SIZE_Y) * C_SIZE_X) + ((z % C_SIZE_Z) * C_SIZE_CONSTANT)
end

local targetDirVal = 0
local function setCullingDirection(dir)
	targetDirVal = dir
end

local function addCullingValue(cull)
	if cull then
		targetValue = targetValue + targetDirVal
	end
end

local function emitCulling()
	targetCullingTable[targetIndex] = targetValue
end


local vmdlTable = ZVox.GetVoxelModelRegistry()
-- we're checking if A is covered by B
-- a being the vmdlTable[dir]
-- b being the vmdlTable[OPPOSITE_DIR_TABLE[dir]]
-- TODO: we can precompute this as a table!
local function dirCull(a, b)
	local ourFace
	local theirFace
	-- for each of our faces
	for i = 1, #a do
		ourFace = a[i]

		if not ourFace[22] then -- uncullable face this direction, skip
			return false
		end

		-- go through their faces
		local didFit = false
		for j = 1, #b do
			theirFace = b[j]

			if not theirFace[22] then -- if their face no cullable we can't cull in this dir as it exposes
				return false
			end

			local fits = planeFitsInPlane(
				-- our
				ourFace[13], ourFace[14], -- min
				ourFace[15], ourFace[16], -- max

				-- their
				theirFace[13], theirFace[14], -- min
				theirFace[15], theirFace[16] -- max
			)

			if fits then
				didFit = true
				break
			end
		end

		if not didFit then
			return false
		end
	end
	return true
end


local voxelgroupDoCullingLUT = ZVox.GetVoxelGroupNoCullLUT()
local voxelgroupOpaqueLUT = ZVox.GetVoxelGroupOpaqueLUT()
local function cullBlock(x, y, z)
	local thisVMdl, _, thisGroup = getVoxelModelAtPos(x, y, z)
	if not thisVMdl then
		return -- air, no cull!
	end

	setCullingCoordinate(x, y, z)

	if not voxelgroupDoCullingLUT[thisGroup] then
		emitCulling() -- emits zero
		return
	end

	-- special water check
	local notWater = thisGroup ~= ZVOX_VOXELGROUP_WATER

	local vmdlDataThis = vmdlTable[thisVMdl]
	local didCull = false


	local vmdlTarget, oobSkip, otherGroup

	-- X+
	vmdlTarget, oobSkip, otherGroup = getVoxelModelAtPos(x + 1, y, z)
	if oobSkip then
		setCullingDirection(CULL_X_PLUS)
		addCullingValue(true)
	elseif vmdlTarget and ((thisGroup == otherGroup) or voxelgroupOpaqueLUT[otherGroup]) then
		local vmdlDataOther = vmdlTable[vmdlTarget]

		didCull = dirCull(vmdlDataThis[DIR_X_PLUS], vmdlDataOther[DIR_X_MINUS])

		setCullingDirection(CULL_X_PLUS)
		addCullingValue(didCull)
	end

	-- X-
	vmdlTarget, oobSkip, otherGroup = getVoxelModelAtPos(x - 1, y, z)
	if oobSkip then
		setCullingDirection(CULL_X_MINUS)
		addCullingValue(true)
	elseif vmdlTarget and ((thisGroup == otherGroup) or voxelgroupOpaqueLUT[otherGroup]) then
		local vmdlDataOther = vmdlTable[vmdlTarget]

		didCull = dirCull(vmdlDataThis[DIR_X_MINUS], vmdlDataOther[DIR_X_PLUS])

		setCullingDirection(CULL_X_MINUS)
		addCullingValue(didCull)
	end

	-- Y+
	vmdlTarget, oobSkip, otherGroup = getVoxelModelAtPos(x, y + 1, z)
	if oobSkip then
		setCullingDirection(CULL_Y_PLUS)
		addCullingValue(true)
	elseif vmdlTarget and ((thisGroup == otherGroup) or voxelgroupOpaqueLUT[otherGroup]) then
		local vmdlDataOther = vmdlTable[vmdlTarget]

		didCull = dirCull(vmdlDataThis[DIR_Y_PLUS], vmdlDataOther[DIR_Y_MINUS])

		setCullingDirection(CULL_Y_PLUS)
		addCullingValue(didCull)
	end

	-- Y-
	vmdlTarget, oobSkip, otherGroup = getVoxelModelAtPos(x, y - 1, z)
	if oobSkip then
		setCullingDirection(CULL_Y_MINUS)
		addCullingValue(true)
	elseif vmdlTarget and ((thisGroup == otherGroup) or voxelgroupOpaqueLUT[otherGroup]) then
		local vmdlDataOther = vmdlTable[vmdlTarget]

		didCull = dirCull(vmdlDataThis[DIR_Y_MINUS], vmdlDataOther[DIR_Y_PLUS])

		setCullingDirection(CULL_Y_MINUS)
		addCullingValue(didCull)
	end

	-- Z+
	vmdlTarget, oobSkip, otherGroup = getVoxelModelAtPos(x, y, z + 1)
	if oobSkip then
		setCullingDirection(CULL_Z_PLUS)
		addCullingValue(true)
	elseif vmdlTarget and ((thisGroup == otherGroup) or (voxelgroupOpaqueLUT[otherGroup] and notWater)) then
		local vmdlDataOther = vmdlTable[vmdlTarget]

		didCull = dirCull(vmdlDataThis[DIR_Z_PLUS], vmdlDataOther[DIR_Z_MINUS])

		setCullingDirection(CULL_Z_PLUS)
		addCullingValue(didCull)
	end

	-- Z-
	vmdlTarget, oobSkip, otherGroup = getVoxelModelAtPos(x, y, z - 1)
	if oobSkip then
		setCullingDirection(CULL_Z_MINUS)
		addCullingValue(true)
	elseif vmdlTarget and ((thisGroup == otherGroup) or voxelgroupOpaqueLUT[otherGroup]) then
		local vmdlDataOther = vmdlTable[vmdlTarget]

		didCull = dirCull(vmdlDataThis[DIR_Z_MINUS], vmdlDataOther[DIR_Z_PLUS])

		setCullingDirection(CULL_Z_MINUS)
		addCullingValue(didCull)
	end

	emitCulling()
end


function ZVox.Culling_CullVoxel(x, y, z)
	cullBlock(x, y, z)

	-- +x
	if getVoxelAtPos(x + 1, y, z) ~= VOXEL_AIR then
		cullBlock(x + 1, y, z)
	end

	-- -x
	if getVoxelAtPos(x - 1, y, z) ~= VOXEL_AIR then
		cullBlock(x - 1, y, z)
	end

	-- +y
	if getVoxelAtPos(x, y + 1, z) ~= VOXEL_AIR then
		cullBlock(x, y + 1, z)
	end

	-- -y
	if getVoxelAtPos(x, y - 1, z) ~= VOXEL_AIR then
		cullBlock(x, y - 1, z)
	end

	-- +z
	if getVoxelAtPos(x, y, z + 1) ~= VOXEL_AIR then
		cullBlock(x, y, z + 1)
	end

	-- -z
	if getVoxelAtPos(x, y, z - 1) ~= VOXEL_AIR then
		cullBlock(x, y, z - 1)
	end
end

function ZVox.Culling_FullRecullChunk(chunk)
	local univ = chunk["univ"]
	ZVox.FastQuery_SetUniverse(univ)

	emitUnivChunkSizes(univ.chunkSizeX, univ.chunkSizeY, univ.chunkSizeZ)

	local coX, coY, coZ = ZVox.ChunkIndexToWorld(univ, chunk["index"])


	local voxelData = chunk["voxelData"]
	for i = 0, (C_SIZE_X * C_SIZE_Y * C_SIZE_Z) - 1 do
		local xc = (i % C_SIZE_X)
		local yc = (math_floor(i / C_SIZE_X) % C_SIZE_Y)
		local zc = (math_floor(i / C_SIZE_CONSTANT) % C_SIZE_Z)

		local voxID = voxelData[i]
		if not voxID then
			continue
		end

		if voxID == VOXEL_AIR then
			continue
		end

		cullBlock(xc + coX, yc + coY, zc + coZ)
	end
end

-- to fix luarefresh black lighting bug
function ZVox.Culling_SetActiveUniverse()
	if not ZVox.GetActiveUniverse then
		return
	end

	local univ = ZVox.GetActiveUniverse()
	if not univ then
		return
	end

	ZVox.FastQuery_SetUniverse(univ)

	emitUniverse(univ)
	emitUnivChunkSizes(univ.chunkSizeX, univ.chunkSizeY, univ.chunkSizeZ)
end
ZVox.Culling_SetActiveUniverse()