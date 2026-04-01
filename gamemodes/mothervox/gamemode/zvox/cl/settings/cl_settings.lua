ZVox = ZVox or {}

local lastCat = 0
local settingCategories = {}
local settingCategoriesLUT = {}
function ZVox.GetSettingCategoryRegistry()
	return settingCategories
end

function ZVox.GetSettingCategoryLUT()
	return settingCategoriesLUT
end

function ZVox.NewSettingCategory(name, data)
	if not name then
		return
	end

	if not data then
		return
	end

	name = ZVox.NAMESPACES_NamespaceConvert(name)
	if settingCategoriesLUT[name] then
		return
	end

	local devOnly = false
	if data.devOnly then
		devOnly = true
	end

	settingCategories[lastCat] = {
		["name"] = name,
		["fancyName"] = data.fancyName or name,
		["icon"] = data.icon or "settings-misc",
		["devOnly"] = devOnly
	}
	settingCategoriesLUT[name] = lastCat

	lastCat = lastCat + 1

	return name
end

ZVox.NewSettingCategory("invalid", {
	["fancyName"] = "Invalid Category",
	["icon"] = "dynamite"
})



ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX = 1
ZVOX_SETTING_SELECTOR_TYPE_NUMENTRY = 2
ZVOX_SETTING_SELECTOR_TYPE_COMBO    = 3

-- used on saves
ZVOX_SETTING_TYPE_BOOLEAN = 1
ZVOX_SETTING_TYPE_NUMBER = 2
ZVOX_SETTING_TYPE_STRING = 3

local settingRegistry = {}
function ZVox.GetSettingRegistry()
	return settingRegistry
end

local settingRegistryIterator = {}
function ZVox.GetSettingRegistrySequentialIterator()
	return settingRegistryIterator
end


function ZVox.DeclareNewSetting(name, params)
	-- namespace the name
	name = ZVox.NAMESPACES_NamespaceConvert(name)

	settingRegistryIterator[#settingRegistryIterator + 1] = name

	settingRegistry[name] = params


	settingRegistry[name].name = name
	settingRegistry[name].value = params.default
end

local listenerRegistry = {}
function ZVox.NewSettingListener(uniqueName, settingName, callback)
	settingName = ZVox.NAMESPACES_NamespaceConvert(settingName)
	if not listenerRegistry[settingName] then
		listenerRegistry[settingName] = {}
	end

	listenerRegistry[settingName][uniqueName] = callback
end


local function callListenersForSetting(settingName, value)
	local listeners = listenerRegistry[settingName]
	if not listeners then
		return
	end

	for k, v in pairs(listeners) do
		local fine, err = pcall(v, value)

		if not fine then
			ZVox.PrintError("Error with setting listener \"" .. k .. "\"!")
			ZVox.PrintError(err)
			continue
		end
	end
end

function ZVox.GetSettingValue(name)
	local entry = settingRegistry[name]
	if not entry then
		return
	end

	return entry.value
end

function ZVox.SetSettingValue(name, var)
	local entry = settingRegistry[name]
	if not entry then
		return
	end

	if entry.value == var then
		return -- no change, don't call onchange
	end

	entry.value = var
	entry.onChange(var)

	callListenersForSetting(name, var)
end



local typeNameToTypeNumLUT = {
	["boolean"] = ZVOX_SETTING_TYPE_BOOLEAN,
	["number"] = ZVOX_SETTING_TYPE_NUMBER,
	["string"] = ZVOX_SETTING_TYPE_STRING,
}

local typeWritersLUT = {
	[ZVOX_SETTING_TYPE_BOOLEAN] = function(fBuff, val)
		ZVox.FB_WriteBool(fBuff, val)
	end,
	[ZVOX_SETTING_TYPE_NUMBER] = function(fBuff, val)
		ZVox.FB_WriteDouble(fBuff, val)
	end,
	[ZVOX_SETTING_TYPE_STRING] = function(fBuff, val)
		ZVox.FB_WriteULong(fBuff, #val)
		ZVox.FB_Write(fBuff, val)
	end,
}

local typeReadersLUT = {
	[ZVOX_SETTING_TYPE_BOOLEAN] = function(fBuff)
		return ZVox.FB_ReadBool(fBuff)
	end,
	[ZVOX_SETTING_TYPE_NUMBER] = function(fBuff)
		return ZVox.FB_ReadDouble(fBuff)
	end,
	[ZVOX_SETTING_TYPE_STRING] = function(fBuff)
		return ZVox.FB_Read(fBuff, ZVox.FB_ReadULong(fBuff))
	end,
}

-- TODO: should this keep non-existent settings entries?
-- it would let you hop servers and keep the settings of your SP world's mods but it would also let bad actors fingerprint you and possibly crash your game
function ZVox.SaveSettingsToDisk()
	ZVox.PrintInfo("Saving settings...")

	local seq = ZVox.GetSettingRegistrySequentialIterator()

	local fBuff = ZVox.FB_NewFileBuffer()
	ZVox.FB_Write(fBuff, "CONF")
	ZVox.FB_WriteByte(fBuff, 1) -- v1
	local entryCount = #seq

	if entryCount > 65535 then
		ZVox.PrintError("Settings entryCount is over 65535, expect non-saved settings!")
	end
	ZVox.FB_WriteUShort(fBuff, entryCount)

	for i = 1, entryCount do
		local entryName = seq[i]

		local entryPtr = settingRegistry[entryName]
		local entryVal = entryPtr.value
		local entryTypeID = typeNameToTypeNumLUT[type(entryVal)]
		if not entryTypeID then
			ZVox.PrintError("Non-serializable type \"" .. type(entryVal) .. "\" encountered for the setting \"" .. entryName .. "\"!")
			ZVox.PrintError("Contact the addon developer with this error!") -- blame the custom settings other addons will bring for small oversights
			continue
		end

		ZVox.FB_WriteUShort(fBuff, #entryName)
		ZVox.FB_Write(fBuff, entryName)

		ZVox.FB_WriteByte(fBuff, entryTypeID) -- entry type

		local fine, err = pcall(typeWritersLUT[entryTypeID], fBuff, entryVal)
		if not fine then
			ZVox.PrintError("Failed to write the value for the setting \"" .. entryName .. "\"!")
			ZVox.PrintError(err)
			ZVox.PrintError("Contact the addon developer with this error!")
		end
	end

	-- write it to disk
	ZVox.FB_DumpToDisk(fBuff, "zvox/mv_settings.dat")
	ZVox.FB_Close(fBuff)
end

function ZVox.LoadSettingsFromDisk()
	ZVox.PrintInfo("Loading settings...")

	local fBuff = ZVox.FB_NewFileBufferFromFile("zvox/mv_settings.dat")
	if not fBuff then
		ZVox.PrintInfo("No settings file, creating one for next time...")
		ZVox.PrintInfo("Remember to check settings with \"zvox_open_settings\"!")
		ZVox.SaveSettingsToDisk()
		return
	end

	local magic = ZVox.FB_Read(fBuff, 4)
	if magic ~= "CONF" then
		ZVox.FB_Close(fBuff)
		ZVox.PrintError("Failed loading settings!")
		ZVox.PrintError("Magic doesn't match (file may be corrupted)")
		return
	end
	local ver = ZVox.FB_ReadByte(fBuff)
	local entryCount = ZVox.FB_ReadUShort(fBuff)

	for i = 1, entryCount do
		local entryNameLen = ZVox.FB_ReadUShort(fBuff)
		local entryName = ZVox.FB_Read(fBuff, entryNameLen)

		local entryTypeID = ZVox.FB_ReadByte(fBuff)
		local fine, decVal = pcall(typeReadersLUT[entryTypeID], fBuff)
		if not fine then
			ZVox.PrintError("Failed to read the value for the setting \"" .. entryName .. "\"!")
			ZVox.PrintError(decVal)
			ZVox.PrintError("Contact the addon developer with this error!")
			continue
		end


		if decVal == nil then
			continue
		end

		ZVox.SetSettingValue(entryName, decVal)
	end
end