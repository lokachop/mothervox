ZVox = ZVox or {}

local mesh = mesh
local mesh_Begin = mesh.Begin
local mesh_Position = mesh.Position
local mesh_Normal = mesh.Normal
local mesh_TexCoord = mesh.TexCoord
local mesh_Color = mesh.Color
local mesh_AdvanceVertex = mesh.AdvanceVertex
local mesh_End = mesh.End

local voxInfoRegistry = ZVox.GetVoxelRegistry()
local vmdlRegistry = ZVox.GetVoxelModelRegistry()

local texRegistry = ZVox.GetTextureRegistry()
local uvBSize = ZVox.GetTextureAtlasBlockSize()


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


local FACE_REFERENCE_INDEX = 21

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


local faceList = {}
local function face_emitFace()
	local face = getAllocatedFace()

	face[1 ], face[2 ], face[3 ] = _v1_x, _v1_y, _v1_z
	face[4 ], face[5 ], face[6 ] = _v2_x, _v2_y, _v2_z
	face[7 ], face[8 ], face[9 ] = _v3_x, _v3_y, _v3_z
	face[10], face[11], face[12] = _v4_x, _v4_y, _v4_z

	face[13], face[14] = _ustart, _vstart
	face[15], face[16] = _uend, _vend

	face[17], face[18], face[19], face[20] = _c1, _c2, _c3, _c4

	faceList[#faceList + 1] = face[FACE_REFERENCE_INDEX]
end

local function face_resetFaceList()
	faceList = {}
end


local dirToLightValue = {
	[DIR_X_PLUS] = 0.6,
	[DIR_X_MINUS] = 0.6,

	[DIR_Y_PLUS] = 0.8,
	[DIR_Y_MINUS] = 0.8,

	[DIR_Z_PLUS] = 1,
	[DIR_Z_MINUS] = 0.4,
}

local function emitFaces(vmdl, dir, pos, scl, texData, emissiveData)
	local vmdlFaces = vmdl[dir]
	if not vmdlFaces then
		return
	end

	local baseLight = dirToLightValue[dir]

	local b1, b2, b3, b4 = baseLight, baseLight, baseLight, baseLight
	face_setLighting(b1, b2, b3, b4)


	local x, y, z = pos[1], pos[2], pos[3]
	local sX, sY, sZ = scl[1] * 2, scl[2] * 2, scl[3] * 2

	for i = 1, #vmdlFaces do
		local face = vmdlFaces[i]

		face_setCoords_v1(((face[1 ] - .5) + x) * sX, ((face[2 ] - .5) + y) * sY, ((face[3 ] - .5) + z) * sZ)
		face_setCoords_v2(((face[4 ] - .5) + x) * sX, ((face[5 ] - .5) + y) * sY, ((face[6 ] - .5) + z) * sZ)
		face_setCoords_v3(((face[7 ] - .5) + x) * sX, ((face[8 ] - .5) + y) * sY, ((face[9 ] - .5) + z) * sZ)
		face_setCoords_v4(((face[10] - .5) + x) * sX, ((face[11] - .5) + y) * sY, ((face[12] - .5) + z) * sZ)

		-- compute the actual UVs already
		face_setUV(face[17], face[18], face[19], face[20], texData[face[21]])

		local faceEmissive = emissiveData[face[21]]
		if faceEmissive then
			face_setLighting(1, 1, 1, 1)
		end

		face_emitFace()

		if faceEmissive then
			face_setLighting(b1, b2, b3, b4)
		end
	end
end

local texEmissiveLUT = ZVox.GetTexEmissiveRegistry()

-- Gets the mesh to a single voxel, used for viewmodel
-- and for icons
function ZVox.GetVoxelMesh(voxID, pos, scl)
	local voxInfo = voxInfoRegistry[voxID]
	if not voxInfo then
		return
	end

	pos = pos or Vector(0, 0, 0)
	scl = scl or Vector(1, 1, 1)

	resetAllocatedFaces()
	face_resetFaceList()


	local vmdlName = voxInfo["voxelmodel"]
	if not vmdlName then
		ZVox.PrintError("Attempt to get voxelMesh for voxel \"" .. ZVox.GetVoxelName(voxID) .. "\", which has no vmdl!")
		return
	end

	local texData = {
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

	local allTex = voxInfo["tex"]
	texData[1] = allTex
	emissiveData[1] = texEmissiveLUT[allTex]

	local mTex = voxInfo["multitex"]
	if mTex then
		-- tex
		texData[2] = mTex[1]
		texData[3] = mTex[2]

		texData[4] = mTex[3]
		texData[5] = mTex[4]

		texData[6] = mTex[5]
		texData[7] = mTex[6]


		-- emissive
		emissiveData[2] = texEmissiveLUT[mTex[1]]
		emissiveData[3] = texEmissiveLUT[mTex[2]]

		emissiveData[4] = texEmissiveLUT[mTex[3]]
		emissiveData[5] = texEmissiveLUT[mTex[4]]

		emissiveData[6] = texEmissiveLUT[mTex[5]]
		emissiveData[7] = texEmissiveLUT[mTex[6]]
	else -- TODO: if devs aren't stupid this else can go
		-- tex
		texData[1] = allTex

		texData[2] = allTex
		texData[3] = allTex

		texData[4] = allTex
		texData[5] = allTex

		texData[6] = allTex
		texData[7] = allTex

		-- emissive
		local allEmissive = texEmissiveLUT[allTex]
		emissiveData[2] = allEmissive
		emissiveData[3] = allEmissive

		emissiveData[4] = allEmissive
		emissiveData[5] = allEmissive

		emissiveData[6] = allEmissive
		emissiveData[7] = allEmissive
	end


	local vmdl = vmdlRegistry[vmdlName]
	emitFaces(vmdl, DIR_X_PLUS, pos, scl, texData, emissiveData)
	emitFaces(vmdl, DIR_X_MINUS, pos, scl, texData, emissiveData)

	emitFaces(vmdl, DIR_Y_PLUS, pos, scl, texData, emissiveData)
	emitFaces(vmdl, DIR_Y_MINUS, pos, scl, texData, emissiveData)

	emitFaces(vmdl, DIR_Z_PLUS, pos, scl, texData, emissiveData)
	emitFaces(vmdl, DIR_Z_MINUS, pos, scl, texData, emissiveData)



	local faceCount = #faceList
	if faceCount > 8196 then
		ZVox.PrintError("VoxelModel exceeds 8196 faces, this is bad and means we can't have a proper viewmodel!\nExpect issues!")
		faceCount = math.min(faceCount, 8196)
	end

	local meshRet = Mesh()

	mesh_Begin(meshRet, MATERIAL_QUADS, faceCount)
	for i = 1, faceCount do
		local face = allocatedFaces[faceList[i]]

		local c1, c2, c3, c4 = face[17], face[18], face[19], face[20]
		c1 = c1 * 255
		c2 = c2 * 255
		c3 = c3 * 255
		c4 = c4 * 255

		local uStart, vStart, uEnd, vEnd = face[13], face[14], face[15], face[16]

		mesh_Position(face[1 ], face[2 ], face[3 ])
		mesh_TexCoord(0, uStart, vStart)
		mesh_Color(c1, c1, c1, 255)
		mesh_AdvanceVertex()

		mesh_Position(face[4 ], face[5 ], face[6 ])
		mesh_TexCoord(0, uEnd, vStart)
		mesh_Color(c2, c2, c2, 255)
		mesh_AdvanceVertex()

		mesh_Position(face[7 ], face[8 ], face[9 ])
		mesh_TexCoord(0, uEnd, vEnd)
		mesh_Color(c3, c3, c3, 255)
		mesh_AdvanceVertex()

		mesh_Position(face[10], face[11], face[12])
		mesh_TexCoord(0, uStart, vEnd)
		mesh_Color(c4, c4, c4, 255)
		mesh_AdvanceVertex()
	end
	mesh_End()

	return meshRet
end