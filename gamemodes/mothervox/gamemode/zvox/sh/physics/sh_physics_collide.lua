ZVox = ZVox or {}
local math = math
local math_floor = math.floor
local math_max = math.max
local math_min = math.min

local voxInfoRegistry = ZVox.GetVoxelRegistry()
local COLLISIONS_ADJ = 1e-5

local MIN_X = 1
local MIN_Y = 2
local MIN_Z = 3

local MAX_X = 4
local MAX_Y = 5
local MAX_Z = 6

local function clipX(physObj, sizeX, entityBB, extentBB)
	physObj.vel[1] = 0.0

	entityBB[MIN_X] = physObj.pos[1] - sizeX / 2
	extentBB[MIN_X] = entityBB[MIN_X]

	entityBB[MAX_X] = physObj.pos[1] + sizeX / 2
	extentBB[MAX_X] = entityBB[MAX_X]
end

local function clipY(physObj, sizeY, entityBB, extentBB)
	physObj.vel[2] = 0.0

	entityBB[MIN_Y] = physObj.pos[2] - sizeY / 2
	extentBB[MIN_Y] = entityBB[MIN_Y]

	entityBB[MAX_Y] = physObj.pos[2] + sizeY / 2
	extentBB[MAX_Y] = entityBB[MAX_Y]
end

local function clipZ(physObj, sizeZ, entityBB, extentBB)
	physObj.vel[3] = 0.0

	entityBB[MIN_Z] = physObj.pos[3]
	extentBB[MIN_Z] = entityBB[MIN_Z]

	entityBB[MAX_Z] = physObj.pos[3] + sizeZ
	extentBB[MAX_Z] = entityBB[MAX_Z]
end


local blockBBCanSlide = ZVox.PHYSICS_NewAABB()
local function canSlideThrough(adjFinalBB, univ)
	local minX = math_floor(adjFinalBB[MIN_X])
	local minY = math_floor(adjFinalBB[MIN_Y])
	local minZ = math_floor(adjFinalBB[MIN_Z])

	local maxX = math_floor(adjFinalBB[MAX_X])
	local maxY = math_floor(adjFinalBB[MAX_Y])
	local maxZ = math_floor(adjFinalBB[MAX_Z])

	local voxID, voxState
	local aabbs
	local aabb
	for z = minZ, maxZ do
		for y = minY, maxY do
			for x = minX, maxX do
				voxID, voxState = ZVox.GetBlockAtPos(univ, x, y, z)
				aabbs = ZVox.GetVoxelAABBList(voxID, voxState)

				for i = 1, #aabbs do
					aabb = aabbs[i]

					blockBBCanSlide[MIN_X] = aabb[1] + x
					blockBBCanSlide[MIN_Y] = aabb[2] + y
					blockBBCanSlide[MIN_Z] = aabb[3] + z

					blockBBCanSlide[MAX_X] = aabb[4] + x
					blockBBCanSlide[MAX_Y] = aabb[5] + y
					blockBBCanSlide[MAX_Z] = aabb[6] + z

					if not ZVox.PHYSICS_AABBIntersect(blockBBCanSlide, adjFinalBB) then
						continue
					end

					local voxelNfo = voxInfoRegistry[voxID]
					if voxelNfo.solid then
						return false
					end
				end
			end
		end
	end

	return true
end

local adjBBDidSlide = ZVox.PHYSICS_NewAABB()
local function didSlide(physObj, blockBB, sizeX, sizeY, sizeZ, finalBB, entityBB, extentBB)
	local zDist = blockBB[MAX_Z] - entityBB[MIN_Z]

	if (zDist > 0.0) and (zDist <= (physObj.stepSize + 0.01)) then
		local blockBB_MinX = math_max(blockBB[MIN_X], blockBB[MAX_X] - sizeX / 2)
		local blockBB_MaxX = math_min(blockBB[MAX_X], blockBB[MIN_X] + sizeX / 2)

		local blockBB_MinY = math_max(blockBB[MIN_Y], blockBB[MAX_Y] - sizeY / 2)
		local blockBB_MaxY = math_min(blockBB[MAX_Y], blockBB[MIN_Y] + sizeY / 2)


		adjBBDidSlide[MIN_X] = math_min(finalBB[MIN_X], blockBB_MinX + COLLISIONS_ADJ)
		adjBBDidSlide[MAX_X] = math_max(finalBB[MAX_X], blockBB_MaxX - COLLISIONS_ADJ)

		adjBBDidSlide[MIN_Y] = math_min(finalBB[MIN_Y], blockBB_MinY + COLLISIONS_ADJ)
		adjBBDidSlide[MAX_Y] = math_max(finalBB[MAX_Y], blockBB_MaxY - COLLISIONS_ADJ)

		adjBBDidSlide[MIN_Z] = blockBB[MAX_Z] + COLLISIONS_ADJ
		adjBBDidSlide[MAX_Z] = adjBBDidSlide[MIN_Z] + sizeZ

		if not canSlideThrough(adjBBDidSlide, physObj.univ) then
			return false
		end

		physObj.pos[3] = adjBBDidSlide[MIN_Z]
		physObj.onGround = true

		clipZ(physObj, sizeZ, entityBB, extentBB)
		return true
	end

	return false
end

local function clipXMin(physObj, blockBB, entityBB, wasOn, finalBB, extentBB, sizeX, sizeY, sizeZ)
	if (not wasOn) or (not didSlide(physObj, blockBB, sizeX, sizeY, sizeZ, finalBB, entityBB, extentBB)) then
		physObj.pos[1] = blockBB[MIN_X] - sizeX / 2 - COLLISIONS_ADJ
		clipX(physObj, sizeX, entityBB, extentBB)

		physObj.hitXMin = true
	end
end
local function clipXMax(physObj, blockBB, entityBB, wasOn, finalBB, extentBB, sizeX, sizeY, sizeZ)
	if (not wasOn) or (not didSlide(physObj, blockBB, sizeX, sizeY, sizeZ, finalBB, entityBB, extentBB)) then
		physObj.pos[1] = blockBB[MAX_X] + sizeX / 2 + COLLISIONS_ADJ
		clipX(physObj, sizeX, entityBB, extentBB)

		physObj.hitXMax = true
	end
end


local function clipYMin(physObj, blockBB, entityBB, wasOn, finalBB, extentBB, sizeX, sizeY, sizeZ)
	if (not wasOn) or (not didSlide(physObj, blockBB, sizeX, sizeY, sizeZ, finalBB, entityBB, extentBB)) then
		physObj.pos[2] = blockBB[MIN_Y] - sizeY / 2 - COLLISIONS_ADJ
		clipY(physObj, sizeY, entityBB, extentBB)

		physObj.hitYMin = true
	end
end
local function clipYMax(physObj, blockBB, entityBB, wasOn, finalBB, extentBB, sizeX, sizeY, sizeZ)
	if (not wasOn) or (not didSlide(physObj, blockBB, sizeX, sizeY, sizeZ, finalBB, entityBB, extentBB)) then
		physObj.pos[2] = blockBB[MAX_Y] + sizeY / 2 + COLLISIONS_ADJ
		clipY(physObj, sizeY, entityBB, extentBB)

		physObj.hitYMax = true
	end
end


local function clipZMin(physObj, blockBB, entityBB, extentBB, sizeZ)
	physObj.pos[3] = blockBB[MIN_Z] - sizeZ - COLLISIONS_ADJ
	physObj.hitZMin = true

	clipZ(physObj, sizeZ, entityBB, extentBB)
end
local function clipZMax(physObj, blockBB, entityBB, extentBB, sizeZ)
	physObj.onGround = true
	physObj.hitZMax = true

	physObj.pos[3] = blockBB[MAX_Z] + COLLISIONS_ADJ
	clipZ(physObj, sizeZ, entityBB, extentBB)
end


local blockBB = ZVox.PHYSICS_NewAABB()
local finalBB = ZVox.PHYSICS_NewAABB()
local function collideWithReachableBlocks(physObj, searcherResults, entityBB, entityExtentBB)
	-- store the prev state for later
	local wasOn = physObj["onGround"]

	-- reset the collision state of the physobj
	physObj["onGround"] = false

	physObj["hitXMin"] = false
	physObj["hitYMin"] = false
	physObj["hitZMin"] = false

	physObj["hitXMax"] = false
	physObj["hitYMax"] = false
	physObj["hitZMax"] = false


	local physObjVel = physObj["vel"]

	local blockX, blockY, blockZ
	local collideX, collideY, collideZ
	local sizeX, sizeY, sizeZ = physObj["scl"]:Unpack()
	for i = 1, #searcherResults do
		local result = searcherResults[i]

		blockX = result[1]
		blockY = result[2]
		blockZ = result[3]

		-- basically AABB:Set(resultAABB + blockPos)
		blockBB[MIN_X] = result[ 5] + blockX
		blockBB[MIN_Y] = result[ 6] + blockY
		blockBB[MIN_Z] = result[ 7] + blockZ

		blockBB[MAX_X] = result[ 8] + blockX
		blockBB[MAX_Y] = result[ 9] + blockY
		blockBB[MAX_Z] = result[10] + blockZ

		if not ZVox.PHYSICS_AABBIntersect(entityExtentBB, blockBB) then -- if we're not hitting it, skip it
			continue
		end

		local tx, ty, tz = ZVox.PHYSICS_SearcherCalcTime(physObjVel, entityBB, blockBB)
		if (tx > 1.0 or ty > 1.0 or tz > 1.0) then
			ZVox.PrintFatal("[ClassiCube phys] t > 1 in physics calculation.. this shouldn't have happened.")
		end

		collideX = physObjVel[1] * tx
		collideY = physObjVel[2] * ty
		collideZ = physObjVel[3] * tz

		finalBB[MIN_X] = entityBB[MIN_X] + collideX
		finalBB[MIN_Y] = entityBB[MIN_Y] + collideY
		finalBB[MIN_Z] = entityBB[MIN_Z] + collideZ

		finalBB[MAX_X] = entityBB[MAX_X] + collideX
		finalBB[MAX_Y] = entityBB[MAX_Y] + collideY
		finalBB[MAX_Z] = entityBB[MAX_Z] + collideZ

		-- if we have hit the bottom of a block, we need to change the axis we test first
		if not physObj.hitZMin then
			if (finalBB[MIN_Z] + COLLISIONS_ADJ) >= blockBB[MAX_Z] then
				clipZMax(physObj, blockBB, entityBB, entityExtentBB, sizeZ)
			elseif (finalBB[MAX_Z] - COLLISIONS_ADJ) <= blockBB[MIN_Z] then
				clipZMin(physObj, blockBB, entityBB, entityExtentBB, sizeZ)
			elseif (finalBB[MIN_X] + COLLISIONS_ADJ) >= blockBB[MAX_X] then
				clipXMax(physObj, blockBB, entityBB, wasOn, finalBB, entityExtentBB, sizeX, sizeY, sizeZ)
			elseif (finalBB[MAX_X] - COLLISIONS_ADJ) <= blockBB[MIN_X] then
				clipXMin(physObj, blockBB, entityBB, wasOn, finalBB, entityExtentBB, sizeX, sizeY, sizeZ)
			elseif (finalBB[MIN_Y] + COLLISIONS_ADJ) >= blockBB[MAX_Y] then
				clipYMax(physObj, blockBB, entityBB, wasOn, finalBB, entityExtentBB, sizeX, sizeY, sizeZ)
			elseif (finalBB[MAX_Y] - COLLISIONS_ADJ) <= blockBB[MIN_Y] then
				clipYMin(physObj, blockBB, entityBB, wasOn, finalBB, entityExtentBB, sizeX, sizeY, sizeZ)
			end
		else
			-- if flying or falling, test the horizontal axes first
			if finalBB[MIN_X] + COLLISIONS_ADJ >= blockBB[MAX_X] then
				clipXMax(physObj, blockBB, entityBB, wasOn, finalBB, entityExtentBB, sizeX, sizeY, sizeZ)
			elseif finalBB[MAX_X] - COLLISIONS_ADJ <= blockBB[MIN_X] then
				clipXMin(physObj, blockBB, entityBB, wasOn, finalBB, entityExtentBB, sizeX, sizeY, sizeZ)
			elseif finalBB[MIN_Y] + COLLISIONS_ADJ >= blockBB[MAX_Y] then
				clipYMax(physObj, blockBB, entityBB, wasOn, finalBB, entityExtentBB, sizeX, sizeY, sizeZ)
			elseif finalBB[MAX_Y] - COLLISIONS_ADJ <= blockBB[MIN_Y] then
				clipYMin(physObj, blockBB, entityBB, wasOn, finalBB, entityExtentBB, sizeX, sizeY, sizeZ)
			elseif finalBB[MIN_Z] + COLLISIONS_ADJ >= blockBB[MAX_Z] then
				clipZMax(physObj, blockBB, entityBB, entityExtentBB, sizeZ)
			elseif finalBB[MAX_Z] - COLLISIONS_ADJ <= blockBB[MIN_Z] then
				clipZMin(physObj, blockBB, entityBB, entityExtentBB, sizeZ)
			end
		end

	end
end

local lastSearcherResults
function ZVox.PHYSICS_MoveAndWallSlide(physObj)
	if physObj["vel"]:Length() == 0 then
		return
	end

	local searcherResults, entityBB, entityExtentBB = ZVox.PHYSICS_SearcherFindReachableBlocks(physObj)
	lastSearcherResults = searcherResults

	collideWithReachableBlocks(physObj, searcherResults, entityBB, entityExtentBB)
end

-- used for debug collision mode
function ZVox.PHYSICS_GetLastCollisionSearcherResults()
	return lastSearcherResults
end