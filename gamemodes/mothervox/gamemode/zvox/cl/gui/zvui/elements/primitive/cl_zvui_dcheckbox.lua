ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}


local colours_enabled = {
	["neutral"] = Color(64, 138, 64),
	["highlight"] = Color(92, 176, 92),
	["press"] = Color(120, 214, 120)
}

local colours_disabled = {
	["neutral"] = Color(138, 64, 64),
	["highlight"] = Color(176, 92, 92),
	["press"] = Color(214, 120, 120)
}

local col_disabled = Color(64, 64, 64)
local col_text_disabled = Color(128, 128, 128)
local col_text_enabled = Color(255, 255, 255)
function PANEL:Init()
	self:SetSize(16, 16)
	self:SetText("")

	self._checked = false
	self._changeCallback = nil

	self._buttonColour = Color(255, 0, 0)
	self.m_colText = ""
	self._textColour = col_text_enabled
end

function PANEL:SetChangeCallback(callback)
	self._changeCallback = callback
end

function PANEL:SetChecked(state)
	self._checked = state

	self:UpdateColours()
end

function PANEL:GetChecked()
	return self._checked
end

function PANEL:DoClick()
	self._checked = not self._checked

	if self._changeCallback then
		self._changeCallback()
	end

	self:UpdateColours()
end

function PANEL:UpdateColours()
	if not self:IsEnabled() then
		self._buttonColour = col_disabled
		self:SetTextStyleColor(col_text_disabled)
		self:SetCursor("no")
		return
	end
	self:SetTextStyleColor(col_text_enabled)
	self:SetCursor("hand")


	local targetColTable = self._checked and colours_enabled or colours_disabled

	if self:IsDown() then
		self._buttonColour = targetColTable.press
		return
	end

	if self:IsHovered() then
		self._buttonColour = targetColTable.highlight
		return
	end

	self._buttonColour = targetColTable.neutral
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(39, 39, 39)
	surface.DrawRect(0, 0, w, h)


	surface.SetDrawColor(self._buttonColour)
	surface.DrawRect(1, 1, w - 2, h - 2)

	local cX, cY = (w * .5) - 8, (h * .5) - 8
	surface.SetDrawColor(self._textColour)

	ZVUI.RenderIcon(self._checked and "checkbox-on" or "checkbox-off", cX, cY, 16, 16)
end

vgui.Register("ZVUI_DCheckBox", PANEL, "DButton")