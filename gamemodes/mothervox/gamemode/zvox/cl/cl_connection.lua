ZVox = ZVox or {}
local univReg = ZVox.GetUniverseRegistry()

function ZVox.ConnectToUniverse(univObj)
	ZVox.SetActiveUniverse(univObj)
	ZVox.SetPlayerUniverse(univObj)
	ZVox.Lighting_SetActiveUniverse()
	ZVox.Culling_SetActiveUniverse()

	ZVox.RemeshUniv(univObj, true)

	ZVox.SetState(ZVOX_STATE_INGAME)
end


function ZVox.AttemptConnectionToUniverse(univName)
	if IsValid(ZVox.UniverseListFrame) then
		ZVox.UniverseListFrame:Close()
	end
	ZVox.CloseEscapeMenu()
	ZVox.CloseInventory()

	local univObj = univReg[univName]
	if univObj and univObj.clientOnly then
		ZVox.ConnectToUniverse(univObj)
		return
	end

	net.Start("zvox_requestuniverse")
		net.WriteString(univName)
	net.SendToServer()
end


function ZVox.DisconnectFromUniverse()
	ZVox.SetState(ZVOX_STATE_MAINMENU)
	ZVox.CloseEscapeMenu()
	ZVox.CloseInventory()

	net.Start("zvox_leaveuniverse")
	net.SendToServer()
end


concommand.Add("zvox_connect_to_universe", function(ply, cmd, args)
	local univTarget = args[1]
	if not univTarget then
		ZVox.CommandErrorNotify("zvox_connect_to_universe <univTarget>")
		return
	end

	ZVox.AttemptConnectionToUniverse(univTarget)
end)
