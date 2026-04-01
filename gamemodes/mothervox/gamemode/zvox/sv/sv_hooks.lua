ZVox = ZVox or {}

function ZVox.ThinkSV()
	ZVox.UniverseTransmitThink()
	ZVox.BroadcastPlayerUpdates()
	--ZVox.UniverseAutoSaveThink()

	ZVox.ProgressiveSaveThink()
end

function ZVox.OnShutDown()
	ZVox.SaveAllUniverses()
	ZVox.EmergencyProgressiveSaveNOW() -- this freezes but makes sure univs are saved
end


function GM:Think()
	ZVox.ThinkSV()
end

function GM:ShutDown()
	ZVox.OnShutDown()
end

function GM:CanPlayerSuicide(ply)
	return false
end