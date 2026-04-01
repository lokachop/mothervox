ZVox = ZVox or {}
local voxelInfoRegistry = ZVox.GetVoxelRegistry()
ZVox.InventoryFrame = ZVox.InventoryFrame



ZVox.PropertySheet = ZVox.PropertySheet
ZVox.InventoryPrevTab = ZVox.InventoryPrevTab or ZVOX_VOXELCATEGORY_NATURE

local hoveredVoxelID = -1
local function emitHoveredVoxelID(ID)
	hoveredVoxelID = ID
end


function ZVox.NEW_CloseInventory()
	if not IsValid(ZVox.InventoryFrame) then
		return
	end

	if ZVox.PropertySheet then
		local tab = ZVox.PropertySheet:GetActiveTab()
		if tab then
			local pnl = tab:GetPanel()

			ZVox.InventoryPrevTab = pnl._zvox_InvCategory
		end
	end


	ZVox.InventoryFrame:Close()
	gui.EnableScreenClicker(false)
end

local catIDToFancyNameLUT = {
	[ZVOX_VOXELCATEGORY_NATURE] = "Nature",
	[ZVOX_VOXELCATEGORY_TERRAIN] = "Terrain",
	[ZVOX_VOXELCATEGORY_BUILDINGBLOCKS] = "Building Blocks",
	[ZVOX_VOXELCATEGORY_ABSTRACT] = "Abstract",
	[ZVOX_VOXELCATEGORY_METALLIC] = "Metallic",
	[ZVOX_VOXELCATEGORY_NUMBER] = "Character & Digit",
	[ZVOX_VOXELCATEGORY_UNKNOWN] = "Unknown",
}

local catIDToIconLUT = {
	[ZVOX_VOXELCATEGORY_NATURE] = "nature",
	[ZVOX_VOXELCATEGORY_TERRAIN] = "terrain",
	[ZVOX_VOXELCATEGORY_BUILDINGBLOCKS] = "buildingblocks",
	[ZVOX_VOXELCATEGORY_ABSTRACT] = "abstract",
	[ZVOX_VOXELCATEGORY_METALLIC] = "metallic",
	[ZVOX_VOXELCATEGORY_NUMBER] = "words",
	[ZVOX_VOXELCATEGORY_UNKNOWN] = "abstract",
}

local function categoryBuild(catID, dProperty)
	local scrollBase = vgui.Create("ZVUI_DScrollPanel", dProperty)
	scrollBase:Dock(FILL)
	scrollBase:DockPadding(0, 0, 0, 0)
	scrollBase:DockMargin(0, 4, 0, 4)


	local currRow = vgui.Create("DPanel", scrollBase)
	currRow:SetTall(74)
	currRow:DockMargin(0, 1, 0, 0)
	currRow:Dock(TOP)
	function currRow:Paint() end

	local rowAccum = 0
	for i = 2, ZVox.GetVoxelCount() do
		local voxID = i

		local voxCat = ZVox.GetVoxelCategory(voxID)
		if voxCat ~= catID then
			continue
		end

		local voxelBtn = vgui.Create("DButton", currRow)
		voxelBtn:SetSize(74, 74)
		voxelBtn:DockMargin(1, 0, 0, 0)
		voxelBtn:SetText("")
		voxelBtn:Dock(LEFT)

		local thisMat = ZVox.GetVoxelIconMat(voxID)
		function voxelBtn:Paint(w, h)
			local hovered = self:IsHovered()

			if hovered then
				surface.SetDrawColor(32, 32, 32, 96)
			else
				surface.SetDrawColor(24, 24, 24, 96)
			end
			surface.DrawRect(0, 0, w, h)

			if hovered then
				surface.SetDrawColor(48, 48, 48, 128)
			else
				surface.SetDrawColor(32, 32, 32, 128)
			end
			surface.DrawOutlinedRect(0, 0, w, h, 2)


			local realScl = 64

			if self:IsHovered() then
				realScl = 64 + 8
			end

			local h_realScl = realScl * .5

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(thisMat)

			surface.DrawTexturedRect((w * .5) - h_realScl, (h * .5) - h_realScl, realScl, realScl)
		end

		function voxelBtn:Think()
			if self:IsHovered() then
				emitHoveredVoxelID(voxID)
			end
		end

		function voxelBtn:DoClick()
			ZVox.SetBlockAtHotbarSlotID(voxID)
			ZVox.CloseInventory()
		end


		rowAccum = rowAccum + 1
		if rowAccum >= 10 then -- push a new row
			rowAccum = 0

			currRow = vgui.Create("DPanel", scrollBase)
			currRow:SetTall(74)
			currRow:DockMargin(0, 1, 0, 1)
			currRow:Dock(TOP)
			function currRow:Paint() end
		end

	end



	scrollBase._zvox_InvCategory = catID

	local name = catIDToFancyNameLUT[catID]
	local icon = catIDToIconLUT[catID]
	dProperty:AddSheet(name, scrollBase, icon)
end

local colVoxName = Color(255, 255, 255)
local colAddonName = Color(164, 164, 164)
function ZVox.NEW_OpenInventory()
	if IsValid(ZVox.InventoryFrame) then
		ZVox.CloseInventory()
		return
	end
	gui.EnableScreenClicker(true)

	hoveredVoxelID = -1


	ZVox.InventoryFrame = vgui.Create("ZVUI_DFrame")
	ZVox.InventoryFrame:SetSize(800, 600)
	ZVox.InventoryFrame:Center()
	ZVox.InventoryFrame:ShowCloseButton(false)
	ZVox.InventoryFrame:SetDraggable(false)
	--ZVox.InventoryFrame:MakePopup()
	ZVox.InventoryFrame:SetTitle("ZVox Inventory")


	local bottomInfoPanel = vgui.Create("DPanel", ZVox.InventoryFrame)
	bottomInfoPanel:SetTall(64)
	bottomInfoPanel:Dock(BOTTOM)
	bottomInfoPanel:DockMargin(0, 8, 0, 0)

	function bottomInfoPanel:Paint(w, h)
		ZVUI.PaintCoolSurface(self, w, h)

		local mod = "n/a"
		local msg = "Select a Voxel"
		local voxGet = ZVox.GetVoxelByID(hoveredVoxelID)
		if voxGet then
			local namespace = ZVox.GetVoxelName(hoveredVoxelID)

			local modName, name = ZVox.NAMESPACES_NamespaceDeconvert(namespace)
			mod = "ZVox"
			msg = string.gsub(name, "_", " ")

			if ZVox.GetDebugDraw() then
				mod = modName
				msg = namespace
				msg = msg .. " (#" .. tostring(hoveredVoxelID) .. ")"
			end
		end

		ZVox.DrawRetroText(self, msg, w * .5, h * .5 - 12, colVoxName, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3)
		ZVox.DrawRetroText(self, mod, w * .5, h * .5 + 12, colAddonName, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
	end


	local invDProperty = vgui.Create("ZVUI_DPropertySheet", ZVox.InventoryFrame)
	invDProperty:Dock(FILL)
	invDProperty:DockPadding(8, 0, 8, 0)
	invDProperty:SetFadeTime(0)

	ZVox.PropertySheet = invDProperty

	categoryBuild(ZVOX_VOXELCATEGORY_NATURE, invDProperty)
	--categoryBuild(ZVOX_VOXELCATEGORY_TERRAIN, invDProperty)
	categoryBuild(ZVOX_VOXELCATEGORY_BUILDINGBLOCKS, invDProperty)
	categoryBuild(ZVOX_VOXELCATEGORY_ABSTRACT, invDProperty)
	categoryBuild(ZVOX_VOXELCATEGORY_METALLIC, invDProperty)
	categoryBuild(ZVOX_VOXELCATEGORY_NUMBER, invDProperty)
	categoryBuild(ZVOX_VOXELCATEGORY_UNKNOWN, invDProperty)


	-- go back to the tab we were in
	local items = invDProperty:GetItems()
	for i = 1, #items do
		local itemGet = items[i]
		if not itemGet then
			continue
		end

		local tab = itemGet.Tab

		if not tab then
			continue
		end

		local pnl = tab:GetPanel()
		if not pnl then
			continue
		end

		if pnl._zvox_InvCategory == ZVox.InventoryPrevTab then
			invDProperty:SetActiveTab(tab)
		end
	end
end


ZVox.NEW_CloseInventory()