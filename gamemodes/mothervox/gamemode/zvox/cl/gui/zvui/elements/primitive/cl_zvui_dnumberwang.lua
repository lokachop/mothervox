ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

local col_neutral = Color(192, 210, 230)
local col_highlight = Color(148, 186, 233)
local col_press = Color(109, 177, 255)

local col_text_disabled = Color(128, 128, 128)
local function selectorUpdateColour(self)
	if not self:IsEnabled() then
		self:SetTextStyleColor(col_text_disabled)
		self:SetCursor("no")
		return
	end
	self:SetCursor("hand")


	if self:IsDown() then
		self:SetTextStyleColor(col_press)
		return
	end

	if self:IsHovered() then
		self:SetTextStyleColor(col_highlight)
		return
	end

	self:SetTextStyleColor(col_neutral)
end


function PANEL:Init()
	self.Up.UpdateColours = selectorUpdateColour
	function self.Up:Paint(w, h)
		surface.SetDrawColor(self:GetTextStyleColor())
		ZVUI.RenderIcon("dnumberwang-up", 0, 0, 16, 16)
	end

	self.Down.UpdateColours = selectorUpdateColour
	function self.Down:Paint(w, h)
		surface.SetDrawColor(self:GetTextStyleColor())
		ZVUI.RenderIcon("dnumberwang-down", 0, 0, 16, 16)
	end
end


local textCol = Color(255, 255, 255)
function PANEL:Paint(w, h)
	surface.SetDrawColor(39, 39, 39)
	surface.DrawRect(0, 0, w, h)


	surface.SetDrawColor(48, 48, 48)
	surface.DrawRect(1, 1, w - 2, h - 2)

	local val = tostring(self:GetValue())
	ZVox.DrawRetroText(self, val, 2, 1, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2)

	if not self:HasFocus() then
		return
	end


	local CHARACTER_WIDTH = 7.4

	local caret = self:GetCaretPos()
	local subStringStart = string.sub(val, 1, caret)

	-- fake caret bs
	if math.floor((CurTime() * 4) % 2) == 1 then
		local tLen = ZVox.GetTextWidth(subStringStart, 2)


		surface.SetDrawColor(255, 255, 255)
		surface.DrawRect(2 + tLen, 2, 1, h - 4)
	end


	-- selected bs
	--surface.SetDrawColor(96, 96, 225, 96)
	local startSel, endSel = self:GetSelectedTextRange()

	local subStringSelStart = string.sub(val, 1, startSel)
	local subStringSel = string.sub(val, startSel + 1, endSel)

	local lenStart = ZVox.GetTextWidth(subStringSelStart, 2)
	local lenSel = ZVox.GetTextWidth(subStringSel, 2)


	startSel = lenStart
	endSel = lenStart + lenSel

	local selRectStart = math.min(startSel, endSel)
	local selRectW = math.abs(startSel - endSel)


	if not ZVOX_DO_UI_FASTMODE then
		render.OverrideBlend(true, BLEND_ONE_MINUS_DST_COLOR, BLEND_ZERO, BLENDFUNC_ADD)
	end
		surface.SetDrawColor(96, 96, 225, 96)
		surface.DrawRect(2 + selRectStart, 1, selRectW, h - 2)

	if not ZVOX_DO_UI_FASTMODE then
		render.OverrideBlend(false)
	end
end

vgui.Register("ZVUI_DNumberWang", PANEL, "DNumberWang")