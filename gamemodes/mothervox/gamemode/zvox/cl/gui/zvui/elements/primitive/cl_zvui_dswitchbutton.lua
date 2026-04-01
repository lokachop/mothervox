ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

local ANIM_TIME = 0.3

local col_neutral = Color(64, 98, 138)
local col_highlight = Color(92, 131, 176)
function PANEL:Init()
	self:SetSize(256, 64)
	self._upperFunc = function() end
	self._lowerFunc = function() end

	-- anim
	self._selectIndex = 1
	self._selectIndexOld = 2
	self._selectTime = 0
	self._selectAnimate = false


	self.btnUpper = vgui.Create("DButton", self)
	local bUpper = self.btnUpper
	bUpper:SetSize(256 - 8, 28)
	bUpper:SetPos(4, 4)

	bUpper.m_colText = ""
	bUpper._text = "Upper Option"
	bUpper._textFont = "DermaDefault"
	bUpper._textColour = Color(255, 255, 255)
	function bUpper:Paint(w, h)
		draw.SimpleText(self._text, self._textFont, w * .5, (h * .5) - 1, self._textColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function bUpper.DoClick()
		local doPress = self:beginAnimate(1)

		if doPress and self._upperFunc then
			self._upperFunc()
		end
	end



	self.btnLower = vgui.Create("DButton", self)
	local bLower = self.btnLower
	bLower:SetSize(256 - 8, 28)
	bLower:SetPos(4, 56 - 4)

	bLower.m_colText = ""
	bLower._text = "Lower Option"
	bLower._textFont = "DermaDefault"
	bLower._textColour = Color(255, 255, 255)
	function bLower:Paint(w, h)
		draw.SimpleText(self._text, self._textFont, w * .5, (h * .5) - 1, self._textColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function bLower.DoClick()
		local doPress = self:beginAnimate(2)

		if doPress and self._lowerFunc then
			self._lowerFunc()
		end
	end
end

function PANEL:beginAnimate(targetSrc)
	local newSrc = self._selectIndex

	if targetSrc == newSrc then
		return false
	end

	self._selectIndexOld = newSrc
	self._selectIndex = targetSrc

	self._selectTime = CurTime()
	self._selectAnimate = true

	return true
end

function PANEL:Think()
	if not self._selectAnimate then
		return
	end

	local delta = (CurTime() - self._selectTime) / ANIM_TIME
	delta = math.min(delta, 1)

	if delta >= 1 then
		self._selectAnimate = false
	end
end


function PANEL:PerformLayout(w, h)
	local hSub = h - 8
	local hSubHalf = hSub * .5

	local bUpper = self.btnUpper
	bUpper:SetSize(w - 8, hSubHalf)
	bUpper:SetPos(4, 4)

	local bLower = self.btnLower
	bLower:SetSize(w - 8, hSubHalf)
	bLower:SetPos(4, h - 4 - hSubHalf)
end

function PANEL:SetUpperActionName(name)
	local bUpper = self.btnUpper
	bUpper._text = name
end

function PANEL:SetUpperActionCallFunc(func)
	self._upperFunc = func
end

function PANEL:SetLowerActionName(name)
	local bLower = self.btnLower
	bLower._text = name
end

function PANEL:SetLowerActionCallFunc(func)
	self._lowerFunc = func
end

function PANEL:RawSetState(state)
	self._selectIndex = state
end


function PANEL:paintSelectedSlideSquare(w, h)
	local hSub = h - 8
	local hSubHalf = hSub * .5

	local oldSrc = self._selectIndexOld
	local newSrc = self._selectIndex
	local yCalc = newSrc == 1 and 4 or (h - 4 - hSubHalf)

	if self._selectAnimate then
		local delta = (CurTime() - self._selectTime) / ANIM_TIME
		delta = math.min(delta, 1)


		local yOld = oldSrc == 1 and 4 or (h - 4 - hSubHalf)

		local yNew = newSrc == 1 and 4 or (h - 4 - hSubHalf)

		yCalc = Lerp(math.ease.InOutQuart(delta), yOld, yNew)
	end

	surface.SetDrawColor(39, 39, 39)
	surface.DrawRect(4, yCalc, w - 8, hSubHalf)

	surface.SetDrawColor(col_neutral)
	surface.DrawRect(5, yCalc + 1, w - 8 - 2, hSubHalf - 2)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(39, 39, 39)
	surface.DrawRect(0, 0, w, h)


	surface.SetDrawColor(54, 54, 54)
	surface.DrawRect(1, 1, w - 2, h - 2)

	surface.SetDrawColor(44, 44, 44)
	surface.DrawRect(4, 4, w - 8, h - 8)

	self:paintSelectedSlideSquare(w, h)
end

vgui.Register("ZVUI_DSwitchButton", PANEL, "DPanel")