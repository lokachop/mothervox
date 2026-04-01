ZVox = ZVox or {}
local voxInfoRegistry = ZVox.GetVoxelRegistry()


local plyPrevX, plyPrevY, plyPrevZ = 0, 0, 0
local digTX, digTY, digTZ = 0, 0, 0
local digVoxName = ""
local digDidBreak = false
local isDigging = false
local digEnd = 0
local digLen = 0
function ZVox.PlayerDigThink()
	if not isDigging then
		return
	end

	local digDelta = 1 - ((digEnd - CurTime()) / digLen)
	digDelta = math.min(math.max(digDelta, 0), 1)

	if digDelta >= 1 then
		isDigging = false
		 ZVox.Sound_EndDigSound()
		return
	end

	if digDidBreak == false and digDelta > .25 then
		digDidBreak = true

		local noBreak = ZVox.CallVoxelOnDig(digVoxName)

		if not noBreak then
			local act = ZVox.NewAction("zvox:break")
			act:SetUniverseName(ZVox.GetActiveUniverse()["name"])

			act:SetPosition(digTX, digTY, digTZ)

			ZVox.CL_ExecuteAction(act)
			ZVox.CL_SendAction(act)
		end
	end


	local newPlyX = Lerp(digDelta, plyPrevX, (digTX + .5))
	local newPlyY = Lerp(digDelta, plyPrevY, (digTY + .5))
	local newPlyZ = Lerp(digDelta, plyPrevZ, (digTZ))

	ZVox.SetPlayerPos(Vector(newPlyX, newPlyY, newPlyZ))
	ZVox.SetPlayerVel(Vector(0, 0, 0))
	ZVox.SetPlayerGrounded(true)
end

function ZVox.IsPlayerDigging()
	return isDigging
end

function ZVox.PlayerBeginDig(x, y, z, voxID)
	if isDigging then
		return
	end

	digVoxName = ZVox.GetVoxelName(voxID)

	local drillWait = ZVox.Upgrades_GetDrillTimeWait()
	local zMul = ZVox.GetPlayerInterpolatedPos()[3]
	zMul = math.min(zMul, 990)
	zMul = zMul / 990
	zMul = 1 - zMul

	zMul = math.ease.InCirc(zMul)

	local drillSpeed = Lerp(zMul, drillWait, 0.75)

	digLen = drillSpeed
	digEnd = CurTime() + digLen

	ZVox.DoScreenShake(math.min(24 * digLen, 8), digLen)

	isDigging = true
	digDidBreak = false

	plyPrevX, plyPrevY, plyPrevZ = ZVox.GetPlayerInterpolatedPos():Unpack()
	digTX, digTY, digTZ = x, y, z
	ZVox.Sound_BeginDigSound()
end


local plyBoundsAABB = ZVox.PHYSICS_NewAABB()
local voxelAABBCopy = ZVox.PHYSICS_NewAABB()
function ZVox.CanPlaceVoxelAtPos(voxID, x, y, z, isAirOverride)
	local prevBlock = ZVox.GetBlockAtPos(ZVox.GetActiveUniverse(), x, y, z)
	if prevBlock ~= 0 and (not isAirOverride) then
		return false
	end

	local physObj = ZVox.GetPlayerPhysicsObject()
	ZVox.PHYSICS_SetAABB(plyBoundsAABB, ZVox.PHYSICS_GetPhysicsObjectPos(physObj), ZVox.PHYSICS_GetPhysicsObjectScl(physObj))

	local aabbList = ZVox.GetVoxelAABBList(voxID, 0)
	for i = 1, #aabbList do
		local voxelAABB = aabbList[i]

		voxelAABBCopy[1] = voxelAABB[1] + x
		voxelAABBCopy[2] = voxelAABB[2] + y
		voxelAABBCopy[3] = voxelAABB[3] + z

		voxelAABBCopy[4] = voxelAABB[4] + x
		voxelAABBCopy[5] = voxelAABB[5] + y
		voxelAABBCopy[6] = voxelAABB[6] + z

		if ZVox.PHYSICS_AABBIntersect(voxelAABBCopy, plyBoundsAABB) then
			return false
		end
	end

	return true
end

function ZVox.CanPlayerReach(hitMapPos)
	local moveType = ZVox.GetPlayerMovementType()

	if moveType == ZVOX_MOVEMENT_NOCLIP then
		return true
	else
		if not ZVox.GetPlayerGrounded() then
			return false
		end

		local plyMapPos = ZVox.GetPlayerInterpolatedPos() * 1
		plyMapPos[1] = math.floor(plyMapPos[1])
		plyMapPos[2] = math.floor(plyMapPos[2])
		plyMapPos[3] = math.floor(plyMapPos[3])

		if plyMapPos[3] < hitMapPos[3] then
			return false
		end

		local dist = hitMapPos:DistToSqr(plyMapPos)
		return dist <= 1
	end
end

function ZVox.CanPlayerBreakBlock(voxID)
	local moveType = ZVox.GetPlayerMovementType()

	if moveType == ZVOX_MOVEMENT_NOCLIP then
		return true
	else
		local voxName = ZVox.GetVoxelName(voxID)

		return MOTHERVOX_ALLOWED_CAN_BREAK_BLOCKS[voxName] ~= nil
	end
end

function ZVox.GetMoveTypePlayerReach()
	local moveType = ZVox.GetPlayerMovementType()

	if moveType == ZVOX_MOVEMENT_NOCLIP then
		return math.huge
	else
		return ZVox.GetPlayerReach()
	end
end

local function onLeftClick()
	local eyeTrace = ZVox.GetEyeTrace()

	if isDigging then
		return false
	end

	if not eyeTrace.Hit then
		return false
	end

	if not ZVox.CanPlayerReach(eyeTrace["HitMapPos"]) then
		return false
	end

	if not ZVox.CanPlayerBreakBlock(eyeTrace["VoxelID"]) then
		surface.PlaySound("mothervox/sfx/dig/no_dig.wav")
		return true
	end

	local moveType = ZVox.GetPlayerMovementType()

	if moveType == ZVOX_MOVEMENT_NOCLIP then
		local newBlockPos = eyeTrace.HitMapPos

		ZVox.PushMessageToLogFile("onLeftClick(), l166")
		local act = ZVox.NewAction("zvox:break")
		ZVox.PushMessageToLogFile("onLeftClick(), l168")
		act:SetUniverseName(ZVox.GetActiveUniverse()["name"])

		ZVox.PushMessageToLogFile("onLeftClick(), l171")
		act:SetPosition(newBlockPos[1], newBlockPos[2], newBlockPos[3])

		ZVox.PushMessageToLogFile("onLeftClick(), l174")
		ZVox.CL_ExecuteAction(act)
		ZVox.PushMessageToLogFile("onLeftClick(), l176")
		ZVox.CL_SendAction(act)
	else
		local newBlockPos = eyeTrace.HitMapPos

		ZVox.PlayerBeginDig(newBlockPos[1], newBlockPos[2], newBlockPos[3], eyeTrace["VoxelID"])
	end
	return true
end

local function onMiddleClick()
	local moveType = ZVox.GetPlayerMovementType()
	if moveType ~= ZVOX_MOVEMENT_NOCLIP then
		return
	end

	local eyeTrace = ZVox.GetEyeTrace()

	if not eyeTrace.Hit then
		return false
	end

	if not ZVox.CanPlayerReach(eyeTrace["HitMapPos"]) then
		return false
	end

	ZVox.SwitchToBlockAtHotbarID(eyeTrace.VoxelID)
	return true
end


local function oldPlace()
	local eyeTrace = ZVox.GetEyeTrace()

	if not eyeTrace.Hit then
		return false
	end

	if not ZVox.CanPlayerReach(eyeTrace["HitMapPos"]) then
		return false
	end

	local blockName = ZVox.GetSelectedVoxelName()
	local voxID = ZVox.GetVoxelID(blockName)


	local checkOverride = false
	local newBlockPos = eyeTrace.HitMapPos + eyeTrace.Normal
	local voxStateType = ZVox.GetVoxelStateType(voxID)
	if voxStateType ~= VOXELSTATE_TYPE_NONE then
		local doOverride, overrideBlockName = ZVox.CallVoxelStatePlaceOverride(voxStateType, voxID)

		if doOverride then
			newBlockPos = eyeTrace.HitMapPos
			checkOverride = true
		end

		if overrideBlockName then
			blockName = overrideBlockName
			voxID = ZVox.GetVoxelID(overrideBlockName)
			voxStateType = ZVox.GetVoxelStateType(voxID)
		end
	end

	local voxelState = 0x0
	if voxStateType ~= VOXELSTATE_TYPE_NONE then
		voxelState = ZVox.CallVoxelStateOnPlace(voxStateType, newBlockPos[1], newBlockPos[2], newBlockPos[3]) or 0x0
	end

	local otherID, otherState = ZVox.GetBlockAtPos(ZVox.GetActiveUniverse(), newBlockPos[1], newBlockPos[2], newBlockPos[3])
	if not checkOverride and voxStateType ~= VOXELSTATE_TYPE_NONE then
		local doOverride, overrideBlockName = ZVox.CallVoxelStatePlaceOverrideReplacer(voxStateType, voxID, voxelState, otherID, otherState)

		if doOverride then
			checkOverride = true
		end

		if overrideBlockName then
			blockName = overrideBlockName
			voxID = ZVox.GetVoxelID(overrideBlockName)
			voxStateType = ZVox.GetVoxelStateType(voxID)
			voxelState = 0x0
		end
	end


	local noclipping = ZVox.GetPlayerNoclipping()
	if (not noclipping) and (not ZVox.CanPlaceVoxelAtPos(voxID, newBlockPos[1], newBlockPos[2], newBlockPos[3], checkOverride)) then
		return false
	end

	ZVox.SetVMPlaceAnim()

	local act = ZVox.NewAction("zvox:place")
	act:SetUniverseName(ZVox.GetActiveUniverse()["name"])

	act:SetPosition(newBlockPos[1], newBlockPos[2], newBlockPos[3])
	act:SetVoxelID(voxID)
	act:SetVoxelState(voxelState)


	ZVox.CL_ExecuteAction(act) -- run for fake fake prediction
	ZVox.CL_SendAction(act)

	return true
end


local function onRightClick()
	local moveType = ZVox.GetPlayerMovementType()
	if moveType == ZVOX_MOVEMENT_NOCLIP then
		return oldPlace()
	end

	-- interact

	local eyeTrace = ZVox.GetEyeTrace()

	if not eyeTrace.Hit then
		return false
	end

	if not ZVox.CanPlayerReach(eyeTrace["HitMapPos"]) then
		return false
	end

	local voxName = ZVox.GetVoxelName(eyeTrace["VoxelID"])
	return ZVox.CallVoxelOnInteract(voxName)
end




local _flagRegistry = {}
local function flagged(mouseButton)
	local down = input.IsMouseDown(mouseButton)

	if not _flagRegistry[mouseButton] then
		_flagRegistry[mouseButton] = 0
	end


	local entry = _flagRegistry[mouseButton] > CurTime()

	if not entry and down then
		return true
	end

	if entry and not down then
		_flagRegistry[mouseButton] = 0
		return false
	end

	return false
end

local function flag_write(mouseButton, bool)
	if not bool then
		return
	end

	_flagRegistry[mouseButton] = CurTime() + ZVox.GetPlayerInteractionDelay()
end

function ZVox.PlayerInteractLMB()
	if flagged(MOUSE_LEFT) then
		flag_write(MOUSE_LEFT, onLeftClick())
	end
end

function ZVox.PlayerInteractMMB()
	if flagged(MOUSE_MIDDLE) then
		flag_write(MOUSE_MIDDLE, onMiddleClick())
	end
end

function ZVox.PlayerInteractRMB()
	if flagged(MOUSE_RIGHT) then
		flag_write(MOUSE_RIGHT, onRightClick())
	end
end