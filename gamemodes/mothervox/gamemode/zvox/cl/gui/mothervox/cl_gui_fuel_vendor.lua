ZVox = ZVox or {}

ZVox.FuelVendorFrame = ZVox.FuelVendorFrame

local function attemptBuyFuel(amount)
	if ZVox.Fuel_GetPlayerFuelDelta() >= 1 then
		return
	end

	local amount = math.min(ZVox.Fuel_GetMaxFuelCanBuy(), amount)
	-- $1 / liter

	local canAfford = ZVox.Money_CanAfford(amount)
	if not canAfford then
		return
	end

	ZVox.Money_SpendMoney(math.ceil(amount))
	ZVox.Fuel_GainFuel(amount)
	surface.PlaySound("mothervox/sfx/ui/buy.wav")
end


function ZVox.OpenFuelVendor()
	if IsValid(ZVox.FuelVendorFrame) then
		ZVox.FuelVendorFrame:Close()
	end

	ZVox.FuelVendorFrame = vgui.Create("ZVUI_DFrame")
	ZVox.FuelVendorFrame:SetSize(800, 600)
	ZVox.FuelVendorFrame:Center()
	ZVox.FuelVendorFrame:MakePopup()
	ZVox.FuelVendorFrame:SetTitle("Fuel Vendor")
	ZVox.FuelVendorFrame:SetDraggable(false)

	ZVox.FuelVendorFrame._canClose = CurTime() + .5
	function ZVox.FuelVendorFrame:OnClose()
		ZVox.DecrementPauseStack()
		ZVox.SetActiveSong("sound/mothervox/music/main.ogg")
	end

	function ZVox.FuelVendorFrame:Think()
		if ZVox.FuelVendorFrame._canClose > CurTime() then
			return
		end

		if ZVox.GetButtonDownKeyboardOnly() then
			self:Close()
		end
	end
	ZVox.SetActiveSong("sound/mothervox/music/shop.ogg")
	ZVox.IncrementPauseStack()


	local colMoneyFG = Color(255, 203, 0)
	local colText = Color(255, 226, 82)
	local colText2 = Color(255, 255, 255)
	local colText3 = Color(64, 64, 64)
	local pnlTopBar = vgui.Create("DPanel", ZVox.FuelVendorFrame)
	pnlTopBar:SetTall(64 + 10)
	pnlTopBar:Dock(TOP)
	function pnlTopBar:Paint(w, h)
		--surface.SetDrawColor(128, 96, 255)
		--surface.DrawRect(0, 0, w, h)

		local moneyStr = "$ " .. tostring(ZVox.Money_GetCurrentMoney())
		ZVox.DrawRetroText(self, moneyStr, 8, h / 2, colMoneyFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 5)

		-- stencil BULLLSHIIIT
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
		surface.DrawRect(200, 4, 512 + 128, 24 + 1)
		render.OverrideColorWriteEnable(false, false)

		render.SetStencilReferenceValue(1)
		render.SetStencilPassOperation(STENCILOPERATION_KEEP)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		ZVox.DrawRetroText(self, "Fuel Vendor 12000", 295, 4, colText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 5)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
		ZVox.DrawRetroText(self, "Fuel Vendor 12000", 295, 4, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 5)

		render.SetStencilEnable(false)

		-- here yo fucking go again loka tacking on ss13 onto places it doesn't fit
		local tW = ZVox.DrawRetroText(self, "Phoron free!", 295, 4 + 32 + 16, colText3, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2)

		ZVox.DrawRetroText(self, "*", 295 + tW + 2, 4 + 32 + 16, colText3, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1)
	end

	local pnlOtherBase = vgui.Create("DPanel", ZVox.FuelVendorFrame)
	pnlOtherBase:Dock(FILL)
	function pnlOtherBase:Paint(w, h)
	end


	local pnlBarPump = vgui.Create("DPanel", pnlOtherBase)
	pnlBarPump:SetWidth(300 - 6)
	pnlBarPump:Dock(LEFT)
	local colCurrFuelText = Color(196, 196, 196)
	local colTextFuel = Color(35, 142, 31)

	local colGradStart = Color(255, 255, 255, 8)
	local colGradEnd = Color(255, 255, 255, 32)
	function pnlBarPump:Paint(w, h)
		--surface.SetDrawColor(255, 0, 0)
		--surface.DrawRect(0, 0, w, h)


		ZVox.DrawRetroText(self, "Current Fuel", (w / 2), 8, colCurrFuelText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3)

		surface.SetDrawColor(16, 19, 15)
		surface.DrawRect((w / 2) - 96, h - 48 - 16, 192, 48)

		surface.SetDrawColor(35, 40, 32)
		surface.DrawRect((w / 2) - 96 + 2, h - 48 - 16 + 2, 192 - 4, 48 - 4)

		local fuelVal = math.floor(ZVox.Fuel_GetPlayerFuel())
		local fuelMax = math.floor(ZVox.Fuel_GetPlayerMaxFuel())

		ZVox.DrawRetroText(self, fuelVal .. "/" .. fuelMax .. " L", (w / 2), h - 24 - 16, colTextFuel, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3)


		surface.SetDrawColor(111, 94, 48)
		surface.DrawRect((w / 2) - 32, 32 + 16, 64, h - 128)

		local fuelDelta = 1 - ZVox.Fuel_GetPlayerFuelDelta()
		surface.SetDrawColor(28, 22, 16)
		surface.DrawRect((w / 2) - 32, 32 + 16, 64, (h - 128) * fuelDelta)

		ZVox.RenderGradientSRGBHorizontal((w / 2) - 32, 32 + 16, 64 - 40, h - 128, 16, colGradStart, colGradEnd)
		ZVox.RenderGradientSRGBHorizontal((w / 2) - 32 + 24, 32 + 16, 40, h - 128, 16, colGradEnd, colGradStart)

		ZVox.DrawRetroText(self, "* only in select locations nowhere near the spinward sector.", 0, h, colText3, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1)
	end


	local pnlButtons = vgui.Create("DPanel", pnlOtherBase)
	pnlButtons:SetWidth(500 - 6)
	pnlButtons:Dock(LEFT)
	function pnlButtons:Paint(w, h)
		--surface.SetDrawColor(0, 255, 0)
		--surface.DrawRect(0, 0, w, h)

		ZVUI.PaintCoolSurface(self, w, h)
	end

	local pnlFirstRowButtons = vgui.Create("DPanel", pnlButtons)
	pnlFirstRowButtons:SetTall(128 + 32)
	pnlFirstRowButtons:Dock(TOP)
	pnlFirstRowButtons:DockPadding(8, 8, 8, 8)
	function pnlFirstRowButtons:Paint(w, h)
		--surface.SetDrawColor(0, 0, 255)
		--surface.DrawRect(0, 0, w, h)
	end

	local btn5Bucks = vgui.Create("ZVUI_DButton", pnlFirstRowButtons)
	btn5Bucks:SetWide(196 + 32)
	btn5Bucks:Dock(LEFT)
	btn5Bucks:SetText("$5")
	btn5Bucks:SetTextFont("ZVUI_FrameTitleFont")
	function btn5Bucks:DoClick()
		attemptBuyFuel(5)
	end

	local btn10Bucks = vgui.Create("ZVUI_DButton", pnlFirstRowButtons)
	btn10Bucks:SetWide(196 + 32)
	btn10Bucks:Dock(RIGHT)
	btn10Bucks:SetText("$10")
	btn10Bucks:SetTextFont("ZVUI_FrameTitleFont")
	function btn10Bucks:DoClick()
		attemptBuyFuel(10)
	end


	local pnlSecondRowButtons = vgui.Create("DPanel", pnlButtons)
	pnlSecondRowButtons:SetTall(128 + 32)
	pnlSecondRowButtons:Dock(TOP)
	pnlSecondRowButtons:DockPadding(8, 8, 8, 8)
	function pnlSecondRowButtons:Paint(w, h)
		--surface.SetDrawColor(255, 0, 255)
		--surface.DrawRect(0, 0, w, h)
	end


	local btn25Bucks = vgui.Create("ZVUI_DButton", pnlSecondRowButtons)
	btn25Bucks:SetWide(196 + 32)
	btn25Bucks:Dock(LEFT)
	btn25Bucks:SetText("$25")
	btn25Bucks:SetTextFont("ZVUI_FrameTitleFont")
	function btn25Bucks:DoClick()
		attemptBuyFuel(25)
	end

	local btn50Bucks = vgui.Create("ZVUI_DButton", pnlSecondRowButtons)
	btn50Bucks:SetWide(196 + 32)
	btn50Bucks:Dock(RIGHT)
	btn50Bucks:SetText("$50")
	btn50Bucks:SetTextFont("ZVUI_FrameTitleFont")
	function btn50Bucks:DoClick()
		attemptBuyFuel(50)
	end

	local pnlThirdRowButtons = vgui.Create("DPanel", pnlButtons)
	pnlThirdRowButtons:SetTall(128 + 32)
	pnlThirdRowButtons:Dock(TOP)
	pnlThirdRowButtons:DockPadding(8, 8, 8, 8)
	function pnlThirdRowButtons:Paint(w, h)
		--surface.SetDrawColor(255, 255, 0)
		--surface.DrawRect(0, 0, w, h)
	end

	local btnFillTank = vgui.Create("ZVUI_DButton", pnlThirdRowButtons)
	btnFillTank:SetWide(196 + 32)
	btnFillTank:Dock(FILL)
	btnFillTank:SetText("Fill Tank")
	btnFillTank:SetTextFont("ZVUI_FrameTitleFont")
	function btnFillTank:DoClick()
		attemptBuyFuel(512000)
	end
end