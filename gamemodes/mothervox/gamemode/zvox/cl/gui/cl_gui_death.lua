ZVox = ZVox or {}

ZVox.DeathFrame = ZVox.DeathFrame
function ZVox.OpenDeathGUI()
	if IsValid(ZVox.DeathFrame) then
		ZVox.DeathFrame:Close()
	end


	ZVox.DeathFrame = vgui.Create("ZVUI_DFrame")
	ZVox.DeathFrame:SetSize(300, 200)
	ZVox.DeathFrame:Center()
	ZVox.DeathFrame:MakePopup()
	ZVox.DeathFrame:SetTitle("You died!")
	ZVox.DeathFrame:ShowCloseButton(false)
	ZVox.DeathFrame:SetDraggable(false)


	local btnContinue = vgui.Create("ZVUI_DButton", ZVox.DeathFrame)
	btnContinue:Dock(FILL)
	btnContinue:SetText("Continue")
	function btnContinue:DoClick()
		ZVox.MV_SaveProgress()
		net.Start("mothervox_save_world")
		net.SendToServer()

		ZVox.SetActiveSong("")
		ZVox.DecrementPauseStack()
		ZVox.SetState(ZVOX_STATE_MAINMENU)
		ZVox.SetPlayerVel(Vector(0, 0, 0))

		ZVox.DeathFrame:Close()
	end

end