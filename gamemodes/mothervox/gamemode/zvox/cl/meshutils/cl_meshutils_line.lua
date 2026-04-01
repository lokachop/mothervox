ZVox = ZVox or {}

local mesh = mesh
local mesh_Begin = mesh.Begin
local mesh_Position = mesh.Position
local mesh_Normal = mesh.Normal
local mesh_TexCoord = mesh.TexCoord
local mesh_Color = mesh.Color
local mesh_AdvanceVertex = mesh.AdvanceVertex
local mesh_End = mesh.End


local cSizeX = ZVOX_CHUNKSIZE_X
local cSizeY = ZVOX_CHUNKSIZE_Y
local cSizeZ = ZVOX_CHUNKSIZE_Z

-- line render utils
local NULL_NORM = Vector(0, 0, 1)
local function emitGridPlaneMesh(pos, scl, rot, sclGridX, sclGridY, col)
	local szX, szY, szZ = scl[1], scl[2], scl[3]

	local cR, cG, cB = col.r, col.g, col.b

	local pCalc = Vector(0, 0, 0)
	for x = 0, sclGridX do
		local xD = ((x / sclGridX) - .5) * szX
		xD = xD + (szX * .5)

		local szY_ADD = (szY * .5)

		pCalc:SetUnpacked(xD, szY * .5 + szY_ADD, 0)
		pCalc:Rotate(rot)


		mesh_Position(pCalc + pos)
		mesh_Normal(NULL_NORM)
		mesh_Color(cR, cG, cB, 255)
		mesh_AdvanceVertex()

		pCalc:SetUnpacked(xD, -szY * .5 + szY_ADD, 0)
		pCalc:Rotate(rot)

		mesh_Position(pCalc + pos)
		mesh_Normal(NULL_NORM)
		mesh_Color(cR, cG, cB, 255)
		mesh_AdvanceVertex()
	end

	for y = 0, sclGridY do
		local yD = ((y / sclGridY) - .5) * szY
		yD = yD + (szY * .5)

		local szX_ADD = (szX * .5)


		pCalc:SetUnpacked(szX * .5 + szX_ADD, yD, 0)
		pCalc:Rotate(rot)


		mesh_Position(pCalc + pos)
		mesh_Normal(NULL_NORM)
		mesh_Color(cR, cG, cB, 255)
		mesh_AdvanceVertex()

		pCalc:SetUnpacked(-szX * .5 + szX_ADD, yD, 0)
		pCalc:Rotate(rot)

		mesh_Position(pCalc + pos)
		mesh_Normal(NULL_NORM)
		mesh_Color(cR, cG, cB, 255)
		mesh_AdvanceVertex()
	end
end


function ZVox.GetGridMesh(pos, scl, col)
	local primitiveCount = 4 * 4

	local meshRet = Mesh()

	mesh_Begin(meshRet, MATERIAL_LINES, primitiveCount)
		emitGridPlaneMesh(pos, scl, Angle(0, 0, 0), 4, 4, col)
	mesh_End()

	return meshRet
end




local NULL_POS = Vector(0, 0, 0)
local NULL_SCALE = Vector(1, 1, 1)
local NULL_COLOR = Color(0, 0, 0)

local _colX = NULL_COLOR --Color(196, 32, 32)
local _colY = NULL_COLOR --Color(32, 196, 32)
local _colZ = NULL_COLOR --Color(32, 32, 196)


-- Z rot
local _rot0 = Angle(0, 0, 0)

-- X rot
local _rot1 = Angle(0, 90, 90)

-- Y rot
local _rot2 = Angle(0, 180, 90)
function ZVox.GetChunkBoundaryMesh()
	local primitiveCount = 0
	-- +X
	primitiveCount = primitiveCount + (cSizeX * cSizeZ)

	-- -X
	primitiveCount = primitiveCount + (cSizeX * cSizeZ)

	-- +Y
	primitiveCount = primitiveCount + (cSizeY * cSizeZ)

	-- -Y
	primitiveCount = primitiveCount + (cSizeY * cSizeZ)

	-- +Z
	primitiveCount = primitiveCount + (cSizeX * cSizeY)

	-- -Z
	primitiveCount = primitiveCount + (cSizeX * cSizeY)



	local meshRet = Mesh()

	local posVec = Vector()
	local sclVec = Vector()
	mesh_Begin(meshRet, MATERIAL_LINES, primitiveCount)
		-- X
		-- +X
		sclVec:SetUnpacked(cSizeX, cSizeZ, 1)
		posVec:SetUnpacked(cSizeX, 0, 0)
		emitGridPlaneMesh(posVec, sclVec, _rot1, cSizeX, cSizeZ, _colX)

		-- -X
		sclVec:SetUnpacked(cSizeX, cSizeZ, 1)
		posVec:SetUnpacked(0, 0, 0)
		emitGridPlaneMesh(posVec, sclVec, _rot1, cSizeX, cSizeZ, _colX)

		-- Y
		-- +Y
		sclVec:SetUnpacked(cSizeY, cSizeZ, 1)
		posVec:SetUnpacked(cSizeX, cSizeY, 0)
		emitGridPlaneMesh(posVec, sclVec, _rot2, cSizeY, cSizeZ, _colY)


		-- -Y
		sclVec:SetUnpacked(cSizeY, cSizeZ, 1)
		posVec:SetUnpacked(cSizeX, 0, 0)
		emitGridPlaneMesh(posVec, sclVec, _rot2, cSizeY, cSizeZ, _colY)

		-- Z
		-- +Z
		sclVec:SetUnpacked(cSizeX, cSizeY, 1)
		posVec:SetUnpacked(0, 0, cSizeZ)
		emitGridPlaneMesh(posVec, sclVec, _rot0, cSizeX, cSizeY, _colZ)

		-- -Z
		sclVec:SetUnpacked(cSizeX, cSizeY, 1)
		posVec:SetUnpacked(0, 0, 0)
		emitGridPlaneMesh(NULL_POS, sclVec, _rot0, cSizeX, cSizeY, _colZ)
	mesh_End()

	return meshRet
end


local function primLine(v1, v2, cR, cG, cB)
	mesh_Position(v1)
	mesh_Color(cR, cG, cB, 255)
	mesh_AdvanceVertex()

	mesh_Position(v2)
	mesh_Color(cR, cG, cB, 255)
	mesh_AdvanceVertex()
end

function ZVox.GetCubeLineMesh(pos, scl, cR, cG, cB)
	pos = pos or Vector(0, 0, 0)
	scl = scl or Vector(1, 1, 1)
	cR = cR or 255
	cG = cG or 255
	cB = cB or 255

	local meshRet = Mesh()

	local v1 = pos * 1
	-- o---o  o---o
	-- |z+ |  |z- |
	-- o---o  f---X
	local v2 = pos + Vector(scl[1], 0, 0)
	-- o---o  X---o
	-- |z+ |  |z- |
	-- o---o  f---o
	local v3 = pos + Vector(0, scl[2], 0)
	-- o---o  o---X
	-- |z+ |  |z- |
	-- o---o  f---o
	local v4 = pos + Vector(scl[1], scl[2], 0)
	----------------
	-- Z POSITIVE --
	----------------
	-- o---o  o---o
	-- |z+ |  |z- |
	-- X---o  f---o
	local v5 = pos + Vector(0, 0, scl[3])
	-- o---o  o---o
	-- |z+ |  |z- |
	-- o---X  f---o
	local v6 = pos + Vector(scl[1], 0, scl[3])
	-- X---o  o---o
	-- |z+ |  |z- |
	-- o---o  f---o
	local v7 = pos + Vector(0, scl[2], scl[3])
	-- o---X  o---o
	-- |z+ |  |z- |
	-- o---o  f---o
	local v8 = pos + Vector(scl[1], scl[2], scl[3])


	mesh_Begin(meshRet, MATERIAL_LINES, 4 + 4 + 4)
		primLine(v1, v2, cR, cG, cB)
		primLine(v2, v4, cR, cG, cB)
		primLine(v4, v3, cR, cG, cB)
		primLine(v3, v1, cR, cG, cB)

		primLine(v5, v6, cR, cG, cB)
		primLine(v6, v8, cR, cG, cB)
		primLine(v8, v7, cR, cG, cB)
		primLine(v7, v5, cR, cG, cB)

		primLine(v1, v5, cR, cG, cB)
		primLine(v2, v6, cR, cG, cB)
		primLine(v3, v7, cR, cG, cB)
		primLine(v4, v8, cR, cG, cB)
	mesh_End()

	return meshRet
end



local DIR_X = 1
local DIR_Y = 2
local DIR_Z = 3

local thickSize = .0015

local thickVecXPlus = Vector(thickSize, 0, 0)
local thickVecXMinus = Vector(-thickSize, 0, 0)

local thickVecYPlus = Vector(0, thickSize, 0)
local thickVecYMinus = Vector(0, -thickSize, 0)

local thickVecZPlus = Vector(0, 0, thickSize)
local thickVecZMinus = Vector(0, 0, -thickSize)
local function thickPrimLine(startPos, endPos, r, g, b, excludeAxis)
	primLine(startPos, endPos, r, g, b)

	if (excludeAxis ~= DIR_X) then
		primLine(startPos + thickVecXPlus, endPos + thickVecXPlus, r, g, b)
		primLine(startPos + thickVecXMinus, endPos + thickVecXMinus, r, g, b)
	end

	if (excludeAxis ~= DIR_Y) then
		primLine(startPos + thickVecYPlus, endPos + thickVecYPlus, r, g, b)
		primLine(startPos + thickVecYMinus, endPos + thickVecYMinus, r, g, b)
	end

	if (excludeAxis ~= DIR_Z) then
		primLine(startPos + thickVecZPlus, endPos + thickVecZPlus, r, g, b)
		primLine(startPos + thickVecZMinus, endPos + thickVecZMinus, r, g, b)
	end
end

function ZVox.GetAxisLineMesh(sz)
	local meshRet = Mesh()

	mesh_Begin(meshRet, MATERIAL_LINES, 3 * 5)
		thickPrimLine(Vector(0, 0, 0), Vector(sz, 0, 0), 255, 0, 0, DIR_X)
		thickPrimLine(Vector(0, 0, 0), Vector(0, sz, 0), 0, 255, 0, DIR_Y)
		thickPrimLine(Vector(0, 0, 0), Vector(0, 0, sz), 0, 0, 255, DIR_Z)
	mesh_End()

	return meshRet
end