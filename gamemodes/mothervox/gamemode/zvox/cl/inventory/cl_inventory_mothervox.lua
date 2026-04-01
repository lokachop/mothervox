ZVox = ZVox or {}
ZVox.MV_InventoryFrame = ZVox.MV_InventoryFrame

function ZVox.MV_CloseInventory()
	if not IsValid(ZVox.MV_InventoryFrame) then
		return
	end

	ZVox.MV_InventoryFrame:Close()
	gui.EnableScreenClicker(false)
end


local function uvCorrect(u0, v0, u1, v1)
	local du = 0.5 / 32 -- half pixel anticorrection
	local dv = 0.5 / 32 -- half pixel anticorrection
	u0, v0 = (u0 - du) / (1 - 2 * du), (v0 - dv) / (1 - 2 * dv)
	u1, v1 = (u1 - du) / (1 - 2 * du), (v1 - dv) / (1 - 2 * dv)

	return u0, v0, u1, v1
end

local function capitalize(msg)
	return string.upper(msg[1]) .. string.sub(msg, 2)
end


local matVehicleHud = Material("mothervox/gui/vehicle-hud.png", "ignorez nocull")
local matDiscardArrow = Material("mothervox/gui/throw-out-arrow.png", "ignorez nocull")
function ZVox.MV_OpenInventory()
	if IsValid(ZVox.MV_InventoryFrame) then
		ZVox.CloseInventory()
		return
	end
	gui.EnableScreenClicker(true)

	ZVox.IncrementPauseStack()
	ZVox.MV_InventoryFrame = vgui.Create("ZVUI_DFrame")
	ZVox.MV_InventoryFrame:SetSize(800, 600)
	ZVox.MV_InventoryFrame:Center()
	ZVox.MV_InventoryFrame:ShowCloseButton(true)
	ZVox.MV_InventoryFrame:SetDraggable(false)
	ZVox.MV_InventoryFrame:SetTitle("MotherVox Inventory")


	function ZVox.MV_InventoryFrame:OnClose()
		gui.EnableScreenClicker(false)
		ZVox.DecrementPauseStack()
	end

	ZVox.MV_InventoryFrame._canClose = CurTime() + .5
	function ZVox.MV_InventoryFrame:Think()
		if self._canClose > CurTime() then
			return
		end

		if ZVox.GetButtonDownKeyboardOnly() then
			self:Close()
		end
	end

	local pnlLeft = vgui.Create("DPanel", ZVox.MV_InventoryFrame)
	pnlLeft:SetWide(400 - 6)
	pnlLeft:Dock(LEFT)

	function pnlLeft:Paint(w, h)
		--surface.SetDrawColor(255, 0, 0)
		--surface.DrawRect(0, 0, w, h)
	end
	local pnlCargoInfo = vgui.Create("DPanel", pnlLeft)
	pnlCargoInfo:SetTall(96)
	pnlCargoInfo:Dock(TOP)

	local colText = Color(38, 201, 37)
	function pnlCargoInfo:Paint(w, h)
		--surface.SetDrawColor(0, 0, 255)
		--surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(matVehicleHud)

		surface.DrawTexturedRectUV(4, 4, 128, 128, uvCorrect(0, 0, 1, 1))

		local cargoPerc = ZVox.Storage_GetStorageFilledDelta()
		cargoPerc = math.min(math.floor(cargoPerc * 100), 100)
		ZVox.DrawRetroText(self, "Cargo " .. tostring(cargoPerc) .. "% full", 128, 8, colText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)

		local oreCount = ZVox.Storage_GetTotalOreCount()
		local weight = 1980 + (oreCount * 10) -- cba with dynamic ore weight
		ZVox.DrawRetroText(self, tostring(weight) .. " Kg", 128, 8 + 32, colText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
		ZVox.DrawRetroText(self, "---------------------", 6, 8 + 64, colText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	end

	local pnlEquiment = vgui.Create("DPanel", pnlLeft)
	pnlEquiment:SetTall(256 + 48)
	pnlEquiment:Dock(TOP)

	local colText = Color(18, 226, 19)
	local colText2 = Color(18, 184, 19)
	function pnlEquiment:Paint(w, h)
		--surface.SetDrawColor(255, 0, 255)
		--surface.DrawRect(0, 0, w, h)

		ZVox.DrawRetroText(self, "EQUIPMENT", 4, 4, colText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 5)

		for i = 1, MV_PART_MAX do
			local partTier = ZVox.Upgrades_GetPartLevel(i)
			local partName = ZVox.Upgrades_GetPartName(i, partTier)

			local yC = i - 1
			yC = yC * 36
			ZVox.DrawRetroText(self, partName, 4, 4 + 48 + yC, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
		end
	end


	local pnlConsumables = vgui.Create("DPanel", pnlLeft)
	pnlConsumables:SetTall(96 + 32 + 10 + 16)
	pnlConsumables:Dock(TOP)
	function pnlConsumables:Paint(w, h)
		--surface.SetDrawColor(0, 255, 255)
		--surface.DrawRect(0, 0, w, h)

		for i = 1, 6 do
			local count = ZVox.Consumable_GetCurrentCount(i)
			local icon = ZVox.Consumable_GetIcon(i)
			if count <= 0 then
				surface.SetDrawColor(255, 255, 255, 96)
			else
				surface.SetDrawColor(255, 255, 255, 255)
			end

			local xOff = (i - 1) % 3
			xOff = xOff * (64 + 64)
			xOff = xOff + 16

			local yOff = math.floor((i - 1) / 3)
			yOff = yOff * (64 + 8)
			yOff = yOff + 8

			surface.SetMaterial(icon)
			surface.DrawTexturedRectUV(xOff, yOff, 64, 64, uvCorrect(0, 0, 1, 1))

			if count > 0 then
				ZVox.DrawRetroText(self, "x" .. tostring(count), xOff + 48, yOff + 32, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3)
			end
		end
	end


	local pnlRight = vgui.Create("DPanel", ZVox.MV_InventoryFrame)
	pnlRight:SetWide(400 - 6)
	pnlRight:Dock(LEFT)

	function pnlRight:Paint(w, h)
		--surface.SetDrawColor(0, 255, 0)
		--surface.DrawRect(0, 0, w, h)
		ZVUI.PaintCoolSurface(self, w, h)
	end

	local oreOrder = ZVox.Storage_GetOreOrderArray()
	for i = 1, #oreOrder do
		local oreName = oreOrder[i]
		local oreCount = ZVox.Storage_GetOreCount(oreName)
		local btnAdd = vgui.Create("DButton", pnlRight)
		btnAdd:SetTall(56)
		btnAdd:DockMargin(0, 4, 0, 0)
		btnAdd:Dock(TOP)
		btnAdd:SetText("")

		if oreCount <= 0 then
			btnAdd:SetDisabled(true)
			btnAdd:SetCursor("no")
		end

		function btnAdd:Paint(w, h)
			--surface.SetDrawColor(0, 0, 255)
			--surface.DrawRect(0, 0, w, h)

			local count = ZVox.Storage_GetOreCount(oreName)
			local iconMat = ZVox.Storage_GetOreIcon(oreName).mat
			if count <= 0 then
				surface.SetDrawColor(255, 255, 255, 96)
			else
				surface.SetDrawColor(255, 255, 255, 255)
			end

			surface.SetMaterial(iconMat)
			surface.DrawTexturedRect(0, 0, 56, 56)

			if count > 0 then
				ZVox.DrawRetroText(self, "x" .. tostring(count) .. " (" .. capitalize(oreName) .. ")", 64, 56 * .5, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3)


				if self:IsHovered() then
					surface.SetDrawColor(0, 0, 0, 128)
					surface.DrawRect(0, 0, w, h)

					local yDelta = (CurTime() * 2.5) % 1

					local whiteFlash = (CurTime() * 4) % 1

					surface.SetDrawColor(Lerp(whiteFlash, 18, 255), Lerp(whiteFlash, 184, 255), Lerp(whiteFlash, 19, 255), math.ease.OutCirc(1 - yDelta) * 255)
					surface.SetMaterial(matDiscardArrow)
					surface.DrawTexturedRectUV((56 * .5) - 16, (yDelta * 24), 32, 32, uvCorrect(0, 0, 1, 1))
				end
			end
		end

		function btnAdd:DoClick()
			ZVox.Storage_DiscardOre(oreName)
			surface.PlaySound("mothervox/sfx/ui/inv_drop.wav")

			local count = ZVox.Storage_GetOreCount(oreName)
			if count <= 0 then
				self:SetDisabled(true)
				self:SetCursor("no")
			end
		end
	end
end

ZVox.MV_CloseInventory()