ZVox = ZVox or {}

local temp = Vector()
local function isKeyDown(buttonCode)
	if vgui.CursorVisible() then
		return
	end

	return ZVox.IsControlDown(buttonCode)
end

function ZVox.PlayerNoclipMove()
	local physObj = ZVox.GetPlayerPhysicsObject()

	ZVox.PHYSICS_GetPhysicsObjectVel(physObj):Zero()
	ZVox.PHYSICS_SetPhysicsObjectOnGround(physObj, false)

	local dt = ZVOX_MOVEMENT_TPS

	local moveang = LocalPlayer():EyeAngles()
	local forward = moveang:Forward()
	local right   = moveang:Right()

	local fmove, smove = 0, 0
	if isKeyDown("move_forward") then
		fmove = fmove + 1
	end
	if isKeyDown("move_backward") then
		fmove = fmove - 1
	end
	if isKeyDown("move_left") then
		smove = smove - 1
	end
	if isKeyDown("move_right") then
		smove = smove + 1
	end

	-- TODO: nuke this zynxcode
	temp:Zero()
	for i = 1, 3 do
		temp[ i ] = forward[ i ] * fmove + right[ i ] * smove
	end
	temp:Normalize()

	local upMove = 0
	if isKeyDown("move_up") then
		upMove = upMove + 1
	end
	if isKeyDown("move_down") then
		upMove = upMove - 1
	end
	temp[3] = temp[3] + upMove


	local speed = isKeyDown("move_sprint") and 25 or ZVOX_PLAYER_MAX_VEL_LENGTH
	temp:Mul(dt * speed)

	ZVox.PHYSICS_GetPhysicsObjectPos(physObj):Add(temp)
end
