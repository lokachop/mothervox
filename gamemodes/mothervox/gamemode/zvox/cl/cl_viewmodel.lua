ZVox = ZVox or {}


local meshCubeVM = ZVox.GetVoxelMesh(25, Vector(0, 0, 0), Vector(.4, .4, .4))
local voxelInfoRegistry = ZVox.GetVoxelRegistry()
function ZVox.RecomputeViewmodel()
	local voxID = ZVox.GetSelectedVoxelID()

	ZVox.PrintDebug("Recomputing VM...")
	ZVox.PrintDebug("[#" .. voxID .. "](" .. voxelInfoRegistry[voxID]["name"] .. ")")

	if meshCubeVM then
		meshCubeVM:Destroy()
	end

	meshCubeVM = ZVox.GetVoxelMesh(voxID, Vector(0, 0, 0), Vector(.4, .4, .4))
end


local noBlockSwitch = false
local targetAnim = "none"
local animStart = 0
local animLen = 0
local function doAnimLength(len)
	if noBlockSwitch then
		noBlockSwitch = false
	end

	animStart = CurTime()
	animLen = len
end

local function getAnimDelta()
	return (CurTime() - animStart) / animLen
end

local function setNoBlockSwitch(bool)
	noBlockSwitch = bool
end


function ZVox.SetVMPlaceAnim()
	targetAnim = "place"
	doAnimLength(.15)
end

function ZVox.SetVMBreakAnim()
	targetAnim = "break"
	doAnimLength(.35)
end

function ZVox.SetVMBlockSwitchAnim()
	ZVox.RecomputeViewmodel()

	targetAnim = "switch"
	doAnimLength(.3)
	setNoBlockSwitch(true)
end



local _pi = math.pi
local animCallbacks = {
	["none"] = function(matrixBlock)
		matrixBlock:Translate(Vector(1.5, -.85, -.95))
		matrixBlock:Rotate(Angle(0, 135, 0))
	end,
	["place"] = function(matrixBlock)
		local delta = getAnimDelta()

		local addZ = delta * 1

		matrixBlock:Translate(Vector(1.5, -.85, -1.95 + addZ))
		matrixBlock:Rotate(Angle(0, 135, 0))
	end,
	["switch"] = function(matrixBlock)
		local delta = getAnimDelta()

		if delta >= .5 and noBlockSwitch then
			setNoBlockSwitch(false)
		end

		local addZ
		if delta < .5 then
			addZ = -delta * 2
		else
			local t_delta = delta - .5

			addZ = -1 + (t_delta * 2)
		end

		matrixBlock:Translate(Vector(1.5, -.85, -.95 + addZ))
		matrixBlock:Rotate(Angle(0, 135, 0))
	end,
	["break"] = function(matrixBlock) -- https://github.com/ClassiCube/ClassiCube/wiki/Dig-animation-details
		local delta = getAnimDelta()

		local sinHalfCircle = math.sin(delta * _pi)
		local sqrtLerpPI  = math.sqrt(delta) * _pi
		local sinHalfCircleWeird = math.sin(delta * delta * _pi)


		local xOff = math.sin(sqrtLerpPI) * 0.4
		local yOff = math.sin(sqrtLerpPI * 2) * 0.2
		local zOff = sinHalfCircle * 0.2


		matrixBlock:Translate(Vector(1.5, -.85, -.95))

		matrixBlock:Translate(Vector(zOff, xOff, yOff))

		local yRot = math.sin(sqrtLerpPI) * 80
		local xRot = -sinHalfCircleWeird * 20

		matrixBlock:Rotate(Angle(yRot, 0, 0))
		matrixBlock:Rotate(Angle(0, xRot, 0))

		matrixBlock:Rotate(Angle(0, 135, 0))
	end,
}

function ZVox.PerformVMPlaceAnim()
end

local matrixCenter = Matrix()
matrixCenter:Identity()
local texAtlas =  ZVox.GetTextureAtlasMat()
local prevID = -999
function ZVox.RenderViewmodel(univObj)
	if ZVox.GetCameraModeState() then
		return
	end

	if ZVox.GetPlayerMovementType() ~= ZVOX_MOVEMENT_NOCLIP then
		return
	end

	-- TODO: change when we have a block switch callback
	local currVoxID = ZVox.GetSelectedVoxelID()

	if not noBlockSwitch and prevID ~= currVoxID then
		ZVox.RecomputeViewmodel()

		prevID = currVoxID
	end

	ZVox.ClearRTDepth()

	matrixCenter:Identity()

	if targetAnim ~= "none" then
		local delta = getAnimDelta()
		if delta > 1 then
			noBlockSwitch = false
			targetAnim = "none"
		end
	end

	local fine, err = pcall(animCallbacks[targetAnim], matrixCenter)
	if not fine then
		if ZVox.PrintLevel <= PRINTLEVEL_DEBUG then
			ZVox.PrintError("Anim error for VM anim \"" .. tostring(targetAnim) .. "\"!")
			ErrorNoHaltWithStack(err)
		end

		-- we reset to idle in case of error
		matrixCenter:Identity()
		matrixCenter:Translate(Vector(1.5, -.85, -.95))
		matrixCenter:Rotate(Angle(0, -45, 0))
	end

	render.OverrideDepthEnable(true, true)
	cam.PushModelMatrix(matrixCenter)
		render.SetMaterial(texAtlas)
		if meshCubeVM then
			meshCubeVM:Draw()
		end
	cam.PopModelMatrix()
	render.OverrideDepthEnable(false, false)

end