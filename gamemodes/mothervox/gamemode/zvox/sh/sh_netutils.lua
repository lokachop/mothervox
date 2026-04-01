ZVox = ZVox or {}

function ZVox.NET_WriteSkinTag(skinTag)
	if not skinTag then
		net.WriteUInt(ZVOX_SKINTAG_TYPE_PREFAB, 8)
		net.WriteUInt(0x0, 24)
		net.WriteString("prefab1")
		net.WriteString("")
		return
	end

	local sType = skinTag["type"] ~= nil and skinTag.type or ZVOX_SKINTAG_TYPE_PREFAB
	local sFlags = skinTag["flags"] ~= nil and skinTag.flags or 0x0
	local sData = skinTag["data"] ~= nil and skinTag.data or "prefab1"
	local sCape = skinTag["cape"] ~= nil and skinTag.cape or ""

	net.WriteUInt(sType, 8)
	net.WriteUInt(sFlags, 24)
	net.WriteString(sData)
	net.WriteString(sCape)

end

function ZVox.NET_ReadSkinTag()
	local skType = net.ReadUInt(8)
	local skFlags = net.ReadUInt(24)
	local skData = net.ReadString()
	local skCape = net.ReadString()

	local tag = {
		["type"] = skType,
		["flags"] = skFlags,
		["data"] = skData,
		["cape"] = skCape
	}

	return tag
end



function ZVox.NET_WritePNG(pngData)
	local len = #pngData

	net.WriteUInt(len, 32)
	net.WriteData(pngData, len)
end

function ZVox.NET_ReadPNG()
	local lenRead = net.ReadUInt(32)
	if not lenRead then
		return
	end

	return net.ReadData(lenRead)
end



local typeSenders = {
	[ZVOX_ACTION_FIELD_LONG] = function(v) net.WriteInt(v, 32) end,
	[ZVOX_ACTION_FIELD_ULONG] = function(v) net.WriteUInt(v, 32) end,

	[ZVOX_ACTION_FIELD_SHORT] = function(v) net.WriteInt(v, 16) end,
	[ZVOX_ACTION_FIELD_USHORT] = function(v) net.WriteUInt(v, 16) end,

	[ZVOX_ACTION_FIELD_FLOAT] = function(v) net.WriteFloat(v) end,
	[ZVOX_ACTION_FIELD_DOUBLE] = function(v) net.WriteDouble(v) end,
	[ZVOX_ACTION_FIELD_BOOLEAN] = function(v) net.WriteBool(v) end,

	[ZVOX_ACTION_FIELD_STRING] = function(v) net.WriteString(v) end,

	[ZVOX_ACTION_FIELD_DATA] = function(v)
		net.WriteUInt(#v, 32)
		net.WriteData(v, #v)
	end,
	[ZVOX_ACTION_FIELD_VECTOR] = function(v)
		net.WriteDouble(v[1])
		net.WriteDouble(v[2])
		net.WriteDouble(v[3])
	end,
}

local actTypeRegistry = ZVox.GetActionTypeRegistry()
function ZVox.NET_WriteAction(act)
	local actType = act["type"]
	local actEntry = actTypeRegistry[actType]
	if not actEntry then
		ZVox.PrintError("No action entry for type \"" .. tostring(actType) .. "\"")
		return
	end

	local actID = ZVox.GetActionID(actType)
	net.WriteUInt(actID, 16)
	net.WriteString(act:GetUniverseName())

	local structure = actEntry["structure"]
	local structEntry
	for i = 1, #structure do
		structEntry = structure[i]

		local sender = typeSenders[structEntry[2]]
		if not sender then
			ZVox.PrintError("Invalid typeSender #" .. tostring(structEntry[2]) .. " on action \"" .. structEntry[1] .. "\"")
			continue
		end

		sender(act[structEntry[1]])
	end
end

local typeReceivers = {
	[ZVOX_ACTION_FIELD_LONG] = function() return net.ReadInt(32) end,
	[ZVOX_ACTION_FIELD_ULONG] = function() return net.ReadUInt(32) end,

	[ZVOX_ACTION_FIELD_SHORT] = function() return net.ReadInt(16) end,
	[ZVOX_ACTION_FIELD_USHORT] = function() return net.ReadUInt(16) end,

	[ZVOX_ACTION_FIELD_FLOAT] = function() return net.ReadFloat() end,
	[ZVOX_ACTION_FIELD_DOUBLE] = function() return net.ReadDouble() end,
	[ZVOX_ACTION_FIELD_BOOLEAN] = function() return net.ReadBool() end,

	[ZVOX_ACTION_FIELD_STRING] = function() return net.ReadString() end,

	[ZVOX_ACTION_FIELD_DATA] = function()
		return net.ReadData(net.ReadUInt(32))
	end,
	[ZVOX_ACTION_FIELD_VECTOR] = function()
		return Vector(net.ReadDouble(), net.ReadDouble(), net.ReadDouble())
	end,
}

function ZVox.NET_ReadAction()
	local actID = net.ReadUInt(16)
	if not actID then
		return
	end

	local actName = ZVox.GetActionName(actID)
	if not actName then
		return
	end


	local actEntry = actTypeRegistry[actName]
	if not actEntry then
		return
	end


	local univTarget = net.ReadString()
	if not univTarget then
		univTarget = "mothervox"
	end

	local act = ZVox.NewAction(actName)
	act:SetUniverseName(univTarget)

	-- deserialize it

	local structure = actEntry["structure"]
	local structEntry
	for i = 1, #structure do
		structEntry = structure[i]

		local receiver = typeReceivers[structEntry[2]]
		if not receiver then
			ZVox.PrintError("Invalid typeSender #" .. tostring(structEntry[2]) .. " on action \"" .. structEntry[1] .. "\"")
			continue
		end

		local recv = receiver()
		act[structEntry[1]] = recv
	end
	return act
end