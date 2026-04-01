ZVox = ZVox or {}
ZVUI = ZVUI or {}

function ZVUI.PaintCoolSurface(self, w, h)
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

function ZVUI.PaintCoolSurfaceRect(self, x, y, w, h)
	-- top fx
	surface.SetDrawColor(0, 0, 0, 48)
	surface.DrawRect(x, y, w, 1)

	-- main surface
	surface.SetDrawColor(32, 32, 32, 220)
	surface.DrawRect(x, y + 1, w, h - 1)

	-- top fx 2
	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(x, y + 1, w, 2)

	surface.DrawRect(x, y + 1, w, 1)


	-- left side fx
	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(x, y, 2, h - 1)

	--surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(x, y + 1, 1, h - 1)

	-- right side fx
	surface.SetDrawColor(0, 0, 0, 48)
	surface.DrawRect(x + w - 1, y + 1, 1, h - 1)


	-- bottom fx
	surface.SetDrawColor(0, 0, 0, 24)
	surface.DrawRect(x, y + h - 3, w, 3)

	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(x, y + h - 2, w, 2)
end