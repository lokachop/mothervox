ZVox = ZVox or {}

local state = ZVox.NewState(ZVOX_STATE_INGAME)

local rtRender = ZVox.GetViewPortRT()
ZVox.NewSettingListener("zvox_hooks_lowres_recompute_rt", "fun_lowres_viewport", function(newState)
	rtRender = ZVox.GetViewPortRT()
end)

function state:Think()
	local univ = ZVox.GetActiveUniverse()

	ZVox.IngameThink(univ)
	ZVox.ScreenShakeThink()
end

local texturizeW = 64
local texturizeH = texturizeW * 8
local texturizeIndexHash = texturizeW .. ":" .. texturizeH
local texturizeRT = GetRenderTarget("zvox_wrongbranch_texturize_rt_" .. texturizeIndexHash, texturizeW, texturizeH)
local texturizeMat = CreateMaterial("zvox_wrongbranch_texturize_mat" .. texturizeIndexHash, "UnlitGeneric", {
	["$basetexture"] = texturizeRT:GetName(),
	["$nocull"] = 1,
	["$ignorez"] = 1,
	["$vertexcolor"] = 1,
})
ZVox.PixelFuncOnRT(texturizeRT, function(x, y)
	local xD = x / texturizeRT:Width()
	local yD = y / texturizeRT:Height()

	local xChecker = math.floor(x / 32)
	local yChecker = math.floor(y / 32)
	local yVal = (((xChecker + yChecker) % 2) == 0) and yD or 0

	return yVal * (196 + 64), yVal * (96 + 32), xD * 0
end)

function state:Render(pos, ang, fov)
	local univ = ZVox.GetActiveUniverse()

	ZVox.SetCamPos(ZVox.GetPlayerInterpolatedCamera())
	ZVox.SetCamAng(LocalPlayer():EyeAngles())

	if ZVox.GetPlayerCameraUnderwater() then
		fov = (fov - 5)
		ZVox.ViewmodelFOV = 85
	else
		ZVox.ViewmodelFOV = 90
	end

	if ZVOX_DO_MC_FOV_CALC then
		-- convert to MC FoV
		local realerFOV = fov

		local mcFOV = math.atan(4 / 3 * math.tan(math.rad(realerFOV / 2))) * 2
		ZVox.CamFOV = math.deg(mcFOV)
	else
		ZVox.CamFOV = fov
	end


	local mtx = ZVox.TransformViewportQTele()
	if mtx then
		cam.PushModelMatrix(mtx, true)
	end

	local mtx2 = ZVox.TransformViewportMTrans()
	if mtx2 then
		cam.PushModelMatrix(mtx2, true)
	end


	ZVox.PushRenderTarget(rtRender)
		-- Don't clear here, sky rendering clears for us
		--ZVox.ClearRT(0, 0, 0)
		ZVox.RenderUniverse(univ)
	ZVox.PopRenderTarget()

	ZVox.RenderFramebuffer()

	if not ZVox.GetCameraModeState() then
		ZVox.RenderCrosshair()
		ZVox.RenderUI()

		ZVox.DebugDrawInfo()
		ZVox.DebugRenderMesherPauseInfoMessage()

		ZVox.Scanner_RenderScanned()

		-- HOTBAR IS SEPARATE, DON?T RENDER IT TO THE RT!!!
		ZVox.RenderHotbar()


		ZVox.Health_RenderTakeDamage()
		ZVox.RenderExplosionFX()

		ZVox.TintViewPortQTele()
		ZVox.TintViewPortMTrans()
	end

	if ZVox.GetGamePaused() and not ZVox.GetGameTempPaused() then
		DrawTexturize(32, texturizeMat)
	end

	ZVox.RenderPauseBlur()

	if mtx then
		cam.PopModelMatrix()
	end

	if mtx2 then
		cam.PopModelMatrix()
	end

	ZVox.RenderPauseTransitionFX()

	return true
end

function state:OnEnter()
	-- TODO: fix the reset each lua refresh, this could be done by only enabling when netmessage, not on state load
	ZVox.PlayerEnable(ZVox.GetActiveUniverse())
	ZVox.SetActiveSong("sound/mothervox/music/main.ogg")

	surface.PlaySound("mothervox/sfx/mothership.wav")

	ZVox.Sound_BeginVehicleSounds()
	ZVox.UnobtainalumHumStart()
end

function state:OnExit()
	ZVox.PlayerDisable()
	ZVox.Sound_EndVehicleSounds()
	ZVox.SetActiveSong("")
end