ZVox = ZVox or {}

local math = math
local math_floor = math.floor
local math_min = math.min
local math_abs = math.abs
local math_max = math.max

local SIDE_X = 0
local SIDE_Y = 1
local SIDE_Z = 2

local cSizeX = ZVOX_CHUNKSIZE_X
local cSizeY = ZVOX_CHUNKSIZE_Y
local cSizeZ = ZVOX_CHUNKSIZE_Z
local cSizeConst1 = ZVOX_CHUNKSIZE_X * ZVOX_CHUNKSIZE_Y

-- Returns our own TraceResult-Like format
-- 
-- 1:1 parity should come with FutureMesher since voxelstate models and aabbs will be handled differently...
-- TODO: fix normals with non full aabbs
-- FutureMesher here, we have parity!

local aabbHitPosOverride = Vector(0, 0, 0)
local aabbHitNormOverride = Vector(0, 0, 1)
local aabbHitDistOverride = math.huge

local _tempPos = Vector(0, 0, 0)
local _tempAABB = {
	Vector(0, 0, 0),
	Vector(0, 0, 0)
}


local _dirFracVec = Vector(0, 0, 0)
local _dirVec = Vector(0, 0, 0)
function ZVox.SetRayAABBDirFract(dir)
	_dirVec:Set(dir)

	_dirFracVec:SetUnpacked(
		1 / dir[1],
		1 / dir[2],
		1 / dir[3]
	)
end

function ZVox.RayAABB(pos, aabb)
	local t1 = (aabb[1][1] - pos[1]) * _dirFracVec[1]
	local t2 = (aabb[2][1] - pos[1]) * _dirFracVec[1]
	local t3 = (aabb[1][2] - pos[2]) * _dirFracVec[2]
	local t4 = (aabb[2][2] - pos[2]) * _dirFracVec[2]
	local t5 = (aabb[1][3] - pos[3]) * _dirFracVec[3]
	local t6 = (aabb[2][3] - pos[3]) * _dirFracVec[3]

	local tmin = math_max(math_max(math_min(t1, t2), math_min(t3, t4)), math_min(t5, t6))
	local tmax = math_min(math_min(math_max(t1, t2), math_max(t3, t4)), math_max(t5, t6))

	-- ray is intersecting AABB, but whole AABB is behind us
	if tmax < 0 then
		return false
	end

	-- ray does not intersect AABB
	if tmin > tmax then
		return false
	end

	-- Return collision point and distance from ray origin
	return pos + _dirVec * tmin, tmin
end



local _tempNormalObj = Vector(0, 0, 0)
function ZVox.RaycastWorld(univ, pos, dir, steps, killOOB, groupMask)
	local univSzX = (univ.chunkSizeX * cSizeX)
	local univSzY = (univ.chunkSizeY * cSizeY)
	local univSzZ = (univ.chunkSizeZ * cSizeZ)

	local posX = pos[1]
	local posY = pos[2]
	local posZ = pos[3]

	local mapX = math_floor(posX)
	local mapY = math_floor(posY)
	local mapZ = math_floor(posZ)

	local rayDirX = dir[1]
	local rayDirY = dir[2]
	local rayDirZ = dir[3]


	local sideDistX = 0
	local sideDistY = 0
	local sideDistZ = 0

	local deltaDistX = math_abs(1 / rayDirX)
	local deltaDistY = math_abs(1 / rayDirY)
	local deltaDistZ = math_abs(1 / rayDirZ)
	local perpWallDist = 0

	local stepX = 0
	local stepY = 0
	local stepZ = 0

	local hit = false
	local side = 0

	if rayDirX < 0 then
		stepX = -1
		sideDistX = (posX - mapX) * deltaDistX
	else
		stepX = 1
		sideDistX = (mapX + 1.0 - posX) * deltaDistX
	end

	if rayDirY < 0 then
		stepY = -1
		sideDistY = (posY - mapY) * deltaDistY
	else
		stepY = 1
		sideDistY = (mapY + 1.0 - posY) * deltaDistY
	end

	if rayDirZ < 0 then
		stepZ = -1
		sideDistZ = (posZ - mapZ) * deltaDistZ
	else
		stepZ = 1
		sideDistZ = (mapZ + 1.0 - posZ) * deltaDistZ
	end

	--if CLIENT then
	ZVox.SetRayAABBDirFract(dir)
	aabbHitDistOverride = math.huge
	--end

	local initial = true

	local hadAABB = false

	local voxID = 0
	local voxState = 0x0
	for i = 1, (steps or 32) do
		if not initial then -- hack to get the initial raycast hitting stuff inside of us
			if sideDistX < sideDistY then
				if sideDistX < sideDistZ then
					sideDistX = sideDistX + deltaDistX
					mapX = mapX + stepX
					side = SIDE_X
				else
					sideDistZ = sideDistZ + deltaDistZ
					mapZ = mapZ + stepZ
					side = SIDE_Z
				end
			else
				if sideDistY < sideDistZ then
					sideDistY = sideDistY + deltaDistY
					mapY = mapY + stepY
					side = SIDE_Y
				else
					sideDistZ = sideDistZ + deltaDistZ
					mapZ = mapZ + stepZ
					side = SIDE_Z
				end
			end
		end

		if killOOB then
			if mapX < 0 or mapX > univSzX then
				break
			end
			if mapY < 0 or mapY > univSzY then
				break
			end
			if mapZ < 0 or mapZ > univSzZ then
				break
			end
		end

		initial = false

		local cont, state = ZVox.GetBlockAtPos(univ, mapX, mapY, mapZ)
		if not cont then
			continue
		end

		if cont == 0 then
			continue
		end

		if groupMask then
			local voxelGroup = ZVox.GetVoxelCollisionGroup(cont)
			if bit.band(groupMask, voxelGroup) == 0 then
				continue
			end
		end

		local aabbEntries = ZVox.GetVoxelAABBList(cont, state)
		-- if we're client, check if we falsely hit something like a slab
		if aabbEntries then

			local aabbHit = false
			-- for each of the sub AABBs cast a ray
			for j = 1, #aabbEntries do
				local aabbEntry = aabbEntries[j]

				_tempPos:SetUnpacked(posX, posY, posZ)

				local minX = aabbEntry[1]
				local minY = aabbEntry[2]
				local minZ = aabbEntry[3]

				local maxX = aabbEntry[4]
				local maxY = aabbEntry[5]
				local maxZ = aabbEntry[6]

				local aabbMinX = (minX + mapX)
				local aabbMinY = (minY + mapY)
				local aabbMinZ = (minZ + mapZ)

				local aabbMaxX = (maxX + mapX)
				local aabbMaxY = (maxY + mapY)
				local aabbMaxZ = (maxZ + mapZ)

				_tempAABB[1]:SetUnpacked(aabbMinX, aabbMinY, aabbMinZ)
				_tempAABB[2]:SetUnpacked(aabbMaxX, aabbMaxY, aabbMaxZ)

				local hitPos, dist = ZVox.RayAABB(_tempPos, _tempAABB)

				if not hitPos then
					continue
				end

				if dist > aabbHitDistOverride then
					continue
				end

				aabbHitNormOverride:SetUnpacked(0, 0, 0)

				local aabbCx = maxX - minX
				local aabbCy = maxY - minY
				local aabbCz = maxZ - minZ

				local posCx = ((hitPos[1] - minX - mapX) / aabbCx)
				local posCy = ((hitPos[2] - minY - mapY) / aabbCy)
				local posCz = ((hitPos[3] - minZ - mapZ) / aabbCz)

				posCx = (posCx - .5) * 2
				posCy = (posCy - .5) * 2
				posCz = (posCz - .5) * 2

				-- calc normal
				local aCx = math_abs(posCx)
				local aCy = math_abs(posCy)
				local aCz = math_abs(posCz)

				if aCz > aCx then
					if aCz > aCy then
						aabbHitNormOverride[3] = posCz < 0 and -1 or 1
						side = SIDE_Z
					else
						aabbHitNormOverride[2] = posCy < 0 and -1 or 1
						side = SIDE_Y
					end
				else
					if aCx > aCy then
						aabbHitNormOverride[1] = posCx < 0 and -1 or 1
						side = SIDE_X
					else
						aabbHitNormOverride[2] = posCy < 0 and -1 or 1
						side = SIDE_Y
					end
				end

				aabbHitPosOverride = hitPos
				aabbHitDistOverride = dist
				hadAABB = true
				aabbHit = true
			end

			if not aabbHit then
				continue
			end
		end


		voxID = cont
		voxState = state
		hit = true
		break
	end


	if side == SIDE_X then
		perpWallDist = sideDistX - deltaDistX
		_tempNormalObj:SetUnpacked(-stepX, 0, 0)
	elseif side == SIDE_Y then
		perpWallDist = sideDistY - deltaDistY
		_tempNormalObj:SetUnpacked(0, -stepY, 0)
	else
		perpWallDist = sideDistZ - deltaDistZ
		_tempNormalObj[3] = -stepZ
		_tempNormalObj:SetUnpacked(0, 0, -stepZ)
	end

	local normal = hadAABB and aabbHitNormOverride or _tempNormalObj

	local posHit = hadAABB and aabbHitPosOverride or pos + (dir * perpWallDist)
	local mapPos = Vector(mapX, mapY, mapZ)

	return {
		["Hit"]  = hit,
		["Side"] = side,
		["Dist"] = hadAABB and math_min(aabbHitDistOverride, perpWallDist) or perpWallDist,
		["HitPos"] = posHit,
		["Normal"] = normal,
		["VoxelID"] = voxID,
		["VoxelState"] = voxState,
		["HitMapPos"] = mapPos,
	}
end