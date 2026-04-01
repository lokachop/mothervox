ZVox = ZVox or {}

local DIR_X_PLUS = 1
local DIR_X_MINUS = 2

local DIR_Y_PLUS = 3
local DIR_Y_MINUS = 4

local DIR_Z_PLUS = 5
local DIR_Z_MINUS = 6

local bbAxisToAngle = {
	["x"] = Angle(1, 0, 0),
	["y"] = Angle(0, 1, 0),
	["z"] = Angle(0, 0, 1),
}

local voxelModels = {}
function ZVox.GetVoxelModelRegistry()
	return voxelModels
end

function ZVox.GetVoxelModel(name)
	return voxelModels[name]
end

local projectionKillingAxis = {
	[DIR_X_PLUS] = 1,
	[DIR_X_MINUS] = 1,

	[DIR_Y_PLUS] = 2,
	[DIR_Y_MINUS] = 2,

	[DIR_Z_PLUS] = 3,
	[DIR_Z_MINUS] = 3,
}

local projectionCaringAxis = {
	[DIR_X_PLUS] = {2, 3},
	[DIR_X_MINUS] = {2, 3},

	[DIR_Y_PLUS] = {1, 3},
	[DIR_Y_MINUS] = {1, 3},

	[DIR_Z_PLUS] = {1, 2},
	[DIR_Z_MINUS] = {1, 2},
}

local TEXTURE_ALL = 1

local TEXTURE_X_PLUS = 2
local TEXTURE_X_MINUS = 3

local TEXTURE_Y_PLUS = 4
local TEXTURE_Y_MINUS = 5

local TEXTURE_Z_PLUS = 6
local TEXTURE_Z_MINUS = 7

local texNameToIdx = {
	["#all"] = TEXTURE_ALL,

	["#south"] = TEXTURE_X_PLUS,
	["#north"] = TEXTURE_X_MINUS,

	["#west"] = TEXTURE_Y_PLUS,
	["#east"] = TEXTURE_Y_MINUS,

	["#up"] = TEXTURE_Z_PLUS,
	["#down"] = TEXTURE_Z_MINUS,

	-- these work based on the template
	-- make sure your texturedef looks like this!:
	--[[
	"textures": {
		"0": "plus_x",
		"1": "plus_y",
		"2": "plus_z",
		"3": "minus_x",
		"4": "minus_y",
		"5": "minus_z",
		"particle": "plus_x"
	},
	]]

	["#0"] = TEXTURE_X_PLUS,
	["#1"] = TEXTURE_Y_PLUS,
	["#2"] = TEXTURE_Z_PLUS,
	["#3"] = TEXTURE_X_MINUS,
	["#4"] = TEXTURE_Y_MINUS,
	["#5"] = TEXTURE_Z_MINUS,
}


-- face object need to store
-- the origin & size of itself
-- the same in 2d for culling checks
local function emitFace(mdlData, dir, v1, v2, v3, v4, faceData)
	-- check if the mdldata has a buffer for that direction
	if not mdlData[dir] then
		mdlData[dir] = {}
	end

	local dirEntry = mdlData[dir]

	-- build face
	local faceObj = {}

	-- 3d data
	faceObj[1 ], faceObj[2 ], faceObj[3 ] = v1[1] / 16, v1[2] / 16, v1[3] / 16
	faceObj[4 ], faceObj[5 ], faceObj[6 ] = v2[1] / 16, v2[2] / 16, v2[3] / 16
	faceObj[7 ], faceObj[8 ], faceObj[9 ] = v3[1] / 16, v3[2] / 16, v3[3] / 16
	faceObj[10], faceObj[11], faceObj[12] = v4[1] / 16, v4[2] / 16, v4[3] / 16

	-- 2d data
	-- prject it to the axis, for culling
	-- TBD
	-- actually that's stupid and MC doesn't even do it, just store a flag on the model if it should cull or not on that direction
	-- this doesn't work for all cases but it speeds it up significantly

	-- time to project!
	-- we get given an axis, that axis is an index into a LUT that gives us which axis of the vector to nuke
	-- also this is 2d, we can make it a origin / size so only 4 numbers vs 8 nums if it was each vertex

	local killingAxis = projectionKillingAxis[dir]

	local projV1 = v1 * 1
	projV1[killingAxis] = 0

	local projV2 = v2 * 1
	projV2[killingAxis] = 0

	local projV3 = v3 * 1
	projV3[killingAxis] = 0

	local projV4 = v4 * 1
	projV4[killingAxis] = 0

	-- now turn them into aabbs
	local caringAxis = projectionCaringAxis[dir]
	local axisA = caringAxis[1]
	local axisB = caringAxis[2]

	local minA = math.min(projV1[axisA], projV2[axisA], projV3[axisA], projV4[axisA])
	local minB = math.min(projV1[axisB], projV2[axisB], projV3[axisB], projV4[axisB])

	local maxA = math.max(projV1[axisA], projV2[axisA], projV3[axisA], projV4[axisA])
	local maxB = math.max(projV1[axisB], projV2[axisB], projV3[axisB], projV4[axisB])

	faceObj[13] = minA
	faceObj[14] = minB
	faceObj[15] = maxA
	faceObj[16] = maxB


	-- store the UV start / end
	local uvData = faceData["uv"]
	if not uvData then
		ZVox.PrintError("Voxel model face has no UV data, malformed...")
		--faceObj[17] = 0
		--faceObj[18] = 0
		--faceObj[19] = 1
		--faceObj[20] = 1

		uvData = {minA, minB, maxA, maxB} -- calc it from the min, max, this is stupid but we don't care...

		--return
	end


	local uStart = uvData[1]
	local vStart = uvData[2]

	local uEnd = uvData[3]
	local vEnd = uvData[4]

	faceObj[17] = uStart / 16
	faceObj[18] = vStart / 16
	faceObj[19] = uEnd / 16
	faceObj[20] = vEnd / 16

	-- textureID
	local texID = texNameToIdx[faceData["texture"] or "#all"] or TEXTURE_ALL
	faceObj[21] = texID

	-- emissive
	--local emissive = faceData["emissive"] and true or false -- not in the mc model format spec, we don't care
	--faceObj[22] = emissive

	local kaV1 = math.abs(v1[killingAxis] - 8)
	local kaV2 = math.abs(v2[killingAxis] - 8)
	local kaV3 = math.abs(v3[killingAxis] - 8)
	local kaV4 = math.abs(v4[killingAxis] - 8)

	local cullable = (kaV1 == 8) and (kaV2 == 8) and (kaV3 == 8) and (kaV4 == 8)

	faceObj[22] = cullable

	local rot = faceData["rotation"] or 0
	faceObj[23] = rot -- rotation

	dirEntry[#dirEntry + 1] = faceObj
end


local buildCube_fromVec = Vector()
local buildCube_toVec = Vector()

local buildCube_origin = Vector()
local buildCube_size = Vector()

local buildCube_v1 = Vector()
local buildCube_v2 = Vector()
local buildCube_v3 = Vector()
local buildCube_v4 = Vector()

local buildCube_v5 = Vector()
local buildCube_v6 = Vector()
local buildCube_v7 = Vector()
local buildCube_v8 = Vector()

local buildCube_szVec = Vector()

local buildCube_rotOrigin = Vector()

local function buildCube(elementData, mdlData)
	-- parse the min, max
	local fromDataRaw = elementData.from
	buildCube_fromVec:SetUnpacked(fromDataRaw[3], fromDataRaw[1], fromDataRaw[2])

	local toDataRaw = elementData.to
	buildCube_toVec:SetUnpacked(toDataRaw[3], toDataRaw[1], toDataRaw[2])
	-- from, to is the mins, maxs


	-- calc. origin and size
	buildCube_origin:Set(buildCube_fromVec)

	-- size of the cube
	buildCube_size:Set(buildCube_toVec)
	buildCube_size:Sub(buildCube_fromVec)


	local size = buildCube_size

	-- calc the eight cube vertices
	-- X = current vert
	-- f = origin
	----------------
	-- Z NEGATIVE --
	----------------
	-- o---o  o---o
	-- |z+ |  |z- |
	-- o---o  X---o
	buildCube_v1:Set(buildCube_origin)
	-- o---o  o---o
	-- |z+ |  |z- |
	-- o---o  f---X
	buildCube_v2:Set(buildCube_origin)

	buildCube_szVec:SetUnpacked(size[1], 0, 0) -- + Vector(size[1], 0, 0)
	buildCube_v2:Add(buildCube_szVec)

	-- o---o  X---o
	-- |z+ |  |z- |
	-- o---o  f---o
	--local v3 = origin + Vector(0, size[2], 0)
	buildCube_v3:Set(buildCube_origin)

	buildCube_szVec:SetUnpacked(0, size[2], 0)
	buildCube_v3:Add(buildCube_szVec)

	-- o---o  o---X
	-- |z+ |  |z- |
	-- o---o  f---o
	buildCube_v4:Set(buildCube_origin)

	buildCube_szVec:SetUnpacked(size[1], size[2], 0) -- + Vector(size[1], size[2], 0)
	buildCube_v4:Add(buildCube_szVec)

	----------------
	-- Z POSITIVE --
	----------------
	-- o---o  o---o
	-- |z+ |  |z- |
	-- X---o  f---o
	buildCube_v5:Set(buildCube_origin)

	buildCube_szVec:SetUnpacked(0, 0, size[3]) -- + Vector(0, 0, size[3])
	buildCube_v5:Add(buildCube_szVec)


	-- o---o  o---o
	-- |z+ |  |z- |
	-- o---X  f---o
	buildCube_v6:Set(buildCube_origin)

	buildCube_szVec:SetUnpacked(size[1], 0, size[3]) -- + Vector(size[1], 0, size[3])
	buildCube_v6:Add(buildCube_szVec)

	-- X---o  o---o
	-- |z+ |  |z- |
	-- o---o  f---o
	buildCube_v7:Set(buildCube_origin)

	buildCube_szVec:SetUnpacked(0, size[2], size[3]) -- + Vector(0, size[2], size[3])
	buildCube_v7:Add(buildCube_szVec)

	-- o---X  o---o
	-- |z+ |  |z- |
	-- o---o  f---o
	buildCube_v8:Set(buildCube_origin)

	buildCube_szVec:SetUnpacked(size[1], size[2], size[3]) -- + Vector(size[1], size[2], size[3])
	buildCube_v8:Add(buildCube_szVec)

	-- there might be rotation, so we need to worry about that, rotate the vertices around the origin
	local rotData = elementData.rotation
	if rotData then
		local originRaw = rotData.origin
		buildCube_rotOrigin:SetUnpacked(originRaw[3], originRaw[1], originRaw[2])

		local rotAngle = rotData.angle
		local rotAxisAngle = bbAxisToAngle[rotData.axis] * rotAngle

		-- offset the vertices by the origin
		buildCube_v1:Sub(buildCube_rotOrigin)
		buildCube_v2:Sub(buildCube_rotOrigin)
		buildCube_v3:Sub(buildCube_rotOrigin)
		buildCube_v4:Sub(buildCube_rotOrigin)

		buildCube_v5:Sub(buildCube_rotOrigin)
		buildCube_v6:Sub(buildCube_rotOrigin)
		buildCube_v7:Sub(buildCube_rotOrigin)
		buildCube_v8:Sub(buildCube_rotOrigin)

		-- rotate them by the angle
		buildCube_v1:Rotate(rotAxisAngle)
		buildCube_v2:Rotate(rotAxisAngle)
		buildCube_v3:Rotate(rotAxisAngle)
		buildCube_v4:Rotate(rotAxisAngle)

		buildCube_v5:Rotate(rotAxisAngle)
		buildCube_v6:Rotate(rotAxisAngle)
		buildCube_v7:Rotate(rotAxisAngle)
		buildCube_v8:Rotate(rotAxisAngle)


		-- move them back
		buildCube_v1:Add(buildCube_rotOrigin)
		buildCube_v2:Add(buildCube_rotOrigin)
		buildCube_v3:Add(buildCube_rotOrigin)
		buildCube_v4:Add(buildCube_rotOrigin)

		buildCube_v5:Add(buildCube_rotOrigin)
		buildCube_v6:Add(buildCube_rotOrigin)
		buildCube_v7:Add(buildCube_rotOrigin)
		buildCube_v8:Add(buildCube_rotOrigin)
	end

	local faces = elementData.faces
	if not faces then
		ZVox.PrintError("Voxel model cube has no face array, malformed...")
	end

	-- emit faces
	if faces["south"] then -- +x
		emitFace(mdlData, DIR_X_PLUS, buildCube_v6, buildCube_v8, buildCube_v4, buildCube_v2, faces["south"])
	end
	if faces["north"] then -- -x
		emitFace(mdlData, DIR_X_MINUS, buildCube_v7, buildCube_v5, buildCube_v1, buildCube_v3, faces["north"])
	end

	if faces["west"] then -- +y
		emitFace(mdlData, DIR_Y_PLUS, buildCube_v8, buildCube_v7, buildCube_v3, buildCube_v4, faces["west"])
	end
	if faces["east"] then -- -y
		emitFace(mdlData, DIR_Y_MINUS, buildCube_v5, buildCube_v6, buildCube_v2, buildCube_v1, faces["east"])
	end
	if faces["up"] then -- +z
		emitFace(mdlData, DIR_Z_PLUS, buildCube_v5, buildCube_v7, buildCube_v8, buildCube_v6, faces["up"])
	end
	if faces["down"] then -- -z
		emitFace(mdlData, DIR_Z_MINUS, buildCube_v4, buildCube_v3, buildCube_v1, buildCube_v2, faces["down"])
	end
end


-- FOR LOKA IDIOT TO READ
-- rather than building per DIRECTION
-- we wanna isolate the cubes, then for each cube call a func
-- to add it to the face list
-- THIS IS CLEANER AND FASTER AND COOLER SO YOU GET OUT OF THIS STUPID BLOCK YOU GOT YOURSELF IN LOKA I FUCKING HATE YOU I HOPE THAT YOU DIE
-- LOKA YOU FUCKING IDIOT YOU ALWAYS DO THIS WITH ALL OF YOUR FUCKING PROJECTS THIS SHIT SHOULDA BE FINISHED BY SUMMER AND YOURE THE MOST ABHORRENT
-- SLOW CODER EVER


-- generates the intermediary plane format
function ZVox.NewVoxelModel(name, data)
	if not name then
		return
	end

	name = ZVox.NAMESPACES_NamespaceConvert(name)

	local dataParse = util.JSONToTable(data)
	if not dataParse then
		ZVox.PrintFatal("Error building voxelmodel \"" .. name .. "\", no dataParse!")
		return
	end

	local mdlData = {}
	--mdlData[IDX_FACELIST] = {}

	-- loop thru each element and build the cube for it
	local elementList = dataParse.elements
	for i = 1, #elementList do
		local elementData = elementList[i]

		--print("--================ ELEMENT " .. i .. " ================--")
		--PrintTable(elementData)
		buildCube(elementData, mdlData)
	end
	voxelModels[name] = mdlData
end