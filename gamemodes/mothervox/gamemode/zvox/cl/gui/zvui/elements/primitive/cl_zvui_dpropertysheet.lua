ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

function PANEL:Init()

end

function PANEL:AddSheet( label, panel, material, NoStretchX, NoStretchY, Tooltip )

	if ( not IsValid( panel ) ) then
		ErrorNoHalt( "DPropertySheet:AddSheet tried to add invalid panel!" )
		debug.Trace()
		return
	end

	local Sheet = {}

	Sheet.Name = label

	Sheet.Tab = vgui.Create( "ZVUI_DTab", self )
	Sheet.Tab:SetTooltip( Tooltip )
	Sheet.Tab:Setup( label, self, panel, material )

	Sheet.Panel = panel
	Sheet.Panel.NoStretchX = NoStretchX
	Sheet.Panel.NoStretchY = NoStretchY
	Sheet.Panel:SetPos( self:GetPadding(), 20 + self:GetPadding() )
	Sheet.Panel:SetVisible( false )

	panel:SetParent( self )

	table.insert( self.Items, Sheet )

	if ( not self:GetActiveTab() ) then
		self:SetActiveTab( Sheet.Tab )
		Sheet.Panel:SetVisible( true )
	end

	self.tabScroller:AddPanel( Sheet.Tab )

	return Sheet

end

local function paintSurface(offX, offY, w, h)


	-- top fx
	surface.SetDrawColor(0, 0, 0, 48)
	surface.DrawRect(offX, offY, w, 1)

	-- main surface
	surface.SetDrawColor(32, 32, 32, 220)
	surface.DrawRect(offX, offY + 1, w, h - 1)

	-- top fx 2
	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(offX, offY + 1, w, 2)

	surface.DrawRect(offX, offY + 1, w, 1)


	-- left side fx
	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(offX, offY, 2, h - 1)

	--surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(offX, offY + 1, 1, h - 1)

	-- right side fx
	surface.SetDrawColor(0, 0, 0, 48)
	surface.DrawRect(offX + w - 1, offY + 1, 1, h - 1)


	-- bottom fx
	surface.SetDrawColor(0, 0, 0, 24)
	surface.DrawRect(offX, offY + h - 3, w, 3)

	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(offX, offY + h - 2, w, 2)
end

function PANEL:Paint(w, h)
	local offX, offY = 0, 18

	paintSurface(offX, offY, w, h - offY)
end

vgui.Register("ZVUI_DPropertySheet", PANEL, "DPropertySheet")