ZVox = ZVox or {}
-- Frustrum culling adapted from https://raw.githubusercontent.com/NekerSqu4w/my_starfall_code/refs/heads/main/camera%20frustum%20culling.lua
-- All credits goes to https://github.com/NekerSqu4w


local PLANE_NEAR = 1
local PLANE_FAR = 2

local PLANE_LEFT = 3
local PLANE_RIGHT = 4

local PLANE_TOP = 5
local PLANE_BOTTOM = 6


local function newPlane()
	return {
		0, 0, 0, -- pos
		0, 0, 0, -- norm
		0, -- dist
	}
end

local cullPlanes = {
	[1] = newPlane(), -- near
	[2] = newPlane(), -- far

	[3] = newPlane(), -- left
	[4] = newPlane(), -- right

	[5] = newPlane(), -- top
	[6] = newPlane(), -- bottom
}

local function setPlane(idx, pos, norm)
	local plane = cullPlanes[idx]

	plane[1] = pos[1]
	plane[2] = pos[2]
	plane[3] = pos[3]

	plane[4] = norm[1]
	plane[5] = norm[2]
	plane[6] = norm[3]
end

local function setPlaneEQDistance(idx, eqDistance)
	cullPlanes[idx][7] = eqDistance
end

-- position, angle, aspect, fov, znear, zfar
function ZVox.RecomputeFrustrum()
	local camPos = ZVox.GetCamPos()
	local camAng = ZVox.GetCamAng()


	local aspect = ScrW() / ScrH()
	local FoV = ZVox.GetCamFOV()

	local zNear, zFar = ZVox.GetCamZDistances()


	local camForward = camAng:Forward()
	local camUp = camAng:Up()
	local camRight = camAng:Right()

	local tanFovHalf = math.tan(math.rad(FoV * 0.5))
	local nearPlaneHeight = tanFovHalf * zNear
	local nearPlaneWidth = nearPlaneHeight * aspect



	-- near and far Plane
	setPlane(PLANE_NEAR,
		camPos + camForward * zNear,
		camForward
	)
	setPlane(PLANE_FAR,
		camPos + camForward * zFar,
		-camForward
	)


	-- compute the frustum corners on the near plane
	local nearCenter = camPos + camForward * zNear
	local rightVec = camRight * nearPlaneWidth
	local upVec = camUp * nearPlaneHeight
	local nearTopLeft = nearCenter + upVec - rightVec
	local nearTopRight = nearCenter + upVec + rightVec
	--local nearBottomLeft = nearCenter - upVec - rightVec
	local nearBottomRight = nearCenter - upVec + rightVec

	-- right and left Planes
	setPlane(PLANE_LEFT,
		camPos,
		(nearTopLeft - camPos):Cross(camUp):GetNormalized()
	)
	setPlane(PLANE_RIGHT,
		camPos,
		camUp:Cross(nearTopRight - camPos):GetNormalized()
	)

	-- top and bottom Planes
	setPlane(PLANE_TOP,
		camPos,
		(nearTopRight - camPos):Cross(camRight):GetNormalized()
	)
	setPlane(PLANE_BOTTOM,
		camPos,
		camRight:Cross(nearBottomRight - camPos):GetNormalized()
	)

	-- pre compute all Eq distance
	for i = 1, #cullPlanes do
		local plane = cullPlanes[i]
		setPlaneEQDistance(i,(plane[4] * plane[1]) + (plane[5] * plane[2]) + (plane[6] * plane[3]))
	end
end




function ZVox.IsBoxInFrustrum(minX, minY, minZ, maxX, maxY, maxZ)
	for i = 1, #cullPlanes do
		local plane = cullPlanes[i]

		local normX, normY, normZ = plane[4], plane[5], plane[6]

		local pX = normX > 0 and maxX or minX
		local pY = normY > 0 and maxY or minY
		local pZ = normZ > 0 and maxZ or minZ

		local dist = (normX * pX) + (normY * pY) + (normZ * pZ) - plane[7]

		if dist < 0 then
			return false
		end
	end

	return true
end

-- TODO: optimize!
local cSizeX = ZVOX_CHUNKSIZE_X
local cSizeY = ZVOX_CHUNKSIZE_Y
local cSizeZ = ZVOX_CHUNKSIZE_Z
function ZVox.IsChunkInFrustrum(univ, chunkIdx)
	local wX, wY, wZ = ZVox.ChunkIndexToWorld(univ, chunkIdx) -- this is slow, we should localize it and make it faster

	return ZVox.IsBoxInFrustrum(
		wX, wY, wZ,
		wX + cSizeX, wY + cSizeY, wZ + cSizeZ
	)
end

local cullList = {}
function ZVox.ComputeCulledChunks(univ)
	local chunks = univ["chunks"]
	local chunkCount = #chunks

	for i = 0, chunkCount do
		local chunk = chunks[i]

		if not ZVox.IsChunkInFrustrum(univ, chunk["index"]) then
			cullList[i] = true
			continue
		end

		cullList[i] = false
	end
end

function ZVox.IsChunkIndexCulled(index)
	return cullList[index]
end