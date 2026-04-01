ZVox = ZVox or {}

ZVox.EscapeMenuOpen = ZVox.EscapeMenuOpen or false
ZVox.EscapeMenuFrame = ZVox.EscapeMenuFrame

function ZVox.CloseEscapeMenu()
	if not IsValid(ZVox.EscapeMenuFrame) then
		return
	end

	ZVox.EscapeMenuFrame:Close()
end


function ZVox.OpenEscapeMenu()
	if IsValid(ZVox.EscapeMenuFrame) then
		if ZVOX_DO_UI_ESC_CLOSE then
			ZVox.EscapeMenuFrame:Close()
			return false
		end

		return true
	end


	local btnCount = 4

	ZVox.CloseInventory()
	ZVox.EscapeMenuOpen = true

	ZVox.EscapeMenuFrame = vgui.Create("ZVUI_DFrame")
	ZVox.EscapeMenuFrame:SetSize(400, 48 + (btnCount * 64))
	ZVox.EscapeMenuFrame:Center()
	ZVox.EscapeMenuFrame:MakePopup()
	ZVox.EscapeMenuFrame:SetTitle("ZVox Pause Menu")
	ZVox.EscapeMenuFrame:SetDraggable(false)
	--ZVox.EscapeMenuFrame:ShowCloseButton(false)


	function ZVox.EscapeMenuFrame:OnClose()
		ZVox.EscapeMenuOpen = false
	end

	local btnBackToGame = vgui.Create("ZVUI_DButton", ZVox.EscapeMenuFrame)
	btnBackToGame:SetTall(64)
	btnBackToGame:Dock(TOP)
	btnBackToGame:SetText("Back to the game...")
	function btnBackToGame:DoClick()
		if IsValid(ZVox.EscapeMenuFrame) then
			ZVox.EscapeMenuFrame:Close()
		end
	end

	local btnSettings = vgui.Create("ZVUI_DButton", ZVox.EscapeMenuFrame)
	btnSettings:SetTall(64)
	btnSettings:Dock(TOP)
	btnSettings:SetText("Change settings...")
	function btnSettings:DoClick()
		ZVox.OpenSettings()
	end

	local btnCredits = vgui.Create("ZVUI_DButton", ZVox.EscapeMenuFrame)
	btnCredits:SetTall(64)
	btnCredits:Dock(TOP)
	btnCredits:SetText("Read the credits...")
	function btnCredits:DoClick()
		ZVox.OpenCredits()
	end

	local btnLeave = vgui.Create("ZVUI_DButton", ZVox.EscapeMenuFrame)
	btnLeave:SetTall(64)
	btnLeave:Dock(TOP)
	btnLeave:SetText("Save and return to the main menu...")
	function btnLeave:DoClick()
		ZVox.MV_SaveProgress()
		net.Start("mothervox_save_world")
		net.SendToServer()

		ZVox.DisconnectFromUniverse()
	end

	return false
end

function ZVox.IsEscapeMenuOpen()
	return ZVox.EscapeMenuOpen
end


local texturizeW = 64
local texturizeH = texturizeW * 8

local texturizeIndexHash = texturizeW .. ":" .. texturizeH
local texturizeRT = GetRenderTarget("zvox_texturize_rt_" .. texturizeIndexHash, texturizeW, texturizeH)
local texturizeMat = CreateMaterial("zvox_texturize_mat" .. texturizeIndexHash, "UnlitGeneric", {
	["$basetexture"] = texturizeRT:GetName(),
	["$nocull"] = 1,
	["$ignorez"] = 1,
	["$vertexcolor"] = 1,
})
ZVox.PixelFuncOnRT(texturizeRT, function(x, y)
	local xD = x / texturizeRT:Width()
	local yD = y / texturizeRT:Height()

	local xChecker = math.floor(x / 32)
	local yChecker = math.floor(y / 32)
	local yVal = (((xChecker + yChecker) % 2) == 0) and yD or 0

	return yVal * 196, yVal * 96, xD * 96
end)




local colFlash = Color(255, 96, 96)
local colNoFlash = Color(255, 255, 255)
function ZVox.RenderPauseBlur()
	if not ZVox.EscapeMenuOpen then
		return
	end

	-- if this shit is on we also render a helper info
	if ZVOX_DO_UI_ESC_CLOSE then
		local colTarget = math.floor(CurTime() * 4) % 2 > 0 and colFlash or colNoFlash

		ZVox.DrawRetroTextShadowed(nil, "ESC to close Escape Menu is set!!!!", ScrW() * .5, 32, colTarget, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 4)
		ZVox.DrawRetroTextShadowed(nil, "SHIFT + ESC to open the GMod escape menu...", ScrW() * .5, 32 + 48, colTarget, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3)
	end
end