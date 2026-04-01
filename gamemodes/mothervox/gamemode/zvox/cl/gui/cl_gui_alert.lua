ZVox = ZVox or {}

local colHead = Color(255, 255, 255)


local function iconWithOutlineThisIsSlowAndBad(name, x, y, w, h)
	local colState = surface.GetDrawColor()
	local r, g, b, a = colState:Unpack()


	local pxSz = math.floor(w / 16)
	surface.SetDrawColor(0, 0, 0, 255)

	ZVUI.RenderIcon(name, x - pxSz, y - pxSz, w, h)
	ZVUI.RenderIcon(name, x       , y - pxSz, w, h)
	ZVUI.RenderIcon(name, x + pxSz, y - pxSz, w, h)

	ZVUI.RenderIcon(name, x - pxSz, y       , w, h)
	ZVUI.RenderIcon(name, x       , y       , w, h)
	ZVUI.RenderIcon(name, x + pxSz, y       , w, h)

	ZVUI.RenderIcon(name, x - pxSz, y + pxSz, w, h)
	ZVUI.RenderIcon(name, x       , y + pxSz, w, h)
	ZVUI.RenderIcon(name, x + pxSz, y + pxSz, w, h)


	surface.SetDrawColor(r, g, b, a)
	ZVUI.RenderIcon(name, x, y, w, h)
end



ZVox.AlertFrame = ZVox.AlertFrame
function ZVox.OpenAlertPanel(data)
	if IsValid(ZVox.AlertFrame) then
		ZVox.AlertFrame:Close()
	end

	ZVox.AlertFrame = vgui.Create("ZVUI_DFrame")
	ZVox.AlertFrame:SetSize(data.width or 800, data.height or 600)
	ZVox.AlertFrame:Center()
	ZVox.AlertFrame:MakePopup()
	ZVox.AlertFrame:SetTitle("ZVox Alert")

	local pnlHead = vgui.Create("DPanel", ZVox.AlertFrame)
	pnlHead:SetTall(96)
	pnlHead:DockMargin(0, 0, 0, 8)
	pnlHead:Dock(TOP)

	local headCol = data.headerColor or colHead
	local headIcon = data.headerIcon
	local headSz = data.headerFontSize or 4
	function pnlHead:Paint(w, h)
		ZVUI.PaintCoolSurface(self, w, h)

		ZVox.DrawRetroText(self, data.header or "ZVox", w * .5, h * .5, headCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, headSz)

		if headIcon then
			local iconScl = data.headerIconScale or 1
			local iconSidePad = data.headerIconPad or 0

			local iconSz = 16 * iconScl

			surface.SetDrawColor(headCol)
			--ZVUI.RenderIcon(headIcon, 0, (h * .5) - (iconSz * .5), iconSz, iconSz)
			--ZVUI.RenderIcon(headIcon, w - iconSz, (h * .5) - (iconSz * .5), iconSz, iconSz)

			iconWithOutlineThisIsSlowAndBad(headIcon, iconSidePad, (h * .5) - (iconSz * .5), iconSz, iconSz)
			iconWithOutlineThisIsSlowAndBad(headIcon, w - iconSz - iconSidePad, (h * .5) - (iconSz * .5), iconSz, iconSz)
		end
	end

	-- now for the body
	local truHeight = (data.height or 600) - 32 - 96 - 16 - 8
	local pnlBody = vgui.Create("DPanel", ZVox.AlertFrame)
	pnlBody:SetTall(truHeight)
	pnlBody:Dock(TOP)



	-- let's do markup =D
	-- ts is the most overengineered shit ever
	local textOriginal = data.text or "No text"

	local textLines = ZVox.ParseMarkup(textOriginal)

	local textPadLeft = data.textPadLeft or 0
	local texPadTop = data.textPadTop or 0

	local textSz = data.textSize or 1
	local colAccumObj = Color(255, 255, 255)
	function pnlBody:Paint(w, h)
		ZVUI.PaintCoolSurface(self, w, h)

		--surface.SetDrawColor(255, 0, 0)
		--surface.DrawRect(0, 0, w, h)

		local xAccum = textPadLeft
		local yAccum = texPadTop
		colAccumObj:SetUnpacked(255, 255, 255, 255)
		for i = 1, #textLines do
			local linesHere = textLines[i]

			for j = 1, #linesHere do
				local lineHere = linesHere[j]

				local colEntry = lineHere[1]
				colAccumObj:SetUnpacked(colEntry[1], colEntry[2], colEntry[3], 255)
				local tW = ZVox.DrawRetroText(self, lineHere[2], xAccum, yAccum, colAccumObj, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, textSz)
				xAccum = xAccum + tW
			end
			xAccum = textPadLeft
			yAccum = yAccum + 12 * textSz -- NEWLINE!!
		end
	end

end