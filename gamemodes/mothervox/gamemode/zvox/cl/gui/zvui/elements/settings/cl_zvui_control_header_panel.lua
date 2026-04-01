ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

function PANEL:Init()
	self.title = "FIXME!! ZVUI_ControlHeaderPanel not getting title"
end

function PANEL:SetTitle(title)
	self.title = title
end

local textCol = Color(255, 255, 255)
function PANEL:Paint(w, h)
	local _, tH = draw.SimpleText(self.title, "ZVUI_UniversePanelTitleFont", w * .5, h * .5, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local hrHeight = (h * .5) + (tH * .5)
	-- draw the HR
	surface.SetDrawColor(64, 98, 138)
	surface.DrawRect(4, hrHeight, w - (4 * 2), 2)
end

vgui.Register("ZVUI_ControlHeaderPanel", PANEL, "DPanel")