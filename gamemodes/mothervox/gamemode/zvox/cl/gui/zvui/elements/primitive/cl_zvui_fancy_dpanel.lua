ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

function PANEL:Init()
end

local function paintSurface(self, w, h)
	-- top fx
	surface.SetDrawColor(0, 0, 0, 48)
	surface.DrawRect(0, 0, w, 1)

	-- main surface
	surface.SetDrawColor(32, 32, 32, 220)
	surface.DrawRect(0, 1, w, h - 1)

	-- top fx 2
	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(0, 1, w, 2)

	surface.DrawRect(0, 1, w, 1)


	-- left side fx
	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(0, 0, 2, h - 1)

	--surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(0, 1, 1, h - 1)

	-- right side fx
	surface.SetDrawColor(0, 0, 0, 48)
	surface.DrawRect(w - 1, 1, 1, h - 1)


	-- bottom fx
	surface.SetDrawColor(0, 0, 0, 24)
	surface.DrawRect(0, h - 3, w, 3)

	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(0, h - 2, w, 2)
end

function PANEL:Paint(w, h)
	paintSurface(self, w, h)
end

vgui.Register("ZVUI_FancyDPanel", PANEL, "DPanel")