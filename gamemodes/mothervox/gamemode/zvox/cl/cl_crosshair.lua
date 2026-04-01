ZVox = ZVox or {}

function ZVox.RenderCrosshair()
	local w, h = ScrW(), ScrH()

	local cX, cY = w * .5, h * .5

	local shakeX, shakeY = ZVox.GetScreenShake()
	cX = cX + shakeX
	cY = cY + shakeY


	render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_SUBTRACT)
		surface.SetDrawColor(255, 255, 255)

		-- horz
		surface.DrawRect(cX - 9, cY - 1, 18, 2)

		-- vert
		surface.DrawRect(cX - 1, cY - 9, 2, 8)
		surface.DrawRect(cX - 1, cY + 1, 2, 8)
	render.OverrideBlend(false)
end