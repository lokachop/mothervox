ZVox = ZVox or {}
local state = ZVox.NewState(ZVOX_STATE_ENDING)
local enterTime = 0


function state:Think()
end


local endingMsg = ""
endingMsg = endingMsg .. "<255,255,255>As the drill pierces the unobtainalum chunk, you feel an\n"
endingMsg = endingMsg .. "<255,255,255>immense sense of dread.\n"
endingMsg = endingMsg .. "<255,255,255>\n"
endingMsg = endingMsg .. "<255,255,255>You're not sure how you ended up here.\n"
endingMsg = endingMsg .. "<255,255,255>You wish that you weren't here.\n"
endingMsg = endingMsg .. "<255,255,255>It is too late for that now.\n"
endingMsg = endingMsg .. "<255,255,255>\n"
endingMsg = endingMsg .. "<255,255,255>\n"
endingMsg = endingMsg .. "<255,255,255>The last thing you feel is your skin searing off.\n"

local endingMarkup = ZVox.ParseMarkup(endingMsg)


local texRegistry = ZVox.GetTextureRegistry()
local function renderBackground(w, h)
	local texData = texRegistry["zvox:unobtainalum"]
	-- first calc how much we can fit

	local fitW = w / 64 -- TODO: change when bigger res texture support
	local fitH = h / 64

	render.PushFilterMag(ZVOX_FILTERMODE)
	render.PushFilterMin(ZVOX_FILTERMODE)
		surface.SetDrawColor(48, 48, 48)
		surface.SetMaterial(texData.mat) -- individual mat, no atlas
		surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, fitW, fitH)
	render.PopFilterMin()
	render.PopFilterMag()
end

local function stage1(delta)
	local invDelta = 1 - delta

	local szW = ScrW() * invDelta
	local szH = ScrH() * invDelta

	local oX = ScrW() * .5
	local oY = ScrH() * .5

	local h_szW = szW * .5
	local h_szH = szH * .5

	local viewportRT = ZVox.GetViewPortRT()
	render.DrawTextureToScreenRect(viewportRT, oX - h_szW, oY - h_szH, szW, szH)
end


local function stage2(delta, truTime)
	local deltaIn = truTime / 4
	deltaIn = math.min(deltaIn, 1)
	local alphaIn = deltaIn * 255

	local deltaOut = (truTime - (20 - 4)) / 4
	deltaOut = math.min(deltaOut, 1)
	deltaOut = math.max(deltaOut, 0)

	local alphaOut = (1 - deltaOut) * 255

	local alphaTarget = truTime < 5 and alphaIn or alphaOut


	local boxW = 512 + 256 + 196
	local boxH = 512 - 64

	local boxX = ScrW() * .5
	local boxY = ScrH() * .5

	local h_boxW = boxW * .5
	local h_boxH = boxH * .5

	surface.SetDrawColor(255, 0, 0)

	--surface.DrawRect(boxX - h_boxW, boxY - h_boxH, boxW, boxH)
	ZVox.RenderMarkup(nil, endingMarkup, 4, boxX - h_boxW, boxY - h_boxH, alphaTarget)
end


local uiOpenFlag = false
ZVox.GGFrame = ZVox.GGFrame
local function openGGUI()
	if uiOpenFlag then
		return
	end

	uiOpenFlag = true


	if IsValid(ZVox.GGFrame) then
		ZVox.GGFrame:Close()
	end

	ZVox.GGFrame = vgui.Create("ZVUI_DFrame")
	ZVox.GGFrame:SetSize(800, 600 - 96 - 32)
	ZVox.GGFrame:Center()
	ZVox.GGFrame:MakePopup()
	ZVox.GGFrame:SetTitle("You won?")
	ZVox.GGFrame:ShowCloseButton(false)
	ZVox.GGFrame:SetDraggable(false)

	local pnlFancyCongrats = vgui.Create("DPanel", ZVox.GGFrame)
	pnlFancyCongrats:SetTall(128)
	pnlFancyCongrats:Dock(TOP)

	local col1 = Color(255, 255, 0, 255)
	local col2 = Color(255, 220, 64, 255 * .75)
	local col3 = Color(255, 240, 128, 255 * .5)
	local col4 = Color(255, 255, 180, 255 * .25)
	local str = "CONGRATULATIONS!"
	function pnlFancyCongrats:Paint(w, h)
		--surface.SetDrawColor(255, 0, 0)
		--surface.DrawRect(0, 0, w, h)
		local tW = ZVox.GetTextWidth(str, 8)

		local currX = (w * .5) - tW * .5
		for i = 1, #str do
			local yOff1 = math.sin((CurTime() * 8) + (i * .25)) * 24
			local yOff2 = math.sin(((CurTime() - .1) * 8) + (i * .25)) * 24
			local yOff3 = math.sin(((CurTime() - .2) * 8) + (i * .25)) * 24
			local yOff4 = math.sin(((CurTime() - .3) * 8) + (i * .25)) * 24


			ZVox.DrawRetroText(self, str[i], currX, h * .5 + yOff4, col4, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 8)
			ZVox.DrawRetroText(self, str[i], currX, h * .5 + yOff3, col3, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 8)
			ZVox.DrawRetroText(self, str[i], currX, h * .5 + yOff2, col2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 8)
			local wGet = ZVox.DrawRetroText(self, str[i], currX, h * .5 + yOff1, col1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 8)
			currX = currX + wGet
		end
	end


	local pnlStats = vgui.Create("DPanel", ZVox.GGFrame)
	pnlStats:SetTall(256 - 32)
	pnlStats:Dock(TOP)
	function pnlStats:Paint(w, h)
		ZVUI.PaintCoolSurface(self, w, h)

		--surface.SetDrawColor(0, 255, 0)
		--surface.DrawRect(0, 0, w, h)

		ZVox.DrawRetroText(self, "You had $" .. tostring(ZVox.Money_GetCurrentMoney()) .. " by the end.", 4, 4, col1, TEXT_ALIGN_TOP, TEXT_ALIGN_LEFT, 4)
		ZVox.DrawRetroText(self, "You dug " .. tostring(ZVox.DugBlocksTotal) .. " blocks by the end.", 4, 4 + 42, col1, TEXT_ALIGN_TOP, TEXT_ALIGN_LEFT, 4)
		ZVox.DrawRetroText(self, "You exploded " .. tostring(ZVox.ExplodedBlocksTotal) .. " blocks by the end.", 4, 4 + (42 * 2), col1, TEXT_ALIGN_TOP, TEXT_ALIGN_LEFT, 4)
		ZVox.DrawRetroText(self, tostring(ZVox.ExplodedMineralsTotal) .. " of those blocks were minerals.", 4, 4 + (42 * 3), col1, TEXT_ALIGN_TOP, TEXT_ALIGN_LEFT, 4)
		ZVox.DrawRetroText(self, "You dug " .. tostring(ZVox.DugMagmaTotal) .. " magma blocks by the end.", 4, 4 + (42 * 4), col1, TEXT_ALIGN_TOP, TEXT_ALIGN_LEFT, 4)
	end

	local pnlHoldBtn = vgui.Create("DPanel", ZVox.GGFrame)
	pnlHoldBtn:SetTall(64 + 8)
	pnlHoldBtn:Dock(TOP)
	pnlHoldBtn:DockPadding(256, 8, 256, 8)
	function pnlHoldBtn:Paint(w, h)
		--surface.SetDrawColor(0, 0, 255)
		--surface.DrawRect(0, 0, w, h)
	end

	local btnContinue = vgui.Create("ZVUI_DButton", pnlHoldBtn)
	btnContinue:Dock(FILL)
	btnContinue:SetText("Continue")
	function btnContinue:DoClick()
		ZVox.SetState(ZVOX_STATE_MAINMENU)
		ZVox.GGFrame:Close()
	end
end



function state:Render(pos, ang, fov)
	renderBackground(ScrW(), ScrH())

	local enterSince = CurTime() - enterTime

	-- debug
	--enterSince = 24

	if enterSince < 2 then
		stage1(enterSince / 2)
	elseif enterSince < 24 then
		stage2((enterSince - 2) / 22, (enterSince - 2))
	else
		openGGUI()
	end

	return true
end

function state:OnEnter()
	surface.PlaySound("mothervox/sfx/misc/unobtainalum_dig_ending.wav")
	enterTime = CurTime()
end

function state:OnExit()
end