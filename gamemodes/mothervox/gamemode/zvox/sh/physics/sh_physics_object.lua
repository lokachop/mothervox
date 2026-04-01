ZVox = ZVox or {}

local noParams = {}
function ZVox.PHYSICS_NewPhysicsObject(params)
	params = params or noParams

	return {
		["pos"] = params.pos or Vector(0, 0, 0),
		["scl"] = params.scl or Vector(.5, .5, .5),
		["vel"] = params.vel or Vector(0, 0, 0),

		["stepSize"] = params.stepSize or 0,

		["onGround"] = false,
		["univ"] = nil,

		["hitXMin"] = false,
		["hitXMax"] = false,

		["hitYMin"] = false,
		["hitYMax"] = false,

		["hitZMin"] = false,
		["hitZMax"] = false,
	}
end

function ZVox.PHYSICS_SetPhysicsObjectUniverse(physObj, univ)
	physObj["univ"] = univ
end
function ZVox.PHYSICS_GetPhysicsObjectUniverse(physObj)
	return physObj["univ"]
end


function ZVox.PHYSICS_SetPhysicsObjectPos(physObj, pos)
	physObj["pos"]:Set(pos)
end

---Gets the position of the physics object
---@shared
---@internal
---@group internal
---@category physobject
---@return Vector pos pos of the physobj
function ZVox.PHYSICS_GetPhysicsObjectPos(physObj)
	return physObj["pos"]
end


function ZVox.PHYSICS_SetPhysicsObjectScl(physObj, scl)
	physObj["scl"]:Set(scl)
end
function ZVox.PHYSICS_GetPhysicsObjectScl(physObj)
	return physObj["scl"]
end


function ZVox.PHYSICS_SetPhysicsObjectVel(physObj, vel)
	physObj["vel"]:Set(vel)
end
function ZVox.PHYSICS_GetPhysicsObjectVel(physObj)
	return physObj["vel"]
end

function ZVox.PHYSICS_SetPhysicsObjectStepSize(physObj, stepSize)
	physObj["stepSize"] = stepSize
end
function ZVox.PHYSICS_GetPhysicsObjectStepSize(physObj)
	return physObj["stepSize"]
end

function ZVox.PHYSICS_SetPhysicsObjectOnGround(physObj, onGround)
	physObj["onGround"] = onGround
end
function ZVox.PHYSICS_GetPhysicsObjectOnGround(physObj)
	return physObj["onGround"]
end

function ZVox.PHYSICS_GetPhysicsObjectHit(physObj)
	return
		physObj["hitXMin"] or
		physObj["hitXMax"] or

		physObj["hitYMin"] or
		physObj["hitYMax"] or

		physObj["hitZMin"] or
		physObj["hitZMax"]
end