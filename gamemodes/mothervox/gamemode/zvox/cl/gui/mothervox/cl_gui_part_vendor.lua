ZVox = ZVox or {}


local activeSelector = false
local activeUpgrade = "6 range, 4 / s"
local activeCost = 500000
local activePartName = "Energy-Temporalium Hull"
local activeIdx = 1


ZVox.PartVendorScreenPanel = ZVox.PartVendorScreenPanel
ZVox.PartVendorTopNavScreen = ZVox.PartVendorTopNavScreen
ZVox.PartVendorBuyButton = ZVox.PartVendorBuyButton
local function clearScreenPanel()
	for k, v in pairs(ZVox.PartVendorScreenPanel:GetChildren()) do
		v:Remove()
	end

	activeSelector = false

	if IsValid(ZVox.PartVendorBuyButton) then
		ZVox.PartVendorBuyButton:SetDisabled(true)
	end
end


local function setButtonBuyTarget(cat, tier)
	if not ZVox.PartVendorBuyButton then
		return
	end

	if not IsValid(ZVox.PartVendorBuyButton) then
		return
	end

	if not cat then
		ZVox.PartVendorBuyButton:SetDisabled(true)
		return
	end

	local lvlCat = ZVox.Upgrades_GetPartLevel(cat)
	if lvlCat >= tier then
		ZVox.PartVendorBuyButton:SetDisabled(true)
		return
	end

	ZVox.PartVendorBuyButton:SetDisabled(false)
	ZVox.PartVendorBuyButton._buyCategory = cat
	ZVox.PartVendorBuyButton._buyTier = tier
end



local activeDefault = ""
local changeStack = 0
local function makeOnHoverHooks(pnl, msg)
	pnl._prevHover = false
	function pnl:Think()
		local isHover = self:IsHovered()

		if isHover and not self._prevHover then
			self._prevHover = true
			ZVox.PartVendorTopNavScreen._msg = msg
			changeStack = changeStack + 1
		elseif not isHover and self._prevHover then
			self._prevHover = false
			changeStack = changeStack - 1

			if changeStack <= 0 then
				ZVox.PartVendorTopNavScreen._msg = activeDefault
			end
		end
	end
end


local catToDefaultMsgLUT = {
	[MV_PART_DRILL] = "DRILL",
	[MV_PART_HULL] = "HULL",
	[MV_PART_ENGINE] = "ENGINE",
	[MV_PART_FUEL_TANK] = "FUEL TANK",
	[MV_PART_RADIATOR] = "RADIATOR",
	[MV_PART_STORAGE_BAY] = "CARGO BAY",
	[MV_PART_SENSOR] = "SENSOR",
}

local function uvCorrect(u0, v0, u1, v1)
	local du = 0.5 / 32 -- half pixel anticorrection
	local dv = 0.5 / 32 -- half pixel anticorrection
	u0, v0 = (u0 - du) / (1 - 2 * du), (v0 - dv) / (1 - 2 * dv)
	u1, v1 = (u1 - du) / (1 - 2 * du), (v1 - dv) / (1 - 2 * dv)

	return u0, v0, u1, v1
end

local function makePartButton(parent, cat, itr)
	local btnPanel = vgui.Create("DButton", parent)
	btnPanel:SetWidth(140 - 8)
	btnPanel:DockMargin(4, 4, 4, 4)
	btnPanel:SetText("")
	btnPanel:Dock(LEFT)

	local colGradStart = Color(128, 128, 128, 12)
	local colGradEnd = Color(128, 128, 128, 0)
	function btnPanel:Paint(w, h)
		surface.SetDrawColor(17, 21, 18)
		surface.DrawRect(0, 0, w, h)

		ZVox.RenderGradientSRGB(0, 0, w, 32, 8, colGradStart, colGradEnd)

		local partIcon = ZVox.Upgrades_GetPartIcon(cat, itr)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(partIcon)

		surface.DrawTexturedRectUV(0, 0, w, h, uvCorrect(0, 0, 1, 1))


		if activeSelector and (activeIdx == itr) then
			local delta = ((CurTime() * 4) % 1)
			local truDelta = math.abs(.5 - delta) * 2


			surface.SetDrawColor(255, 255, 255, truDelta * 8)
			surface.DrawRect(0, 0, w, h)
		end

		surface.SetDrawColor(20, 64, 20)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
	end

	function btnPanel:DoClick()
		activeIdx = itr
		activeSelector = true

		activePartName = ZVox.Upgrades_GetPartName(cat, itr)
		activeCost = ZVox.Upgrades_GetCostForPartLevel(itr)
		activeUpgrade = ZVox.Upgrades_GetPartDesc(cat, itr)


		setButtonBuyTarget(cat, itr)
	end
end



function ZVox.MakePartCategory(cat)
	clearScreenPanel()
	activeDefault = catToDefaultMsgLUT[cat]



	local pnlLeftThing = vgui.Create("DPanel", ZVox.PartVendorScreenPanel)
	pnlLeftThing:SetWidth(256)
	pnlLeftThing:Dock(LEFT)

	function pnlLeftThing:Paint(w, h)
		--surface.SetDrawColor(255, 0, 0)
		--surface.DrawRect(0, 0, w, h)
	end

	local pnlLeftInfo = vgui.Create("DPanel", pnlLeftThing)
	pnlLeftInfo:SetTall(305)
	pnlLeftInfo:Dock(TOP)

	local colText = Color(25, 189, 26)
	local colText2 = Color(17, 143, 18)

	local colGradStart = Color(128, 128, 128, 12)
	local colGradEnd = Color(128, 128, 128, 0)
	function pnlLeftInfo:Paint(w, h)
		--surface.SetDrawColor(0, 0, 255)
		--surface.DrawRect(0, 0, w, h)

		local currTier = ZVox.Upgrades_GetPartLevel(cat)
		local partName = ZVox.Upgrades_GetPartName(cat, currTier)
		local partIcon = ZVox.Upgrades_GetPartIcon(cat, currTier)

		ZVox.DrawRetroText(self, "CURRENT:", 4, 0, colText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)

		surface.SetDrawColor(17, 21, 18)
		surface.DrawRect(4, 32, 96, 96)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(partIcon)
		surface.DrawTexturedRect(4, 32, 96, 96)


		surface.SetDrawColor(255, 255, 0, 8)
		surface.DrawRect(4, 32, 96, 96)

		surface.SetDrawColor(99, 103, 13)
		surface.DrawOutlinedRect(4, 32, 96, 96, 1)

		ZVox.RenderGradientSRGB(4, 32, 96, 32, 8, colGradStart, colGradEnd)



		ZVox.DrawRetroText(self, partName, 4, 32 + 96 + 4, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
		ZVox.DrawRetroText(self, "------------", 4, 32 + 96 + 4 + 32, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)

		if activeSelector then
			ZVox.DrawRetroText(self, activeUpgrade, 4, 32 + 96 + 4 + 32 + 48, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
			ZVox.DrawRetroText(self, "$" .. tostring(activeCost), 4, 32 + 96 + 4 + 32 + 48 + 48, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
		end
	end

	ZVox.PartVendorBuyButton = vgui.Create("ZVUI_DButton", pnlLeftThing)
	ZVox.PartVendorBuyButton:SetTall(32)
	ZVox.PartVendorBuyButton:Dock(TOP)
	ZVox.PartVendorBuyButton:SetText("[PURCHASE]")
	ZVox.PartVendorBuyButton:SetTextFont("ZVUI_FrameTitleFont")
	ZVox.PartVendorBuyButton:SetDisabled(true)

	function ZVox.PartVendorBuyButton:DoClick()
		-- try buy
		local category = self._buyCategory
		local tier = self._buyTier

		local cost = ZVox.Upgrades_GetCostForPartLevel(tier)

		if not ZVox.Money_CanAfford(cost) then
			return
		end

		local didUpgrade = ZVox.Upgrades_UpgradePart(category, tier)
		if not didUpgrade then
			return
		end

		ZVox.Money_SpendMoney(cost)
		surface.PlaySound("mothervox/sfx/ui/buy.wav")
		self:SetDisabled(true)
	end

	local pnlRightAvailableUpgrades = vgui.Create("DPanel", ZVox.PartVendorScreenPanel)
	pnlRightAvailableUpgrades:SetWidth(256 + 128 + 32 + 4)
	pnlRightAvailableUpgrades:Dock(LEFT)

	function pnlRightAvailableUpgrades:Paint(w, h)
		--surface.SetDrawColor(0, 255, 0)
		--surface.DrawRect(0, 0, w, h)
	end

	local topPnlAvailUpgrades = vgui.Create("DPanel", pnlRightAvailableUpgrades)
	topPnlAvailUpgrades:SetTall(33)
	topPnlAvailUpgrades:Dock(TOP)

	function topPnlAvailUpgrades:Paint(w, h)
		--surface.SetDrawColor(255, 0, 255)
		--surface.DrawRect(0, 0, w, h)

		ZVox.DrawRetroText(self, "AVAILABLE UPGRADES:", 4, 0, colText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	end

	local row1Upgrades = vgui.Create("DPanel", pnlRightAvailableUpgrades)
	row1Upgrades:SetTall(128 + 8)
	row1Upgrades:Dock(TOP)
	function row1Upgrades:Paint(w, h)
		--surface.SetDrawColor(128, 0, 255)
		--surface.DrawRect(0, 0, w, h)
	end

	local maxLvl = ZVox.Upgrades_GetMaxLevelForPart(cat)
	for i = 1, 3 do
		makePartButton(row1Upgrades, cat, i)
	end

	local row2Upgrades = vgui.Create("DPanel", pnlRightAvailableUpgrades)
	row2Upgrades:SetTall(128 + 8)
	row2Upgrades:Dock(TOP)
	function row2Upgrades:Paint(w, h)
		--surface.SetDrawColor(0, 128, 255)
		--surface.DrawRect(0, 0, w, h)
	end

	for i = 4, maxLvl do
		makePartButton(row2Upgrades, cat, i)
	end

	local pnlOptBuy = vgui.Create("DPanel", pnlRightAvailableUpgrades)
	pnlOptBuy:SetTall(32)
	pnlOptBuy:Dock(TOP)

	function pnlOptBuy:Paint(w, h)
		--surface.SetDrawColor(128, 128, 255)
		--surface.DrawRect(0, 0, w, h)

		if activeSelector then
			ZVox.DrawRetroText(self, activePartName, 4, 0, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
		end
	end
end



ZVox.PartVendor = ZVox.PartVendor
function ZVox.OpenPartVendor()
	changeStack = 0
	activeDefault = ""

	if IsValid(ZVox.PartVendor) then
		ZVox.PartVendor:Close()
	end

	ZVox.PartVendor = vgui.Create("ZVUI_DFrame")
	ZVox.PartVendor:SetSize(800, 600)
	ZVox.PartVendor:Center()
	ZVox.PartVendor:MakePopup()
	ZVox.PartVendor:SetTitle("Part Vendor")
	ZVox.PartVendor:SetDraggable(false)

	ZVox.PartVendor._canClose = CurTime() + .5
	function ZVox.PartVendor:OnClose()
		ZVox.DecrementPauseStack()
		ZVox.SetActiveSong("sound/mothervox/music/main.ogg")
	end

	function ZVox.PartVendor:Think()
		if ZVox.PartVendor._canClose > CurTime() then
			return
		end

		if ZVox.GetButtonDownKeyboardOnly() then
			self:Close()
		end
	end

	ZVox.SetActiveSong("sound/mothervox/music/shop.ogg")
	ZVox.IncrementPauseStack()

	local pnlTopShit = vgui.Create("DPanel", ZVox.PartVendor)
	pnlTopShit:SetTall(96 + 16)
	pnlTopShit:Dock(TOP)

	local colAutoBuy = Color(255, 255, 255)
	local col2k = Color(255, 32, 16)
	function pnlTopShit:Paint(w, h)
		--surface.SetDrawColor(255, 0, 0)
		--surface.DrawRect(0, 0, w, h)

		local autoW = ZVox.DrawRetroText(self, "Auto", 400, 4, colAutoBuy, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 9)
		ZVox.DrawRetroText(self, "Buy", 400 + autoW + 4, 4, colAutoBuy, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 5)
		ZVox.DrawRetroText(self, "2000", 400 + autoW + 16, 4 + 48 + 4, col2k, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 6)
	end

	local pnlTopSignContainer = vgui.Create("DPanel", pnlTopShit)
	pnlTopSignContainer:SetWidth(400 - 5)
	pnlTopSignContainer:Dock(LEFT)
	pnlTopSignContainer:DockPadding(4, 4, 4, 4)
	function pnlTopSignContainer:Paint(w, h)
	end

	local topNavScreenCont = vgui.Create("DPanel", pnlTopSignContainer)
	topNavScreenCont:SetTall(48 - 6)
	topNavScreenCont:Dock(TOP)
	topNavScreenCont:DockPadding(64, 4, 64, 4)
	function topNavScreenCont:Paint(w, h)
		surface.SetDrawColor(67, 68, 66)
		draw.RoundedBox(8, 0, 0, w, h, surface.GetDrawColor())
	end

	ZVox.PartVendorTopNavScreen = vgui.Create("DPanel", topNavScreenCont)
	ZVox.PartVendorTopNavScreen:Dock(FILL)
	ZVox.PartVendorTopNavScreen._msg = ""

	local colScr = Color(25, 172, 16)
	function ZVox.PartVendorTopNavScreen:Paint(w, h)
		surface.SetDrawColor(105, 128, 83)
		draw.RoundedBox(8, 0, 0, w, h, surface.GetDrawColor())

		surface.SetDrawColor(25, 44, 16)
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, surface.GetDrawColor())

		ZVox.DrawRetroText(self, self._msg, 4, 4, colScr, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	end

	local bottomNavButtons = vgui.Create("DPanel", pnlTopSignContainer)
	bottomNavButtons:SetTall((48 - 6) + 16)
	bottomNavButtons:Dock(BOTTOM)
	bottomNavButtons:DockPadding(1, 4, 0, 12)
	function bottomNavButtons:Paint(w, h)
		surface.SetDrawColor(67, 68, 66)
		draw.RoundedBox(8, 0, 0, w, h, surface.GetDrawColor())
	end


	local pnlTopShitTwo = vgui.Create("DPanel", ZVox.PartVendor)
	pnlTopShitTwo:SetTall(48)
	pnlTopShitTwo:Dock(TOP)

	local colMoneyFG = Color(255, 203, 0)
	function pnlTopShitTwo:Paint(w, h)
		--surface.SetDrawColor(0, 255, 0)
		--surface.DrawRect(0, 0, w, h)

		local moneyStr = "$ " .. tostring(ZVox.Money_GetCurrentMoney())
		ZVox.DrawRetroText(self, moneyStr, 48, 4 + h / 2, colMoneyFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 5)
	end


	local pnlScreenBase = vgui.Create("DPanel", ZVox.PartVendor)
	pnlScreenBase:SetTall(460 - 51 - 16)
	pnlScreenBase:Dock(TOP)
	pnlScreenBase:DockPadding(48, 8, 48, 32)
	function pnlScreenBase:Paint(w, h)
		--surface.SetDrawColor(255, 255, 0)
		--surface.DrawRect(0, 0, w, h)
	end

	ZVox.PartVendorScreenPanel = vgui.Create("DPanel", pnlScreenBase)
	ZVox.PartVendorScreenPanel:Dock(FILL)
	ZVox.PartVendorScreenPanel:DockPadding(8, 8, 8, 8)
	function ZVox.PartVendorScreenPanel:Paint(w, h)
		surface.SetDrawColor(51, 61, 52)
		draw.RoundedBox(8, 0, 0, w, h, surface.GetDrawColor())

		surface.SetDrawColor(20, 33, 21)
		draw.RoundedBox(8, 4, 4, w - 8, h - 8, surface.GetDrawColor())
	end

	local pnlTextDefault = vgui.Create("DPanel", ZVox.PartVendorScreenPanel)
	pnlTextDefault:Dock(FILL)

	local markupStr = ""
	markupStr = markupStr .. "<25,189,26>Welcome to the part vendor!\n"
	markupStr = markupStr .. " \n"
	markupStr = markupStr .. "<25,189,26>If you're looking to enhance your\n"
	markupStr = markupStr .. "<25,189,26>digging machine, you've come to the\n"
	markupStr = markupStr .. "<25,189,26>right place!\n"
	markupStr = markupStr .. " \n"
	markupStr = markupStr .. "<25,189,26>You can browse the different\n"
	markupStr = markupStr .. "<25,189,26>upgrade categories using the\n"
	markupStr = markupStr .. "<25,189,26>buttons above."

	local msgParse = ZVox.ParseMarkup(markupStr)
	function pnlTextDefault:Paint(w, h)
		ZVox.RenderMarkup(self, msgParse, 3)
	end

	local btnMargin = 3
	local btnIconScale = 2

	-- buttons
	local btnDrill = vgui.Create("ZVUI_DButton", bottomNavButtons)
	btnDrill:SetSize(42, 42)
	btnDrill:Dock(LEFT)
	btnDrill:SetText("")
	btnDrill:SetImage("drill-icon")
	btnDrill:SetImageScale(btnIconScale)
	btnDrill:DockMargin(btnMargin, 0, btnMargin, 0)
	makeOnHoverHooks(btnDrill, "DRILL")
	function btnDrill:DoClick()
		ZVox.MakePartCategory(MV_PART_DRILL)
	end

	local btnHull = vgui.Create("ZVUI_DButton", bottomNavButtons)
	btnHull:SetSize(42, 42)
	btnHull:Dock(LEFT)
	btnHull:SetText("")
	btnHull:SetImage("hull-icon")
	btnHull:SetImageScale(btnIconScale)
	btnHull:DockMargin(btnMargin, 0, btnMargin, 0)
	makeOnHoverHooks(btnHull, "HULL")
	function btnHull:DoClick()
		ZVox.MakePartCategory(MV_PART_HULL)
	end

	local btnEngine = vgui.Create("ZVUI_DButton", bottomNavButtons)
	btnEngine:SetSize(42, 42)
	btnEngine:Dock(LEFT)
	btnEngine:SetText("")
	btnEngine:SetImage("engine-icon")
	btnEngine:SetImageScale(btnIconScale)
	btnEngine:DockMargin(btnMargin, 0, btnMargin, 0)
	makeOnHoverHooks(btnEngine, "ENGINE")
	function btnEngine:DoClick()
		ZVox.MakePartCategory(MV_PART_ENGINE)
	end

	local btnFuelTank = vgui.Create("ZVUI_DButton", bottomNavButtons)
	btnFuelTank:SetSize(42, 42)
	btnFuelTank:Dock(LEFT)
	btnFuelTank:SetText("")
	btnFuelTank:SetImage("fuel-icon")
	btnFuelTank:SetImageScale(btnIconScale)
	btnFuelTank:DockMargin(btnMargin, 0, btnMargin, 0)
	makeOnHoverHooks(btnFuelTank, "FUEL TANK")
	function btnFuelTank:DoClick()
		ZVox.MakePartCategory(MV_PART_FUEL_TANK)
	end

	local btnRadiator = vgui.Create("ZVUI_DButton", bottomNavButtons)
	btnRadiator:SetSize(42, 42)
	btnRadiator:Dock(LEFT)
	btnRadiator:SetText("")
	btnRadiator:SetImage("radiator-icon")
	btnRadiator:SetImageScale(btnIconScale)
	btnRadiator:DockMargin(btnMargin, 0, btnMargin, 0)
	makeOnHoverHooks(btnRadiator, "RADIATOR")
	function btnRadiator:DoClick()
		ZVox.MakePartCategory(MV_PART_RADIATOR)
	end

	local btnStorage = vgui.Create("ZVUI_DButton", bottomNavButtons)
	btnStorage:SetSize(42, 42)
	btnStorage:Dock(LEFT)
	btnStorage:SetText("")
	btnStorage:SetImage("cargo-icon")
	btnStorage:SetImageScale(btnIconScale)
	btnStorage:DockMargin(btnMargin, 0, btnMargin, 0)
	makeOnHoverHooks(btnStorage, "CARGO BAY")
	function btnStorage:DoClick()
		ZVox.MakePartCategory(MV_PART_STORAGE_BAY)
	end

	local btnSensor = vgui.Create("ZVUI_DButton", bottomNavButtons)
	btnSensor:SetSize(42, 42)
	btnSensor:Dock(LEFT)
	btnSensor:SetText("")
	btnSensor:SetImage("sensor-icon")
	btnSensor:SetImageScale(btnIconScale)
	btnSensor:DockMargin(btnMargin, 0, btnMargin, 0)
	makeOnHoverHooks(btnSensor, "SENSOR")
	function btnSensor:DoClick()
		ZVox.MakePartCategory(MV_PART_SENSOR)
	end

	local btnExit = vgui.Create("ZVUI_DButton", bottomNavButtons)
	btnExit:SetSize(42, 42)
	btnExit:Dock(LEFT)
	btnExit:SetText("")
	btnExit:SetImage("close")
	btnExit:SetImageScale(btnIconScale)
	btnExit:DockMargin(btnMargin, 0, btnMargin, 0)
	makeOnHoverHooks(btnExit, "EXIT")
	function btnExit:DoClick()
		ZVox.PartVendor:Close()
	end
end