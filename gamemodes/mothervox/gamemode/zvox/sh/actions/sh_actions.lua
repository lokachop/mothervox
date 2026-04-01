ZVox = ZVox or {}
-- new action system
-- TODO: optimize this shit eventually

local actionIDRegistry = {}
local actionIDToNameRegistry = {}
local actionTypeRegistry = {}
function ZVox.GetActionName(actID)
	return actionIDToNameRegistry[actID]
end

function ZVox.GetActionID(actName)
	return actionIDRegistry[actName]
end

function ZVox.GetActionTypeRegistry()
	return actionTypeRegistry
end

local lastID = 0
function ZVox.DeclareNewActionType(actionName, data)
	actionName = ZVox.NAMESPACES_NamespaceConvert(actionName)

	if actionTypeRegistry[actionName] then
		ZVox.PrintError("Attempting to re-declare existing action \"" .. actionName .. "\", bad!")
		return
	end

	if not data["structure"] then
		ZVox.PrintError("Attempting to declare action \"" .. actionName .. "\" with no structure, bad!")
		return
	end

	data["SetUniverseName"] = function(act, univName)
		act["_univNameTarget"] = univName
	end

	data["GetUniverseName"] = function(act)
		return act["_univNameTarget"]
	end

	data.__index = data


	actionTypeRegistry[actionName] = data
	actionIDRegistry[actionName] = lastID
	actionIDToNameRegistry[lastID] = actionName

	lastID = lastID + 1
end


local typeConstructors = {
	[ZVOX_ACTION_FIELD_LONG] = function() return 0 end,
	[ZVOX_ACTION_FIELD_ULONG] = function() return 0 end,

	[ZVOX_ACTION_FIELD_SHORT] = function() return 0 end,
	[ZVOX_ACTION_FIELD_USHORT] = function() return 0 end,

	[ZVOX_ACTION_FIELD_FLOAT] = function() return 0 end,
	[ZVOX_ACTION_FIELD_DOUBLE] = function() return 0 end,
	[ZVOX_ACTION_FIELD_BOOLEAN] = function() return false end,

	[ZVOX_ACTION_FIELD_STRING] = function() return "" end,
	[ZVOX_ACTION_FIELD_DATA] = function() return "" end,
	[ZVOX_ACTION_FIELD_VECTOR] = function() return Vector() end,
}

function ZVox.NewAction(actionName)
	local regEntry = actionTypeRegistry[actionName]
	if not regEntry then
		ZVox.PrintError("No action entry for \"" .. tostring(actionName) .. "\" when creating a new action, bad!")
		return
	end

	local act = {
		["type"] = actionName,
		["_univNameTarget"] = "none",
	}

	local structure = regEntry["structure"]
	local structEntry
	for i = 1, #structure do
		structEntry = structure[i]

		local constructor = typeConstructors[structEntry[2]]
		if not constructor then
			ZVox.PrintError("Action \"" .. actionName .. "\" uses unknown type #" .. tostring(structEntry[2]))
			continue
		end

		act[structEntry[1]] = constructor()
	end
	setmetatable(act, regEntry)
	act.__index = regEntry

	return act
end


function ZVox.CL_ExecuteAction(act)
	ZVox.PushMessageToLogFile("ZVox.CL_ExecuteAction(), l102")
	local actType = act["type"]
	local actEntry = actionTypeRegistry[actType]
	if not actEntry then
		ZVox.PrintError("no action entry for type #" .. tostring(actType))
		return
	end

	ZVox.PushMessageToLogFile("ZVox.CL_ExecuteAction(), l110")
	actEntry.execute_cl(act)
	ZVox.PushMessageToLogFile("ZVox.CL_ExecuteAction(), l112")
end

function ZVox.SV_ExecuteAction(ply, act)
	local actType = act["type"]
	local actEntry = actionTypeRegistry[actType]
	if not actEntry then
		ZVox.PrintError("no action entry for type #" .. tostring(actType))
		return
	end

	actEntry.execute_sv(act, ply)
end



function ZVox.CL_SendAction(act)
	local actType = act["type"]
	local actEntry = actionTypeRegistry[actType]
	if not actEntry then
		ZVox.PrintError("no action entry for type #" .. tostring(actType))
		return
	end

	local activeUniv = ZVox.GetActiveUniverse()
	if activeUniv and activeUniv.clientOnly then
		return
	end

	net.Start("zvox_sendplayeraction")
		ZVox.NET_WriteAction(act)
	net.SendToServer()

	ZVox.IncOutboundActions()
end

function ZVox.SV_BroadcastAction(act, omitPly)
	local actType = act["type"]
	local actEntry = actionTypeRegistry[actType]
	if not actEntry then
		ZVox.PrintError("no action entry for type #" .. tostring(actType))
		return
	end


	if omitPly then
		local noSends = ZVox.SV_GetNetOmitForUniverse(act:GetUniverseName(), omitPly)

		net.Start("zvox_sendaction")
			ZVox.NET_WriteAction(act)
		net.SendOmit(noSends)
	else
		net.Start("zvox_sendaction")
			ZVox.NET_WriteAction(act)
		net.Broadcast()
	end
end