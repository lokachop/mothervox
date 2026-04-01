ZVox = ZVox or {}
local math = math
local math_abs = math.abs
local math_floor = math.floor

local table = table
local table_sort = table.sort

local MATH_HUGE = 1 / 0
local voxInfoRegistry = ZVox.GetVoxelRegistry()

local MIN_X = 1
local MIN_Y = 2
local MIN_Z = 3

local MAX_X = 4
local MAX_Y = 5
local MAX_Z = 6


-- https://github.com/ClassiCube/ClassiCube/blob/master/src/Physics.c#L216
function ZVox.PHYSICS_SearcherCalcTime(vel, entityBB, blockBB)
	local dx = vel[1] > 0.0 and (blockBB[MIN_X] - entityBB[MAX_X]) or (entityBB[MIN_X] - blockBB[MAX_X])
	local dy = vel[2] > 0.0 and (blockBB[MIN_Y] - entityBB[MAX_Y]) or (entityBB[MIN_Y] - blockBB[MAX_Y])
	local dz = vel[3] > 0.0 and (blockBB[MIN_Z] - entityBB[MAX_Z]) or (entityBB[MIN_Z] - blockBB[MAX_Z])

	local tx, ty, tz = 0, 0, 0
	if not ((entityBB[MAX_X] >= blockBB[MIN_X]) and (entityBB[MIN_X] <= blockBB[MAX_X])) then
		tx = (vel[1] == 0.0) and MATH_HUGE or math_abs(dx / vel[1])
	end

	if not ((entityBB[MAX_Y] >= blockBB[MIN_Y]) and (entityBB[MIN_Y] <= blockBB[MAX_Y])) then
		ty = (vel[2] == 0.0) and MATH_HUGE or math_abs(dy / vel[2])
	end

	if not ((entityBB[MAX_Z] >= blockBB[MIN_Z]) and (entityBB[MIN_Z] <= blockBB[MAX_Z])) then
		tz = (vel[3] == 0.0) and MATH_HUGE or math_abs(dz / vel[3])
	end


	return tx, ty, tz
end


local function sortByTSquared(a, b)
	return a[4] < b[4]
end

local voxelBB = ZVox.PHYSICS_NewAABB()
local entityBB = ZVox.PHYSICS_NewAABB()
local entityExtentBB = ZVox.PHYSICS_NewAABB()
function ZVox.PHYSICS_SearcherFindReachableBlocks(physObj)
	local univ = physObj["univ"]
	if not univ then
		ZVox.PrintError("ZVox.PHYSICS_SearcherFindReachableBlocks, no universe!!")
		return
	end

	ZVox.PHYSICS_SetAABB(entityBB, physObj["pos"], physObj["scl"])

	local vel = physObj["vel"]
	local velX = vel[1]
	local velY = vel[2]
	local velZ = vel[3]

	entityExtentBB[MIN_X] = entityBB[MIN_X] + (velX < 0.0 and velX or 0.0)
	entityExtentBB[MIN_Y] = entityBB[MIN_Y] + (velY < 0.0 and velY or 0.0)
	entityExtentBB[MIN_Z] = entityBB[MIN_Z] + (velZ < 0.0 and velZ or 0.0)

	entityExtentBB[MAX_X] = entityBB[MAX_X] + (velX > 0.0 and velX or 0.0)
	entityExtentBB[MAX_Y] = entityBB[MAX_Y] + (velY > 0.0 and velY or 0.0)
	entityExtentBB[MAX_Z] = entityBB[MAX_Z] + (velZ > 0.0 and velZ or 0.0)

	local minX = math_floor(entityExtentBB[MIN_X])
	local minY = math_floor(entityExtentBB[MIN_Y])
	local minZ = math_floor(entityExtentBB[MIN_Z])

	local maxX = math_floor(entityExtentBB[MAX_X])
	local maxY = math_floor(entityExtentBB[MAX_Y])
	local maxZ = math_floor(entityExtentBB[MAX_Z])


	-- hax to make it solid on borders
	local univMaxX = univ["chunkSizeX"] * ZVOX_CHUNKSIZE_X
	local univMaxY = univ["chunkSizeY"] * ZVOX_CHUNKSIZE_Y


	local reachables = {}
	for z = minZ, maxZ  do
		for y = minY, maxY do
			for x = minX, maxX do
				local voxID, voxState = ZVox.GetBlockAtPos(univ, x, y, z)
				if (x >= univMaxX) or (y >= univMaxY) or (x < 0) or (y < 0) then
					voxID = 1
					voxState = 0x00
				end


				local voxelNfo = voxInfoRegistry[voxID]
				if not voxelNfo then
					continue
				end

				if not voxelNfo.solid then
					continue
				end

				local voxelAABBs = ZVox.GetVoxelAABBList(voxID, voxState)
				for i = 1, #voxelAABBs do
					local voxAABB = voxelAABBs[i]

					voxelBB[MIN_X] = voxAABB[MIN_X] + x
					voxelBB[MIN_Y] = voxAABB[MIN_Y] + y
					voxelBB[MIN_Z] = voxAABB[MIN_Z] + z

					voxelBB[MAX_X] = voxAABB[MAX_X] + x
					voxelBB[MAX_Y] = voxAABB[MAX_Y] + y
					voxelBB[MAX_Z] = voxAABB[MAX_Z] + z


					-- necessary for non whole blocks. (slabs)
					if not ZVox.PHYSICS_AABBIntersect(entityExtentBB, voxelBB) then
						continue
					end

					local tx, ty, tz = ZVox.PHYSICS_SearcherCalcTime(vel, entityBB, voxelBB)
					if (tx > 1.0 or ty > 1.0 or tz > 1.0) then
						continue
					end

					reachables[#reachables + 1] = {
						x, y, z,
						tx * tx + ty * ty + tz * tz,
						voxAABB[MIN_X], voxAABB[MIN_Y], voxAABB[MIN_Z],
						voxAABB[MAX_X], voxAABB[MAX_Y], voxAABB[MAX_Z],
					}
				end
			end
		end
	end

	table_sort(reachables, sortByTSquared)

	return reachables, entityBB, entityExtentBB
end