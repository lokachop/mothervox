ZVox = ZVox or {}

local settingsRegistry = ZVox.GetSettingRegistry()
local settingRegistryIterator = ZVox.GetSettingRegistrySequentialIterator()

local catTypeRegistry = ZVox.GetSettingCategoryRegistry()
local catTypeLUT = ZVox.GetSettingCategoryLUT()
local function categoryInitDPropertySheet(catType, dProperty)
	local scrollBase = vgui.Create("ZVUI_DScrollPanel", dProperty)
	scrollBase:Dock(FILL)

	scrollBase:DockPadding(0, 0, 0, 0)

	-- get all of the settings of this type

	for i = 1, #settingRegistryIterator do
		local settingName = settingRegistryIterator[i]


		local entry = settingsRegistry[settingName]
		local settingCat = entry.category

		if settingCat ~= catType then
			continue
		end

		-- instance a panel
		local settingPanel = vgui.Create("ZVUI_SettingPanel", scrollBase)
		settingPanel:Dock(TOP)


		local entryName = entry.name

		settingPanel:SetName(entry.fancyName or settingName)
		settingPanel:SetDescription(entry.description or "No description... If you're a dev, please write one!")

		if entry.min then
			settingPanel:SetMinMax(entry.min or 0, entry.max or 100)
		end

		if entry.options then
			settingPanel:SetOptions(entry.options)
		end

		settingPanel:SetSelectorType(entry.selector)
		settingPanel:SetDefault(entry.default)

		settingPanel:SetOnChangeFunc(function(var)
			ZVox.SetSettingValue(entryName, var)
		end)

		settingPanel:SetValueNoFuncCall(ZVox.GetSettingValue(entryName))
	end



	local catTypeID = catTypeLUT[catType]
	if not catTypeID then
		ZVox.PrintError("Invalid category \"" .. catType .. "\"!")
		catTypeID = 0
	end

	local catTypeInfo = catTypeRegistry[catTypeID]


	local name = catTypeInfo.fancyName
	local icon = catTypeInfo.icon
	dProperty:AddSheet(name, scrollBase, icon)
end

local controlPanelsToRefresh = {}
function ZVox.JANK_ReloadConflictingControlLabels()
	for i = 1, #controlPanelsToRefresh do
		if not controlPanelsToRefresh[i] then
			continue
		end

		controlPanelsToRefresh[i]:UpdateButtonLabel()
	end
end

local debugOnlyCategories = {
	["Debug"] = true,
	["DebugInteraction"] = true,
}


local function controlsInitDPropertySheet(dProperty)
	local scrollBase = vgui.Create("ZVUI_DScrollPanel", dProperty)
	scrollBase:Dock(FILL)
	scrollBase:DockPadding(0, 0, 0, 0)

	-- this needs to get from a different table, that the controls API provides
	local sortedControlsTable = ZVox.GetCategorySortedRegistry()

	controlPanelsToRefresh = {}
	for i = 1, #sortedControlsTable do
		local category = sortedControlsTable[i]
		local catName = category.name

		if debugOnlyCategories[catName] and (not ZVOX_DEVMODE) then
			continue
		end

		local baseFancyDPanel = vgui.Create("ZVUI_FancyDPanel", scrollBase)
		baseFancyDPanel:DockMargin(0, 0, 8, 5)
		baseFancyDPanel:Dock(TOP)
		baseFancyDPanel:SetTall((32 + 5) + (#category * 32))


		local headerPanel = vgui.Create("ZVUI_ControlHeaderPanel", baseFancyDPanel)
		headerPanel:Dock(TOP)
		headerPanel:SetTitle(catName)
		headerPanel:SetTall(32)



		for j = 1, #category do
			local catEntry = category[j]
			local controlEntry = ZVox.GetControlEntryByName(catEntry)


			local controlPanel = vgui.Create("ZVUI_ControlPanel", baseFancyDPanel)
			controlPanel:Dock(TOP)
			controlPanel:SetEntry(controlEntry)
			controlPanel:SetEven((j % 2) == 1)
			controlPanel:SetTall(32)

			controlPanelsToRefresh[#controlPanelsToRefresh + 1] = controlPanel
		end
	end

	dProperty:AddSheet("Controls", scrollBase, "settings-controls")
end

ZVox.SettingsFrame = ZVox.SettingsFrame
function ZVox.OpenSettings()
	if IsValid(ZVox.SettingsFrame) then
		ZVox.SettingsFrame:Close()
	end


	ZVox.SettingsFrame = vgui.Create("ZVUI_DFrame")
	ZVox.SettingsFrame:SetSize(800, 600)
	ZVox.SettingsFrame:Center()
	ZVox.SettingsFrame:MakePopup()
	ZVox.SettingsFrame:SetTitle("ZVox Settings")

	function ZVox.SettingsFrame:OnClose()
		-- dump to disk when closing
		ZVox.SaveSettingsToDisk()
		ZVox.SaveControlsToDisk()
	end


	-- do DPropertySheet
	-- one for each category

	local settingsDProperty = vgui.Create("ZVUI_DPropertySheet", ZVox.SettingsFrame)
	settingsDProperty:Dock(FILL)
	settingsDProperty:DockPadding(8, 0, 8, 0)

	controlsInitDPropertySheet(settingsDProperty)


	for i = 1, #catTypeRegistry do
		local catGet = catTypeRegistry[i]

		if catGet.devOnly and not ZVOX_DEVMODE then
			continue
		end

		categoryInitDPropertySheet(catGet.name, settingsDProperty)
	end
end



concommand.Add("zvox_open_settings", function()
	ZVox.OpenSettings()
end)