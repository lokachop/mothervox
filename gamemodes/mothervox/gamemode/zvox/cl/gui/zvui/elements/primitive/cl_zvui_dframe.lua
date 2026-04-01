ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

local _col_white = Color(255, 255, 255)
function PANEL:Init()
	self:SetFocusTopLevel(true)
	self:SetPaintShadow(true)

	self.btnClose:Remove()
	self.btnMaxim:Remove()
	self.btnMinim:Remove()
	self.lblTitle:Remove()


	self.btnClose = vgui.Create("DButton", self)
	self.btnClose:SetText("")
	self.btnClose.DoClick = function(button)
		self:Close()
	end


	self.btnClose.Paint = function(panel, w, h)
		if panel:IsHovered() then
			surface.SetDrawColor(204, 0, 0)
			surface.DrawRect(0, 0, w, h)
		end

		local w_H = w * .5
		local h_H = h * .5


		local rectSz = 16
		local h_rectSz = rectSz * .5


		local minX = w_H - h_rectSz
		local minY = h_H - h_rectSz

		local maxX = w_H + h_rectSz
		local maxY = h_H + h_rectSz

		if panel:IsHovered() then
			surface.SetDrawColor(255, 155, 155)
		else
			surface.SetDrawColor(155, 155, 155)
		end
		ZVUI.RenderIcon("close", minX, minY)
	end

	self:SetDraggable(true)
	self:SetSizable(false)
	self:SetScreenLock(false)
	self:SetDeleteOnClose(true)
	self:SetTitle("ZVUI Window")

	self:SetMinWidth(64)
	self:SetMinHeight(64)

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)

	self.m_fCreateTime = SysTime()

	self:DockPadding(6, 32 + 8, 6, 6)
end


function PANEL:SetTitle(strTitle)
	self._title = strTitle
end

function PANEL:ShowCloseButton(bShow)
	self.btnClose:SetVisible(bShow)
end

function PANEL:PerformLayout()
	self.btnClose:SetPos(self:GetWide() - 45, 0)
	self.btnClose:SetSize(45, 31)
end


local texFidelity = 96
-- shadow blur textures
local shadowVRT, shadowVMat = ZVox.NewRTMatPairPixelFuncAlpha("zvui_shadowv", texFidelity, 2, function(x, y)
	local xD = x / texFidelity

	--xD = xD ^ 3
	xD = 1 - xD

	xD = xD * 255
	return 255, 255, 255, xD
end)


local shadowHRT, shadowHMat = ZVox.NewRTMatPairPixelFuncAlpha("zvui_shadowh", 2, texFidelity, function(x, y)
	local yD = y / texFidelity

	--yD = yD ^ 3
	yD = 1 - yD

	yD = yD * 255
	return 255, 255, 255, yD
end)

local shadowHVRT, shadowHVMat = ZVox.NewRTMatPairPixelFuncAlpha("zvui_shadowhv", texFidelity, texFidelity, function(x, y)
	local dist = math.DistanceSqr(x, y, 0, 0)
	
	local delta = dist / (texFidelity * texFidelity)
	delta = math.sqrt(delta)
	delta = math.min(delta, 1)

	--delta = delta ^ 3
	delta = 1 - delta

	delta = delta * 255
	return 255, 255, 255, delta
end)

local function renderShadow(self, w, h)
	DisableClipping(true)
		local megaW = w + 22
		local megaH = h + 22


		local offX = -10
		local offY = -8

		local borderSz = 24
		-- main hull

		local alpha = self:HasFocus() and 220 or 140

		surface.SetDrawColor(0, 0, 0, alpha)
		surface.DrawRect(offX + borderSz, offY + borderSz, megaW - (borderSz * 2), megaH - (borderSz * 2))

		-- vertical blurs
		-- tall ones
		-- right
		surface.SetMaterial(shadowVMat)
		surface.DrawTexturedRectUV(offX + megaW - borderSz, offY + borderSz, borderSz, megaH - (borderSz * 2), 0, 0, 1, 1)

		-- left
		surface.DrawTexturedRectUV(offX, offY + borderSz, borderSz, megaH - (borderSz * 2), 1, 0, 0, 1)



		-- horizontal blurs
		-- wide ones
		-- bottom
		surface.SetMaterial(shadowHMat)
		surface.DrawTexturedRectUV(offX + borderSz, megaH + offY - borderSz, megaW - (borderSz * 2), borderSz, 0, 0, 1, 1)

		-- top
		surface.DrawTexturedRectUV(offX + borderSz, offY, megaW - (borderSz * 2), borderSz, 0, 1, 1, 0)


		-- corner blurs
		-- small corners
		-- bottom right
		surface.SetMaterial(shadowHVMat)
		surface.DrawTexturedRectUV(offX + megaW - borderSz, offY + megaH - borderSz, borderSz, borderSz, 0, 0, 1, 1)

		-- bottom left
		surface.SetMaterial(shadowHVMat)
		surface.DrawTexturedRectUV(offX, offY + megaH - borderSz, borderSz, borderSz, 1, 0, 0, 1)

		-- top right
		surface.SetMaterial(shadowHVMat)
		surface.DrawTexturedRectUV(offX + megaW - borderSz, offY, borderSz, borderSz, 0, 1, 1, 0)

		-- top left
		surface.SetMaterial(shadowHVMat)
		surface.DrawTexturedRectUV(offX, offY, borderSz, borderSz, 1, 1, 0, 0)


	DisableClipping(false)
end




local _cStart = Color(41, 41, 41)
local _cEnd = Color(32, 32, 32)
local textCol = Color(255, 255, 255)
function PANEL:Paint(w, h)
	if ZVOX_DO_UI_SHADOWS then
		renderShadow(self, w, h)
	end


	local steps = math.floor(h / (30 * .25))
	ZVox.RenderGradientSRGB(0, 32, w, h - 32, steps, _cStart, _cEnd)

	surface.SetDrawColor(54, 54, 54)
	surface.DrawRect(0, 0, w, 31)
	surface.SetDrawColor(22, 22, 22)
	surface.DrawRect(0, 31, w, 1)



	-- draw the logo icon thing
	-- on TGUI it is the nanotrasen / syndicate / cybersun logo
	-- in our case we'll do an abstract box
	-- we'll use the icon


	-- shadowing
	-- on TGUI im p sure they do some CSS blurring
	-- here we fake it with precomputed boxes and colours

	surface.SetDrawColor(39, 39, 39)
	surface.DrawRect(0, 32, w, 3)

	surface.SetDrawColor(37, 37, 37)
	surface.DrawRect(1, 32, w, 2)


	-- title label
	draw.SimpleText(self._title, "ZVUI_FrameTitleFont", 13, 16, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end


vgui.Register("ZVUI_DFrame", PANEL, "DFrame")