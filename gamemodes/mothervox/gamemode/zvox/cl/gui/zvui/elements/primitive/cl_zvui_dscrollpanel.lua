ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}


function PANEL:Init()
	local scroll = self.VBar
	-- style the vbar

	function scroll:Paint(w, h)
		surface.SetDrawColor(28, 28, 28)
		surface.DrawRect(0, 0, w, h)
	end


	local btnUp = scroll.btnUp
	function btnUp:Paint(w, h)
		local _add = 0
		if self:IsHovered() then
			_add = _add + 24
		end

		if self:IsDown() then
			_add = _add + 24
		end

		surface.SetDrawColor(28 + _add, 28 + _add, 28 + _add)
		surface.DrawRect(0, 0, w, h)


		surface.SetDrawColor(146 + _add, 146 + _add, 146 + _add)
		local cX = (w * .5) - 8
		local cY = (h * .5) - 8

		ZVUI.RenderIcon("vbar-arrow-up", cX, cY)
	end

	local btnDown = scroll.btnDown
	function btnDown:Paint(w, h)
		local _add = 0
		if self:IsHovered() then
			_add = _add + 24
		end

		if self:IsDown() then
			_add = _add + 24
		end

		surface.SetDrawColor(28 + _add, 28 + _add, 28 + _add)
		surface.DrawRect(0, 0, w, h)


		surface.SetDrawColor(146 + _add, 146 + _add, 146 + _add)
		local cX = (w * .5) - 8
		local cY = (h * .5) - 8

		ZVUI.RenderIcon("vbar-arrow-down", cX, cY)
	end



	local btnGrip = scroll.btnGrip
	function btnGrip:Paint(w, h)
		local _add = 0
		if self.Hovered then
			_add = _add + 24
		end

		if self.Depressed then
			_add = _add + 24
		end

		surface.SetDrawColor(59 + _add, 59 + _add, 59 + _add)
		surface.DrawRect(0, 0, w, h)
	end
end

vgui.Register("ZVUI_DScrollPanel", PANEL, "DScrollPanel")