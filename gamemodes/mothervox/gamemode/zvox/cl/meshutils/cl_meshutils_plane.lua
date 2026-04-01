ZVox = ZVox or {}

local mesh = mesh
local mesh_Begin = mesh.Begin
local mesh_Position = mesh.Position
local mesh_Normal = mesh.Normal
local mesh_TexCoord = mesh.TexCoord
local mesh_Color = mesh.Color
local mesh_AdvanceVertex = mesh.AdvanceVertex
local mesh_End = mesh.End

-- returns a mesh of a plane with variable detail
function ZVox.GetPlaneMeshEx(itrX, itrY, normFlip, scale, pOff)
	local meshRet = Mesh()
	-- create a sphere mesh with uvs
	-- this is harder than it sounds

	local flipMul = normFlip and -1 or 1
	local norm = Vector(0, 0, 1) * flipMul

	local primitiveCount = (itrX * itrY)
	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
	for y = 0, itrY - 1 do
		local nextY = (y % itrY) + 1

		local deltaY = (y / itrY)
		local deltaNextY = (nextY / itrY)

		for x = 0, itrX - 1 do
			-- push quads here somehow cook cook
			local nextX = (x % itrX) + 1

			local deltaX = (x / itrX)
			local deltaNextX = (nextX / itrX)

			-- X nextX
			-- : :
			-- o-o <- nextY
			-- | |
			-- X-o <- y
			local pos

			if normFlip then
				pos = (Vector(deltaNextX, deltaY, 0) * scale) + pOff
			else
				pos = (Vector(deltaX, deltaY, 0) * scale) + pOff
			end
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, deltaX, deltaY)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			-- X-o
			-- | |
			-- o-o
			if normFlip then
				pos = (Vector(deltaNextX, deltaNextY, 0) * scale) + pOff
			else
				pos = (Vector(deltaX, deltaNextY, 0) * scale) + pOff
			end
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, deltaX, deltaNextY)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			-- o-X
			-- | |
			-- o-o
			if normFlip then
				pos = (Vector(deltaX, deltaNextY, 0) * scale) + pOff
			else
				pos = (Vector(deltaNextX, deltaNextY, 0) * scale) + pOff
			end
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, deltaNextX, deltaNextY)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			-- o-o
			-- | |
			-- o-X
			if normFlip then
				pos = (Vector(deltaX, deltaY, 0) * scale) + pOff
			else
				pos = (Vector(deltaNextX, deltaY, 0) * scale) + pOff
			end
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, deltaNextX, deltaY)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		end
	end
	mesh_End()

	return meshRet
end


function ZVox.GetPlaneMeshOp(itrX, itrY, normFlip, scale, pOff, funcCol, funcUV)
	local meshRet = Mesh()
	-- create a sphere mesh with uvs
	-- this is harder than it sounds

	local flipMul = normFlip and -1 or 1
	local norm = Vector(0, 0, 1) * flipMul

	local primitiveCount = (itrX * itrY)
	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
	for y = 0, itrY - 1 do
		local nextY = (y % itrY) + 1

		local deltaY = (y / itrY)
		local deltaNextY = (nextY / itrY)

		for x = 0, itrX - 1 do
			-- push quads here somehow cook cook
			local nextX = (x % itrX) + 1

			local deltaX = (x / itrX)
			local deltaNextX = (nextX / itrX)

			-- X nextX
			-- : :
			-- o-o <- nextY
			-- | |
			-- X-o <- y
			local pos

			if normFlip then
				pos = (Vector(deltaNextX, deltaY, 0) * scale) + pOff
			else
				pos = (Vector(deltaX, deltaY, 0) * scale) + pOff
			end

			local u, v = funcUV(pos, norm, scale)
			local r, g, b, a = funcCol(pos, norm, scale)
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, u, v)
			mesh_Color(r, g, b, a)
			mesh_AdvanceVertex()

			-- X-o
			-- | |
			-- o-o
			if normFlip then
				pos = (Vector(deltaNextX, deltaNextY, 0) * scale) + pOff
			else
				pos = (Vector(deltaX, deltaNextY, 0) * scale) + pOff
			end

			u, v = funcUV(pos, norm, scale)
			r, g, b, a = funcCol(pos, norm, scale)
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, u, v)
			mesh_Color(r, g, b, a)
			mesh_AdvanceVertex()

			-- o-X
			-- | |
			-- o-o
			if normFlip then
				pos = (Vector(deltaX, deltaNextY, 0) * scale) + pOff
			else
				pos = (Vector(deltaNextX, deltaNextY, 0) * scale) + pOff
			end

			u, v = funcUV(pos, norm, scale)
			r, g, b, a = funcCol(pos, norm, scale)
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, u, v)
			mesh_Color(r, g, b, a)
			mesh_AdvanceVertex()

			-- o-o
			-- | |
			-- o-X
			if normFlip then
				pos = (Vector(deltaX, deltaY, 0) * scale) + pOff
			else
				pos = (Vector(deltaNextX, deltaY, 0) * scale) + pOff
			end

			u, v = funcUV(pos, norm, scale)
			r, g, b, a = funcCol(pos, norm, scale)
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, u, v)
			mesh_Color(r, g, b, a)
			mesh_AdvanceVertex()
		end
	end
	mesh_End()

	return meshRet
end


-- a flat x plane with specificable start / end uvs
-- this is used with the particle system to precompute a few flat planes that are translated to cam
function ZVox.GetPlaneMeshSimple(scl, uStart, vStart, uEnd, vEnd)
	local meshRet = Mesh()

	local sX, sY = scl[1], scl[2]
	local normUp = Vector(0, 0, 1)

	-- 1 plane
	local primitiveCount = 1

	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
		mesh_Position(0, -sX, sY)
		mesh_Normal(normUp)
		mesh_TexCoord(0, uStart, vStart)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		mesh_Position(0, sX, sY)
		mesh_Normal(normUp)
		mesh_TexCoord(0, uEnd, vStart)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		mesh_Position(0, sX, -sY)
		mesh_Normal(normUp)
		mesh_TexCoord(0, uEnd, vEnd)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		mesh_Position(0, -sX, -sY)
		mesh_Normal(normUp)
		mesh_TexCoord(0, uStart, vEnd)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()
	mesh_End()

	return meshRet
end

function ZVox.GetPlaneMeshSimpleZUp(scl, uStart, vStart, uEnd, vEnd)
	local meshRet = Mesh()

	local sX, sY = scl[1], scl[2]
	local normUp = Vector(0, 0, 1)

	-- 1 plane
	local primitiveCount = 1

	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
		mesh_Position(-sX, sY, 0)
		mesh_Normal(normUp)
		mesh_TexCoord(0, uStart, vStart)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		mesh_Position(sX, sY, 0)
		mesh_Normal(normUp)
		mesh_TexCoord(0, uEnd, vStart)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		mesh_Position(sX, -sY, 0)
		mesh_Normal(normUp)
		mesh_TexCoord(0, uEnd, vEnd)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		mesh_Position(-sX, -sY, 0)
		mesh_Normal(normUp)
		mesh_TexCoord(0, uStart, vEnd)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()
	mesh_End()

	return meshRet
end


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

-- returns a plane mesh with a voxel texture
-- tiled the itrX and itrY amounts
function ZVox.GetPlaneMeshTexture(name, itrX, itrY, scale, pOff)
	local tex_u, tex_v = getUVsFromTexName(name)

	local meshRet = Mesh()

	local flipMul = 1 -- normFlip and -1 or 1
	local norm = Vector(0, 0, 1) * flipMul

	local primitiveCount = (itrX * itrY)
	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
	for y = 0, itrY - 1 do
		local nextY = (y % itrY) + 1

		local deltaY = (y / itrY)
		local deltaNextY = (nextY / itrY)

		for x = 0, itrX - 1 do
			-- push quads here somehow cook cook
			local nextX = (x % itrX) + 1

			local deltaX = (x / itrX)
			local deltaNextX = (nextX / itrX)

			-- X nextX
			-- : :
			-- o-o <- nextY
			-- | |
			-- X-o <- y
			local pos

			pos = (Vector(deltaX, deltaY, 0) * scale) + pOff
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, tex_u, tex_v)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			-- X-o
			-- | |
			-- o-o
			pos = (Vector(deltaX, deltaNextY, 0) * scale) + pOff
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, tex_u, tex_v + uvBSize)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			-- o-X
			-- | |
			-- o-o
			pos = (Vector(deltaNextX, deltaNextY, 0) * scale) + pOff
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, tex_u + uvBSize, tex_v + uvBSize)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			-- o-o
			-- | |
			-- o-X
			pos = (Vector(deltaNextX, deltaY, 0) * scale) + pOff
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, tex_u + uvBSize, tex_v)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		end
	end
	mesh_End()

	return meshRet
end

-- returns a plane mesh given multiplane data
-- multiplane struct example below
--ZVox.GetPlaneMeshMulti({
--	{
--		["pos"] = Vector(0, 0, 0),
--		["scl"] = Vector(1, 1, 1),
--		["rot"] = Angle(0, 0, 0),
--		["uv"] = {0, 0, 1, 1},
--		["uvScale"] = 1,
--	},
--	...
--})

local null_vec = Vector(0, 0, 0)
local null_scl = Vector(1, 1, 1)
local null_uvData = {0, 0, 1, 1}
local norm_up = Vector(0, 0, 1)
local null_ang = Angle(0, 0, 0)
function ZVox.GetPlaneMeshMulti(data)
	local meshRet = Mesh()
	local primitiveCount = #data

	local norm = norm_up

	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
	for i = 1, primitiveCount do
		local planeData = data[i]

		local pos = planeData.pos or null_vec
		local scl = planeData.scl or null_scl
		local rot = planeData.rot or null_ang

		local uvData = planeData.uv or null_uvData
		local uvScale = planeData.uvScale or 1

		local minU = uvData[1] / uvScale
		local minV = uvData[2] / uvScale
		local maxU = minU + (uvData[3] / uvScale)
		local maxV = minV + (uvData[4] / uvScale)

		local sclX = scl[1]
		local sclY = scl[2]

		-- with all of this data we can build the plane
		local posCalc = Vector()

		-- X-o
		-- | |
		-- o-o
		posCalc:SetUnpacked(pos[1], pos[2], pos[3])
		posCalc:Rotate(rot)
		mesh_Position(posCalc)
		mesh_Normal(norm)
		mesh_TexCoord(0, minU, minV)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		-- o-X
		-- | |
		-- o-o
		posCalc:SetUnpacked(pos[1] + sclX, pos[2], pos[3])
		posCalc:Rotate(rot)
		mesh_Position(posCalc)
		mesh_Normal(norm)
		mesh_TexCoord(0, maxU, minV)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		-- o-o
		-- | |
		-- o-X
		posCalc:SetUnpacked(pos[1] + sclX, pos[2] + sclY, pos[3])
		posCalc:Rotate(rot)
		mesh_Position(posCalc)
		mesh_Normal(norm)
		mesh_TexCoord(0, maxU, maxV)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		-- o-o
		-- | |
		-- X-o
		posCalc:SetUnpacked(pos[1], pos[2] + sclY, pos[3])
		posCalc:Rotate(rot)
		mesh_Position(posCalc)
		mesh_Normal(norm)
		mesh_TexCoord(0, minU, maxV)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()
	end
	mesh_End()

	return meshRet
end

function ZVox.GetPlaneMeshMultiXUp(data)
	local meshRet = Mesh()
	local primitiveCount = #data

	local norm = norm_up

	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
	for i = 1, primitiveCount do
		local planeData = data[i]

		local pos = planeData.pos or null_vec
		local scl = planeData.scl or null_scl
		local rot = planeData.rot or null_ang


		local uvData = planeData.uv or null_uvData
		local uvScale = planeData.uvScale or 1

		local minU = uvData[1] / uvScale
		local minV = uvData[2] / uvScale
		local maxU = minU + (uvData[3] / uvScale)
		local maxV = minV + (uvData[4] / uvScale)

		local sclX = scl[1]
		local sclY = scl[2]

		-- with all of this data we can build the plane
		local posCalc = Vector()

		-- X-o
		-- | |
		-- o-o
		posCalc:SetUnpacked(pos[1], pos[2], pos[3])
		posCalc:Rotate(rot)
		mesh_Position(posCalc)
		mesh_Normal(norm)
		mesh_TexCoord(0, minU, minV)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		-- o-X
		-- | |
		-- o-o
		posCalc:SetUnpacked(pos[1], pos[2] + sclX, pos[3])
		posCalc:Rotate(rot)
		mesh_Position(posCalc)
		mesh_Normal(norm)
		mesh_TexCoord(0, maxU, minV)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		-- o-o
		-- | |
		-- o-X
		posCalc:SetUnpacked(pos[1], pos[2] + sclX, pos[3] + sclY)
		posCalc:Rotate(rot)
		mesh_Position(posCalc)
		mesh_Normal(norm)
		mesh_TexCoord(0, maxU, maxV)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()

		-- o-o
		-- | |
		-- X-o
		posCalc:SetUnpacked(pos[1], pos[2], pos[3] + sclY)
		posCalc:Rotate(rot)
		mesh_Position(posCalc)
		mesh_Normal(norm)
		mesh_TexCoord(0, minU, maxV)
		mesh_Color(255, 255, 255, 255)
		mesh_AdvanceVertex()
	end
	mesh_End()

	return meshRet
end