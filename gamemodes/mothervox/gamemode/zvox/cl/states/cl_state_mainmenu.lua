ZVox = ZVox or {}

local state = ZVox.NewState(ZVOX_STATE_MAINMENU)

local SPARK_LIFE = 0.8
local SPARK_SUBPARTICLE_COUNT = 24
local SUBPARTICLE_MOVE_MUL = 256

local sparks = {}
local function pushSparks(x, y)
	local subparticles = {}

	for i = 1, SPARK_SUBPARTICLE_COUNT do
		subparticles[i] = {
			["velX"] = (math.random() - .5) * 1,
			["velY"] = math.random(),
			["rot"] = math.random() * 360,
		}
	end

	local spark = {
		["x"] = x,
		["y"] = y,
		["start"] = CurTime(),
		["die"] = CurTime() + SPARK_LIFE,
		["subparticles"] = subparticles
	}

	sparks[#sparks+1] = spark
end

local function updateSparkThink()
	local toDel = {}
	for i = 1, #sparks do
		local spark = sparks[i]

		if CurTime() > spark["die"] then
			toDel[#toDel + 1] = i
		end
	end

	if #toDel <= 0 then
		return
	end

	for i = #toDel, 1, -1 do
		local sparkIdx = toDel[i]
		table.remove(sparks, sparkIdx)
	end
end

-- im lazy as fuuuuck
-- https://wiki.facepunch.com/gmod/surface.DrawPoly
local function drawCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local mtxSubPart = Matrix()
local angSubPart = Angle()
local vtxSubPart = Vector()

local BOOM_TIME = .6
local function renderSparks()
	render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD)
	for i = 1, #sparks do
		local spark = sparks[i]
		local x, y = spark.x, spark.y


		local sparkLife = (CurTime() - spark.start)
		local sparkLifeDelta = sparkLife / SPARK_LIFE

		local boomDelta = math.min(sparkLife, BOOM_TIME) * (1 / BOOM_TIME)
		local boomDeltaSz = math.ease.OutExpo(boomDelta)
		local boomDeltaA = (1 - math.ease.OutExpo(boomDelta))

		surface.SetDrawColor(255 * boomDeltaA, 226 * boomDeltaA, 32 * boomDeltaA)
		draw.NoTexture()
		drawCircle(x, y, 6 + (boomDeltaSz * 8), 16)

		surface.SetDrawColor(255 * boomDeltaA, 240 * boomDeltaA, 196 * boomDeltaA)
		draw.NoTexture()
		drawCircle(x, y, 2 + (boomDeltaSz * 6), 16)

		-- subparticles
		local fakeAlphaMul = (1 - sparkLifeDelta)
		surface.SetDrawColor(255 * fakeAlphaMul, (48 + ((1 - sparkLifeDelta) * 194)) * fakeAlphaMul, 0)
		local subparticles = spark.subparticles
		for j = 1, #subparticles do
			local subpart = subparticles[j]
			local vXFinal = subpart["velX"] * sparkLifeDelta * SUBPARTICLE_MOVE_MUL
			local vYFinal = subpart["velY"] * sparkLifeDelta * SUBPARTICLE_MOVE_MUL
			subpart["velY"] = subpart["velY"] + (FrameTime() * 2)
			mtxSubPart:Identity()

			vtxSubPart:SetUnpacked(x + vXFinal, y + vYFinal, 0)
			mtxSubPart:SetTranslation(vtxSubPart)

			angSubPart:SetUnpacked(0, subpart["rot"], 0)
			mtxSubPart:SetAngles(angSubPart)

			cam.PushModelMatrix(mtxSubPart, true)
				surface.DrawRect(0, 0, 8, 2)
			cam.PopModelMatrix()
		end
	end
	render.OverrideBlend(false, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD)
end


local nextSpark = 0
local function genSparkThink()
	if CurTime() < nextSpark then
		return
	end

	nextSpark = CurTime() + 0.3 + (math.random() * 2)

	local w, h = ScrW(), ScrH()
	local fW, fH = 500, 64 + ((64) * 4)

	local pnlX, pnlY = 32 + 128 * 2.5 - (fW * .5), (h * .5) - (fH * .5) + 50

	local xC = pnlX + fW + (math.random() * 32)
	local yC = pnlY + (fH / 2) + (math.random() * 32)

	surface.PlaySound("mothervox/sfx/ui/spark.wav")
	pushSparks(xC, yC)
end


function state:Think()
	genSparkThink()
	updateSparkThink()
end

local logoMenuBackground = Material("mothervox/menu/bg_temp2.png", "nocull ignorez smooth")
local function renderBackgroundNew(w, h)
	surface.SetMaterial(logoMenuBackground)
	surface.SetDrawColor(255, 255, 255) -- temp colour set
	surface.DrawTexturedRect(0, 0, w, h)
end

local logoIconMat = Material("mothervox/logo.png", "nocull ignorez")


local col_VerName = Color(85, 85, 85)
local function renderLogo(w, h)
	local rectW = logoIconMat:Width() * 2
	local rectH = logoIconMat:Height() * 2

	surface.SetMaterial(logoIconMat)
	surface.SetDrawColor(255, 255, 255)
	surface.DrawTexturedRect(ScrW() / 2 - rectW / 2, 0, rectW, rectH)

	ZVox.DrawRetroTextShadowed(nil, ZVOX_VERSION .. " - Licensed under AGPL3", w - 8, h - 8, col_VerName, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 3)
end





local function renderSparkPanel()
	local w, h = ScrW(), ScrH()

	local fW, fH = 500, 64 + ((64) * 5)
	local pX, pY = 64 + 128 * 2.5 - (fW * .5), (h * .5) - (fH * .5) + 50


	surface.SetDrawColor(32, 24, 16)
	surface.DrawRect(pX, pY + 64, fW, fH - 128)
end


function state:Render(pos, ang, fov)
	local w, h = ScrW(), ScrH()
	renderBackgroundNew(w, h)

	renderSparkPanel()

	renderSparks()
	renderLogo(w, h)
	return true
end





ZVox.MainMenuFrame = ZVox.MainMenuFrame
local function buildMainMenuPanel()
	if IsValid(ZVox.MainMenuFrame) then
		ZVox.MainMenuFrame:Close()
	end

	local w, h = ScrW(), ScrH()



	local fW, fH = 500, 64 + ((64) * 5)

	ZVox.MainMenuFrame = vgui.Create("DPanel")
	ZVox.MainMenuFrame:SetSize(fW, fH)
	ZVox.MainMenuFrame:Center()

	ZVox.MainMenuFrame:SetPos(64 + 128 * 2.5 - (fW * .5), (h * .5) - (fH * .5) + 50)
	ZVox.MainMenuFrame:DockPadding(4, 32, 48 + 4, 0)

	ZVox.MainMenuFrame:MakePopup()

	function ZVox.MainMenuFrame:Paint(w, h)
		surface.SetDrawColor(64, 64, 64)
		surface.DrawRect(0, 0, w - 48, h)

		surface.SetDrawColor(51, 61, 52)
		draw.RoundedBox(16, 32, 16, w - 64 - 48, h - 32, surface.GetDrawColor())

		surface.SetDrawColor(20, 33, 21)
		draw.RoundedBox(16, 32 + 4, 16 + 4, w - 64 - 48 - 8, h - 32 - 8, surface.GetDrawColor())



		--surface.SetDrawColor(32, 32, 32)
		--surface.DrawRect(32, 16, w - 64 - 32, h - 32)
	end

	local btnNewGame = vgui.Create("MotherVox_DButton", ZVox.MainMenuFrame)
	btnNewGame:SetTall(64)
	btnNewGame:Dock(TOP)
	btnNewGame:SetMsg("NEW GAME")
	function btnNewGame:DoClick()
		if ZVox.MV_HasSaveFile() then
			ZVox.OpenConfirmationPrompt("<255,255,255>This will delete your old save file\n<255,255,255>Are you sure?", function()
				net.Start("mothervox_regenerate_world")
				net.SendToServer()

				-- this is retarded
				timer.Simple(1, function()
					ZVox.MV_ResetProgress()
					ZVox.Fuel_SetFuel(6)
					ZVox.AttemptConnectionToUniverse("mothervox")
					ZVox.MV_SaveProgress()
				end)
			end)
		else
			ZVox.MV_ResetProgress()
			ZVox.Fuel_SetFuel(6)
			ZVox.AttemptConnectionToUniverse("mothervox")
			ZVox.MV_SaveProgress()
		end
	end


	local btnLoadGame = vgui.Create("MotherVox_DButton", ZVox.MainMenuFrame)
	btnLoadGame:SetTall(64)
	btnLoadGame:Dock(TOP)
	btnLoadGame:SetMsg("LOAD GAME")
	btnLoadGame:SetDisabled(false)
	function btnLoadGame:DoClick()
		ZVox.MV_ResetProgress()

		ZVox.MV_LoadProgress()
		ZVox.AttemptConnectionToUniverse("mothervox")
	end

	--[[
	local btnInstructions = vgui.Create("MotherVox_DButton", ZVox.MainMenuFrame)
	btnInstructions:SetTall(64)
	btnInstructions:Dock(TOP)
	btnInstructions:SetMsg("INSTRUCTIONS")
	function btnInstructions:DoClick()
	end
	]]--

	local btnSettings = vgui.Create("MotherVox_DButton", ZVox.MainMenuFrame)
	btnSettings:SetTall(64)
	btnSettings:Dock(TOP)
	btnSettings:SetMsg("SETTINGS")
	function btnSettings:DoClick()
		ZVox.OpenSettings()
	end

	local btnCredits = vgui.Create("MotherVox_DButton", ZVox.MainMenuFrame)
	btnCredits:SetTall(64)
	btnCredits:Dock(TOP)
	btnCredits:SetMsg("CREDITS")
	function btnCredits:DoClick()
		ZVox.OpenCredits()
	end

	local btnLeave = vgui.Create("MotherVox_DButton", ZVox.MainMenuFrame)
	btnLeave:SetTall(64)
	btnLeave:Dock(TOP)
	btnLeave:SetMsg("QUIT")
	function btnLeave:DoClick()
		RunConsoleCommand("disconnect")
	end
end


ZVox.WrongPlayerCountFrame = ZVox.WrongPlayerCountFrame
local function buildWrongPlayerCountPanel()
	if IsValid(ZVox.WrongPlayerCountFrame) then
		ZVox.WrongPlayerCountFrame:Close()
	end

	ZVox.WrongPlayerCountFrame = vgui.Create("ZVUI_DFrame")
	ZVox.WrongPlayerCountFrame:SetSize(640, 294)
	ZVox.WrongPlayerCountFrame:Center()
	ZVox.WrongPlayerCountFrame:MakePopup()
	ZVox.WrongPlayerCountFrame:SetTitle("Wrong Playercount!")
	ZVox.WrongPlayerCountFrame:ShowCloseButton(false)
	ZVox.WrongPlayerCountFrame:SetDraggable(false)

	local pnlInfo = vgui.Create("DPanel", ZVox.WrongPlayerCountFrame)
	pnlInfo:Dock(FILL)

	local markupMsg = ""
	markupMsg = markupMsg .. "<255,255,255>This is a <255,96,96>single-player <255,255,255>gamemode.\n \n"
	markupMsg = markupMsg .. "<255,255,255>You are playing this on a <96,96,255>multi-player <255,255,255>server.\n \n"
	markupMsg = markupMsg .. "<255,255,255>Please shut down the gamemode.\n"
	markupMsg = markupMsg .. "<255,255,255>And start it up on <255,96,96>single-player <255,255,255>instead.\n"
	markupMsg = markupMsg .. "<255,255,255>Warm regards, <96,255,128>Lokachop <96,96,96>(as of 10/03/2026)\n"
	local markupObj = ZVox.ParseMarkup(markupMsg)

	function pnlInfo:Paint(w, h)
		ZVUI.PaintCoolSurface(self, w, h)

		ZVox.RenderMarkup(self, markupObj, 3)
	end
end


function state:OnEnter()
	RunConsoleCommand("stopsound")
	ZVox.SetActiveSong()

	if game.MaxPlayers() > 1 then
		buildWrongPlayerCountPanel()
		return
	end

	buildMainMenuPanel()
end

function state:OnExit()
	if IsValid(ZVox.MainMenuFrame) then
		ZVox.MainMenuFrame:Remove()
	end
end

