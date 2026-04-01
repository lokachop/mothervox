ZVox = ZVox or {}



local PROCESSING_MESSAGE_LOG = {}
local MAX_MESSAGES = math.floor(256 / 24) + 1
function ZVox.PushLoadingMessage(message) -- poo poo from LK3D
	local timeStamp = os.date("[%H:%M:%S] ")

	local toWrite = timeStamp .. tostring(message)
	PROCESSING_MESSAGE_LOG[#PROCESSING_MESSAGE_LOG + 1] = toWrite

	local msgCount = #PROCESSING_MESSAGE_LOG

	if msgCount > MAX_MESSAGES then
		table.remove(PROCESSING_MESSAGE_LOG, 1)
	end
end

local loadBarDelta = 0
local chunkCountTotal = 0
local chunkCountCurrent = 0
function ZVox.SetLoadBarChunkCount(count)
	chunkCountTotal = count
	chunkCountCurrent = 0
end

function ZVox.AddLoadBarProgress(chunkCount)
	chunkCountCurrent = chunkCountCurrent + chunkCount


	loadBarDelta = math.min(chunkCountCurrent / chunkCountTotal, 1)
end


local texRegistry = ZVox.GetTextureRegistry()
local function renderBackground(w, h)
	surface.SetDrawColor(16, 24, 32)
	surface.DrawRect(0, 0, w, h)

	-- pattern with dirt
	local texData = texRegistry["zvox:stone"]
	-- first calc how much we can fit

	local fitW = w / 64 -- TODO: change when bigger res texture support
	local fitH = h / 64

	render.PushFilterMag(ZVOX_FILTERMODE)
	render.PushFilterMin(ZVOX_FILTERMODE)
		surface.SetDrawColor(100, 100, 100)
		surface.SetMaterial(texData.mat) -- individual mat, no atlas
		surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, fitW, fitH)
	render.PopFilterMin()
	render.PopFilterMag()
end


local function renderLoadBar(w, h)
	local h_w = w * .5
	local h_h = h * .5

	local barW = w * .75
	local barH = 64

	-- border
	surface.SetDrawColor(39, 39, 39, 255)
	surface.DrawRect(h_w - barW * .5, h_h - barH * .5, barW, barH)

	-- bar
	surface.SetDrawColor(54, 54, 54, 255)
	surface.DrawRect(h_w - barW * .5 + 2, h_h - barH * .5 + 2, barW - 4, barH - 4)



	local progDelta = loadBarDelta

	-- bar green
	local progBarX = h_w - barW * .5 + 4
	local progBarY = h_h - barH * .5 + 4
	local progBarW = math.max(barW * progDelta - 8, 0)
	local progBarH = barH - 8

	surface.SetDrawColor(16, 196, 16, 255)
	surface.DrawRect(progBarX, progBarY, progBarW, progBarH)


	if not ZVOX_DO_UI_FASTMODE then
		-- gradient
		render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD)
			ZVox.RenderGradientSRGB(progBarX, progBarY, progBarW, progBarH * .5, 32, Color(220, 220, 220), Color(0, 0, 0))
		render.OverrideBlend(false)

		render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_REVERSE_SUBTRACT)
			ZVox.RenderGradientSRGB(progBarX, progBarY + progBarH * .5, progBarW, progBarH * .5, 32, Color(0, 0, 0), Color(48, 180, 48))
		render.OverrideBlend(false)
	end
end

local colourLog = Color(255, 255, 255)
local function renderProcessingMessages(w, h)
	local h_w = w * .5
	local h_h = h * .5

	local boxW = 800
	local boxH = 256

	surface.SetDrawColor(24, 24, 24, 200)
	surface.DrawRect(h_w - boxW * .5, (h * .5) + 64, boxW, boxH)

	local m_scl = Matrix()


	for i = 1, #PROCESSING_MESSAGE_LOG do
		local inverseOffset = (#PROCESSING_MESSAGE_LOG - i) + 1

		local message = PROCESSING_MESSAGE_LOG[inverseOffset]

		local xc = h_w - boxW * .5
		local yc = (h * .5) + 64 + (i - 1) * 24

		ZVox.DrawRetroText(nil, message, xc, yc, colourLog, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2)
	end
end



local col_LoadingText = Color(85, 220, 154)
local function renderLogo(w, h)
	ZVox.DrawRetroTextShadowed(nil, "Loading", w * .5, (h * .25) + 128, col_LoadingText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 6)
end

function ZVox.RenderLoadScreen()
	local w, h = ScrW(), ScrH()

	renderBackground(w, h)

	-- align guides
	--surface.SetDrawColor(255, 0, 0, 255)
	--surface.DrawRect(0, h * .5, w, 1)

	--surface.SetDrawColor(0, 255, 0, 255)
	--surface.DrawRect(w * .5, 0, 1, h)

	renderLoadBar(w, h)

	renderProcessingMessages(w, h)

	renderLogo(w, h)
end



function ZVox.BeginLoadScreen(univObj)
	ZVox.SetState(ZVOX_STATE_LOADING)

	ZVox.PushLoadingMessage("Connecting to universe \"" .. univObj["name"] .. "\"")

	local cSizeX = univObj["chunkSizeX"]
	local cSizeY = univObj["chunkSizeY"]
	local cSizeZ = univObj["chunkSizeZ"]

	ZVox.PushLoadingMessage("Universe chunk size is " .. cSizeX .. "x" .. cSizeY .. "x" .. cSizeZ)

	local count = univObj["chunkSizeX"] * univObj["chunkSizeY"] * univObj["chunkSizeZ"]
	ZVox.PushLoadingMessage("Total chunk count is " .. count)

	ZVox.SetLoadBarChunkCount(count)
end

local updateMsgWait = 1 -- 1s
local nextUpdateMsg = 0


local buffAddBar = 0
local nextBarUpdate = 0




function ZVox.AddLoadScreenChunks(chunksReceived)
	buffAddBar = buffAddBar + chunksReceived

	if CurTime() > nextBarUpdate then -- fake stuttering so it feels realer
		nextBarUpdate = CurTime() + .025 + (math.random() * .4)

		ZVox.AddLoadBarProgress(buffAddBar)
		buffAddBar = 0
	end

	if CurTime() > nextUpdateMsg then
		ZVox.PushLoadingMessage("Chunk receive progress #" .. chunkCountCurrent .. "/" .. chunkCountTotal)

		nextUpdateMsg = CurTime() + updateMsgWait
	end
end