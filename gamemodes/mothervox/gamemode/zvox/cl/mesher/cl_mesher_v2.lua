ZVox = ZVox or {}

local math = math
local math_floor = math.floor
local math_min = math.min

local MAX_PRIMITIVES = 8191
-- ZVox can probably use this, but we don't do it by default for compat with old GMod versions
--MAX_PRIMITIVES = 16383

ZVox.NewSettingListener("zvox_mesher2_big_maxprimitives", "misc_larger_primitive_count", function(newState)
	if newState then
		MAX_PRIMITIVES = 16383
	else
		MAX_PRIMITIVES = 8191
	end
end)



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


local cSizeX = ZVOX_CHUNKSIZE_X
local cSizeY = ZVOX_CHUNKSIZE_Y
local cSizeZ = ZVOX_CHUNKSIZE_Z
local cSizeConst1 = ZVOX_CHUNKSIZE_X * ZVOX_CHUNKSIZE_Y


local function remesh_setRenderMatrix(chunk, univ)
	-- init the renderMatrix if not already
	if not chunk["renderMatrix"] then
		chunk["renderMatrix"] = Matrix()
		local renderMatrix = chunk["renderMatrix"]
		renderMatrix:Identity()

		local chunkIndex = chunk["index"]
		local wX, wY, wZ = ZVox.ChunkIndexToWorld(univ, chunkIndex)

		renderMatrix:SetTranslation(Vector(wX, wY, wZ))
	end
end

local lightValues = 16
local lightOff2 = lightValues * lightValues
local lightOff3 = lightValues * lightValues * lightValues
local lightMul = 256 / lightValues


local function unpackLight(light)
	return (light % lightValues) * lightMul,
	       (math_floor(light / lightValues) % lightValues) * lightMul,
	       (math_floor(light / lightOff2) % lightValues) * lightMul,
	       (math_floor(light / lightOff3) % lightValues) * lightMul
end



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

local _v1_x, _v1_y, _v1_z = 0, 0, 0
local _v2_x, _v2_y, _v2_z = 0, 0, 0
local _v3_x, _v3_y, _v3_z = 0, 0, 0
local _v4_x, _v4_y, _v4_z = 0, 0, 0

local function face_setCoords_v1(x1, y1, z1)
	_v1_x, _v1_y, _v1_z = x1, y1, z1
end

local function face_setCoords_v2(x2, y2, z2)
	_v2_x, _v2_y, _v2_z = x2, y2, z2
end

local function face_setCoords_v3(x3, y3, z3)
	_v3_x, _v3_y, _v3_z = x3, y3, z3
end

local function face_setCoords_v4(x4, y4, z4)
	_v4_x, _v4_y, _v4_z = x4, y4, z4
end


local _ustart, _vstart = 0, 0
local _uend, _vend = 0, 0

local texRegistry = ZVox.GetTextureRegistry()
local uvBSize = ZVox.GetTextureAtlasBlockSize()
local function face_setUV(uStart, vStart, uEnd, vEnd, texName)
	-- transform the uvs to the correct ones
	local data = texRegistry[texName]
	if not data then
		ZVox.PrintError("No texData for \"" .. texName .. "\" holy shit we're going to melt down!!!")
		return
	end
	local uvs = data["uv"]
	local uAdd, vAdd = uvs[1], uvs[2]

	-- scale the uvs to the blocksize
	_ustart, _vstart = uAdd + (uStart * uvBSize), vAdd + (vStart * uvBSize)
	_uend, _vend = uAdd + (uEnd * uvBSize), vAdd + (vEnd * uvBSize)
end


local _c1, _c2, _c3, _c4 = 0, 0, 0, 0
local function face_setLighting(c1, c2, c3, c4)
	_c1, _c2, _c3, _c4 = c1, c2, c3, c4
end

local _rot = 0
local function face_setRot(rot)
	_rot = rot
end

local _group = 0
local function face_setGroup(group)
	_group = group
end


local FACE_REFERENCE_INDEX = 22

-- so we don't make table objects each remesh, just make them once
local allocatedFaces = {}
local allocatedAddLast = 0
local allocatedFetchPtr = 0
local function getAllocatedFace()
	if allocatedFetchPtr >= allocatedAddLast then
		allocatedAddLast = allocatedAddLast + 1
		allocatedFaces[allocatedAddLast] = {
			_v1_x, _v1_y, _v1_z,
			_v2_x, _v2_y, _v2_z,
			_v3_x, _v3_y, _v3_z,
			_v4_x, _v4_y, _v4_z,

			_ustart, _vstart,
			_uend, _vend,

			_c1, _c2, _c3, _c4,

			_rot,

			-- idx for referencing
			allocatedAddLast,
		}
	end

	allocatedFetchPtr = allocatedFetchPtr + 1
	return allocatedFaces[allocatedFetchPtr]
end

local function resetAllocatedFaces()
	allocatedFetchPtr = 0
end



local faceList = {
	[ZVOX_VOXELGROUP_SOLID] = {},
	[ZVOX_VOXELGROUP_TRANSLUCENT] = {},
	[ZVOX_VOXELGROUP_BINARY_TRANSPARENCY] = {},
	[ZVOX_VOXELGROUP_WATER] = {},
}

local faceTgtTable = nil
local function face_emitFace()
	local face = getAllocatedFace()

	face[1 ], face[2 ], face[3 ] = _v1_x, _v1_y, _v1_z
	face[4 ], face[5 ], face[6 ] = _v2_x, _v2_y, _v2_z
	face[7 ], face[8 ], face[9 ] = _v3_x, _v3_y, _v3_z
	face[10], face[11], face[12] = _v4_x, _v4_y, _v4_z

	face[13], face[14] = _ustart, _vstart
	face[15], face[16] = _uend, _vend

	face[17], face[18], face[19], face[20] = _c1, _c2, _c3, _c4
	face[21] = _rot

	faceTgtTable = faceList[_group]
	faceTgtTable[#faceTgtTable + 1] = face[FACE_REFERENCE_INDEX]
end

local function face_resetFaceList()
	faceList = {
		[ZVOX_VOXELGROUP_SOLID] = {},
		[ZVOX_VOXELGROUP_TRANSLUCENT] = {},
		[ZVOX_VOXELGROUP_BINARY_TRANSPARENCY] = {},
		[ZVOX_VOXELGROUP_WATER] = {},
	}
end


local dirToLightValue = {
	[DIR_X_PLUS] = 0.6,
	[DIR_X_MINUS] = 0.6,

	[DIR_Y_PLUS] = 0.8,
	[DIR_Y_MINUS] = 0.8,

	[DIR_Z_PLUS] = 1,
	[DIR_Z_MINUS] = 0.4,
}

-- fullbright table (possibly a thing later on?)
--[[
local dirToLightValue = {
	[DIR_X_PLUS] = 1,
	[DIR_X_MINUS] = 1,

	[DIR_Y_PLUS] = 1,
	[DIR_Y_MINUS] = 1,

	[DIR_Z_PLUS] = 1,
	[DIR_Z_MINUS] = 1,
}
]]--


local _DO_AO = ZVOX_DO_AO
ZVox.NewSettingListener("zvox_mesher2_update_ao", "graphics_ao", function(newState)
	_DO_AO = newState
end)


local WATER_OFFSET = (1.5) / 16
local function remesh_emitFaces(chunk, dir, vmdl, x, y, z, lightData, texData, emissiveData, voxGroup)
	local vmdlFaces = vmdl[dir]
	if not vmdlFaces then
		return
	end

	local faceEmissive = false

	local b1, b2, b3, b4 = 255, 255, 255, 255
	if _DO_AO then
		b1, b2, b3, b4 = unpackLight(lightData)
	end
	local baseLight = dirToLightValue[dir]
	b1 = b1 * baseLight
	b2 = b2 * baseLight
	b3 = b3 * baseLight
	b4 = b4 * baseLight

	face_setLighting(b1, b2, b3, b4)
	face_setGroup(voxGroup)

	local waterOffset = (voxGroup == ZVOX_VOXELGROUP_WATER) and WATER_OFFSET or 0

	for i = 1, #vmdlFaces do
		local face = vmdlFaces[i]

		face_setCoords_v1(face[1 ] + x, face[2 ] + y, (face[3 ] - waterOffset) + z)
		face_setCoords_v2(face[4 ] + x, face[5 ] + y, (face[6 ] - waterOffset) + z)
		face_setCoords_v3(face[7 ] + x, face[8 ] + y, (face[9 ] - waterOffset) + z)
		face_setCoords_v4(face[10] + x, face[11] + y, (face[12] - waterOffset) + z)

		-- compute the actual UVs already
		face_setUV(face[17], face[18], face[19], face[20], texData[face[21]])
		face_setRot(face[23])

		faceEmissive = emissiveData[face[21]]

		if faceEmissive then
			face_setLighting(255, 255, 255, 255)
		end

		face_emitFace()

		if faceEmissive then
			face_setLighting(b1, b2, b3, b4)
		end
	end
end


local function xyz2idx(x, y, z)
	return (x % cSizeX) + ((y % cSizeY) * cSizeX) + ((z % cSizeZ) * cSizeConst1)
end


local _NULL_VERTLIGHT_ENTRY = 4368 -- makes people realize something very wrong has happened
local _NULL_VERTLIGHT_ENTRIES = {
	_NULL_VERTLIGHT_ENTRY,
	_NULL_VERTLIGHT_ENTRY,
	_NULL_VERTLIGHT_ENTRY,
	_NULL_VERTLIGHT_ENTRY,
	_NULL_VERTLIGHT_ENTRY,
	_NULL_VERTLIGHT_ENTRY,
}

local texEmissiveLUT = ZVox.GetTexEmissiveRegistry()
local vmdlRegistry = ZVox.GetVoxelModelRegistry()
local function remesh_pushFaces(chunk)
	local univ = chunk["univ"]
	remesh_setRenderMatrix(chunk, univ)


	local voxelData = chunk["voxelData"]
	local stateData = chunk["voxelState"]
	local vertexLightingData = chunk["vertexLighting"]
	local cullingData = chunk["cullingData"]


	local multiTex = {
		"error", -- all

		"error", -- south x+
		"error", -- north x-

		"error", -- west y+
		"error", -- east y-

		"error", -- up z+
		"error", -- down z-
	}

	-- whether the texture on a direction is emissive or not
	local emissiveData = {
		false, -- all

		false, -- south x+
		false, -- north x-

		false, -- west y+
		false, -- east y-

		false, -- up z+
		false, -- down z-
	}


	local voxID
	local voxInfo
	local vmdlName
	local vmdlTable

	local voxGroup
	local xc, yc, zc
	local vertLightEntry

	local cullingEntry
	local vmdl
	local allTex

	local mTex

	for i = 0, (cSizeX * cSizeY * cSizeZ) - 1 do
		voxID = voxelData[i]
		if not voxID then
			continue
		end

		voxInfo = voxInfoExpressRegistry[voxID]
		if not voxInfo then
			continue
		end

		if not voxInfo[_EXPRESS_IDX_VISIBLE] then
			continue
		end

		vmdlName = voxInfo[_EXPRESS_IDX_VOXELMODEL]
		if not vmdlName then
			continue
		end

		vmdlTable = voxInfo[_EXPRESS_IDX_VOXELMODEL_TABLE]
		if vmdlTable then
			local voxState = stateData[i]
			local vmdlNameNew = vmdlTable[voxState]

			if vmdlNameNew then
				vmdlName = vmdlNameNew
			end
		end

		voxGroup = voxInfo[_EXPRESS_IDX_VOXELGROUP]

		xc = (i % cSizeX)
		yc = (math_floor(i / cSizeX) % cSizeY)
		zc = (math_floor(i / cSizeConst1) % cSizeZ)

		vertLightEntry = _NULL_VERTLIGHT_ENTRIES
		if _DO_AO then
			vertLightEntry = vertexLightingData[i] or _NULL_VERTLIGHT_ENTRIES
		end

		cullingEntry = cullingData[i] or 0

		vmdl = vmdlRegistry[vmdlName]


		allTex = voxInfo[_EXPRESS_IDX_TEX]
		multiTex[1] = allTex
		emissiveData[1] = texEmissiveLUT[allTex]

		mTex = voxInfo[_EXPRESS_IDX_MULTITEX]
		if mTex then
			-- tex
			multiTex[2] = mTex[1]
			multiTex[3] = mTex[2]

			multiTex[4] = mTex[3]
			multiTex[5] = mTex[4]

			multiTex[6] = mTex[5]
			multiTex[7] = mTex[6]

			-- emissive
			emissiveData[2] = texEmissiveLUT[mTex[1]]
			emissiveData[3] = texEmissiveLUT[mTex[2]]

			emissiveData[4] = texEmissiveLUT[mTex[3]]
			emissiveData[5] = texEmissiveLUT[mTex[4]]

			emissiveData[6] = texEmissiveLUT[mTex[5]]
			emissiveData[7] = texEmissiveLUT[mTex[6]]
		else -- TODO: if devs aren't stupid this else can go
			-- tex
			multiTex[1] = allTex

			multiTex[2] = allTex
			multiTex[3] = allTex

			multiTex[4] = allTex
			multiTex[5] = allTex

			multiTex[6] = allTex
			multiTex[7] = allTex

			-- emissive
			local allEmissive = texEmissiveLUT[allTex]
			emissiveData[2] = allEmissive
			emissiveData[3] = allEmissive

			emissiveData[4] = allEmissive
			emissiveData[5] = allEmissive

			emissiveData[6] = allEmissive
			emissiveData[7] = allEmissive
		end

		-- band the directions
		if bit.band(cullingEntry, CULL_X_PLUS) == 0 then -- emit X+ faces
			remesh_emitFaces(chunk, DIR_X_PLUS , vmdl, xc, yc, zc, vertLightEntry[1] or 4096, multiTex, emissiveData, voxGroup)
		end
		if bit.band(cullingEntry, CULL_X_MINUS) == 0 then -- emit X- faces
			remesh_emitFaces(chunk, DIR_X_MINUS, vmdl, xc, yc, zc, vertLightEntry[2] or 4096, multiTex, emissiveData, voxGroup)
		end

		if bit.band(cullingEntry, CULL_Y_PLUS) == 0 then -- emit Y+ faces
			remesh_emitFaces(chunk, DIR_Y_PLUS , vmdl, xc, yc, zc, vertLightEntry[3] or 4096, multiTex, emissiveData, voxGroup)
		end
		if bit.band(cullingEntry, CULL_Y_MINUS) == 0 then -- emit Y- faces
			remesh_emitFaces(chunk, DIR_Y_MINUS, vmdl, xc, yc, zc, vertLightEntry[4] or 4096, multiTex, emissiveData, voxGroup)
		end

		if bit.band(cullingEntry, CULL_Z_PLUS) == 0 then -- emit Z+ faces
			remesh_emitFaces(chunk, DIR_Z_PLUS , vmdl, xc, yc, zc, vertLightEntry[5] or 4096, multiTex, emissiveData, voxGroup)
		end
		if bit.band(cullingEntry, CULL_Z_MINUS) == 0 then -- emit Z- faces
			remesh_emitFaces(chunk, DIR_Z_MINUS, vmdl, xc, yc, zc, vertLightEntry[6] or 4096, multiTex, emissiveData, voxGroup)
		end

	end
end




local MATERIAL_QUADS = MATERIAL_QUADS

local mesh = mesh
local mesh_Begin = mesh.Begin
local mesh_Position = mesh.Position
local mesh_Normal = mesh.Normal
local mesh_TexCoord = mesh.TexCoord
local mesh_Color = mesh.Color
local mesh_AdvanceVertex = mesh.AdvanceVertex
local mesh_End = mesh.End



local randomRotTable = {}
local randomRotCount = 256
for i = 0, randomRotCount do
	local rnd = util.SharedRandom("zvox_mesher2_random_rot", 0, 1, i)

	rnd = math.floor(rnd * 4)
	rnd = rnd * 90

	randomRotTable[i] = rnd
end


-- uStart, vStart, uEnd, vEnd
-- 13, 14, 15, 16
local rotTable = {
	[0] = {
		13, 14,
		15, 14,
		15, 16,
		13, 16,
	},
	[90] = {
		15, 14,
		15, 16,
		13, 16,
		13, 14,
	},
	[180] = {
		15, 16,
		13, 16,
		13, 14,
		15, 14,
	},
	[270] = {
		13, 16,
		13, 14,
		15, 14,
		15, 16,
	},
}


local function remesh_meshFaces(chunk, group)
	local faceListGet = faceList[group]

	if #faceListGet <= 0 then
		return
	end

	if not chunk["renderObjects"] then
		chunk["renderObjects"] = {
			[ZVOX_VOXELGROUP_SOLID] = {},
			[ZVOX_VOXELGROUP_BINARY_TRANSPARENCY] = {},
			[ZVOX_VOXELGROUP_TRANSLUCENT] = {},
			[ZVOX_VOXELGROUP_WATER] = {},
		}
	end

	local renderObjects = chunk["renderObjects"]

	local meshObj = Mesh()
	local accumPrimitiveCount = 0


	local c1, c2, c3, c4

	local faceID
	local face

	local rot
	local rotEntry
	local uGet, vGet
	mesh_Begin(meshObj, MATERIAL_QUADS, math.min(#faceListGet, MAX_PRIMITIVES))
	for i = 1, #faceListGet do
		if accumPrimitiveCount >= MAX_PRIMITIVES then
			mesh_End()
			accumPrimitiveCount = 0

			local rObjGroup = renderObjects[group]
			rObjGroup[#rObjGroup + 1] = meshObj

			local facesLeft = #faceListGet - i
			if facesLeft == 0 then
				break
			end

			meshObj = Mesh()
			mesh_Begin(meshObj, MATERIAL_QUADS, math.min(facesLeft, MAX_PRIMITIVES))
		end

		faceID = faceListGet[i]
		face = allocatedFaces[faceID]

		-- mesh that shit

		c1, c2, c3, c4 = face[17], face[18], face[19], face[20]
		--c1 = c1 * 255
		--c2 = c2 * 255
		--c3 = c3 * 255
		--c4 = c4 * 255

		rot = face[21]
		if rot == -1 then
			--local hash = (face[1] + (face[2] * cSizeX) + (face[3] * cSizeConst1)) % randomRotCount

			rot = randomRotTable[(face[1] + (face[2] * cSizeX) + (face[3] * cSizeConst1)) % randomRotCount]
		end



		rotEntry = rotTable[rot]

		uGet, vGet = face[rotEntry[1]], face[rotEntry[2]]
		mesh_Position(face[1 ], face[2 ], face[3 ])
		mesh_TexCoord(0, uGet, vGet)
		mesh_Color(c1, c1, c1, 255)
		mesh_AdvanceVertex()

		uGet, vGet = face[rotEntry[3]], face[rotEntry[4]]
		mesh_Position(face[4 ], face[5 ], face[6 ])
		mesh_TexCoord(0, uGet, vGet)
		mesh_Color(c2, c2, c2, 255)
		mesh_AdvanceVertex()

		uGet, vGet = face[rotEntry[5]], face[rotEntry[6]]
		mesh_Position(face[7 ], face[8 ], face[9 ])
		mesh_TexCoord(0, uGet, vGet)
		mesh_Color(c3, c3, c3, 255)
		mesh_AdvanceVertex()

		uGet, vGet = face[rotEntry[7]], face[rotEntry[8]]
		mesh_Position(face[10], face[11], face[12])
		mesh_TexCoord(0, uGet, vGet)
		mesh_Color(c4, c4, c4, 255)
		mesh_AdvanceVertex()

		accumPrimitiveCount = accumPrimitiveCount + 1
	end
	mesh_End()

	local rObjGroup = renderObjects[group]
	rObjGroup[#rObjGroup + 1] = meshObj
end




function ZVox.ReMeshChunk(chunk)
	resetAllocatedFaces()
	face_resetFaceList()

	local renderObj = chunk["renderObjects"]
	local clearTbl
	if renderObj then
		clearTbl = renderObj[ZVOX_VOXELGROUP_SOLID]
		for i = 1, #clearTbl do
			clearTbl[i]:Destroy()
			clearTbl[i] = nil
		end

		clearTbl = renderObj[ZVOX_VOXELGROUP_BINARY_TRANSPARENCY]
		for i = 1, #clearTbl do
			clearTbl[i]:Destroy()
			clearTbl[i] = nil
		end

		clearTbl = renderObj[ZVOX_VOXELGROUP_TRANSLUCENT]
		for i = 1, #clearTbl do
			clearTbl[i]:Destroy()
			clearTbl[i] = nil
		end

		clearTbl = renderObj[ZVOX_VOXELGROUP_WATER]
		for i = 1, #clearTbl do
			clearTbl[i]:Destroy()
			clearTbl[i] = nil
		end
	end

	remesh_pushFaces(chunk)


	remesh_meshFaces(chunk, ZVOX_VOXELGROUP_SOLID)
	remesh_meshFaces(chunk, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)
	remesh_meshFaces(chunk, ZVOX_VOXELGROUP_TRANSLUCENT)
	remesh_meshFaces(chunk, ZVOX_VOXELGROUP_WATER)
end










local _toRemeshExistanceMap = {}
local _toRemeshArray = {}
local _toRemeshCount = 0

function ZVox.EmitChunkToRemesh(chunk)
	if _toRemeshExistanceMap[chunk] then
		return
	end

	_toRemeshArray[#_toRemeshArray + 1] = chunk
	_toRemeshExistanceMap[chunk] = true
	_toRemeshCount = _toRemeshCount + 1
end

function ZVox.GetToRemeshCount()
	return _toRemeshCount
end

local remeshesPerSec = 0
function ZVox.GetRemeshesPerSec()
	return remeshesPerSec
end

local currRemeshesAccum = 0
local nextClear = CurTime()
local function remeshPerSecThink()
	if CurTime() <= nextClear then
		return
	end
	nextClear = CurTime() + 1

	remeshesPerSec = currRemeshesAccum
	currRemeshesAccum = 0
end


ZVox.MesherPause = ZVox.MesherPause or false
if not ZVOX_DEVMODE then
	ZVox.MesherPause = false
end

function ZVox.RemeshChunkHandle()
	if ZVox.MesherPause then
		return
	end


	remeshPerSecThink()

	if _toRemeshCount <= 0 then
		return
	end

	if _toRemeshCount > ZVOX_REMESH_HURRY_THRESHOLD then
		ZVOX_MAX_REMESH_PER_FRAME = ZVOX_MAX_REMESH_PER_FRAME_HURRY
	else
		ZVOX_MAX_REMESH_PER_FRAME = ZVOX_MAX_REMESH_PER_FRAME
	end

	currRemeshesAccum = currRemeshesAccum + 1


	for i = 1, math.min(ZVOX_MAX_REMESH_PER_FRAME, _toRemeshCount) do
		local chunk = table.remove(_toRemeshArray, _toRemeshCount)
		_toRemeshExistanceMap[chunk] = nil
		_toRemeshCount = _toRemeshCount - 1

		ZVox.ReMeshChunk(chunk)
	end
end


local flashColourLUT = {
	Color(255, 32, 32),
	Color(255, 128, 32),
	Color(255, 196, 32),
}

function ZVox.DebugRenderMesherPauseInfoMessage()
	if not ZVox.MesherPause then
		return
	end

	local cIdx = math.floor(CurTime() * 2) % (#flashColourLUT)
	cIdx = cIdx + 1
	local colGet = flashColourLUT[cIdx]

	ZVox.DrawRetroTextShadowed(nil, "/!\\ MESHER IS PAUSED /!\\", ScrW() * .5, 32, colGet, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 6)

	local keyToFix = ZVox.GetControlKey("dbg_toggle_remeshing")
	local keyNameToFix = ZVox.GetButtonNiceName(keyToFix)
	ZVox.DrawRetroTextShadowed(nil, "PRESS " .. keyNameToFix .. " TO RE-ENABLE!!", ScrW() * .5, 64 + 24, colGet, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3)
end

ZVox.NewControlListener("dbg_toggle_remeshing", "debug_toggle_remeshing", function()
	if not ZVOX_DEVMODE then
		return
	end


	ZVox.MesherPause = not ZVox.MesherPause

	ZVox.PrintInfo("Mesher Pause; " .. (ZVox.MesherPause and "ON" or "OFF"))
end)