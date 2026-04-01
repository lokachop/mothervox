ZVox = ZVox or {}


local function attemptBuyHealth(amount)
	if ZVox.Health_GetHealthDelta() >= 1 then
		return
	end

	local amount = math.min(ZVox.Health_GetMaxHealthCanBuy(), amount)
	-- $50 / 3 hp
	local cost = amount * 16

	local canAfford = ZVox.Money_CanAfford(cost)
	if not canAfford then
		return
	end

	ZVox.Money_SpendMoney(math.ceil(cost))
	ZVox.Health_GainHealth(amount)
	surface.PlaySound("mothervox/sfx/ui/buy.wav")
end



ZVox.ConsumableVendor = ZVox.ConsumableVendor
ZVox.ConsumableVendorButton = ZVox.ConsumableVendorButton

local activeSelector = false
local activeCost = 0
local activeControl = "none"
local activeDesc = ZVox.ParseMarkup("<255,0,0>penis")
local activeName = ""
local activeIdx = 0

local function setButtonBuyTarget(consumableID)
	if not ZVox.ConsumableVendorButton then
		return
	end

	if not IsValid(ZVox.ConsumableVendorButton) then
		return
	end

	ZVox.ConsumableVendorButton:SetDisabled(false)
	activeSelector = true
	activeCost = ZVox.Consumable_GetCost(consumableID)
	activeControl = ZVox.Consumable_GetKeybind(consumableID)
	activeDesc = ZVox.ParseMarkup(ZVox.Consumable_GetDescription(consumableID))
	activeName = ZVox.Consumable_GetName(consumableID)

	ZVox.ConsumableVendorButton._targetID = consumableID
	activeIdx = consumableID
end

local function uvCorrect(u0, v0, u1, v1)
	local du = 0.5 / 32 -- half pixel anticorrection
	local dv = 0.5 / 32 -- half pixel anticorrection
	u0, v0 = (u0 - du) / (1 - 2 * du), (v0 - dv) / (1 - 2 * dv)
	u1, v1 = (u1 - du) / (1 - 2 * du), (v1 - dv) / (1 - 2 * dv)

	return u0, v0, u1, v1
end

local function makeConsumableButton(consumableID, parent)
	local btnMake = vgui.Create("DButton", parent)
	btnMake:SetWidth(96 + 8)
	btnMake:Dock(LEFT)
	btnMake:DockMargin(4, 0, 4, 0)
	btnMake:SetText("")

	local colCount = Color(39, 243, 35)
	function btnMake:Paint(w, h)
		local iconMat = ZVox.Consumable_GetIcon(consumableID)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(iconMat)
		surface.DrawTexturedRectUV(0, 0, w, h, uvCorrect(0, 0, 1, 1))

		if activeSelector and (activeIdx == consumableID) then
			local delta = ((CurTime() * 4) % 1)
			local truDelta = math.abs(.5 - delta) * 2


			surface.SetDrawColor(255, 255, 255, truDelta * 8)
			surface.DrawRect(0, 0, w, h)
		end


		surface.SetDrawColor(20, 64, 20)
		surface.DrawOutlinedRect(0, 0, w, h, 2)

		local count = ZVox.Consumable_GetCurrentCount(consumableID)
		if count > 0 then
			ZVox.DrawRetroText(self, "x" .. tostring(count), w - 6, h, colCount, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 3)
		end
	end

	function btnMake:DoClick()
		setButtonBuyTarget(consumableID)
	end
end


function ZVox.OpenConsumableVendor()
	if IsValid(ZVox.ConsumableVendor) then
		ZVox.ConsumableVendor:Close()
	end

	activeSelector = false

	ZVox.ConsumableVendor = vgui.Create("ZVUI_DFrame")
	ZVox.ConsumableVendor:SetSize(800, 600)
	ZVox.ConsumableVendor:Center()
	ZVox.ConsumableVendor:MakePopup()
	ZVox.ConsumableVendor:SetTitle("Consumable Vendor")
	ZVox.ConsumableVendor:SetDraggable(false)

	ZVox.ConsumableVendor._canClose = CurTime() + .5
	function ZVox.ConsumableVendor:OnClose()
		ZVox.DecrementPauseStack()
		ZVox.SetActiveSong("sound/mothervox/music/main.ogg")
	end

	function ZVox.ConsumableVendor:Think()
		if ZVox.ConsumableVendor._canClose > CurTime() then
			return
		end

		if ZVox.GetButtonDownKeyboardOnly() then
			self:Close()
		end
	end

	ZVox.SetActiveSong("sound/mothervox/music/shop.ogg")
	ZVox.IncrementPauseStack()


	local pnlShop = vgui.Create("DPanel", ZVox.ConsumableVendor)
	pnlShop:SetWidth(400 - 5 - 8)
	pnlShop:DockMargin(0, 0, 8, 0)
	pnlShop:Dock(LEFT)
	function pnlShop:Paint(w, h)
		--surface.SetDrawColor(255, 0, 0)
		--surface.DrawRect(0, 0, w, h)
	end

	local headerShop = vgui.Create("DPanel", pnlShop)
	headerShop:SetTall(64)
	headerShop:Dock(TOP)
	local colMoneyFG = Color(255, 203, 0)
	function headerShop:Paint(w, h)
		--surface.SetDrawColor(0, 0, 255)
		--surface.DrawRect(0, 0, w, h)

		local moneyStr = "$ " .. tostring(ZVox.Money_GetCurrentMoney())
		ZVox.DrawRetroText(self, moneyStr, 8, h / 2, colMoneyFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 5)
	end

	local shopContainer = vgui.Create("DPanel", pnlShop)
	shopContainer:SetTall(490 - 48)
	shopContainer:Dock(TOP)
	shopContainer:DockPadding(8, 8, 8, 8)
	function shopContainer:Paint(w, h)
		--surface.SetDrawColor(0, 255, 255)
		--surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(51, 61, 52)
		draw.RoundedBox(16, 0, 0, w, h, surface.GetDrawColor())

		surface.SetDrawColor(20, 33, 21)
		draw.RoundedBox(16, 4, 4, w - 8, h - 8, surface.GetDrawColor())
	end

	local btnRow1 = vgui.Create("DPanel", shopContainer)
	btnRow1:SetTall(96)
	btnRow1:Dock(TOP)
	btnRow1:DockMargin(16, 0, 16, 8)
	function btnRow1:Paint(w, h)
		--surface.SetDrawColor(0, 255, 0)
		--surface.DrawRect(0, 0, w, h)
	end

	for i = 1, 3 do
		makeConsumableButton(i, btnRow1)
	end

	local btnRow2 = vgui.Create("DPanel", shopContainer)
	btnRow2:SetTall(96)
	btnRow2:Dock(TOP)
	btnRow2:DockMargin(16, 0, 16, 0)
	function btnRow2:Paint(w, h)
		--surface.SetDrawColor(255, 0, 0)
		--surface.DrawRect(0, 0, w, h)
	end
	for i = 4, 6 do
		makeConsumableButton(i, btnRow2)
	end

	local shopInfoPanel = vgui.Create("DPanel", shopContainer)
	shopInfoPanel:SetTall(128 + 96 - 8)
	shopInfoPanel:Dock(TOP)
	shopInfoPanel:DockMargin(0, 8, 0, 0)

	local colText1 = Color(36, 199, 32)
	function shopInfoPanel:Paint(w, h)
		--surface.SetDrawColor(255, 0, 255)
		--surface.DrawRect(0, 0, w, h)
		if not activeSelector then
			return
		end

		ZVox.DrawRetroText(self, activeName, 0, 0, colText1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 4)
		ZVox.DrawRetroText(self, "$" .. tostring(activeCost), 0, 48, colText1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)

		local keyConsumable = ZVox.GetControlKey(activeControl)
		local keyNameConsumable = ZVox.GetButtonNiceName(keyConsumable)

		ZVox.DrawRetroText(self, "('" .. keyNameConsumable .. "' to use)", 128 + 128 + 96, 48, colText1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 3)

		ZVox.RenderMarkup(self, activeDesc, 3, 16, 48 + 32)
	end


	local shopContainerBtn = vgui.Create("DPanel", pnlShop)
	shopContainerBtn:SetTall(48)
	shopContainerBtn:Dock(TOP)
	shopContainerBtn:DockPadding(128, 4, 128, 4)
	function shopContainerBtn:Paint(w, h)
		--surface.SetDrawColor(255, 0, 128)
		--surface.DrawRect(0, 0, w, h)
	end

	ZVox.ConsumableVendorButton = vgui.Create("ZVUI_DButton", shopContainerBtn)
	ZVox.ConsumableVendorButton:SetTall(48)
	ZVox.ConsumableVendorButton:Dock(FILL)
	ZVox.ConsumableVendorButton:SetText("BUY")
	ZVox.ConsumableVendorButton:SetDisabled(true)

	function ZVox.ConsumableVendorButton:DoClick()
		local targetID = self._targetID
		if not targetID then
			return
		end

		local cost = ZVox.Consumable_GetCost(targetID)
		if not ZVox.Money_CanAfford(cost) then
			return
		end

		ZVox.Consumable_AddConsumable(targetID)
		ZVox.Money_SpendMoney(cost)
		surface.PlaySound("mothervox/sfx/ui/buy.wav")
	end


	local pnlHull = vgui.Create("DPanel", ZVox.ConsumableVendor)
	pnlHull:SetWidth(400 - 5 - 8)
	pnlHull:DockMargin(8, 0, 0, 0)
	pnlHull:Dock(LEFT)

	function pnlHull:Paint(w, h)
		--surface.SetDrawColor(0, 255, 0)
		--surface.DrawRect(0, 0, w, h)
	end


	local pnlCurrHullHealth = vgui.Create("DPanel", pnlHull)
	pnlCurrHullHealth:SetTall(128 + 64)
	pnlCurrHullHealth:Dock(TOP)

	local colCurrHull = Color(196, 196, 196)

	local colGradStart = Color(255, 255, 255, 8)
	local colGradEnd = Color(255, 255, 255, 32)
	function pnlCurrHullHealth:Paint(w, h)
		--surface.SetDrawColor(0, 0, 255)
		--surface.DrawRect(0, 0, w, h)

		ZVox.DrawRetroText(self, "Current Hull", w / 2, 8, colCurrHull, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 4)



		surface.SetDrawColor(255, 0, 0)
		surface.DrawRect(16, 48 + 8, w - 32, 48)

		local healthDelta = 1 - ZVox.Health_GetHealthDelta()
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(16, 48 + 8, (w - 32) * healthDelta, 48)


		ZVox.RenderGradientSRGB(16, 48 + 8, w - 32, 12, 16, colGradStart, colGradEnd)
		ZVox.RenderGradientSRGB(16, 48 + 8 + 12, w - 32, 36, 16, colGradEnd, colGradStart)

		local boxW = 128 + 64
		local boxH = 48
		local h_boxW = boxW * .5
		local h_boxH = boxH * .5

		surface.SetDrawColor(51, 61, 52)
		draw.RoundedBox(8, (w / 2) - h_boxW, 128, boxW, boxH, surface.GetDrawColor())

		surface.SetDrawColor(20, 33, 21)
		draw.RoundedBox(8, (w / 2) + 4 - h_boxW, 128 + 4, boxW - 8, boxH - 8, surface.GetDrawColor())

		local healthStr = tostring(math.floor(ZVox.Health_GetHealth())) .. "/" .. tostring(ZVox.Upgrades_GetMaxHullHealth()) .. " HP"

		ZVox.DrawRetroText(self, healthStr, (w / 2), 128 + h_boxH, colText1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3)
	end

	local rowContainer = vgui.Create("ZVUI_FancyDPanel", pnlHull)
	rowContainer:SetTall((96 + 24) * 3)
	rowContainer:Dock(TOP)

	local row1Health = vgui.Create("DPanel", rowContainer)
	row1Health:SetTall(96 + 24)
	row1Health:Dock(TOP)
	row1Health:DockPadding(8, 8, 8, 8)
	function row1Health:Paint(w, h)
		--surface.SetDrawColor(255, 0, 0)
		--surface.DrawRect(0, 0, w, h)
	end

	local row2Health = vgui.Create("DPanel", rowContainer)
	row2Health:SetTall(96 + 24)
	row2Health:Dock(TOP)
	row2Health:DockPadding(8, 8, 8, 8)
	function row2Health:Paint(w, h)
		--surface.SetDrawColor(255, 0, 255)
		--surface.DrawRect(0, 0, w, h)
	end

	local row3Health = vgui.Create("DPanel", rowContainer)
	row3Health:SetTall(96 + 24)
	row3Health:Dock(TOP)
	row3Health:DockPadding(8, 8, 8, 8)
	function row3Health:Paint(w, h)
		--surface.SetDrawColor(0, 255, 255)
		--surface.DrawRect(0, 0, w, h)
	end

	local button50 = vgui.Create("ZVUI_DButton", row1Health)
	button50:SetWidth((400 - 5 - 8 - 16) / 2 - 8)
	button50:DockMargin(0, 0, 8, 0)
	button50:Dock(LEFT)
	button50:SetText("$50")
	button50:SetTextFont("ZVUI_FrameTitleFont")
	function button50:DoClick()
		attemptBuyHealth(3)
	end

	local button100 = vgui.Create("ZVUI_DButton", row1Health)
	button100:SetWidth((400 - 5 - 8 - 16) / 2 - 8)
	button100:DockMargin(8, 0, 0, 0)
	button100:Dock(LEFT)
	button100:SetText("$100")
	button100:SetTextFont("ZVUI_FrameTitleFont")
	function button100:DoClick()
		attemptBuyHealth(6)
	end

	local button200 = vgui.Create("ZVUI_DButton", row2Health)
	button200:SetWidth((400 - 5 - 8 - 16) / 2 - 8)
	button200:DockMargin(0, 0, 8, 0)
	button200:Dock(LEFT)
	button200:SetText("$200")
	button200:SetTextFont("ZVUI_FrameTitleFont")
	function button200:DoClick()
		attemptBuyHealth(12)
	end


	local button500 = vgui.Create("ZVUI_DButton", row2Health)
	button500:SetWidth((400 - 5 - 8 - 16) / 2 - 8)
	button500:DockMargin(8, 0, 0, 0)
	button500:Dock(LEFT)
	button500:SetText("$500")
	button500:SetTextFont("ZVUI_FrameTitleFont")
	function button500:DoClick()
		attemptBuyHealth(30)
	end


	local buttonTotal = vgui.Create("ZVUI_DButton", row3Health)
	buttonTotal:SetWidth((400 - 5 - 8 - 16))
	buttonTotal:Dock(LEFT)
	buttonTotal:SetText("Total Repair")
	buttonTotal:SetTextFont("ZVUI_FrameTitleFont")
	function buttonTotal:DoClick()
		attemptBuyHealth(3000000)
	end

end