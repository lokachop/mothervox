ZVox = ZVox or {}

ZVox.SetVoxelOnDig("zvox:coal_ore", function()
	ZVox.Storage_AddToStorage("coal")
end)

ZVox.SetVoxelOnDig("zvox:copper_ore", function()
	ZVox.Storage_AddToStorage("copper")
end)

ZVox.SetVoxelOnDig("zvox:iron_ore", function()
	ZVox.Storage_AddToStorage("iron")
end)

ZVox.SetVoxelOnDig("zvox:silver_ore", function()
	ZVox.Storage_AddToStorage("silver")
end)

ZVox.SetVoxelOnDig("zvox:gold_ore", function()
	ZVox.Storage_AddToStorage("gold")
end)

ZVox.SetVoxelOnDig("zvox:diamond_ore", function()
	ZVox.Storage_AddToStorage("diamond")
end)

ZVox.SetVoxelOnDig("zvox:uranium_ore", function()
	ZVox.Storage_AddToStorage("uranium")
end)

ZVox.SetVoxelOnDig("zvox:voidinium_ore", function()
	ZVox.Storage_AddToStorage("voidinium")
end)

ZVox.SetVoxelOnDig("zvox:temporalium_ore", function()
	ZVox.Storage_AddToStorage("temporalium")
end)


ZVox.DugMagmaTotal = ZVox.DugMagmaTotal or 0
ZVox.SetVoxelOnDig("zvox:magma", function()
	local maxHealth = ZVox.Upgrades_GetMaxHullHealth()
	local dmgMul = ZVox.Upgrades_GetRadiatorDamageMul()

	ZVox.Health_TakeDamage(maxHealth * dmgMul)
	surface.PlaySound("mothervox/sfx/dig/lava.wav")
	ZVox.DugMagmaTotal = ZVox.DugMagmaTotal + 1
end)

ZVox.SetVoxelOnDig("zvox:unobtainalum", function()
	ZVox.MV_SaveProgress()
	net.Start("mothervox_save_world")
	net.SendToServer()

	ZVox.SetState(ZVOX_STATE_ENDING)

	return true
end)
