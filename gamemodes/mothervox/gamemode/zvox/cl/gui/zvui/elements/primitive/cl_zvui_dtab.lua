ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

function PANEL:Init()

	self:SetMouseInputEnabled( true )
	self:SetContentAlignment( 7 )
	self:SetTextInset( 0, 4 )

	self._imgColor = Color(255, 255, 255, 255)
end


function PANEL:Setup(label, pPropertySheet, pPanel, strMaterial )
	if IsValid(self.Image) then
		self.Image:Remove()
	end

	self:SetText( label )
	self:SetPropertySheet( pPropertySheet )
	self:SetPanel( pPanel )

	self._msg = label
	if ( strMaterial ) then
		self._iconName = strMaterial
	end
end

function PANEL:PerformLayout()
	self:ApplySchemeSettings()

	if ( not self:IsActive() ) then
		self._imgColor = Color(255, 255, 255, 155)
	else
		self._imgColor = Color(255, 255, 255, 255)
	end

end

function PANEL:ApplySchemeSettings()

	local ExtraInset = 10

	if ( self._iconName ) then
		ExtraInset = ExtraInset + 16
	end

	self:SetTextInset( ExtraInset, 4 )
	local w, h = self:GetContentSize()
	h = self:GetTabHeight()

	self:SetSize( w + 10, h )

	DLabel.ApplySchemeSettings( self )

end

local colStart1 = Color(54, 54, 54, 255)
local colEnd1 = Color(54, 54, 54, 0)

local colStart2 = Color(39, 39, 39, 255)
local colEnd2 = Color(39, 39, 39, 0)

function PANEL:Paint(w, h)
	--surface.SetDrawColor(39, 39, 39)
	--surface.DrawRect(0, 0, w, h)

	--surface.SetDrawColor(54, 54, 54)
	--surface.DrawRect(1, 1, w - 2, h - 2)

	surface.SetDrawColor(39, 39, 39)
	surface.DrawRect(0, 0, w, h * .75)

	surface.SetDrawColor(54, 54, 54)
	surface.DrawRect(1, 1, w - 2, h * .75)


	ZVox.RenderGradientSRGB(0, h * .75, w, h * .25, 6, colStart2, colEnd2)
	ZVox.RenderGradientSRGB(1, h * .75, w - 2, h * .25 - 1, 6, colStart1, colEnd1)

	local iconName = self._iconName
	if iconName then
		surface.SetDrawColor(255, 255, 255)
		ZVUI.RenderIcon(iconName, 7, 3, 16, 16)
	end
end

vgui.Register("ZVUI_DTab", PANEL, "DTab")