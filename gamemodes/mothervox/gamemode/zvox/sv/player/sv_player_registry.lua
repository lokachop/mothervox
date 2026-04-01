ZVox = ZVox or {}

ZVox.PersistentSIDToUnivObjLUT = ZVox.PersistentSIDToUnivObjLUT or {}
local sIDToUnivObjLUT = ZVox.PersistentSIDToUnivObjLUT

ZVox.PersistentActivePlayerLUT = ZVox.PersistentActivePlayerLUT or {}
local activePlayerLUT = ZVox.PersistentActivePlayerLUT


function ZVox.SV_NewPlayer(sID, univObj)
	if not univObj then
		-- TODO: netsafety; kick if too much
		ZVox.PrintError("Attempt to add player \"" .. sID .. "\" with no universe")
		return
	end

	local univName = univObj["name"]
	if not activePlayerLUT[univName] then
		activePlayerLUT[univName] = {}
	end

	if activePlayerLUT[univName][sID] then -- ply already exists
		return
	end

	local spawnPos = ZVox.GetUniverseSpawnPoint(univObj) * 1
	local physObj = ZVox.PHYSICS_NewPhysicsObject({
		["pos"] = spawnPos,
		["scl"] = Vector(.6, .6, 1.8),
		["stepSize"] = 0.5,
	})
	ZVox.PHYSICS_SetPhysicsObjectUniverse(physObj, univObj)
	sIDToUnivObjLUT[sID] = univObj
end

function ZVox.SV_GetPlayerUniverse(sID)
	local univObj = sIDToUnivObjLUT[sID]
	if not univObj then
		return
	end

	return univObj
end

function ZVox.SV_RemovePlayer(sID)
	local univObj = sIDToUnivObjLUT[sID]
	if not univObj then -- player never really existed
		return
	end

	local univName = univObj["name"]
	
end