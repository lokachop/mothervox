ZVox = ZVox or {}

local math = math
local math_floor = math.floor

local cSizeX = ZVOX_CHUNKSIZE_X
local cSizeY = ZVOX_CHUNKSIZE_Y
local cSizeZ = ZVOX_CHUNKSIZE_Z
local cSizeConst1 = ZVOX_CHUNKSIZE_X * ZVOX_CHUNKSIZE_Y
local cSizeConst2 = ZVOX_CHUNKSIZE_X * ZVOX_CHUNKSIZE_Y * ZVOX_CHUNKSIZE_Z

function ZVox.NewChunk(idx)
	if not idx then
		error("[ZVox] Attempt to create invalid chunk!")
	end

	return {
		["renderObjects"] = nil, -- client only, table of voxelgroups, each voxelgroup is a table of IMeshes to be drawn, we do this for transparency
		["renderMatrix"] = nil, -- client only, translated matrix for this chunk, used when rendering, only generated when meshed
		["voxelData"] = {}, -- all of the voxel data
		["voxelState"] = {}, -- voxel state (ex. orientation to voxels)

		-- CLIENTSIDE ONES
		["vertexLighting"] = {}, -- stores lighting info for vertices, practically a *4 version of voxeldata but with lighting values
		["cullingData"] = {},


		["index"] = idx,
		["univ"] = nil,
	}
end


function ZVox.SetChunkUniv(chunk, univ)
	chunk["univ"] = univ
end

-- worlds are 8x8 chunks
function ZVox.WorldToChunkIndex(univ, x, y, z)
	return math_floor(x / cSizeX) + (math_floor(y / cSizeY) * univ.chunkSizeX) + (math_floor(z / cSizeZ) * univ.chunkSizeConst1)
end

function ZVox.ChunkIndexToWorld(univ, hash)
	return ((hash % univ.chunkSizeX) % univ.chunkSizeX) * cSizeX, (math_floor(hash / univ.chunkSizeX) % univ.chunkSizeY) * cSizeY, (math_floor(hash / univ.chunkSizeConst1) % univ.chunkSizeZ) * cSizeZ
end

function ZVox.WorldToChunkBlock(x, y, z)
	return math_floor(x) + (math_floor(y) * cSizeX) + (math_floor(z) * cSizeConst1)
end

function ZVox.ChunkBlockToPos(bInd)
	return bInd % cSizeX, math_floor(bInd / cSizeX) % cSizeY, math_floor(bInd / cSizeConst1) % cSizeZ
end

function ZVox.GetBlockAtChunkPos(chunk, x, y, z)
	return chunk["voxelData"][ZVox.WorldToChunkBlock(x, y, z)]
end

function ZVox.ChunkBlockToWorld(univ, bInd, chunk)
	local hash = chunk["index"]

	local coX, coY = ZVox.ChunkIndexToWorld(univ, hash)

	return (bInd % cSizeX) + coX, (math_floor(bInd / cSizeX) % cSizeY) + coY, math_floor(bInd / cSizeConst1) % cSizeZ
end

---Gets the voxelID and voxelState at a certain pos
---@shared
---@internal
---@group internal
---@category blocks
---@return integer voxelID voxelID at the position
---@return integer? voxelState voxelState at the position, nil if out of bounds
function ZVox.GetBlockAtPos(univ, x, y, z)
	if x < 0 or y < 0 or z < 0 then
		return 0
	end

	if x >= (univ.chunkSizeX * cSizeX) or y >= (univ.chunkSizeY * cSizeY) or z >= (univ.chunkSizeZ * cSizeZ) then
		return 0
	end

	local chunkIdx = ZVox.WorldToChunkIndex(univ, x, y, z)
	local chunk = univ["chunks"][chunkIdx]
	if not chunk then
		return 0
	end

	local blockIdx = ZVox.WorldToChunkBlock(x % cSizeX, y % cSizeY, z % cSizeZ)
	local voxID = chunk["voxelData"][blockIdx]
	local voxState = chunk["voxelState"][blockIdx]

	return voxID, voxState
end


local function point_aabb(aabb, x, y, z)
	-- aabb[1], aabb[2], aabb[3]
	-- aabb[4], aabb[5], aabb[6]
	return  ((x >= aabb[1]) and (x <= aabb[4])) and
			((y >= aabb[2]) and (y <= aabb[5])) and
			((z >= aabb[3]) and (z <= aabb[6]))
end


local VOXEL_AIR = 0
function ZVox.GetPointSolid(univ, x, y, z) -- x, y, z can be floats
	local xW = math_floor(x)
	local yW = math_floor(y)
	local zW = math_floor(z)

	if xW < 0 or yW < 0 or zW < 0 then
		return false
	end

	if xW >= (univ.chunkSizeX * cSizeX) or yW >= (univ.chunkSizeY * cSizeY) or zW >= (univ.chunkSizeZ * cSizeZ) then
		return false
	end

	local chunkIdx = ZVox.WorldToChunkIndex(univ, xW, yW, zW)
	local chunk = univ["chunks"][chunkIdx]
	if not chunk then
		return false
	end

	local blockIdx = ZVox.WorldToChunkBlock(xW % cSizeX, yW % cSizeY, zW % cSizeZ)
	local voxID = chunk["voxelData"][blockIdx]
	if voxID == VOXEL_AIR then
		return false
	end


	local voxState = chunk["voxelState"][blockIdx]

	local aabbs = ZVox.GetVoxelAABBList(voxID, voxState)

	local xLocal = x - xW
	local yLocal = y - yW
	local zLocal = z - zW

	for i = 1, #aabbs do
		if point_aabb(aabbs[i], xLocal, yLocal, zLocal) then
			return true
		end
	end

	return false
end

function ZVox.SetBlockAtPos(univ, x, y, z, voxelID, voxelState, noMesh)
	if x < 0 or y < 0 or z < 0 then
		return
	end

	if x >= (univ.chunkSizeX * cSizeX) or y >= (univ.chunkSizeY * cSizeY) or z >= (univ.chunkSizeZ * cSizeZ) then
		return
	end

	local chunkList = univ["chunks"]


	local chunkIdx = ZVox.WorldToChunkIndex(univ, x, y, z)
	local chunk = chunkList[chunkIdx]
	if not chunk then
		return
	end

	local blockIdx = ZVox.WorldToChunkBlock(x % cSizeX, y % cSizeY, z % cSizeZ)


	chunk["voxelData"][blockIdx] = voxelID
	chunk["voxelState"][blockIdx] = voxelState or 0x0
	if not noMesh and CLIENT then
		ZVox.Lighting_RelightVoxel(x, y, z)
		ZVox.Culling_CullVoxel(x, y, z)
		ZVox.EmitChunkToRemesh(chunk)

		-- check axis to fix issue with meshing
		-- X+
		chunkIdx = ZVox.WorldToChunkIndex(univ, x + 1, y, z)
		local chunkBorder = chunkList[chunkIdx]
		if (chunkBorder ~= nil) and chunk ~= chunkBorder then
			--print("X+")
			ZVox.EmitChunkToRemesh(chunkBorder)
		end

		-- X-
		chunkIdx = ZVox.WorldToChunkIndex(univ, x - 1, y, z)
		chunkBorder = chunkList[chunkIdx]
		if (chunkBorder ~= nil) and chunk ~= chunkBorder then
			--print("X-")
			ZVox.EmitChunkToRemesh(chunkBorder)
		end

		-- Y+
		chunkIdx = ZVox.WorldToChunkIndex(univ, x, y + 1, z)
		chunkBorder = chunkList[chunkIdx]
		if (chunkBorder ~= nil) and chunk ~= chunkBorder then
			--print("Y+")
			ZVox.EmitChunkToRemesh(chunkBorder)
		end

		-- Y-
		chunkIdx = ZVox.WorldToChunkIndex(univ, x, y - 1, z)
		chunkBorder = chunkList[chunkIdx]
		if (chunkBorder ~= nil) and chunk ~= chunkBorder then
			--print("Y-")
			ZVox.EmitChunkToRemesh(chunkBorder)
		end


		-- Z+
		chunkIdx = ZVox.WorldToChunkIndex(univ, x, y, z + 1)
		chunkBorder = chunkList[chunkIdx]
		if (chunkBorder ~= nil) and chunk ~= chunkBorder then
			--print("Z+")
			ZVox.EmitChunkToRemesh(chunkBorder)
		end

		-- Z-
		chunkIdx = ZVox.WorldToChunkIndex(univ, x, y, z - 1)
		chunkBorder = chunkList[chunkIdx]
		if (chunkBorder ~= nil) and chunk ~= chunkBorder then
			--print("Z-")
			ZVox.EmitChunkToRemesh(chunkBorder)
		end


		-- extra corners for AO
		-- Z+
		if ZVOX_DO_AO then
			chunkIdx = ZVox.WorldToChunkIndex(univ, x + 1, y + 1, z + 1)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X+ Y+")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end

			chunkIdx = ZVox.WorldToChunkIndex(univ, x - 1, y + 1, z + 1)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X- Y+")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end

			chunkIdx = ZVox.WorldToChunkIndex(univ, x + 1, y - 1, z + 1)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X+ Y-")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end

			chunkIdx = ZVox.WorldToChunkIndex(univ, x - 1, y - 1, z + 1)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X- Y-")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end


			-- Z=
			chunkIdx = ZVox.WorldToChunkIndex(univ, x + 1, y + 1, z)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X+ Y+")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end

			chunkIdx = ZVox.WorldToChunkIndex(univ, x - 1, y + 1, z)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X- Y+")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end

			chunkIdx = ZVox.WorldToChunkIndex(univ, x + 1, y - 1, z)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X+ Y-")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end

			chunkIdx = ZVox.WorldToChunkIndex(univ, x - 1, y - 1, z)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X- Y-")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end


			-- Z-
			chunkIdx = ZVox.WorldToChunkIndex(univ, x + 1, y + 1, z - 1)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X+ Y+")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end

			chunkIdx = ZVox.WorldToChunkIndex(univ, x - 1, y + 1, z - 1)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X- Y+")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end

			chunkIdx = ZVox.WorldToChunkIndex(univ, x + 1, y - 1, z - 1)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X+ Y-")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end

			chunkIdx = ZVox.WorldToChunkIndex(univ, x - 1, y - 1, z - 1)
			chunkBorder = chunkList[chunkIdx]
			if (chunkBorder ~= nil) and chunk ~= chunkBorder then
				--print("X- Y-")
				ZVox.EmitChunkToRemesh(chunkBorder)
			end
		end
	end
end

---Fills a cube given a voxelID and a voxelstate
---@shared
---@internal
---@group internal
---@category blocks
---@param univ universe The universe to fill in
---@param x integer Start X position
---@param y integer Start Y position
---@param z integer Start Z position
---@param sX integer Size to fill in the X axis
---@param sY integer Size to fill in the Y axis
---@param sZ integer Size to fill in the Z axis
---@param voxelID integer Voxel ID to fill with
---@param voxelState integer? Voxel state to fill with
---@param noMesh boolean? Whether to skip meshing the area
function ZVox.FillCube(univ, x, y, z, sX, sY, sZ, voxelID, voxelState, noMesh)
	if SERVER then
		noMesh = true
	end

	sX = sX - 1
	sY = sY - 1
	sZ = sZ - 1

	voxelState = voxelState or 0

	local bSizeX, bSizeY, bSizeZ = ZVox.GetUniverseBlockSize(univ)
	local startX, endX = math.min(x, x + sX), math.max(x, x + sX)
	local startY, endY = math.min(y, y + sY), math.max(y, y + sY)
	local startZ, endZ = math.min(z, z + sZ), math.max(z, z + sZ)

	startX = math.Clamp(startX, 0, bSizeX - 1)
	startY = math.Clamp(startY, 0, bSizeY - 1)
	startZ = math.Clamp(startZ, 0, bSizeZ - 1)
	endX = math.Clamp(endX, 0, bSizeX - 1)
	endY = math.Clamp(endY, 0, bSizeY - 1)
	endZ = math.Clamp(endZ, 0, bSizeZ - 1)

	local affectedChunkList = {}
	local affectedChunkHashMap = {}

	local chunkList = univ["chunks"]
	local chunk
	for zC = startZ, endZ do
		for yC = startY, endY do
			for xC = startX, endX do
				if not noMesh then
					chunk = chunkList[ZVox.WorldToChunkIndex(univ, xC, yC, zC)]
					if not affectedChunkHashMap[chunk] then
						affectedChunkList[#affectedChunkList+1] = chunk
						affectedChunkHashMap[chunk] = true
					end
				end

				ZVox.SetBlockAtPos(univ, xC, yC, zC, voxelID, voxelState, true)
			end
		end
	end

	if noMesh then
		return
	end

	for i = 1, #affectedChunkList do
		local chunk = affectedChunkList[i]

		ZVox.Lighting_FullRelightChunk(chunk)
		ZVox.Culling_FullRecullChunk(chunk)
		ZVox.EmitChunkToRemesh(chunk)
	end
end

---Fills a sphere given a voxelID and a voxelstate
---@shared
---@internal
---@group internal
---@category blocks
---@param univ universe The universe to fill in
---@param x integer Start X position
---@param y integer Start Y position
---@param z integer Start Z position
---@param sX integer Size to fill in the X axis
---@param sY integer Size to fill in the Y axis
---@param sZ integer Size to fill in the Z axis
---@param voxelID integer Voxel ID to fill with
---@param voxelState integer? Voxel state to fill with
---@param noMesh boolean? Whether to skip meshing the area
function ZVox.FillSphere(univ, x, y, z, sX, sY, sZ, voxelID, voxelState, noMesh)
	if SERVER then
		noMesh = true
	end

	sX = sX - 1
	sY = sY - 1
	sZ = sZ - 1

	voxelState = voxelState or 0

	local bSizeX, bSizeY, bSizeZ = ZVox.GetUniverseBlockSize(univ)
	local startX, endX = math.min(x, x + sX), math.max(x, x + sX)
	local startY, endY = math.min(y, y + sY), math.max(y, y + sY)
	local startZ, endZ = math.min(z, z + sZ), math.max(z, z + sZ)

	startX = math.Clamp(startX, 0, bSizeX - 1)
	startY = math.Clamp(startY, 0, bSizeY - 1)
	startZ = math.Clamp(startZ, 0, bSizeZ - 1)
	endX = math.Clamp(endX, 0, bSizeX - 1)
	endY = math.Clamp(endY, 0, bSizeY - 1)
	endZ = math.Clamp(endZ, 0, bSizeZ - 1)

	local affectedChunkList = {}
	local affectedChunkHashMap = {}

	local chunkList = univ["chunks"]
	local chunk

	local dist
	local xL, yL, zL
	for zC = startZ, endZ do
		for yC = startY, endY do
			for xC = startX, endX do
				zL = (((zC - startZ) / sZ) - .5) * 2
				yL = (((yC - startY) / sY) - .5) * 2
				xL = (((xC - startX) / sX) - .5) * 2

				dist = math.sqrt(zL * zL + yL * yL + xL * xL) - 1

				if not noMesh then
					chunk = chunkList[ZVox.WorldToChunkIndex(univ, xC, yC, zC)]

					if not affectedChunkHashMap[chunk] then
						affectedChunkList[#affectedChunkList+1] = chunk
						affectedChunkHashMap[chunk] = true
					end
				end

				if dist > 0 then
					continue
				end

				ZVox.SetBlockAtPos(univ, xC, yC, zC, voxelID, voxelState, true)
			end
		end
	end

	if noMesh then
		return
	end

	for i = 1, #affectedChunkList do
		local chunk = affectedChunkList[i]

		ZVox.Lighting_FullRelightChunk(chunk)
		ZVox.Culling_FullRecullChunk(chunk)
		ZVox.EmitChunkToRemesh(chunk)
	end
end


---Replaces a cube given what to replace, a voxelID and a voxelState
---@shared
---@internal
---@group internal
---@category blocks
---@param univ universe The universe to fill in
---@param x integer Start X position
---@param y integer Start Y position
---@param z integer Start Z position
---@param sX integer Size to fill in the X axis
---@param sY integer Size to fill in the Y axis
---@param sZ integer Size to fill in the Z axis
---@param voxelIDToReplace integer Voxel ID that we should replace
---@param voxelIDToSet integer Voxel ID to fill with
---@param voxelState integer? Voxel state to fill with
---@param noMesh boolean? Whether to skip meshing the area
function ZVox.ReplaceCube(univ, x, y, z, sX, sY, sZ, voxelIDToReplace, voxelIDToSet, voxelState, noMesh)
	if SERVER then
		noMesh = true
	end

	sX = sX - 1
	sY = sY - 1
	sZ = sZ - 1

	voxelState = voxelState or 0

	local bSizeX, bSizeY, bSizeZ = ZVox.GetUniverseBlockSize(univ)
	local startX, endX = math.min(x, x + sX), math.max(x, x + sX)
	local startY, endY = math.min(y, y + sY), math.max(y, y + sY)
	local startZ, endZ = math.min(z, z + sZ), math.max(z, z + sZ)

	startX = math.Clamp(startX, 0, bSizeX - 1)
	startY = math.Clamp(startY, 0, bSizeY - 1)
	startZ = math.Clamp(startZ, 0, bSizeZ - 1)
	endX = math.Clamp(endX, 0, bSizeX - 1)
	endY = math.Clamp(endY, 0, bSizeY - 1)
	endZ = math.Clamp(endZ, 0, bSizeZ - 1)

	local affectedChunkList = {}
	local affectedChunkHashMap = {}

	local chunkList = univ["chunks"]
	local chunk
	for zC = startZ, endZ do
		for yC = startY, endY do
			for xC = startX, endX do
				if not noMesh then
					chunk = chunkList[ZVox.WorldToChunkIndex(univ, xC, yC, zC)]
					if not affectedChunkHashMap[chunk] then
						affectedChunkList[#affectedChunkList+1] = chunk
						affectedChunkHashMap[chunk] = true
					end
				end

				local oldID = ZVox.GetBlockAtPos(univ, xC, yC, zC)
				if(oldID ~= voxelIDToReplace) then
					continue
				end

				ZVox.SetBlockAtPos(univ, xC, yC, zC, voxelIDToSet, voxelState, true)
			end
		end
	end

	if noMesh then
		return
	end

	for i = 1, #affectedChunkList do
		local chunk = affectedChunkList[i]

		ZVox.Lighting_FullRelightChunk(chunk)
		ZVox.Culling_FullRecullChunk(chunk)
		ZVox.EmitChunkToRemesh(chunk)
	end
end

---Replaces a sphere given what to replace, a voxelID and a voxelState
---@shared
---@internal
---@group internal
---@category blocks
---@param univ universe The universe to fill in
---@param x integer Start X position
---@param y integer Start Y position
---@param z integer Start Z position
---@param sX integer Size to fill in the X axis
---@param sY integer Size to fill in the Y axis
---@param sZ integer Size to fill in the Z axis
---@param voxelIDToReplace integer Voxel ID that we should replace
---@param voxelIDToSet integer Voxel ID to fill with
---@param voxelState integer? Voxel state to fill with
---@param noMesh boolean? Whether to skip meshing the area
function ZVox.ReplaceSphere(univ, x, y, z, sX, sY, sZ, voxelIDToReplace, voxelIDToSet, voxelState, noMesh)
	if SERVER then
		noMesh = true
	end

	sX = sX - 1
	sY = sY - 1
	sZ = sZ - 1

	voxelState = voxelState or 0

	local bSizeX, bSizeY, bSizeZ = ZVox.GetUniverseBlockSize(univ)
	local startX, endX = math.min(x, x + sX), math.max(x, x + sX)
	local startY, endY = math.min(y, y + sY), math.max(y, y + sY)
	local startZ, endZ = math.min(z, z + sZ), math.max(z, z + sZ)

	startX = math.Clamp(startX, 0, bSizeX - 1)
	startY = math.Clamp(startY, 0, bSizeY - 1)
	startZ = math.Clamp(startZ, 0, bSizeZ - 1)
	endX = math.Clamp(endX, 0, bSizeX - 1)
	endY = math.Clamp(endY, 0, bSizeY - 1)
	endZ = math.Clamp(endZ, 0, bSizeZ - 1)

	local affectedChunkList = {}
	local affectedChunkHashMap = {}

	local chunkList = univ["chunks"]
	local chunk

	local dist
	local xL, yL, zL
	for zC = startZ, endZ do
		for yC = startY, endY do
			for xC = startX, endX do
				zL = (((zC - startZ) / sZ) - .5) * 2
				yL = (((yC - startY) / sY) - .5) * 2
				xL = (((xC - startX) / sX) - .5) * 2

				dist = math.sqrt(zL * zL + yL * yL + xL * xL) - 1

				if not noMesh then
					chunk = chunkList[ZVox.WorldToChunkIndex(univ, xC, yC, zC)]

					if not affectedChunkHashMap[chunk] then
						affectedChunkList[#affectedChunkList+1] = chunk
						affectedChunkHashMap[chunk] = true
					end
				end

				if dist > 0 then
					continue
				end

				local oldID = ZVox.GetBlockAtPos(univ, xC, yC, zC)
				if(oldID ~= voxelIDToReplace) then
					continue
				end

				ZVox.SetBlockAtPos(univ, xC, yC, zC, voxelIDToSet, voxelState, true)
			end
		end
	end

	if noMesh then
		return
	end

	for i = 1, #affectedChunkList do
		local chunk = affectedChunkList[i]

		ZVox.Lighting_FullRelightChunk(chunk)
		ZVox.Culling_FullRecullChunk(chunk)
		ZVox.EmitChunkToRemesh(chunk)
	end
end


function ZVox.ChunkPerformWorldGen(univ, chunk)
	if not univ then
		return
	end

	if not chunk then
		return
	end

	ZVox.SetChunkUniv(chunk, univ)

	local coX, coY, coZ = ZVox.ChunkIndexToWorld(univ, chunk["index"])

	local generator = univ["worldgen"]

	for i = 0, (cSizeX * cSizeY * cSizeZ) do
		local xc = (i % cSizeX) + coX
		local yc = (math_floor(i / cSizeX) % cSizeY) + coY
		local zc = (math_floor(i / cSizeConst1) % cSizeZ) + coZ


		local voxName = generator(xc, yc, zc)
		if not voxName then
			voxName = "zvox:air"
		end

		local voxID = ZVox.GetVoxelID(voxName)
		if not voxID then
			voxID = 1
		end

		chunk["voxelData"][i] = voxID
		chunk["voxelState"][i] = 0x0
	end
end

function ZVox.ChunkPerformWorldGenCustom(chunk, func)
	if not chunk then
		return
	end

	for i = 0, (cSizeX * cSizeY * cSizeZ) do
		local xc = (i % cSizeX)
		local yc = (math_floor(i / cSizeX) % cSizeY)
		local zc = (math_floor(i / cSizeConst1) % cSizeZ)


		local voxName = func(xc, yc, zc)
		if not voxName then
			voxName = "zvox:air"
		end

		local voxID = ZVox.GetVoxelID(voxName)
		if not voxID then
			voxID = 1
		end

		chunk["voxelData"][i] = voxID
		chunk["voxelState"][i] = 0x0
	end
end