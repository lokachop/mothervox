ZVox = ZVox or {}

local oreOrder = {
	"coal",
	"copper",
	"iron",
	"silver",
	"gold",
	"diamond",
	"uranium",
	"voidinium",
	"temporalium",
}

function ZVox.Storage_GetOreOrderArray()
	return oreOrder
end


ZVox.CurrentOreCount = ZVox.CurrentOreCount or 0
ZVox.CurrentStorage = ZVox.CurrentStorage or {
	["coal"] = 0,
	["copper"] = 0,
	["iron"] = 0,
	["silver"] = 0,
	["gold"] = 0,
	["diamond"] = 0,
	["uranium"] = 0,
	["voidinium"] = 0,
	["temporalium"] = 0,
}

function ZVox.Storage_GetOreCount(name)
	if not name then
		return 0
	end

	return ZVox.CurrentStorage[name] or 0
end

local oreValueLUT = {
	["coal"] = 60,
	["copper"] = 100,
	["iron"] = 250,
	["silver"] = 750,
	["gold"] = 2000,
	["diamond"] = 5000,
	["uranium"] = 20000,
	["voidinium"] = 100000,
	["temporalium"] = 500000,
}

function ZVox.Storage_GetOreValue(name)
	return oreValueLUT[name] or 0
end

function ZVox.Storage_GetTotalOreValue()
	local total = 0
	for i = 1, #oreOrder do
		local oreName = oreOrder[i]
		local val = ZVox.Storage_GetOreValue(oreName) * ZVox.Storage_GetOreCount(oreName)
		total = total + val
	end

	return total
end


function ZVox.Storage_RefreshOreCount()
	ZVox.CurrentOreCount = 0
	for i = 1, #oreOrder do
		local oreName = oreOrder[i]
		ZVox.CurrentOreCount = ZVox.CurrentOreCount + ZVox.Storage_GetOreCount(oreName)
	end
end
ZVox.Storage_RefreshOreCount()



function ZVox.Storage_GetTotalOreCount()
	return ZVox.CurrentOreCount
end

function ZVox.Storage_GetStorageFilledDelta()
	return ZVox.CurrentOreCount / ZVox.Upgrades_GetStorageMaxCount()
end

function ZVox.Storage_CanStoreMoreOre()
	return ZVox.CurrentOreCount < ZVox.Upgrades_GetStorageMaxCount()
end

local function capitalize(msg)
	return string.upper(msg[1]) .. string.sub(msg, 2)
end


function ZVox.Storage_ClearStorage()
	ZVox.CurrentOreCount = 0
	for i = 1, #oreOrder do
		local oreName = oreOrder[i]
		ZVox.CurrentStorage[oreName] = 0
	end
end

function ZVox.Storage_AddToStorage(name)
	if not ZVox.CurrentStorage[name] then
		return
	end


	if not ZVox.Storage_CanStoreMoreOre() then
		ZVox.AddMinedPopup("STORAGE FULL")
		surface.PlaySound("mothervox/sfx/dig/inv_full_short.wav")
		return
	end

	ZVox.AddMinedPopup("+1 " .. capitalize(name))
	ZVox.CurrentStorage[name] = ZVox.CurrentStorage[name] + 1
	ZVox.CurrentOreCount = ZVox.CurrentOreCount + 1
	surface.PlaySound("mothervox/sfx/dig/collect_ore.wav")
end


function ZVox.Storage_DiscardOre(name)
	if not ZVox.CurrentStorage[name] then
		return
	end

	if ZVox.CurrentStorage[name] <= 0 then
		return
	end

	ZVox.CurrentStorage[name] = ZVox.CurrentStorage[name] - 1
	ZVox.CurrentOreCount = ZVox.CurrentOreCount - 1
end

local oreIconLUT = {
	["coal"] = ZVox.GetVoxelIcon(ZVox.GetVoxelID("zvox:coal_ore")),
	["copper"] = ZVox.GetVoxelIcon(ZVox.GetVoxelID("zvox:copper_ore")),
	["iron"] = ZVox.GetVoxelIcon(ZVox.GetVoxelID("zvox:iron_ore")),
	["silver"] = ZVox.GetVoxelIcon(ZVox.GetVoxelID("zvox:silver_ore")),
	["gold"] = ZVox.GetVoxelIcon(ZVox.GetVoxelID("zvox:gold_ore")),
	["diamond"] = ZVox.GetVoxelIcon(ZVox.GetVoxelID("zvox:diamond_ore")),
	["uranium"] = ZVox.GetVoxelIcon(ZVox.GetVoxelID("zvox:uranium_ore")),
	["voidinium"] = ZVox.GetVoxelIcon(ZVox.GetVoxelID("zvox:voidinium_ore")),
	["temporalium"] = ZVox.GetVoxelIcon(ZVox.GetVoxelID("zvox:temporalium_ore")),
}
function ZVox.Storage_GetOreIcon(name)
	return oreIconLUT[name] or ZVox.GetVoxelIcon(1)
end