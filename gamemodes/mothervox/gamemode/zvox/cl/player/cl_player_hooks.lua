ZVox = ZVox or {}

local function isKeyDown(buttonCode)
	if vgui.CursorVisible() then
		return
	end

	return input.IsKeyDown(buttonCode)
end


local _nullScale = Vector(1, 1, 1)
local _nullTranslate = Vector(0, 0, 0)
function ZVox.PlayerHighlightThink()
	local eyeTrace = ZVox.GetEyeTrace()


	if not ZVox.CanPlayerReach(eyeTrace["HitMapPos"]) then
		ZVox.SetVoxelHighlightShouldRender(false)
		return
	end

	if not eyeTrace.Hit then
		ZVox.SetVoxelHighlightShouldRender(false)
		return
	end

	ZVox.SetVoxelHighlightShouldRender(true)

	ZVox.SetVoxelHighlightIDState(eyeTrace.VoxelID, eyeTrace.VoxelState)

	ZVox.SetVoxelHighlightPos(eyeTrace.HitMapPos)


	local voxName = ZVox.GetVoxelName(eyeTrace["VoxelID"])
	local canDig = MOTHERVOX_ALLOWED_CAN_BREAK_BLOCKS[voxName] ~= nil
	ZVox.SetVoxelHighlightCanDig(canDig)

	local canInteract = MOTHERVOX_ALLOWED_CAN_INTERACT_BLOCKS[voxName] ~= nil
	ZVox.SetVoxelHighlightCanInteract(canInteract)
end


local moveTypeLUT = {
	[ZVOX_MOVEMENT_NOCLIP] = ZVox.PlayerNoclipMove,
	[ZVOX_MOVEMENT_WALK] = ZVox.PlayerWalkMove,
}


local tickStep = 0
function ZVox.GetPlayerTickDelta()
	return tickStep / ZVOX_MOVEMENT_TPS
end

function ZVox.PlayerMoveThink()
	local moveType = ZVox.GetPlayerForcedMovementType() or ZVox.GetPlayerMovementType()
	local moveFunc = moveTypeLUT[moveType]
	if not moveFunc then
		return
	end


	tickStep = tickStep + FrameTime()
	for i = 1, tickStep / ZVOX_MOVEMENT_TPS do
		ZVox.SetPlayerPrevPos(ZVox.GetPlayerPos())

		moveFunc()
	end
	tickStep = tickStep % ZVOX_MOVEMENT_TPS


	-- clamp it to univSize
	if ZVOX_CLAMP_PLAYER_POS then
		local plyUniv = ZVox.GetActiveUniverse()
		if not plyUniv then
			return
		end

		local bSzX = plyUniv["chunkSizeX"] * ZVOX_CHUNKSIZE_X
		local bSzY = plyUniv["chunkSizeY"] * ZVOX_CHUNKSIZE_Y

		local plyStructPos = ZVox.GetPlayerPos()

		plyStructPos[1] = math.max(math.min(plyStructPos[1], bSzX), 0)
		plyStructPos[2] = math.max(math.min(plyStructPos[2], bSzY), 0)
	end
end


function ZVox.PlayerThink()
	if not ZVox.GetPlayerActive() then
		return
	end


	ZVox.PlayerMoveThink()
	ZVox.ComputeEyeTrace()

	ZVox.PlayerHighlightThink()

	ZVox.PlayerDigThink()


	if vgui.CursorVisible() then return end

	ZVox.PlayerInteractLMB()
	ZVox.PlayerInteractMMB()
	ZVox.PlayerInteractRMB()
end

local temp = Vector()
function ZVox.PlayerCalcView(ply, _, _, fov)
	if not ZVox.GetPlayerActive() then
		return
	end

	temp:Set(ZVox.GetPlayerPos())
	temp:Mul(ZVOX_AUDIO_SOUND_SCALE)
	temp:Add(ZVOX_AUDIO_EAR_POS)

	return {
		origin = temp,
		angles = ply:EyeAngles(),
		fov = fov,
		drawviewer = false
	}
end

function ZVox.PlayerEnable(univObj)
	ZVox.ResetPlayerStruct()

	ZVox.SetPlayerUniverse(univObj or ZVox.GetActiveUniverse())
	ZVox.SetPlayerActive(true)
end

function ZVox.PlayerDisable()
	ZVox.SetPlayerActive(false)
end

ZVox.NewControlListener("dbg_noclip", "switch_noclip", function()
	if not ZVox.GetPlayerActive() then
		return
	end

	if not ZVOX_DEVMODE then
		return
	end

	local currNoclip = ZVox.GetPlayerNoclipping()

	ZVox.SetPlayerNoclipping(not currNoclip)
end)