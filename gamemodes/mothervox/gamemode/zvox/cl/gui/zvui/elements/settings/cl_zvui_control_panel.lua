ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

function PANEL:Init()
	self.even = false

	self.title = "BUG! ZVUI_ControlPanel not getting title"
	self.entryName = "none"

	self.btnChange = vgui.Create("ZVUI_DButton", self)
	self.btnChange:SetText("BUG, no :SetEntry()")
	self.btnChange:SetSize(196, 24)
	self.btnChange:SetTextFont("ZVUI_FrameTitleFont")


	function self.btnChange.DoClick(btnChange)
		if btnChange.changing then
			ZVOX_JANK_CAPTURING_KEYBIND = false
			btnChange.changing = false
			self:UpdateButtonLabel()
			return
		end

		btnChange.changing = true
		ZVOX_JANK_CAPTURING_KEYBIND = true

		btnChange:SetColourSkinName("semiscary")
		btnChange:SetText("Press a key")
	end

	function self.btnChange.Think(btnChange)
		if not btnChange.changing then
			return
		end

		local keyDown = ZVox.GetButtonDown()
		if not keyDown then
			return
		end

		if keyDown == KEY_ESCAPE then
			keyDown = 0
		end

		btnChange.changing = false
		ZVOX_JANK_CAPTURING_KEYBIND = false

		local entryName = self.entryName
		ZVox.RebindControl(entryName, keyDown)
		self:UpdateButtonLabel()
		ZVox.JANK_ReloadConflictingControlLabels()
	end


	self.btnReset = vgui.Create("ZVUI_DButton", self)
	self.btnReset:SetText("")
	self.btnReset:SetTooltip("Reset to default")
	self.btnReset:SetSize(24, 24)

	self.btnReset:SetImage("refresh")
	self.btnReset:SetImageScale(1)
	self.btnReset:SetImageFilter(TEXFILTER.POINT)

	function self.btnReset.DoClick(btnReset)
		local entryName = self.entryName
		local entry = ZVox.GetControlEntryByName(entryName)
		if not entry then
			ZVox.PrintError("Attempt to reset key for invalid entry \"" .. tostring(entryName) .. "\"")
			return
		end

		local defaultKey = entry.defaultKey
		ZVox.RebindControl(entryName, defaultKey)
		self:UpdateButtonLabel()
		ZVox.JANK_ReloadConflictingControlLabels()
	end
end

function PANEL:PerformLayout(w, h)
	self.btnChange:SetPos(w - 196 - 24 - 16, (h * .5) - 12)

	self.btnReset:SetPos(w - 24 - 8, (h * .5) - 12)
end

function PANEL:SetEven(even)
	self.even = even
end

function PANEL:SetEntry(entry)
	if not entry then
		return
	end

	self.title = entry.fancyName
	self.entryName = entry.name

	self:UpdateButtonLabel()
end

function PANEL:UpdateButtonLabel()
	local name = self.entryName
	local entry = ZVox.GetControlEntryByName(name)
	if not entry then
		ZVox.PrintError("Got a nil entry when calling ZVUI_ControlPanel:UpdateButtonLabel()!")
		return
	end

	local key = entry.key
	if not key then
		key = 0
	end
	self.btnChange:SetText(ZVox.GetButtonNiceName(key))


	local conflict = ZVox.IsControlConflicting(name)
	if conflict then
		self.btnChange:SetColourSkinName("scary")
	else
		self.btnChange:SetColourSkinName("standard")
	end
end


local textCol = Color(255, 255, 255)
function PANEL:Paint(w, h)
	if self.even then
		surface.SetDrawColor(255, 255, 255, 1)
		surface.DrawRect(4, 0, w - 8, h)
	end


	local _, tH = draw.SimpleText(self.title, "ZVUI_UniversePanelTitleFont", 8, h * .5, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("ZVUI_ControlPanel", PANEL, "DPanel")