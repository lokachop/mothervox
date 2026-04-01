ZVox = ZVox or {}

-- We love Vector producing random hard crashes!...

local PART_INDEX_MESH = 7
local PART_INDEX_DEATH = 8

local math = math
local math_random = math.random
local math_abs = math.abs
local math_floor = math.floor

local textureRegistry = ZVox.GetTextureRegistry()
local voxelInfoRegistry = ZVox.GetVoxelRegistry()
local activeParticles = {}

local particleVariationCount = 64
ZVox.PersistentParticleMeshes = ZVox.PersistentParticleMeshes or {}
local particleMeshes = ZVox.PersistentParticleMeshes
-- pregenerate a few meshes rather than computing them each frame like LK3D
-- this just causes more pushModelMatrix
function ZVox.RecomputeParticleMeshes()
	if #particleMeshes >= particleVariationCount then
		return
	end

	for i = 1, particleVariationCount do
		if particleMeshes[i] then
			particleMeshes[i]:Destroy()
		end

		local sclScalar = .075 + (math_random() * .05)
		local scl = Vector(sclScalar, sclScalar, sclScalar)

		-- calc start uvs
		local uStart = math_random(0, 16) / 16
		local vStart = math_random(0, 16) / 16
		-- now the end uvs are those + 4

		local uEnd = uStart + .25
		local vEnd = vStart + .25


		particleMeshes[i] = ZVox.GetPlaneMeshSimple(scl, uStart, vStart, uEnd, vEnd)
	end

	ZVox.PrintInfo("Recomputed Particle meshes!")
	ZVox.PrintInfo("| mesh count is " .. tostring(particleVariationCount))
end
ZVox.RecomputeParticleMeshes()



local particleCount = 0
local function pushParticle(tex, pX, pY, pZ, vX, vY, vZ)
	if not ZVOX_DO_PARTICLES then
		return
	end

	if particleCount > ZVOX_MAX_PARTICLE_COUNT then
		return
	end

	if not activeParticles[tex] then
		activeParticles[tex] = {}
	end

	local tbl = activeParticles[tex]
	tbl[#tbl + 1] = {
		pX, pY, pZ,
		vX, vY, vZ,
		particleMeshes[math_random(1, particleVariationCount)],
		CurTime() + (1 + (math_random() * 1.1)),
	}

	particleCount = particleCount + 1
end


-- This function is a function!
-- ^- This comment is pure gold I'm never removing it ehehehehe

local vecReuse = Vector()
function ZVox.EmitVoxelBreakParticles(voxID, x, y, z)
	local voxData = voxelInfoRegistry[voxID]
	if not voxData then
		return
	end
	local tex = voxData.tex
	local partCount = 16

	x = x + .5
	y = y + .5
	z = z + .5

	local xAdd, yAdd, zAdd = 0, 0, 0
	for i = 1, partCount do
		xAdd = math_random() - .5
		yAdd = math_random() - .5
		zAdd = math_random() - .75

		vecReuse:SetUnpacked(xAdd, yAdd, math_abs(.25 + zAdd) * 4)
		vecReuse:Normalize()
		vecReuse:Mul(2 + (math_random() * .25))


		xAdd = xAdd + x
		yAdd = yAdd + y
		zAdd = zAdd + z
		pushParticle(
			tex,
			xAdd, yAdd, zAdd,
			vecReuse[1], vecReuse[2], vecReuse[3]
		)
	end
end


function ZVox.EmitLandingParticles(voxID, x, y, z, fallVel)
	local voxData = voxelInfoRegistry[voxID]
	if not voxData then
		return
	end

	fallVel = fallVel or 1

	local tex = voxData.tex

	local partCount = 12
	local xAdd, yAdd, zAdd = 0, 0, 0
	local xVel, yVel, zVel = 0, 0, 0
	local velMul
	for i = 1, partCount do
		xAdd = (math_random() - .5) * .25
		yAdd = (math_random() - .5) * .25
		zAdd = (math_random()) * .1

		velMul = fallVel + (math_random() * .25)

		xVel = (xAdd * 4) * velMul
		yVel = (yAdd * 4) * velMul
		zVel = (.2 + math_random() * .4) * velMul


		xAdd = xAdd + x
		yAdd = yAdd + y
		zAdd = zAdd + z


		pushParticle(
			tex,
			xAdd, yAdd, zAdd,
			xVel, yVel, zVel
		)
	end
end



local angReusePos = Angle()
local vecReusePos = Vector()
local vec_white = Vector(1, 1, 1)
local matrixParticle = Matrix()
matrixParticle:Identity()
local function renderParticleType(matType, particles, univObj)
	-- first we push the material...
	local texData = textureRegistry[matType]
	if not texData then
		return
	end
	render.SetMaterial(texData.mat_z)
	render.OverrideDepthEnable(true, true)
	texData.mat_z:SetVector("$color", ZVox.GetUniverseTrueWorldTint(univObj) or vec_white)


	angReusePos:SetUnpacked(ZVox.CamAng[1] + 180, ZVox.CamAng[2], ZVox.CamAng[3])

	-- clear and init angle outside the loop
	matrixParticle:Identity()
	matrixParticle:SetAngles(angReusePos)

	-- now we loop through the particles...
	for i = 1, #particles do
		local part = particles[i]
		-- then we translate it...
		vecReusePos:SetUnpacked(part[1], part[2], part[3])
		matrixParticle:SetTranslation(vecReusePos)

		-- then we render it...
		cam.PushModelMatrix(matrixParticle)
			part[PART_INDEX_MESH]:Draw()
		cam.PopModelMatrix()
	end

	texData.mat_z:SetVector("$color", vec_white)
	render.OverrideDepthEnable(false, false)

	-- Why do this?
	-- render.DrawSprite doesn't work in our case due to the cam pos being different
	-- thus it will always face the wrong way
	-- So we implement our own!
end


function ZVox.RenderParticles(univObj)
	if not ZVOX_DO_PARTICLES then
		return
	end


	for k, v in pairs(activeParticles) do
		renderParticleType(k, v, univObj)
	end
end

-- bzzzz bzz bzbzbzzzz
local gravMul = 9.807 * 2
local function updateParticleType(matType, particles, univObj)
	local toKill = {}

	local currPX, currPY, currPZ = 0, 0, 0
	local currVX, currVY, currVZ = 0, 0, 0

	local newPX, newPY, newPZ = 0, 0, 0
	for i = #particles, 1, -1 do
		local part = particles[i]
		if CurTime() > part[PART_INDEX_DEATH] then
			toKill[#toKill + 1] = i
			continue
		end


		currPX, currPY, currPZ = part[1], part[2], part[3]
		currVX, currVY, currVZ = part[4], part[5], part[6]

		currVZ = currVZ - (gravMul * FrameTime())

		if ZVOX_DO_PARTICLE_COLLISIONS then
			newPX = currPX + (currVX * FrameTime())
			newPY = currPY + (currVY * FrameTime())
			newPZ = currPZ + (currVZ * FrameTime())

			if ZVOX_DO_PARTICLE_EXPENSIVE_COLLISIONS then
				local solid = ZVox.GetPointSolid(univObj, newPX, newPY, newPZ)

				if solid then
					currVX = 0
					currVY = 0
					currVZ = 0
				end
			else
				local blockCurr = ZVox.GetBlockAtPos(univObj, math_floor(newPX), math_floor(newPY), math_floor(newPZ))

				if blockCurr ~= 0 then
					currVX = 0
					currVY = 0
					currVZ = 0
				end
			end
		end

		part[1] = currPX + (currVX * FrameTime())
		part[2] = currPY + (currVY * FrameTime())
		part[3] = currPZ + (currVZ * FrameTime())

		part[4] = currVX
		part[5] = currVY
		part[6] = currVZ
	end

	if #toKill <= 0 then
		return
	end

	-- back to front to not mess up with table.remove
	for i = 1, #toKill do
		local idx = toKill[i]
		table.remove(activeParticles[matType], idx)
		particleCount = particleCount - 1
	end
end

function ZVox.UpdateParticles(univObj)
	if not ZVOX_DO_PARTICLES then
		return
	end

	for k, v in pairs(activeParticles) do
		updateParticleType(k, v, univObj)
	end
end


function ZVox.GetActiveParticleCount()
	return particleCount
end

-- SLOW
function ZVox.ClearAllParticles()
	particleCount = 0
	activeParticles = {}
end