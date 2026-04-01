ZVox = ZVox or {}
function ZVox.RegenerateWorld()
	local univ = ZVox.GetUniverseByName("mothervox")

	ZVox.SetUniverseWorldGen(univ, "zvox:mothervox")
	ZVox.SetUniverseWorldTint(univ, Vector(.7, .6, .4))
	ZVox.SetUniverseSpawnPoint(univ, Vector(16, 16, 1010))
	ZVox.SetUniverseDoDayAndNight(univ, true)
	ZVox.UniverseGenerateChunks(univ)

	ZVox.MV_LoadBuildingTemplates()
end


local univ = ZVox.GetUniverseByName("mothervox")
if univ then
	return
end

-- TODO: move this elsewhere!
if ZVox.CheckIfSaveExists("mothervox") then
	ZVox.LoadUniverseFromSave("mothervox", "mothervox")
	return
end

univ = ZVox.GetUniverseByName("mothervox")

if univ then
	return
end

-- no save, no world, have to create
local c_SizeX = 32 / ZVOX_CHUNKSIZE_X
local c_SizeY = 32 / ZVOX_CHUNKSIZE_Y
local c_SizeZ = 1024 / ZVOX_CHUNKSIZE_Z
univ = ZVox.NewUniverse("mothervox", {
	["chunkSizeX"] = c_SizeX,
	["chunkSizeY"] = c_SizeY,
	["chunkSizeZ"] = c_SizeZ,
})

ZVox.SetUniverseWorldGen(univ, "zvox:mothervox")
ZVox.SetUniverseWorldTint(univ, Vector(.7, .6, .4))
ZVox.SetUniverseSpawnPoint(univ, Vector(16, 16, 1010))
ZVox.SetUniverseDoDayAndNight(univ, true)
ZVox.UniverseGenerateChunks(univ)

ZVox.MV_LoadBuildingTemplates()
