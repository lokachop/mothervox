ZVox = ZVox or {}


ZVox.PersistentPlayerStruct = ZVox.PersistentPlayerStruct
local playerStruct = {
	["active"] = false,

	-- visual
	["eyeOffset"] = Vector(0, 0, .5),

	-- physobj
	["physObj"] = ZVox.PHYSICS_NewPhysicsObject({
		["pos"] = Vector(48.5, 64.5, 64),
		["scl"] = Vector(.6, .6, .6),
		["stepSize"] = 0.5,
	}),

	["prevPos"] = Vector(48.5, 64.5, 64),

	-- physic, movement
	["gravity"] = 20,
	["jumpPower"] = 54,
	["speedMul"] = 1,

	["forcedMovementType"] = nil,
	["noclipping"] = false,
	["flying"] = false,

	["reach"] = ZVOX_DEFAULT_PLAYER_REACH,
	["interactionDelay"] = 0.1
}

if ZVox.PersistentPlayerStruct then
	playerStruct = ZVox.PersistentPlayerStruct
end

ZVox.PersistentPlayerStruct = playerStruct

function ZVox.ResetPlayerStruct()
	playerStruct["eyeOffset"]:SetUnpacked(0, 0, .5)

	local physObj = playerStruct["physObj"]
	ZVox.PHYSICS_SetPhysicsObjectPos(physObj, Vector(48.5, 64.5, 64)) -- TODO: make these not vector objects
	ZVox.PHYSICS_SetPhysicsObjectScl(physObj, Vector(.6, .6, .6))
	ZVox.PHYSICS_SetPhysicsObjectVel(physObj, Vector(0, 0, 0))

	ZVox.PHYSICS_SetPhysicsObjectStepSize(physObj, 0.5)
	ZVox.PHYSICS_SetPhysicsObjectOnGround(physObj, false)

	playerStruct["prevPos"] = Vector(48.5, 64.5, 64)

	playerStruct["gravity"] = 20
	playerStruct["jumpPower"] = 54
	playerStruct["speedMul"] = 1

	playerStruct["forcedMovementType"] = nil
	playerStruct["noclipping"] = false
	playerStruct["flying"] = false

	playerStruct["reach"] = ZVOX_DEFAULT_PLAYER_REACH
	playerStruct["interactionDelay"] = 0.1
end

function ZVox.GetPlayerStruct()
	return playerStruct
end

function ZVox.GetPlayerPhysicsObject()
	return playerStruct["physObj"]
end

function ZVox.GetPlayerActive()
	return playerStruct.active
end

function ZVox.SetPlayerActive(active)
	playerStruct.active = active
end


function ZVox.GetPlayerEyeOffset()
	return playerStruct.eyeOffset
end

function ZVox.SetPlayerEyeOffset(eyeOffset)
	playerStruct.eyeOffset:Set(eyeOffset)
end

function ZVox.SetPlayerUniverse(univ)
	local physObj = playerStruct["physObj"]
	ZVox.PHYSICS_SetPhysicsObjectUniverse(physObj, univ)

	local spawn = ZVox.GetUniverseSpawnPoint(univ)
	ZVox.PHYSICS_SetPhysicsObjectPos(physObj, spawn)

	playerStruct["prevPos"]:Set(spawn)
end


function ZVox.GetPlayerPos()
	local physObj = playerStruct["physObj"]

	return ZVox.PHYSICS_GetPhysicsObjectPos(physObj)
end

function ZVox.SetPlayerPos(pos)
	local physObj = playerStruct["physObj"]

	ZVox.PHYSICS_SetPhysicsObjectPos(physObj, pos)
	playerStruct["prevPos"]:Set(pos)
end


function ZVox.GetPlayerPrevPos()
	return playerStruct["prevPos"]
end

function ZVox.SetPlayerPrevPos(pos)
	playerStruct["prevPos"]:Set(pos)
end


function ZVox.GetPlayerVel()
	local physObj = playerStruct["physObj"]

	return ZVox.PHYSICS_GetPhysicsObjectVel(physObj)
end

function ZVox.SetPlayerVel(vel)
	local physObj = playerStruct["physObj"]

	ZVox.PHYSICS_SetPhysicsObjectVel(physObj, vel)
end


function ZVox.GetPlayerGrounded()
	local physObj = playerStruct["physObj"]

	return ZVox.PHYSICS_GetPhysicsObjectOnGround(physObj)
end

function ZVox.SetPlayerGrounded(grounded)
	local physObj = playerStruct["physObj"]

	ZVox.PHYSICS_SetPhysicsObjectOnGround(physObj, grounded)
end


function ZVox.GetPlayerForcedMovementType()
	return playerStruct.forcedMovementType
end

function ZVox.SetPlayerForcedMovementType(moveType)
	playerStruct.forcedMovementType = moveType
end

function ZVox.SetPlayerNoclipping(bool)
	playerStruct.noclipping = bool
end

function ZVox.GetPlayerNoclipping()
	return playerStruct.noclipping
end

function ZVox.SetPlayerFlying(bool)
	playerStruct.flying = bool
end

function ZVox.GetPlayerFlying()
	return playerStruct.flying
end


function ZVox.GetPlayerChunkIndex()
	local plyPos = ZVox.GetPlayerPos()
	local chunkIdx = ZVox.WorldToChunkIndex(ZVox.GetActiveUniverse(), plyPos[1], plyPos[2], plyPos[3])

	return chunkIdx
end

function ZVox.GetPlayerReach()
	return playerStruct.reach
end

function ZVox.SetPlayerReach(newReach)
	playerStruct.reach = newReach
end

function ZVox.GetPlayerInteractionDelay()
	return playerStruct.interactionDelay
end

function ZVox.SetPlayerInteractionDelay(newInteractionDelay)
	playerStruct.interactionDelay = newInteractionDelay
end

function ZVox.GetPlayerMovementType()
	if ZVox.GetPlayerNoclipping() then
		return ZVOX_MOVEMENT_NOCLIP
	end

	return ZVOX_MOVEMENT_WALK
end

function ZVox.GetPlayerGravity()
	return playerStruct.gravity
end

function ZVox.SetPlayerGravity(grav)
	playerStruct.gravity = grav
end

function ZVox.GetPlayerJumpPower()
	return playerStruct.jumpPower
end

function ZVox.SetPlayerJumpPower(power)
	playerStruct.jumpPower = power
end

function ZVox.GetPlayerSpeedMul()
	return playerStruct.speedMul
end

function ZVox.SetPlayerSpeedMul(speed)
	playerStruct.speedMul = speed
end

function ZVox.GetPlayerInterpolatedPos()
	local plyPos = ZVox.GetPlayerPrevPos()
	local plyPosNext = ZVox.GetPlayerPos()

	local lerpOut = LerpVector(ZVox.GetPlayerTickDelta(), plyPos, plyPosNext)
	return lerpOut
end

function ZVox.GetPlayerInterpolatedCamera()
	return ZVox.GetPlayerInterpolatedPos() + ZVox.GetPlayerEyeOffset()
end

function ZVox.GetPlayerCameraUnderwater()
	local camPos = ZVox.CamPos

	local voxID, voxState = ZVox.GetBlockAtPos(ZVox.GetActiveUniverse(), math.floor(camPos[1]), math.floor(camPos[2]), math.floor(camPos[3] + (1.5 / 16)))
	if not voxID then
		return false
	end

	if voxID == 0 then
		return false
	end

	local collGroup = ZVox.GetVoxelCollisionGroup(voxID)
	if collGroup ~= ZVOX_COLLISION_GROUP_WATER then
		return false
	end

	return true
end