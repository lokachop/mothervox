ZVox = ZVox or {}
local voxInfoRegistry = ZVox.GetVoxelRegistry()

local function isKeyDown(buttonCode)
	if vgui.CursorVisible() then
		return
	end

	return ZVox.IsControlDown(buttonCode)
end


local function length2D(vec)
	return math.sqrt(vec[1] * vec[1] + vec[2] * vec[2])
end


local function takeFallDamage(zVel)
	zVel = math.min(zVel, 0)
	if zVel >= 0 then
		return
	end

	if zVel > -9 then
		return
	end

	local dmgDelta = math.abs(zVel) - 9
	dmgDelta = dmgDelta * 1.2

	ZVox.PrintDebug("Fall damage; " .. tostring(dmgDelta))
	ZVox.Health_TakeDamage(dmgDelta)
	surface.PlaySound("mothervox/sfx/vehicle/hit_short.wav")
end


local _angRot = Angle()
local _vecMove = Vector()
function ZVox.PlayerWalkMove()
	local physObj = ZVox.GetPlayerPhysicsObject()
	local dt = ZVOX_MOVEMENT_TPS

	local grounded = ZVox.PHYSICS_GetPhysicsObjectOnGround(physObj)
	local speedMul = ZVox.GetPlayerSpeedMul()

	local vel = ZVox.PHYSICS_GetPhysicsObjectVel(physObj)
	-- first we lerp vel towards zero
	if grounded then
		vel[1] = Lerp(dt * ZVOX_PLAYER_SLOW_MUL, vel[1], 0)
		vel[2] = Lerp(dt * ZVOX_PLAYER_SLOW_MUL, vel[2], 0)
	else
		vel[1] = Lerp(dt * ZVOX_PLAYER_SLOW_MUL_AIR, vel[1], 0)
		vel[2] = Lerp(dt * ZVOX_PLAYER_SLOW_MUL_AIR, vel[2], 0)
	end

	-- then we add the move keys but first we normalize
	local fMove, sMove = 0, 0
	if isKeyDown("move_forward") then
		fMove = fMove + 1
	end
	if isKeyDown("move_backward") then
		fMove = fMove - 1
	end
	if isKeyDown("move_left") then
		sMove = sMove + 1
	end
	if isKeyDown("move_right") then
		sMove = sMove - 1
	end

	_vecMove:SetUnpacked(fMove, sMove, 0)
	_vecMove:Normalize()

	local eye = LocalPlayer():EyeAngles()
	_angRot:SetUnpacked(0, eye[2], 0)
	_vecMove:Rotate(_angRot)

	if grounded then
		vel[1] = vel[1] + _vecMove[1] * (ZVOX_PLAYER_WALK_SPEED_MUL * speedMul) * dt
		vel[2] = vel[2] + _vecMove[2] * (ZVOX_PLAYER_WALK_SPEED_MUL * speedMul) * dt
	else
		vel[1] = vel[1] + _vecMove[1] * (ZVOX_PLAYER_WALK_SPEED_MUL_AIR * speedMul) * dt
		vel[2] = vel[2] + _vecMove[2] * (ZVOX_PLAYER_WALK_SPEED_MUL_AIR * speedMul) * dt
	end

	local vel2DLength = length2D(vel)
	local velTarget = (ZVOX_PLAYER_MAX_VEL_LENGTH * speedMul)


	if vel2DLength > velTarget then -- going too fast! slow us down...
		local overMax = vel2DLength / velTarget

		vel[1] = vel[1] / overMax
		vel[2] = vel[2] / overMax
	end


	-- now handle gravity
	--if not grounded then
	vel[3] = vel[3] - (ZVox.GetPlayerGravity() * dt)

	-- terminal velocity clamp
	vel[3] = math.max(vel[3], -14.25)
	vel[3] = math.min(vel[3], 12)

	-- jumping
	if isKeyDown("move_up") then
		if ZVox.PHYSICS_GetPhysicsObjectOnGround(physObj) then -- slab fix
			local pos = ZVox.PHYSICS_GetPhysicsObjectPos(physObj)
			pos[3] = pos[3] + .005
		end

		vel[3] = vel[3] + (ZVox.GetPlayerJumpPower() * dt)
		ZVox.PHYSICS_SetPhysicsObjectOnGround(physObj, false)
	end

	local prevZVel = vel[3]

	vel:Mul(dt)

		ZVox.PHYSICS_MoveAndWallSlide(physObj)
		ZVox.PHYSICS_GetPhysicsObjectPos(physObj):Add(vel)

	vel:Div(dt)

	local newGrounded = ZVox.PHYSICS_GetPhysicsObjectOnGround(physObj)
	if not grounded and newGrounded then
		takeFallDamage(prevZVel)
	end


	if grounded ~= newGrounded then
		ZVox.Sound_TrySwitchPropellerState(newGrounded)
	end
end
