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


local _DIR_X_PLUS = 1
local _DIR_X_MINUS = 2
local _DIR_Y_PLUS = 3
local _DIR_Y_MINUS = 4
local _DIR_Z_PLUS = 5
local _DIR_Z_MINUS = 6

local opaqueLUT = ZVox.FastQuery_GetVoxelOpaqueLUT()
-- https://0fps.net/2013/07/03/ambient-occlusion-for-minecraft-like-worlds/
-- the .19999 is .3333 / .6
-- ^ this shit outdate its .2 + ~(.8 / 4)
local function vertexAO(side1, side2, corner, up) -- i wish that lua had macros so ts would inline
	--if side1 and side2 then
	--	return .4
	--end

	return .2 + ((side1 and 0 or .199) + (side2 and 0 or .199) + (corner and 0 or .199) + (up and 0 or .199))
end

--[[
local function vertexAO(side1, side2, corner, up)
	if side1 and side2 then
		return .4
	end

	return .4 + ((side1 and 0 or .1999) + (side2 and 0 or .1999) + (corner and 0 or .1999))
end
]]--


local cSizeX = ZVOX_CHUNKSIZE_X
local cSizeY = ZVOX_CHUNKSIZE_Y
local cSizeZ = ZVOX_CHUNKSIZE_Z
local cSizeConst = ZVOX_CHUNKSIZE_X * ZVOX_CHUNKSIZE_Y


local _chunkSizeX = 8
local _chunkSizeY = 8
local _chunkSizeZ = 8
local _chunkSizeConst1 = 8 * 8

local _blockSizeX = cSizeX * _chunkSizeX
local _blockSizeY = cSizeY * _chunkSizeY
local _blockSizeZ = cSizeZ * _chunkSizeZ
local _blockSizeConst1 = _blockSizeX * _blockSizeY
local function emitChunkSizes(chunkSizeX, chunkSizeY, chunkSizeZ)
	_chunkSizeX = chunkSizeX
	_chunkSizeY = chunkSizeY
	_chunkSizeZ = chunkSizeZ

	_chunkSizeConst1 = _chunkSizeX * _chunkSizeY

	_blockSizeX = cSizeX * _chunkSizeX
	_blockSizeY = cSizeY * _chunkSizeY
	_blockSizeZ = cSizeZ * _chunkSizeZ

	_blockSizeConst1 = _blockSizeX * _blockSizeY
end

local activeUnivChunks = nil
local function emitUniverse(univ)
	activeUnivChunks = univ["chunks"]
end

local INDEX_VOXELDATA = "voxelData"
local INDEX_VOXELLIGHTING = "vertexLighting"

local function getVoxelAtPos(x, y, z)
	if x < 0 or y < 0 or z < 0 or x >= _blockSizeX or y >= _blockSizeY then
		if z < 18 then -- TODO: get rid of this ugly hack to get worldbounds to AO
			return 1
		end

		return 0
	elseif z >= _blockSizeZ then
		return 0
	end

	local chunkIdx = math_floor(x / cSizeX) + (math_floor(y / cSizeY) * _chunkSizeX) + (math_floor(z / cSizeZ) * _chunkSizeConst1)
	local chunk = activeUnivChunks[chunkIdx]
	if not chunk then
		return
	end

	local voxData = chunk[INDEX_VOXELDATA]
	if not voxData then
		return 0
	end

	local blockIdx = (x % cSizeX) + ((y % cSizeY) * cSizeX) + ((z % cSizeZ) * cSizeConst)
	return voxData[blockIdx]
end



local VOXEL_SOLID = true
local VOXEL_TRANSPARENT = false

local accumGroup = ZVOX_VOXELGROUP_SOLID
local function pushOurGroup(group)
	accumGroup = group
end

local voxelGroupLUT = ZVox.FastQuery_GetVoxelGroupLUT()
local function getVoxelSolidAtPos(x, y, z)
	if x < 0 or y < 0 or z < 0 or x >= _blockSizeX or y >= _blockSizeY then
		if z < 18 then -- TODO: get rid of this ugly hack to get worldbounds to AO
			return VOXEL_SOLID
		end

		return VOXEL_TRANSPARENT
	elseif z >= _blockSizeZ then
		return VOXEL_TRANSPARENT
	end

	local chunkIdx = math_floor(x / cSizeX) + (math_floor(y / cSizeY) * _chunkSizeX) + (math_floor(z / cSizeZ) * _chunkSizeConst1)
	local chunk = activeUnivChunks[chunkIdx]
	if not chunk then
		return
	end

	local voxData = chunk[INDEX_VOXELDATA]
	if not voxData then
		return VOXEL_TRANSPARENT
	end


	local blockIdx = (x % cSizeX) + ((y % cSizeY) * cSizeX) + ((z % cSizeZ) * cSizeConst)
	local voxID = voxData[blockIdx]
	if voxelGroupLUT[voxID] ~= accumGroup then
		return VOXEL_TRANSPARENT
	end


	return opaqueLUT[voxID]
end

local function getVoxelGroupAtPos(x, y, z)
	if x < 0 or y < 0 or z < 0 or x >= _blockSizeX or y >= _blockSizeY then
		if z < 18 then -- TODO: get rid of this ugly hack to get worldbounds to AO
			return ZVOX_VOXELGROUP_SOLID
		end

		return ZVOX_VOXELGROUP_TRANSLUCENT
	elseif z >= _blockSizeZ then
		return ZVOX_VOXELGROUP_TRANSLUCENT
	end

	local chunkIdx = math_floor(x / cSizeX) + (math_floor(y / cSizeY) * _chunkSizeX) + (math_floor(z / cSizeZ) * _chunkSizeConst1)
	local chunk = activeUnivChunks[chunkIdx]
	if not chunk then
		return
	end

	local voxData = chunk[INDEX_VOXELDATA]
	if not voxData then
		return ZVOX_VOXELGROUP_TRANSLUCENT
	end



	local blockIdx = (x % cSizeX) + ((y % cSizeY) * cSizeX) + ((z % cSizeZ) * cSizeConst)
	return voxelGroupLUT[voxData[blockIdx]]
end

local _targetLightingTable = nil
local _targetIndex = nil
local function setLightingCoordinate(x, y, z)
	local chunkIdx = math_floor(x / cSizeX) + (math_floor(y / cSizeY) * _chunkSizeX) + (math_floor(z / cSizeZ) * _chunkSizeConst1)
	local chunk = activeUnivChunks[chunkIdx]
	if not chunk then
		return
	end

	local lightData = chunk[INDEX_VOXELLIGHTING]
	if not lightData then
		return
	end

	_targetLightingTable = lightData
	_targetIndex = (x % cSizeX) + ((y % cSizeY) * cSizeX) + ((z % cSizeZ) * cSizeConst)
end

local _targetFace = _DIR_X_PLUS
local function setLightingFace(face)
	_targetFace = face
end


local lightValues = 16
local lightOff2 = lightValues * lightValues
local lightOff3 = lightValues * lightValues * lightValues


local _targetB0 = 0
local _targetB1 = 0
local _targetB2 = 0
local _targetB3 = 0
local _targetBright = 0
local function setLightingValues(b0, b1, b2, b3)

	_targetB0 = math_floor(b0 * lightValues)
	_targetB1 = math_floor(b1 * lightValues)
	_targetB2 = math_floor(b2 * lightValues)
	_targetB3 = math_floor(b3 * lightValues)

	_targetBright = _targetB0 + (_targetB1 * lightValues) + (_targetB2 * lightOff2) + (_targetB3 * lightOff3)
end

local function emitFaceLighting()
	if not _targetLightingTable[_targetIndex] then
		_targetLightingTable[_targetIndex] = {}
	end

	_targetLightingTable[_targetIndex][_targetFace] = _targetBright
end

local FULLY_SURROUNDED_AMBIENT = .4

local voxelgroupDoCullingLUT = ZVox.GetVoxelGroupNoCullLUT()
local function relightVoxel(xc, yc, zc)
	local ourGroup = getVoxelGroupAtPos(xc, yc, zc)
	pushOurGroup(ourGroup)


	local blockThis = getVoxelSolidAtPos(xc, yc, zc) and voxelgroupDoCullingLUT[ourGroup]
	local blockxp = getVoxelSolidAtPos(xc + 1, yc, zc)
	local blockxm = getVoxelSolidAtPos(xc - 1, yc, zc)

	local blockyp = getVoxelSolidAtPos(xc, yc + 1, zc)
	local blockym = getVoxelSolidAtPos(xc, yc - 1, zc)

	local blockzp = getVoxelSolidAtPos(xc, yc, zc + 1)
	local blockzm = getVoxelSolidAtPos(xc, yc, zc - 1)

	-- quick skip if all sides are covered
	if      blockThis -- if solid cover
		and blockxp -- X+
		and blockxm -- X-
		and blockyp -- Y+
		and blockym -- Y-
		and blockzp -- Z+
		and blockzm -- Z+
	then
		return
	end

	-- to be fair
	-- as the current day 26/10/2025
	-- i don't understand wtf i was cooking with the original AO implementation
	-- back on the oldmesher, it was recomputed everytime too
	-- implement then improve i guess
	local ao_block_xy_pp_zm
	local ao_block_xy_pm_zm
	local ao_block_xy_mp_zm
	local ao_block_xy_mm_zm

	local ao_block_x_p_zm
	local ao_block_x_m_zm

	local ao_block_y_p_zm
	local ao_block_y_m_zm


	local ao_block_xy_pp_zn
	local ao_block_xy_pm_zn
	local ao_block_xy_mp_zn
	local ao_block_xy_mm_zn

	local ao_block_xy_pp_zp
	local ao_block_xy_pm_zp
	local ao_block_xy_mp_zp
	local ao_block_xy_mm_zp

	local ao_block_x_p_zp
	local ao_block_x_m_zp

	local ao_block_y_p_zp
	local ao_block_y_m_zp


	setLightingCoordinate(xc, yc, zc)
	-- do faces

	-- X+
	--local blockxp = getVoxelSolidAtPos(xc + 1, yc, zc)
	if blockThis and blockxp then
		setLightingFace(1)
		setLightingValues(FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT)
		emitFaceLighting()
	else
		ao_block_xy_pm_zn = ao_block_xy_pm_zn or getVoxelSolidAtPos(xc + 1, yc - 1, zc)
		ao_block_x_p_zm = ao_block_x_p_zm or getVoxelSolidAtPos(xc + 1, yc, zc - 1)
		ao_block_xy_pm_zm = ao_block_xy_pm_zm or getVoxelSolidAtPos(xc + 1, yc - 1, zc - 1)

		ao_block_xy_pm_zp = ao_block_xy_pm_zp or getVoxelSolidAtPos(xc + 1, yc - 1, zc + 1)
		ao_block_x_p_zp = ao_block_x_p_zp or getVoxelSolidAtPos(xc + 1, yc, zc + 1)

		ao_block_xy_pp_zn = ao_block_xy_pp_zn or getVoxelSolidAtPos(xc + 1, yc + 1, zc)
		ao_block_xy_pp_zp = ao_block_xy_pp_zp or getVoxelSolidAtPos(xc + 1, yc + 1, zc + 1)

		ao_block_xy_pp_zm = ao_block_xy_pp_zm or getVoxelSolidAtPos(xc + 1, yc + 1, zc - 1)
		local b0 = vertexAO(ao_block_xy_pm_zn, ao_block_x_p_zm, ao_block_xy_pm_zm, blockxp)
		local b1 = vertexAO(ao_block_xy_pm_zn, ao_block_x_p_zp, ao_block_xy_pm_zp, blockxp)
		local b2 = vertexAO(ao_block_xy_pp_zn, ao_block_x_p_zp, ao_block_xy_pp_zp, blockxp)
		local b3 = vertexAO(ao_block_x_p_zm, ao_block_xy_pp_zn, ao_block_xy_pp_zm, blockxp)

		setLightingFace(1)
		setLightingValues(b1, b2, b3, b0)
		emitFaceLighting()
	end

	-- X-
	--local blockxm = getVoxelSolidAtPos(xc - 1, yc, zc)
	if blockThis and blockxm then
		setLightingFace(2)
		setLightingValues(FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT)
		emitFaceLighting()
	else
		ao_block_xy_mm_zn = ao_block_xy_mm_zn or getVoxelSolidAtPos(xc - 1, yc - 1, zc)
		ao_block_x_m_zm = ao_block_x_m_zm or getVoxelSolidAtPos(xc - 1, yc, zc - 1)
		ao_block_xy_mm_zm = ao_block_xy_mm_zm or getVoxelSolidAtPos(xc - 1, yc - 1, zc - 1)

		ao_block_xy_mm_zp = ao_block_xy_mm_zp or getVoxelSolidAtPos(xc - 1, yc - 1, zc + 1)
		ao_block_x_m_zp = ao_block_x_m_zp or getVoxelSolidAtPos(xc - 1, yc, zc + 1)

		ao_block_xy_mp_zn = ao_block_xy_mp_zn or getVoxelSolidAtPos(xc - 1, yc + 1, zc)
		ao_block_xy_mp_zp = ao_block_xy_mp_zp or getVoxelSolidAtPos(xc - 1, yc + 1, zc + 1)

		ao_block_xy_mp_zm = ao_block_xy_mp_zm or getVoxelSolidAtPos(xc - 1, yc + 1, zc - 1)

		local b0 = vertexAO(ao_block_x_m_zm, ao_block_xy_mp_zn, ao_block_xy_mp_zm, blockxm)
		local b1 = vertexAO(ao_block_xy_mp_zn, ao_block_x_m_zp, ao_block_xy_mp_zp, blockxm)
		local b2 = vertexAO(ao_block_xy_mm_zn, ao_block_x_m_zp, ao_block_xy_mm_zp, blockxm)
		local b3 = vertexAO(ao_block_xy_mm_zn, ao_block_x_m_zm, ao_block_xy_mm_zm, blockxm)

		setLightingFace(2)
		setLightingValues(b1, b2, b3, b0)
		emitFaceLighting()
	end


	-- Y+
	--local blockyp = getVoxelSolidAtPos(xc, yc + 1, zc)
	if blockThis and blockyp then
		setLightingFace(3)
		setLightingValues(FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT)
		emitFaceLighting()
	else
		ao_block_y_p_zm = ao_block_y_p_zm or getVoxelSolidAtPos(xc, yc + 1, zc - 1)
		ao_block_xy_mp_zn = ao_block_xy_mp_zn or getVoxelSolidAtPos(xc - 1, yc + 1, zc)
		ao_block_xy_mp_zm = ao_block_xy_mp_zm or getVoxelSolidAtPos(xc - 1, yc + 1, zc - 1)

		ao_block_xy_pp_zn = ao_block_xy_pp_zn or getVoxelSolidAtPos(xc + 1, yc + 1, zc)
		ao_block_xy_pp_zm = ao_block_xy_pp_zm or getVoxelSolidAtPos(xc + 1, yc + 1, zc - 1)

		ao_block_y_p_zp = ao_block_y_p_zp or getVoxelSolidAtPos(xc, yc + 1, zc + 1)
		ao_block_xy_pp_zp = ao_block_xy_pp_zp or getVoxelSolidAtPos(xc + 1, yc + 1, zc + 1)

		ao_block_xy_mp_zp = ao_block_xy_mp_zp or getVoxelSolidAtPos(xc - 1, yc + 1, zc + 1)

		local b0 = vertexAO(ao_block_y_p_zm, ao_block_xy_mp_zn, ao_block_xy_mp_zm, blockyp)
		local b1 = vertexAO(ao_block_y_p_zm, ao_block_xy_pp_zn, ao_block_xy_pp_zm, blockyp)
		local b2 = vertexAO(ao_block_xy_pp_zn, ao_block_y_p_zp, ao_block_xy_pp_zp, blockyp)
		local b3 = vertexAO(ao_block_xy_mp_zn, ao_block_y_p_zp, ao_block_xy_mp_zp, blockyp)

		setLightingFace(3)
		setLightingValues(b2, b3, b0, b1)
		emitFaceLighting()
	end

	-- Y-
	--local blockym = getVoxelSolidAtPos(xc, yc - 1, zc)
	if blockThis and blockym then
		setLightingFace(4)
		setLightingValues(FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT)
		emitFaceLighting()
	else
		ao_block_y_m_zm = ao_block_y_m_zm or getVoxelSolidAtPos(xc, yc - 1, zc - 1)
		ao_block_xy_mm_zn = ao_block_xy_mm_zn or getVoxelSolidAtPos(xc - 1, yc - 1, zc)
		ao_block_xy_mm_zm = ao_block_xy_mm_zm or getVoxelSolidAtPos(xc - 1, yc - 1, zc - 1)

		ao_block_xy_pm_zn = ao_block_xy_pm_zn or getVoxelSolidAtPos(xc + 1, yc - 1, zc)
		ao_block_xy_pm_zm = ao_block_xy_pm_zm or getVoxelSolidAtPos(xc + 1, yc - 1, zc - 1)

		ao_block_y_m_zp = ao_block_y_m_zp or getVoxelSolidAtPos(xc, yc - 1, zc + 1)
		ao_block_xy_pm_zp = ao_block_xy_pm_zp or getVoxelSolidAtPos(xc + 1, yc - 1, zc + 1)

		ao_block_xy_mm_zp = ao_block_xy_mm_zp or getVoxelSolidAtPos(xc - 1, yc - 1, zc + 1)

		local b0 = vertexAO(ao_block_xy_mm_zn, ao_block_y_m_zp, ao_block_xy_mm_zp, blockym)
		local b1 = vertexAO(ao_block_xy_pm_zn, ao_block_y_m_zp, ao_block_xy_pm_zp, blockym)
		local b2 = vertexAO(ao_block_y_m_zm, ao_block_xy_pm_zn, ao_block_xy_pm_zm, blockym)
		local b3 = vertexAO(ao_block_y_m_zm, ao_block_xy_mm_zn, ao_block_xy_mm_zm, blockym)

		setLightingFace(4)
		setLightingValues(b0, b1, b2, b3)
		emitFaceLighting()
	end

	-- Z+
	--local blockzp = getVoxelSolidAtPos(xc, yc, zc + 1)
	if blockThis and blockzp then
		setLightingFace(5)
		setLightingValues(FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT)
		emitFaceLighting()
	else
		ao_block_x_m_zp = ao_block_x_m_zp or getVoxelSolidAtPos(xc - 1, yc, zc + 1)
		ao_block_x_p_zp = ao_block_x_p_zp or getVoxelSolidAtPos(xc + 1, yc, zc + 1)

		ao_block_y_p_zp = ao_block_y_p_zp or getVoxelSolidAtPos(xc, yc + 1, zc + 1)
		ao_block_y_m_zp = ao_block_y_m_zp or getVoxelSolidAtPos(xc, yc - 1, zc + 1)

		ao_block_xy_pp_zp = ao_block_xy_pp_zp or getVoxelSolidAtPos(xc + 1, yc + 1, zc + 1)
		ao_block_xy_pm_zp = ao_block_xy_pm_zp or getVoxelSolidAtPos(xc + 1, yc - 1, zc + 1)
		ao_block_xy_mp_zp = ao_block_xy_mp_zp or getVoxelSolidAtPos(xc - 1, yc + 1, zc + 1)
		ao_block_xy_mm_zp = ao_block_xy_mm_zp or getVoxelSolidAtPos(xc - 1, yc - 1, zc + 1)


		local b0 = vertexAO(ao_block_x_m_zp, ao_block_y_m_zp, ao_block_xy_mm_zp, blockzp)
		local b1 = vertexAO(ao_block_x_m_zp, ao_block_y_p_zp, ao_block_xy_mp_zp, blockzp)
		local b2 = vertexAO(ao_block_x_p_zp, ao_block_y_p_zp, ao_block_xy_pp_zp, blockzp)
		local b3 = vertexAO(ao_block_x_p_zp, ao_block_y_m_zp, ao_block_xy_pm_zp, blockzp)

		setLightingFace(5)
		setLightingValues(b0, b1, b2, b3)
		emitFaceLighting()
	end

	-- Z-
	--local blockzm = getVoxelSolidAtPos(xc, yc, zc - 1)
	if blockThis and blockzm then
		setLightingFace(6)
		setLightingValues(FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT, FULLY_SURROUNDED_AMBIENT)
		emitFaceLighting()
	else
		ao_block_x_m_zm = ao_block_x_m_zm or getVoxelSolidAtPos(xc - 1, yc, zc - 1)
		ao_block_x_p_zm = ao_block_x_p_zm or getVoxelSolidAtPos(xc + 1, yc, zc - 1)

		ao_block_y_p_zm = ao_block_y_p_zm or getVoxelSolidAtPos(xc, yc + 1, zc - 1)
		ao_block_y_m_zm = ao_block_y_m_zm or getVoxelSolidAtPos(xc, yc - 1, zc - 1)

		ao_block_xy_pp_zm = ao_block_xy_pp_zm or getVoxelSolidAtPos(xc + 1, yc + 1, zc - 1)
		ao_block_xy_pm_zm = ao_block_xy_pm_zm or getVoxelSolidAtPos(xc + 1, yc - 1, zc - 1)
		ao_block_xy_mp_zm = ao_block_xy_mp_zm or getVoxelSolidAtPos(xc - 1, yc + 1, zc - 1)
		ao_block_xy_mm_zm = ao_block_xy_mm_zm or getVoxelSolidAtPos(xc - 1, yc - 1, zc - 1)


		local b0 = vertexAO(ao_block_x_m_zm, ao_block_y_m_zm, ao_block_xy_mm_zm, blockzm)
		local b1 = vertexAO(ao_block_x_p_zm, ao_block_y_m_zm, ao_block_xy_pm_zm, blockzm)
		local b2 = vertexAO(ao_block_x_p_zm, ao_block_y_p_zm, ao_block_xy_pp_zm, blockzm)
		local b3 = vertexAO(ao_block_x_m_zm, ao_block_y_p_zm, ao_block_xy_mp_zm, blockzm)

		setLightingFace(6)
		setLightingValues(b2, b3, b0, b1)
		--setLightingValues(.2, .2, .2, .2)
		emitFaceLighting()
	end
end


local _VOXEL_AIR = 0 -- id 0 should always be air

-- TODO: this should recompute ZVox.FastQuery_SetUniverse() if the univ isn't the last one but it doesnt!
-- it doesn't break currently thanks to ZVox.RemeshUniv() calling ZVox.Lighting_FullRelightChunk() which does it!
function ZVox.Lighting_RelightVoxel(x, y, z)
	-- if no AO on, don't bother relighting
	if not ZVOX_DO_AO then
		return
	end

	-- neighbours, we do a square
	for i = 0, (3 * 3 * 3) do
		local xc = ((i % 3) - 1) + x
		local yc = ((math_floor(i / 3) % 3) - 1) + y
		local zc = ((math_floor(i / 9) % 3) - 1) + z

		if (xc < 0) or (yc < 0) or (zc < 0) then
			continue
		end

		if (xc > _blockSizeX) or (yc > _blockSizeY) or (zc > _blockSizeZ) then
			continue
		end


		if getVoxelAtPos(xc, yc, zc) ~= _VOXEL_AIR then
			relightVoxel(xc, yc, zc)
		end
	end
end




function ZVox.Lighting_FullRelightChunk(chunk)
	-- if no AO on, don't bother relighting
	if not ZVOX_DO_AO then
		return
	end


	local univ = chunk["univ"]
	ZVox.FastQuery_SetUniverse(univ)

	emitChunkSizes(univ.chunkSizeX, univ.chunkSizeY, univ.chunkSizeZ)
	emitUniverse(univ)

	local coX, coY, coZ = ZVox.ChunkIndexToWorld(univ, chunk["index"])

	local voxelData = chunk["voxelData"]
	for i = 0, (cSizeX * cSizeY * cSizeZ) - 1 do
		local xc = (i % cSizeX)
		local yc = (math_floor(i / cSizeX) % cSizeY)
		local zc = (math_floor(i / cSizeConst) % cSizeZ)

		local voxID = voxelData[i]
		if not voxID then
			continue
		end

		if voxID == _VOXEL_AIR then
			continue
		end

		--if not voxInfo[_EXPRESS_IDX_VISIBLE] then
		--	continue
		--end

		relightVoxel(xc + coX, yc + coY, zc + coZ)
	end
end

-- to fix luarefresh black lighting bug
function ZVox.Lighting_SetActiveUniverse()
	if not ZVox.GetActiveUniverse then
		return
	end


	local univ = ZVox.GetActiveUniverse()
	if not univ then
		return
	end

	ZVox.FastQuery_SetUniverse(univ)

	emitChunkSizes(univ.chunkSizeX, univ.chunkSizeY, univ.chunkSizeZ)
	emitUniverse(univ)
end
ZVox.Lighting_SetActiveUniverse()