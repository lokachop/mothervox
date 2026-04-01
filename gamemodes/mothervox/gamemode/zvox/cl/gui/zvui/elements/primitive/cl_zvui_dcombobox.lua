
local PANEL = {}

local colNeutral = Color(64, 98, 138)
local colHighlight = Color(92, 131, 176)
local colPress = Color(92 + 28, 131 + 33, 176 + 38)

local colDisabled = Color(64, 64, 64)

local colTextDisabled = Color(128, 128, 128)
local colTextEnabled = Color(255, 255, 255)

Derma_Install_Convar_Functions( PANEL )

AccessorFunc( PANEL, "m_bDoSort", "SortItems", FORCE_BOOL )

function PANEL:Init()
	-- Setup internals
	self:SetTall( 22 )
	self:Clear()

	self:SetContentAlignment( 4 )
	self:SetTextInset( 8, 0 )
	self:SetIsMenu( true )
	self:SetSortItems( true )

	self._buttonColour = colNeutral
	self._textColour = colTextEnabled
end

function PANEL:SetTextStyleColor(col)
	self:SetTextColor(col)
end

function PANEL:UpdateColours()
	if not self:IsEnabled() then
		self._buttonColour = colDisabled
		self:SetTextStyleColor(colTextDisabled)
		self:SetCursor("no")
		return
	end
	self:SetTextStyleColor(colTextEnabled)
	self:SetCursor("hand")


	if self:IsDown() then
		self._buttonColour = colPress
		return
	end

	if self:IsHovered() then
		self._buttonColour = colHighlight
		return
	end

	self._buttonColour = colNeutral
end


function PANEL:Clear()
	self:SetText("")
	self.Choices = {}
	self.Data = {}
	self.ChoiceIcons = {}
	self.Spacers = {}
	self.selected = nil

	self:CloseMenu()
end

function PANEL:GetOptionText(index)

	return self.Choices[index]

end

function PANEL:GetOptionData(index)

	return self.Data[index]

end

function PANEL:GetOptionTextByData( data )

	for id, dat in pairs( self.Data ) do
		if ( dat == data ) then
			return self:GetOptionText( id )
		end
	end

	-- Try interpreting it as a number
	for id, dat in pairs( self.Data ) do
		if ( dat == tonumber( data ) ) then
			return self:GetOptionText( id )
		end
	end

	-- In case we fail
	return data

end

function PANEL:PerformLayout( w, h )
	-- Make sure the text color is updated
	DButton.PerformLayout( self, w, h )

end

function PANEL:ChooseOption( value, index )

	self:CloseMenu()
	self:SetText( value )

	-- This should really be the here, but it is too late now and convar
	-- changes are handled differently by different child elements
	-- self:ConVarChanged( self.Data[ index ] )

	self.selected = index
	self:OnSelect( index, value, self.Data[ index ] )

end

function PANEL:ChooseOptionID( index )

	local value = self:GetOptionText( index )
	self:ChooseOption( value, index )

end

function PANEL:GetSelectedID()

	return self.selected

end

function PANEL:GetSelected()

	if ( not self.selected ) then return end

	return self:GetOptionText( self.selected ), self:GetOptionData( self.selected )

end

function PANEL:OnSelect( index, value, data )
	-- For override
end

function PANEL:OnMenuOpened( menu )
	-- For override
end

function PANEL:AddSpacer()

	self.Spacers[ #self.Choices ] = true

end

function PANEL:AddChoice( value, data, select, icon )

	local index = table.insert( self.Choices, value )

	if ( data ) then
		self.Data[ index ] = data
	end

	if ( icon ) then
		self.ChoiceIcons[ index ] = icon
	end

	if ( select ) then

		self:ChooseOption( value, index )

	end

	return index

end

function PANEL:RemoveChoice( index )
	if ( not isnumber( index ) ) then return end

	local text = table.remove( self.Choices, index )
	local data = table.remove( self.Data, index )
	return text, data

end

function PANEL:IsMenuOpen()

	return IsValid( self.Menu ) and self.Menu:IsVisible()

end

function PANEL:OpenMenu( pControlOpener )

	if ( pControlOpener and pControlOpener == self.TextEntry ) then
		return
	end

	-- Don't do anything if there aren't any options..
	if ( #self.Choices == 0 ) then return end

	-- If the menu still exists and hasn't been deleted
	-- then just close it and don't open a new one.
	self:CloseMenu()

	-- If we have a modal parent at some level, we gotta parent to
	-- that or our menu items are not gonna be selectable
	local parent = self
	while ( IsValid( parent ) and not parent:IsModal() ) do
		parent = parent:GetParent()
	end
	if ( not IsValid( parent ) ) then parent = self end

	self.Menu = ZVUI.DermaMenu( false, parent )

	if ( self:GetSortItems() ) then
		local sorted = {}
		for k, v in pairs( self.Choices ) do
			local val = tostring( v ) --tonumber( v ) or v -- This would make nicer number sorting, but SortedPairsByMemberValue doesn't seem to like number-string mixing
			if ( string.len( val ) > 1 and not tonumber( val ) and val:StartsWith( "#" ) ) then val = language.GetPhrase( val:sub( 2 ) ) end
			table.insert( sorted, { id = k, data = v, label = val } )
		end
		for k, v in SortedPairsByMemberValue( sorted, "label" ) do
			local option = self.Menu:AddOption( v.data, function() self:ChooseOption( v.data, v.id ) end )
			if ( self.ChoiceIcons[ v.id ] ) then
				option:SetIcon( self.ChoiceIcons[ v.id ] )
			end
			if ( self.Spacers[ v.id ] ) then
				self.Menu:AddSpacer()
			end
		end
	else
		for k, v in pairs( self.Choices ) do
			local option = self.Menu:AddOption( v, function() self:ChooseOption( v, k ) end )
			if ( self.ChoiceIcons[ k ] ) then
				option:SetIcon( self.ChoiceIcons[ k ] )
			end
			if ( self.Spacers[ k ] ) then
				self.Menu:AddSpacer()
			end
		end
	end

	local x, y = self:LocalToScreen( 0, self:GetTall() )

	self.Menu:SetMinimumWidth( self:GetWide() )
	self.Menu:Open( x, y, false, self )

	self:OnMenuOpened( self.Menu )

end

function PANEL:CloseMenu()

	if ( IsValid( self.Menu ) ) then
		self.Menu:Remove()
	end

	self.Menu = nil
end

function PANEL:Think()
end

function PANEL:SetValue( strValue )
	self:SetText( strValue )
end

function PANEL:DoClick()
	if ( self:IsMenuOpen() ) then
		return self:CloseMenu()
	end

	self:OpenMenu()
end


function PANEL:Paint(w, h)
	surface.SetDrawColor(39, 39, 39)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(self._buttonColour)
	surface.DrawRect(1, 1, w - 2, h - 2)

	surface.SetDrawColor(255, 255, 255)
	ZVUI.RenderIcon(self:IsMenuOpen() and "combo-uparrow" or "combo-downarrow", w - 16, 0, 16, 16)
end


vgui.Register("ZVUI_DComboBox", PANEL, "DButton")