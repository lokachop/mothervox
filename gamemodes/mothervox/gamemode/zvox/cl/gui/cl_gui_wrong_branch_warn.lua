ZVox = ZVox or {}

local warnRT, warnMat = ZVox.NewRTMatPairPixelFunc("warning_pattern", 16, 16, function(x, y)
	local val = .9 + math.random() * .1

	x = x % 8
	y = y % 8

	if ( x + 2 > y and y + 2 > x ) or ( x - y > 6 ) or ( y - x > 6 ) then
		return 20 * val, 15 * val, 10 * val
	end

	return 220 * val, 96 * val, 96 * val
end)





local function uvCorrect(u0, v0, u1, v1)
	local du = 0.5 / 32 -- half pixel anticorrection
	local dv = 0.5 / 32 -- half pixel anticorrection
	u0, v0 = (u0 - du) / (1 - 2 * du), (v0 - dv) / (1 - 2 * dv)
	u1, v1 = (u1 - du) / (1 - 2 * du), (v1 - dv) / (1 - 2 * dv)

	return u0, v0, u1, v1
end


local branchLUT = {
	["unknown"] = "32 bit",
	["dev"] = "32 bit",
	["prerelease"] = "32 bit",
	["x86-64"] = "64 bit",
}


local texturizeW = 64
local texturizeH = texturizeW * 8
local texturizeIndexHash = texturizeW .. ":" .. texturizeH
local texturizeRT = GetRenderTarget("zvox_wrongbranch_texturize_rt_" .. texturizeIndexHash, texturizeW, texturizeH)
local texturizeMat = CreateMaterial("zvox_wrongbranch_texturize_mat" .. texturizeIndexHash, "UnlitGeneric", {
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

	return yVal * (196 + 64), yVal * (96 + 32), xD * 0
end)



local gameBranchStr = branchLUT[BRANCH] or "Unknown?"
ZVox.WrongBranchFrame = ZVox.WrongBranchFrame
ZVox.WrongBranchCoverPlane = ZVox.WrongBranchCoverPlane
function ZVox.OpenWrongBranchWarning()
	if IsValid(ZVox.WrongBranchFrame) then
		ZVox.WrongBranchCoverPlane:Remove()
		ZVox.WrongBranchFrame:Close()
	end


	-- make a panel that covers the background
	ZVox.WrongBranchCoverPlane = vgui.Create("DPanel")
	ZVox.WrongBranchCoverPlane:SetSize(ScrW(), ScrH())
	ZVox.WrongBranchCoverPlane:MakePopup()
	ZVox.WrongBranchCoverPlane:SetPopupStayAtBack(true)

	function ZVox.WrongBranchCoverPlane:Paint(w, h)
		DrawTexturize(32, texturizeMat)
		--ZVox.BlurScreen(16, 8)
	end


	ZVox.WrongBranchFrame = vgui.Create("ZVUI_DFrame")
	ZVox.WrongBranchFrame:SetSize(887, 600)
	ZVox.WrongBranchFrame:Center()
	ZVox.WrongBranchFrame:MakePopup()
	ZVox.WrongBranchFrame:SetTitle("Wrong Branch!")
	ZVox.WrongBranchFrame:ShowCloseButton(false)
	ZVox.WrongBranchFrame:SetDraggable(false)


	local pnlBase = vgui.Create("DPanel", ZVox.WrongBranchFrame)
	pnlBase:Dock(FILL)

	local texScl = 32
	local rectSz = 8
	function pnlBase:Paint(w, h)
		local uvW = w / texScl
		local uvH = h / texScl

		local tileAmountAddX = uvW / 15 -- hack to fix weird aliasing
		local tileAmountAddY = uvH / 15 -- refer to https://github.com/Facepunch/garrysmod-issues/issues/3173


		-- first make a mask
		render.SetStencilEnable(false)
		render.SetStencilTestMask(255)
		render.SetStencilWriteMask(255)
		render.SetStencilReferenceValue(0)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

		render.SetStencilEnable(true)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilReferenceValue(1)

		render.OverrideColorWriteEnable(true, false)
			surface.SetDrawColor(255, 0, 0)
			surface.DrawRect(rectSz, rectSz, w - (rectSz * 2), h - (rectSz * 2))
		render.OverrideColorWriteEnable(false, false)


		-- then render where that mask didn't render!
		render.SetStencilReferenceValue(0)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

		render.PushFilterMag(TEXFILTER.POINT)
		render.PushFilterMin(TEXFILTER.POINT)
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(warnMat)
			surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, uvW + tileAmountAddX, uvH + tileAmountAddY)
		render.PopFilterMag()
		render.PopFilterMin()

		render.SetStencilEnable(false)
	end
	pnlBase:DockPadding(rectSz, rectSz, rectSz, rectSz)


	local pnlInfoText = vgui.Create("DPanel", pnlBase)
	pnlInfoText:Dock(TOP)
	pnlInfoText:SetTall(512 - 64)


	local text = [[
<200:200:200>You are currently playing on a ]] .. gameBranchStr .. [[ branch of GMod
<200:200:200>The only officially supported branch is the x86-64 branch

<200:200:200>Using an unsupported branch has major issues
<200:200:200>which will cause and is not limited to:
<255:128:128>- Random unexpected game crashes
<255:128:128>- Worlds being corrupted and becoming irrecoverable
<255:128:128>- Config file being bricked
<255:128:128>- Skin preferences being wiped

<160:255:160>To fix this, please switch to the x86-64 branch
<160:255:160>Right click on GMod on Steam > Properties > Betas
<160:255:160>Then select the x86-64 - Chromium + 64 bit binaries
<80:80:80>(or if you want to risk it, press the button below)]]

	local textLines = string.Explode("\n", text, false)

	-- let me be honest, i just ported this shit from DeepDive
	-- code is ass
	local parsedLines = {}
	for k, v in pairs(textLines) do
		local col_indicator_splits = string.gmatch(v, "<%d+:%d+:%d+> *[^<]+")
		parsedLines[#parsedLines + 1] = {}
		local itrpointer = parsedLines[#parsedLines]

		for strdat in col_indicator_splits do
			local tstr = string.match(strdat, "<%d+:%d+:%d+> ?([^<]+)")
			local cstr = string.match(strdat, "(<%d+:%d+:%d+>)")
			local c_r, c_g, c_b = string.match(cstr, "<(%d+):(%d+):(%d+)>")
			c_r = tonumber(c_r)
			c_g = tonumber(c_g)
			c_b = tonumber(c_b)


			itrpointer[#itrpointer + 1] = {Color(c_r, c_g, c_b), tstr}
		end
	end




	local colWarn = Color(255, 96, 96)
	local colText = Color(200, 200, 200)
	function pnlInfoText:Paint(w, h)
		--surface.SetDrawColor(0, 255, 0)
		--surface.DrawRect(0, 0, w, h)

		ZVox.DrawRetroTextShadowed(self, "Wrong Branch!", w * .5, 8, colWarn, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 5)

		-- multiline text now?
		for i = 1, #parsedLines do
			local lines = parsedLines[i]

			local xAccum = 16
			for j = 1, #lines do
				local line = lines[j]
				if not line then
					continue
				end

				local textWidth = ZVox.DrawRetroTextShadowed(self, line[2], xAccum, 32 + i * 28, line[1], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
				xAccum = xAccum + (textWidth * 2)
			end
		end
	end

	local pnlAcknowledgeBtn = vgui.Create("DPanel", pnlBase)
	pnlAcknowledgeBtn:SetTall(64 + 26)
	pnlAcknowledgeBtn:Dock(TOP)

	function pnlAcknowledgeBtn:Paint(w, h)
	end

	pnlAcknowledgeBtn:DockPadding(128, 12, 128, 12)

	local btnAck = vgui.Create("ZVUI_DButton", pnlAcknowledgeBtn)
	btnAck:SetTall(64)
	btnAck:Dock(TOP)

	btnAck:SetText("I Acknowledge that I could lose my worlds [0/3]")
	btnAck:SetTextFont("ZVUI_FrameTitleFont")


	local msgs = {
		[1] = "I have nothing to lose whenever the game crashes [1/3]",
		[2] = "I don't fear data loss at all [2/3]",
		[3] = "I won't open an issue on the GitHub [3/3]",
	}

	local themes = {
		[1] = "standard",
		[2] = "semiscary",
		[3] = "scary",
	}


	local accumAck = 0
	function btnAck:DoClick()
		accumAck = accumAck + 1

		self:SetText(msgs[accumAck])
		self:SetDisabled(true)
		self:SetColourSkinName(themes[accumAck])

		timer.Simple(1, function()
			if not IsValid(self) then
				return
			end

			self:SetDisabled(false)
		end)

		if accumAck <= 3 then
			return
		end

		ZVox.WrongBranchCoverPlane:Remove()
		ZVox.WrongBranchFrame:Close()
	end


end

concommand.Add("zvox_open_wrong_branch_warning", function()
	ZVox.OpenWrongBranchWarning()
end)