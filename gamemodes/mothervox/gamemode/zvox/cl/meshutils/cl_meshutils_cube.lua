ZVox = ZVox or {}

local mesh = mesh
local mesh_Begin = mesh.Begin
local mesh_Position = mesh.Position
local mesh_Normal = mesh.Normal
local mesh_TexCoord = mesh.TexCoord
local mesh_Color = mesh.Color
local mesh_AdvanceVertex = mesh.AdvanceVertex
local mesh_End = mesh.End

-- Creates a generic cube mesh that on each face has full 0-1 UVs
-- This is merely for me to first learn how to procedurally generate cube meshes
function ZVox.GetCubeMesh(pos, scl, normFlip)
	-- first we make the vertices
	local sX, sY, sZ = scl[1], scl[2], scl[3]

	-----------------------
	-- ascii coord guide --
	-----------------------
	--    X  X      X  X --
	--    -  +      -  + --
	-- Y- X--0   Y- 0--0 --
	--    |  |      |  | --
	--    |  |      |  | --
	-- Y+ 0--0   Y+ 0--0 --
	--     z-        z+  --
	-----------------------


	local v1 = Vector(-sX, -sY, -sZ)
	local v2 = Vector( sX, -sY, -sZ)
	local v3 = Vector( sX,  sY, -sZ)
	local v4 = Vector(-sX,  sY, -sZ)

	local v5 = Vector(-sX, -sY,  sZ)
	local v6 = Vector( sX, -sY,  sZ)
	local v7 = Vector( sX,  sY,  sZ)
	local v8 = Vector(-sX,  sY,  sZ)

	local meshRet = Mesh()
	local primitiveCount = 6 -- cubes have 6 faces if we use quads

	local normFlipMul = normFlip and -1 or 1

	local normXp = Vector( 1,  0,  0) * normFlipMul
	local normXm = Vector(-1,  0,  0) * normFlipMul
	local normYp = Vector( 0,  1,  0) * normFlipMul
	local normYm = Vector( 0, -1,  0) * normFlipMul
	local normZp = Vector( 0,  0,  1) * normFlipMul
	local normZm = Vector( 0,  0, -1) * normFlipMul

	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
		-- BEGIN X+
		mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, 0, 1)
			else
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, 0, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, 1, 1)
			else
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, 1, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, 1, 0)
			else
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, 1, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, 0, 0)
			else
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, 0, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END X+

		-- BEGIN X-
			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, 0, 1)
			else
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, 0, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, 1, 1)
			else
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, 1, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, 1, 0)
			else
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, 1, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, 0, 0)
			else
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, 0, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END X-

		-- BEGIN Y+
			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, 0, 1)
			else
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, 0, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, 1, 1)
			else
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, 1, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, 1, 0)
			else
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, 1, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, 0, 0)
			else
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, 0, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END Y+

		-- BEGIN Y-
			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, 0, 1)
			else
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, 0, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, 1, 1)
			else
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, 1, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, 1, 0)
			else
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, 1, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, 0, 0)
			else
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, 0, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END Y-

		-- BEGIN Z+
			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, 0, 1)
			else
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, 0, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, 1, 1)
			else
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, 1, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, 1, 0)
			else
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, 1, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, 0, 0)
			else
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, 0, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END Z+

		-- BEGIN Z-
			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, 0, 1)
			else
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, 0, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, 1, 1)
			else
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, 1, 0)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, 1, 0)
			else
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, 1, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, 0, 0)
			else
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, 0, 1)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END Z-
	mesh_End()
	return meshRet
end


local voxInfoRegistry = ZVox.GetVoxelRegistry()
local voxStateTypeRegistry = ZVox.GetVoxelStateOperatorRegistry()
local texRegistry = ZVox.GetTextureRegistry()
local uvBSize = ZVox.GetTextureAtlasBlockSize()

local function getUVsFromTexName(texName)
	local data = texRegistry[texName]
	if not data then
		return 0, 0
	end

	local uvs = data["uv"]
	return uvs[1], uvs[2]
end

-- Creates a generic cube mesh that has the UVs for the voxelID so it renders correctly with the texture atlas
-- DEPRECATED!
-- DON'T USE THIS!
function ZVox.GetVoxelCubeMesh(voxID, pos, scl)
	local voxInfo = voxInfoRegistry[voxID]
	if not voxInfo then
		return
	end

	local tex = voxInfo["tex"]
	local mTexArray = voxInfo["multitex"]
	local unshaded = voxInfo["unshaded"]

	local tex_u1, tex_v1 = getUVsFromTexName(mTexArray and mTexArray[1] or tex)
	local tex_u2, tex_v2 = getUVsFromTexName(mTexArray and mTexArray[2] or tex)
	local tex_u3, tex_v3 = getUVsFromTexName(mTexArray and mTexArray[3] or tex)
	local tex_u4, tex_v4 = getUVsFromTexName(mTexArray and mTexArray[4] or tex)
	local tex_u5, tex_v5 = getUVsFromTexName(mTexArray and mTexArray[5] or tex)
	local tex_u6, tex_v6 = getUVsFromTexName(mTexArray and mTexArray[6] or tex)

	-- first we make the vertices
	local sX, sY, sZ = scl[1], scl[2], scl[3]


	local v1 = Vector(-sX, -sY, -sZ)
	local v2 = Vector( sX, -sY, -sZ)
	local v3 = Vector( sX,  sY, -sZ)
	local v4 = Vector(-sX,  sY, -sZ)

	local v5 = Vector(-sX, -sY,  sZ)
	local v6 = Vector( sX, -sY,  sZ)
	local v7 = Vector( sX,  sY,  sZ)
	local v8 = Vector(-sX,  sY,  sZ)

	local meshRet = Mesh()
	local primitiveCount = 6 -- cubes have 6 faces if we use quads

	local normXp = Vector( 1,  0,  0)
	local normXm = Vector(-1,  0,  0)
	local normYp = Vector( 0,  1,  0)
	local normYm = Vector( 0, -1,  0)
	local normZp = Vector( 0,  0,  1)
	local normZm = Vector( 0,  0, -1)


	local sideCol = unshaded and 255 or 153
	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
		-- BEGIN X+
		sideCol = unshaded and 255 or 153
			mesh_Position(v6 + pos)
			mesh_Normal(normXp)
			mesh_TexCoord(0, tex_u1, tex_v1)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v7 + pos)
			mesh_Normal(normXp)
			mesh_TexCoord(0, tex_u1 + uvBSize, tex_v1)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v3 + pos)
			mesh_Normal(normXp)
			mesh_TexCoord(0, tex_u1 + uvBSize, tex_v1 + uvBSize)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v2 + pos)
			mesh_Normal(normXp)
			mesh_TexCoord(0, tex_u1, tex_v1 + uvBSize)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()
		-- END X+

		-- BEGIN X-
			mesh_Position(v8 + pos)
			mesh_Normal(normXm)
			mesh_TexCoord(0, tex_u2, tex_v2)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v5 + pos)
			mesh_Normal(normXm)
			mesh_TexCoord(0, tex_u2 + uvBSize, tex_v2)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v1 + pos)
			mesh_Normal(normXm)
			mesh_TexCoord(0, tex_u2 + uvBSize, tex_v2 + uvBSize)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v4 + pos)
			mesh_Normal(normXm)
			mesh_TexCoord(0, tex_u2, tex_v2 + uvBSize)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()
		-- END X-

		-- BEGIN Y+
		sideCol = unshaded and 255 or 204
			mesh_Position(v7 + pos)
			mesh_Normal(normYp)
			mesh_TexCoord(0, tex_u3, tex_v3)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v8 + pos)
			mesh_Normal(normYp)
			mesh_TexCoord(0, tex_u3 + uvBSize, tex_v3)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v4 + pos)
			mesh_Normal(normYp)
			mesh_TexCoord(0, tex_u3 + uvBSize, tex_v3 + uvBSize)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v3 + pos)
			mesh_Normal(normYp)
			mesh_TexCoord(0, tex_u3, tex_v3 + uvBSize)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()
		-- END Y+

		-- BEGIN Y-
			mesh_Position(v5 + pos)
			mesh_Normal(normYm)
			mesh_TexCoord(0, tex_u4, tex_v4)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v6 + pos)
			mesh_Normal(normYm)
			mesh_TexCoord(0, tex_u4 + uvBSize, tex_v4)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v2 + pos)
			mesh_Normal(normYm)
			mesh_TexCoord(0, tex_u4 + uvBSize, tex_v4 + uvBSize)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v1 + pos)
			mesh_Normal(normYm)
			mesh_TexCoord(0, tex_u4, tex_v4 + uvBSize)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()
		-- END Y-

		-- BEGIN Z+
			mesh_Position(v5 + pos)
			mesh_Normal(normZp)
			mesh_TexCoord(0, tex_u5, tex_v5)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Position(v8 + pos)
			mesh_Normal(normZp)
			mesh_TexCoord(0, tex_u5 + uvBSize, tex_v5)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Position(v7 + pos)
			mesh_Normal(normZp)
			mesh_TexCoord(0, tex_u5 + uvBSize, tex_v5 + uvBSize)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Position(v6 + pos)
			mesh_Normal(normZp)
			mesh_TexCoord(0, tex_u5, tex_v5 + uvBSize)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END Z+

		-- BEGIN Z-
		sideCol = unshaded and 255 or 102
			mesh_Position(v2 + pos)
			mesh_Normal(normZm)
			mesh_TexCoord(0, tex_u6, tex_v6)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v3 + pos)
			mesh_Normal(normZm)
			mesh_TexCoord(0, tex_u6 + uvBSize, tex_v6)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v4 + pos)
			mesh_Normal(normZm)
			mesh_TexCoord(0, tex_u6 + uvBSize, tex_v6 + uvBSize)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()

			mesh_Position(v1 + pos)
			mesh_Normal(normZm)
			mesh_TexCoord(0, tex_u6, tex_v6 + uvBSize)
			mesh_Color(sideCol, sideCol, sideCol, 255)
			mesh_AdvanceVertex()
		-- END Z-
	mesh_End()
	return meshRet
end







-- Generates a cube mesh with UVs for the playermodels
-- atlas is 64x64 so uvs are scaled
-- uvInfo struct
-- {
--  	[1] = {oX, oY, uW, uH}, -- +x
-- 		[2] = {oX, oY, uW, uH}, -- -x
--		
--		[3] = {oX, oY, uW, uH}, -- +y
--		[4] = {oX, oY, uW, uH}, -- -y
--		
--		[5] = {oX, oY, uW, uH}, -- +z
--		[6] = {oX, oY, uW, uH}, -- -z
-- }
function ZVox.GetUVCubeMesh(pos, scl, uvInfo, normFlip, scaleFactor)
	-- first we make the vertices
	local sX, sY, sZ = scl[1], scl[2], scl[3]
	local v1 = Vector(-sX, -sY, -sZ)
	local v2 = Vector( sX, -sY, -sZ)
	local v3 = Vector( sX,  sY, -sZ)
	local v4 = Vector(-sX,  sY, -sZ)

	local v5 = Vector(-sX, -sY,  sZ)
	local v6 = Vector( sX, -sY,  sZ)
	local v7 = Vector( sX,  sY,  sZ)
	local v8 = Vector(-sX,  sY,  sZ)

	local meshRet = Mesh()
	local primitiveCount = 6 -- cubes have 6 faces if we use quads

	local normFlipMul = normFlip and -1 or 1

	local normXp = Vector( 1,  0,  0) * normFlipMul
	local normXm = Vector(-1,  0,  0) * normFlipMul
	local normYp = Vector( 0,  1,  0) * normFlipMul
	local normYm = Vector( 0, -1,  0) * normFlipMul
	local normZp = Vector( 0,  0,  1) * normFlipMul
	local normZm = Vector( 0,  0, -1) * normFlipMul

	scaleFactor = scaleFactor or {64, 64}

	local uvsX = scaleFactor[1] or 64
	local uvsY = scaleFactor[2] or 64

	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
		local uvFetch = uvInfo[1]
		local o_u = uvFetch[1] / uvsX
		local o_v = uvFetch[2] / uvsY
		local e_u = o_u + (uvFetch[3] / uvsX)
		local e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN X+
			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(153, 153, 153, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(153, 153, 153, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(153, 153, 153, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(153, 153, 153, 255)
			mesh_AdvanceVertex()
		-- END X+

		uvFetch = uvInfo[2]
		o_u = uvFetch[1] / uvsX
		o_v = uvFetch[2] / uvsY
		e_u = o_u + (uvFetch[3] / uvsX)
		e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN X-
			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(153, 153, 153, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(153, 153, 153, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(153, 153, 153, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(153, 153, 153, 255)
			mesh_AdvanceVertex()
		-- END X-

		uvFetch = uvInfo[3]
		o_u = uvFetch[1] / uvsX
		o_v = uvFetch[2] / uvsY
		e_u = o_u + (uvFetch[3] / uvsX)
		e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN Y+
			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(204, 204, 204, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(204, 204, 204, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(204, 204, 204, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(204, 204, 204, 255)
			mesh_AdvanceVertex()
		-- END Y+

		uvFetch = uvInfo[4]
		o_u = uvFetch[1] / uvsX
		o_v = uvFetch[2] / uvsY
		e_u = o_u + (uvFetch[3] / uvsX)
		e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN Y-
			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(204, 204, 204, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(204, 204, 204, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(204, 204, 204, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(204, 204, 204, 255)
			mesh_AdvanceVertex()
		-- END Y-

		uvFetch = uvInfo[5]
		o_u = uvFetch[1] / uvsX
		o_v = uvFetch[2] / uvsY
		e_u = o_u + (uvFetch[3] / uvsX)
		e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN Z+
			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END Z+

		uvFetch = uvInfo[6]
		o_u = uvFetch[1] / uvsX
		o_v = uvFetch[2] / uvsY
		e_u = o_u + (uvFetch[3] / uvsX)
		e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN Z-
			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(102, 102, 102, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(102, 102, 102, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(102, 102, 102, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(102, 102, 102, 255)
			mesh_AdvanceVertex()
		-- END Z-
	mesh_End()
	return meshRet
end

-- Helpers
function ZVox.GetCubeMeshFlippedPairs(pos, scl)
	return ZVox.GetCubeMesh(pos, scl, false), ZVox.GetCubeMesh(pos, scl, true)
end

function ZVox.GetUVCubeMeshFlippedPairs(pos, scl, uvInfo)
	return ZVox.GetUVCubeMesh(pos, scl, uvInfo, false), ZVox.GetUVCubeMesh(pos, scl, uvInfo, true)
end



function ZVox.GetUVCubeMeshUnshaded(pos, scl, uvInfo, normFlip, scaleFactor)
	-- first we make the vertices
	local sX, sY, sZ = scl[1], scl[2], scl[3]
	local v1 = Vector(-sX, -sY, -sZ)
	local v2 = Vector( sX, -sY, -sZ)
	local v3 = Vector( sX,  sY, -sZ)
	local v4 = Vector(-sX,  sY, -sZ)

	local v5 = Vector(-sX, -sY,  sZ)
	local v6 = Vector( sX, -sY,  sZ)
	local v7 = Vector( sX,  sY,  sZ)
	local v8 = Vector(-sX,  sY,  sZ)

	local meshRet = Mesh()
	local primitiveCount = 6 -- cubes have 6 faces if we use quads

	local normFlipMul = normFlip and -1 or 1

	local normXp = Vector( 1,  0,  0) * normFlipMul
	local normXm = Vector(-1,  0,  0) * normFlipMul
	local normYp = Vector( 0,  1,  0) * normFlipMul
	local normYm = Vector( 0, -1,  0) * normFlipMul
	local normZp = Vector( 0,  0,  1) * normFlipMul
	local normZm = Vector( 0,  0, -1) * normFlipMul

	scaleFactor = scaleFactor or {64, 64}

	local uvsX = scaleFactor[1] or 64
	local uvsY = scaleFactor[2] or 64

	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
		local uvFetch = uvInfo[1]
		local o_u = uvFetch[1] / uvsX
		local o_v = uvFetch[2] / uvsY
		local e_u = o_u + (uvFetch[3] / uvsX)
		local e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN X+
			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXp)
			if normFlip then
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END X+

		uvFetch = uvInfo[2]
		o_u = uvFetch[1] / uvsX
		o_v = uvFetch[2] / uvsY
		e_u = o_u + (uvFetch[3] / uvsX)
		e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN X-
			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normXm)
			if normFlip then
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END X-

		uvFetch = uvInfo[3]
		o_u = uvFetch[1] / uvsX
		o_v = uvFetch[2] / uvsY
		e_u = o_u + (uvFetch[3] / uvsX)
		e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN Y+
			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYp)
			if normFlip then
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END Y+

		uvFetch = uvInfo[4]
		o_u = uvFetch[1] / uvsX
		o_v = uvFetch[2] / uvsY
		e_u = o_u + (uvFetch[3] / uvsX)
		e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN Y-
			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normYm)
			if normFlip then
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END Y-

		uvFetch = uvInfo[5]
		o_u = uvFetch[1] / uvsX
		o_v = uvFetch[2] / uvsY
		e_u = o_u + (uvFetch[3] / uvsX)
		e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN Z+
			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v6 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v5 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZp)
			if normFlip then
				mesh_Position(v7 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v8 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END Z+

		uvFetch = uvInfo[6]
		o_u = uvFetch[1] / uvsX
		o_v = uvFetch[2] / uvsY
		e_u = o_u + (uvFetch[3] / uvsX)
		e_v = o_v + (uvFetch[4] / uvsY)
		-- BEGIN Z-
			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, o_u, e_v)
			else
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, o_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, e_u, e_v)
			else
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, e_u, o_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v3 + pos)
				mesh_TexCoord(0, e_u, o_v)
			else
				mesh_Position(v4 + pos)
				mesh_TexCoord(0, e_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			mesh_Normal(normZm)
			if normFlip then
				mesh_Position(v2 + pos)
				mesh_TexCoord(0, o_u, o_v)
			else
				mesh_Position(v1 + pos)
				mesh_TexCoord(0, o_u, e_v)
			end
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		-- END Z-
	mesh_End()
	return meshRet
end