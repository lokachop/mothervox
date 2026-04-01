ZVox = ZVox or {}

ZVox.SetVoxelOnInteract("zvox:mothervox_shop_ore", function()
	ZVox.OpenOreVendor()
	return true
end)

ZVox.SetVoxelOnInteract("zvox:mothervox_shop_fuel", function()
	ZVox.OpenFuelVendor()
	return true
end)

ZVox.SetVoxelOnInteract("zvox:mothervox_shop_parts", function()
	ZVox.OpenPartVendor()
	return true
end)

ZVox.SetVoxelOnInteract("zvox:mothervox_shop_consumables", function()
	ZVox.OpenConsumableVendor()
	return true
end)