ZVox = ZVox or {}

local function capitalize(msg)
	return string.upper(msg[1]) .. string.sub(msg, 2)
end

ZVox.OreVendorFrame = ZVox.OreVendorFrame
function ZVox.OpenOreVendor()
	if IsValid(ZVox.OreVendorFrame) then
		ZVox.OreVendorFrame:Close()
	end

	ZVox.OreVendorFrame = vgui.Create("ZVUI_DFrame")
	ZVox.OreVendorFrame:SetSize(800, 600)
	ZVox.OreVendorFrame:Center()
	ZVox.OreVendorFrame:MakePopup()
	ZVox.OreVendorFrame:SetTitle("Ore Vendor")
	ZVox.OreVendorFrame:SetDraggable(false)

	ZVox.OreVendorFrame._canClose = CurTime() + .5
	function ZVox.OreVendorFrame:OnClose()
		ZVox.DecrementPauseStack()
		ZVox.SetActiveSong("sound/mothervox/music/main.ogg")
	end

	function ZVox.OreVendorFrame:Think()
		if ZVox.OreVendorFrame._canClose > CurTime() then
			return
		end

		if ZVox.GetButtonDownKeyboardOnly() then
			self:Close()
		end
	end

	ZVox.SetActiveSong("sound/mothervox/music/shop.ogg")
	ZVox.IncrementPauseStack()


	local pnlOreVendor = vgui.Create("DPanel", ZVox.OreVendorFrame)
	pnlOreVendor:Dock(FILL)

	local colText = Color(24, 227, 21)
	local colText2 = Color(20, 186, 20)
	function pnlOreVendor:Paint(w, h)
		ZVUI.PaintCoolSurface(self, w, h - 64)

		local oreOrder = ZVox.Storage_GetOreOrderArray()
		for i = 1, #oreOrder do
			local oreName = oreOrder[i]
			local oreCount = ZVox.Storage_GetOreCount(oreName)
			if oreCount <= 0 then
				continue
			end

			local iconMat = ZVox.Storage_GetOreIcon(oreName).mat

			local yVal = 16 + ((i - 1) * (48 + 6))
			surface.SetMaterial(iconMat)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(8, yVal - 8, 48, 48)


			ZVox.DrawRetroText(self, capitalize(oreName), 64, yVal, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
			ZVox.DrawRetroText(self, tostring(oreCount), 256 + 16, yVal, colText2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 3)
			ZVox.DrawRetroText(self, "x", 256 + 64, yVal, colText2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3)

			local oreValue = ZVox.Storage_GetOreValue(oreName)
			ZVox.DrawRetroText(self, "$" .. tostring(oreValue), 256 + 64 + 96, yVal, colText2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3)

			ZVox.DrawRetroText(self, "=", 256 + 64 + 96 + 96, yVal, colText2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3)

			local totalVal = oreCount * oreValue
			ZVox.DrawRetroText(self, "$" .. tostring(totalVal), 256 + 64 + 96 + 96 + 32, yVal, colText2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
		end

		ZVox.DrawRetroText(self, "--------------", w, h - 32 - 4, colText2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 3)
		ZVox.DrawRetroText(self, "$" .. tostring(ZVox.Storage_GetTotalOreValue()), w - 8, h, colText2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 4)
	end


	local btnSell = vgui.Create("ZVUI_DButton", ZVox.OreVendorFrame)
	btnSell:SetText("[SELL ALL]")
	btnSell:SetTextFont("ZVUI_FrameTitleFont")
	btnSell:SetSize(196, 48)
	btnSell:SetPos(400 - 98, 600 - 48 - 6 - 8)

	function btnSell:DoClick()
		if ZVox.Storage_GetTotalOreCount() <= 0 then
			return
		end

		local finalMoneyGet = 0
		local oreOrder = ZVox.Storage_GetOreOrderArray()
		for i = 1, #oreOrder do
			local oreName = oreOrder[i]

			local oreCount = ZVox.Storage_GetOreCount(oreName)
			if oreCount <= 0 then
				continue
			end

			local oreValue = ZVox.Storage_GetOreValue(oreName)

			finalMoneyGet = finalMoneyGet + (oreValue * oreCount)
		end

		surface.PlaySound("mothervox/sfx/ui/buy.wav")
		ZVox.Money_GainMoney(finalMoneyGet)
		ZVox.Storage_ClearStorage()
	end
end