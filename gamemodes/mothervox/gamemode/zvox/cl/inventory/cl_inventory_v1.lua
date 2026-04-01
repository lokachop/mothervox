ZVox = ZVox or {}
local voxelInfoRegistry = ZVox.GetVoxelRegistry()
ZVox.InventoryPanel = ZVox.InventoryPanel or nil
if IsValid(ZVox.InventoryPanel) then
	ZVox.InventoryPanel:Remove()
	gui.EnableScreenClicker(false)
end

local hoveredVoxelID = -1
local function emitHoveredVoxelID(ID)
	hoveredVoxelID = ID
end




-- Inventory
-- REF, inv is 10 columns
local function addVoxel(parent, voxelID)
	local voxelRect = vgui.Create("DButton", parent)
	voxelRect:SetSize(64, 64)
	voxelRect:SetText("")

	voxelRect:DockMargin(0, 0, 0, 0)
	voxelRect:Dock(LEFT)

	voxelRect:SetMouseInputEnabled(true)

	local thisMat = ZVox.GetVoxelIconMat(voxelID)
	function voxelRect:Paint(w, h)
		local realScl = 48

		if self:IsHovered() then
			realScl = 48 + 16
		end

		local h_realScl = realScl * .5

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(thisMat)

		surface.DrawTexturedRect((w * .5) - h_realScl, (h * .5) - h_realScl, realScl, realScl)
	end

	function voxelRect:Think()
		if self:IsHovered() then
			emitHoveredVoxelID(voxelID)
		end
	end

	function voxelRect:DoClick()
		ZVox.SetBlockAtHotbarSlotID(voxelID)
		ZVox.CloseInventory()
	end
end

local function addVoxelRow(parent, startIdx, endIdx)
	local voxelRow = vgui.Create("DPanel", parent)
	voxelRow:SetSize(640, 64)

	voxelRow:DockPadding(0, 0, 0, 0)
	voxelRow:DockMargin(0, 0, 0, 0)
	voxelRow:Dock(TOP)

	function voxelRow:Paint(w, h)
	end

	for i = startIdx, endIdx do
		addVoxel(voxelRow, i)
	end
end



local function friendly_name(msg)
	local _, name = ZVox.NAMESPACES_NamespaceDeconvert(msg)

	return string.gsub(name, "_", " ")
end

local c_white = Color(255, 255, 255)
function ZVox.OLD_OpenInventory()
	emitHoveredVoxelID(-1)

	if IsValid(ZVox.InventoryPanel) then
		ZVox.InventoryPanel:Remove()
		gui.EnableScreenClicker(false)

		return -- Close if already open
	end
	gui.EnableScreenClicker(true)

	ZVox.InventoryPanel = vgui.Create("DPanel")
	ZVox.InventoryPanel:SetSize(640, 477)
	ZVox.InventoryPanel:Center()

	function ZVox.InventoryPanel:OnRemove()
		gui.EnableScreenClicker(false)
	end

	local c1 = Color(32, 32, 32, 220)
	local c2 = Color(64, 64, 128, 220)
	function ZVox.InventoryPanel:Paint(w, h)
		ZVox.BlurScreenRectPanel(self, 0, 0, w, h, 4, 6)
		ZVox.RenderGradientSRGB(0, 0, w, h, h * .25, c1, c2)
	end

	local namePanel = vgui.Create("DPanel", ZVox.InventoryPanel)
	namePanel:SetSize(640, 32)
	namePanel:Dock(TOP)

	function namePanel:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 196)
		surface.DrawRect(0, 0, w, h)

		if hoveredVoxelID == -1 then
			ZVox.DrawRetroTextShadowed(self, "Select a voxel", w * .5, 16, c_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3)
		else
			local voxInfo = voxelInfoRegistry[hoveredVoxelID]

			local strWrite = friendly_name(voxInfo.name)

			if ZVox.GetDebugDraw() then
				strWrite = voxInfo.name
				strWrite = strWrite .. " (#" .. tostring(hoveredVoxelID) .. ")"
			end

			ZVox.DrawRetroTextShadowed(self, strWrite, w * .5, 16, c_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3)
		end
	end
	local scrollPanelBase = vgui.Create("DPanel", ZVox.InventoryPanel)
	scrollPanelBase:SetSize(640, 445)
	scrollPanelBase:Dock(TOP)
	scrollPanelBase:DockPadding(0, 0, 0, 0)
	function scrollPanelBase:Paint()
	end


	local scrollPanel = vgui.Create("DPanel", scrollPanelBase)
	scrollPanel:SetSize(640, 2048)
	scrollPanel:DockPadding(0, 0, 0, 0)
	scrollPanel._internalScroll = 0

	function scrollPanel:OnMouseWheeled(delta)
		local newScroll = self._internalScroll + delta * 32

		local maxScroll = (math.floor(#voxelInfoRegistry / 10) * -64) + (6 * 64)
		maxScroll = math.min(maxScroll, 0)

		newScroll = math.min(newScroll, 0)
		newScroll = math.max(newScroll, maxScroll)

		self._internalScroll = newScroll
		scrollPanel:SetPos(0, self._internalScroll)
	end

	function scrollPanel:Paint(w, h)
		--surface.SetDrawColor(0, 255, 0)
		--surface.DrawRect(0, 0, w, h)
	end


	local voxelCount = #voxelInfoRegistry -- We don't want people to hold AIR

	for i = 2, voxelCount, 10 do
		local startIdx = i
		local endIdx = math.min(i + 10, voxelCount)

		addVoxelRow(scrollPanel, startIdx, endIdx)
	end

end


function ZVox.OLD_CloseInventory()
	if not IsValid(ZVox.InventoryPanel) then
		return
	end

	ZVox.InventoryPanel:Remove()

	gui.EnableScreenClicker(false)
end