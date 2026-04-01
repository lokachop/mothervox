ZVox = ZVox or {}

function ZVox.IngameThink(univObj)
	if ZVox.GetGamePaused() then
		return
	end

	ZVox.CommunicationsThink()
	ZVox.Scanner_ScannerThink(univObj)
	ZVox.UpdateParticles(univObj)
	ZVox.ActionDebugThink()
	ZVox.UpdateAnimatedTextures()
	ZVox.ControlListenerThink()

	ZVox.Sound_VehicleSoundThink()

	ZVox.Fuel_PlayerFuelThink()
end

function GM:Think()
	if ZVox.GetGamePaused() then
		return
	end

	ZVox.ProgressiveSaveThink()
	ZVox.CallStateThink()
	ZVox.PlayerThink()
end

function GM:RenderScene(pos, ang, fov)
	local renderRet = ZVox.CallStateRender(pos, ang, fov)

	cam.Start2D()
		render.RenderHUD(0, 0, ScrW(), ScrH())
	cam.End2D()

	return renderRet
end

local toHide = {
	["CHudWeaponSelection"] = true,
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudCloseCaption"] = true,
	["CHudCrosshair"] = true,
}
function GM:HUDShouldDraw(elmName)
	if toHide[elmName] then
		return false
	end

	return true
end

function GM:HUDDrawTargetID()
	return false
end

local bannedRetBinds = {
	["slot1"] = true,
	["slot2"] = true,
	["slot3"] = true,
	["slot4"] = true,
	["slot5"] = true,
	["slot6"] = true,
	["slot7"] = true,
	["slot8"] = true,
	["slot9"] = true,
	["slot0"] = true,
}

function GM:PlayerBindPress(ply, bind, pressed, code)
	if ZVox.GetState() ~= ZVOX_STATE_INGAME then
		return
	end

	if not pressed then
		return
	end

	local translatedBind = input.TranslateAlias(bind)
	translatedBind = translatedBind or bind

	ZVox.HotbarSlotScroll(translatedBind)

	if bannedRetBinds[translatedBind] then
		return true
	end
end

function GM:CalcView(ply, _, _, fov)
	return ZVox.PlayerCalcView(ply, _, _, fov)
end

function GM:ShutDown()
	if ZVox.GetState() == ZVOX_STATE_INGAME then
		ZVox.MV_SaveProgress()
	end

	ZVox.CloseLogFile()
end

local nextNoEscapeMessage = 0
function GM:OnPauseMenuShow()
	if ZVox.GetState() ~= ZVOX_STATE_INGAME then
		return true
	end

	if ZVOX_JANK_CAPTURING_KEYBIND then
		ZVOX_JANK_CAPTURING_KEYBIND = false
		return false
	end

	if ZVox.GetGamePaused() then
		return false
	end

	return ZVox.OpenEscapeMenu()
end

function GM:PlayerSwitchWeapon()
	return true
end

function GM:ScoreboardShow()
end

function GM:ScoreboardHide()
end

function GM:PlayerStartVoice()
	return true
end