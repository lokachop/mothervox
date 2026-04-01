ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

function PANEL:Init()
	self._prevHovered = false
	self._hoverStart = 0

	self._text = ""
	self:SetText("")
end

function PANEL:SetMsg(msg)
	self._text = msg
end

function PANEL:Think()
	if not self._prevHovered and self:IsHovered() then
		self._hoverStart = CurTime()
		self._prevHovered = true
	end

	if self._prevHovered and not self:IsHovered() then
		self._prevHovered = false
	end
end

surface.CreateFont("FuckassMenuFont", {
	font		= "Roboto",
	size		= 60,
	weight		= 2000,
	extended	= true
})

local colB1 = Color(81, 234, 76)
local colG1 = Color(79, 231, 72)
local colG2 = Color(79, 139, 72)
local colG3 = Color(79, 200, 72)
function PANEL:Paint(w, h)

	local hovered = self:IsHovered()
	if hovered then
		local delta = (CurTime() - self._hoverStart) / 0.1
		delta = math.min(delta, 1)

		local boxTall = delta * h

		surface.SetDrawColor(81, 234, 76, 255)
		surface.DrawRect(32, (h / 2) - (boxTall / 2), w - 64, boxTall)
	end

	draw.SimpleText(self._text, "FuckassMenuFont", (w * .5) + 4, (h * .5) + 4, hovered and colG3 or colG2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(self._text, "FuckassMenuFont", w * .5, h * .5, hovered and colG2 or colG1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("MotherVox_DButton", PANEL, "DButton")