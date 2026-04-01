ZVox = ZVox or {}

ZVox.ConfirmationPrompt = ZVox.ConfirmationPrompt
function ZVox.OpenConfirmationPrompt(msg, funcYes)
	if IsValid(ZVox.ConfirmationPrompt) then
		ZVox.ConfirmationPrompt:Close()
	end

	local markupGet = ZVox.ParseMarkup(msg)
	local textH = (#markupGet * 32) + 8


	ZVox.ConfirmationPrompt = vgui.Create("ZVUI_DFrame")
	ZVox.ConfirmationPrompt:SetSize(500, 48 + 64 + textH)
	ZVox.ConfirmationPrompt:Center()
	ZVox.ConfirmationPrompt:MakePopup()
	ZVox.ConfirmationPrompt:SetTitle("Confirmation")
	ZVox.ConfirmationPrompt:ShowCloseButton(true)
	ZVox.ConfirmationPrompt:SetDraggable(false)

	local pnlText = vgui.Create("DPanel", ZVox.ConfirmationPrompt)
	pnlText:SetTall(textH)
	pnlText:Dock(TOP)

	function pnlText:Paint(w, h)
		--surface.SetDrawColor(255, 0, 0)
		--surface.DrawRect(0, 0, w, h)
		ZVUI.PaintCoolSurface(self, w, h)

		ZVox.RenderMarkup(self, markupGet, 3, 4, 4)
	end

	local pnlHoldButton = vgui.Create("DPanel", ZVox.ConfirmationPrompt)
	pnlHoldButton:SetTall(64)
	pnlHoldButton:Dock(TOP)
	pnlHoldButton:DockPadding(128, 8, 128, 8)
	function pnlHoldButton:Paint(w, h)
		--surface.SetDrawColor(0, 255, 0)
		--surface.DrawRect(0, 0, w, h)
	end

	local btnYes = vgui.Create("ZVUI_DButton", pnlHoldButton)
	btnYes:SetText("Yes")
	btnYes:Dock(FILL)

	function btnYes:DoClick()
		ZVox.ConfirmationPrompt:Close()
		funcYes()
	end
end