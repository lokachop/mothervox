ZVox = ZVox or {}


local mesh = mesh
local mesh_Begin = mesh.Begin
local mesh_Position = mesh.Position
local mesh_Normal = mesh.Normal
local mesh_TexCoord = mesh.TexCoord
local mesh_Color = mesh.Color
local mesh_AdvanceVertex = mesh.AdvanceVertex
local mesh_End = mesh.End

local _nullScale = Vector(1, 1, 1)
local _pi = math.pi
local _pi2 = math.pi * 2
-- returns a mesh of a sphere with variable detail
function ZVox.GetSphereMeshEx(itrX, itrY, normFlip, scale, uScale, vScale)
	scale = scale or _nullScale
	uScale = uScale or 1
	vScale = vScale or 1

	local meshRet = Mesh()
	-- create a sphere mesh with uvs
	-- this is harder than it sounds

	local flipMul = normFlip and -1 or 1

	local primitiveCount = (itrX * itrY)
	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
	for y = 0, itrY - 1 do
		local nextY = (y % itrY) + 1

		local deltaY = (y / itrY)
		local deltaNextY = (nextY / itrY)

		local sinY = math.sin(deltaY * _pi)
		local sinNextY = math.sin(deltaNextY * _pi)

		local cosY = -math.cos(deltaY * _pi)
		local cosNextY = -math.cos(deltaNextY * _pi)

		for x = 0, itrX - 1 do
			-- push quads here somehow cook cook
			local nextX = (x % itrX) + 1

			local deltaX = (x / itrX)
			local deltaNextX = (nextX / itrX)

			local sinX = math.sin(deltaX * _pi2)
			local sinNextX = math.sin(deltaNextX * _pi2)


			local cosX = math.cos(deltaX * _pi2)
			local cosNextX = math.cos(deltaNextX * _pi2)

			-- X nextX
			-- : :
			-- o-o <- nextY
			-- | |
			-- X-o <- y
			local radMul = sinY
			local pos = Vector(sinX * radMul, cosX * radMul, cosY) * scale
			local norm = pos:GetNormalized() * flipMul
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, deltaX * uScale, deltaY * vScale)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			-- X-o
			-- | |
			-- o-o
			radMul = sinNextY
			pos = Vector(sinX * radMul, cosX * radMul, cosNextY) * scale
			norm = pos:GetNormalized() * flipMul
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, deltaX * uScale, deltaNextY * vScale)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			-- o-X
			-- | |
			-- o-o
			radMul = sinNextY
			pos = Vector(sinNextX * radMul, cosNextX * radMul, cosNextY) * scale
			norm = pos:GetNormalized() * flipMul
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, deltaNextX * uScale, deltaNextY * vScale)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()

			-- o-o
			-- | |
			-- o-X
			radMul = sinY
			pos = Vector(sinNextX * radMul, cosNextX * radMul, cosY) * scale
			norm = pos:GetNormalized() * flipMul
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, deltaNextX * uScale, deltaY * vScale)
			mesh_Color(255, 255, 255, 255)
			mesh_AdvanceVertex()
		end
	end
	mesh_End()

	return meshRet
end

function ZVox.GetSphereMeshOp(itrX, itrY, normFlip, scale, funcCol, funcUV)
	scale = scale or _nullScale

	local meshRet = Mesh()
	-- create a sphere mesh with uvs
	-- this is harder than it sounds

	local flipMul = normFlip and -1 or 1

	local primitiveCount = (itrX * itrY)
	mesh_Begin(meshRet, MATERIAL_QUADS, primitiveCount)
	for y = 0, itrY - 1 do
		local nextY = (y % itrY) + 1

		local deltaY = (y / itrY)
		local deltaNextY = (nextY / itrY)

		local sinY = math.sin(deltaY * _pi)
		local sinNextY = math.sin(deltaNextY * _pi)

		local cosY = -math.cos(deltaY * _pi)
		local cosNextY = -math.cos(deltaNextY * _pi)

		for x = 0, itrX - 1 do
			-- push quads here somehow cook cook
			local nextX = (x % itrX) + 1

			local deltaX = (x / itrX)
			local deltaNextX = (nextX / itrX)

			local sinX = math.sin(deltaX * _pi2)
			local sinNextX = math.sin(deltaNextX * _pi2)


			local cosX = math.cos(deltaX * _pi2)
			local cosNextX = math.cos(deltaNextX * _pi2)

			-- X nextX
			-- : :
			-- o-o <- nextY
			-- | |
			-- X-o <- y
			local radMul = sinY
			local pos = Vector(sinX * radMul, cosX * radMul, cosY) * scale
			local norm = pos:GetNormalized() * flipMul

			local u, v = funcUV(pos, norm, scale)
			local r, g, b, a = funcCol(pos, norm, scale)
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, u, v)
			mesh_Color(r, g, b, a or 255)
			mesh_AdvanceVertex()

			-- X-o
			-- | |
			-- o-o
			radMul = sinNextY
			pos = Vector(sinX * radMul, cosX * radMul, cosNextY) * scale
			norm = pos:GetNormalized() * flipMul

			u, v = funcUV(pos, norm, scale)
			r, g, b, a = funcCol(pos, norm, scale)
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, u, v)
			mesh_Color(r, g, b, a or 255)
			mesh_AdvanceVertex()

			-- o-X
			-- | |
			-- o-o
			radMul = sinNextY
			pos = Vector(sinNextX * radMul, cosNextX * radMul, cosNextY) * scale
			norm = pos:GetNormalized() * flipMul

			u, v = funcUV(pos, norm, scale)
			r, g, b, a = funcCol(pos, norm, scale)
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, u, v)
			mesh_Color(r, g, b, a or 255)
			mesh_AdvanceVertex()

			-- o-o
			-- | |
			-- o-X
			radMul = sinY
			pos = Vector(sinNextX * radMul, cosNextX * radMul, cosY) * scale
			norm = pos:GetNormalized() * flipMul

			u, v = funcUV(pos, norm, scale)
			r, g, b, a = funcCol(pos, norm, scale)
			mesh_Position(pos)
			mesh_Normal(norm)
			mesh_TexCoord(0, u, v)
			mesh_Color(r, g, b, a or 255)
			mesh_AdvanceVertex()
		end
	end
	mesh_End()

	return meshRet
end


function ZVox.GetSphereMesh(itrX, itrY, normFlip)
	return ZVox.GetSphereMeshEx(itrX, itrY, normFlip, _nullScale, 1, 1)
end