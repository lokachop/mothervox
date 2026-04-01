ZVox = ZVox or {}

ZVox.DeclareNewActionType("place", {
	["structure"] = {
		{"x", ZVOX_ACTION_FIELD_ULONG}, -- pos X
		{"y", ZVOX_ACTION_FIELD_ULONG}, -- pos Y
		{"z", ZVOX_ACTION_FIELD_ULONG}, -- pos Z

		{"voxelID", ZVOX_ACTION_FIELD_ULONG}, -- voxelID
		{"voxelState", ZVOX_ACTION_FIELD_ULONG}, -- voxelState
	},

	["SetPosition"] = function(act, x, y, z)
		act["x"] = x
		act["y"] = y
		act["z"] = z
	end,

	["SetVoxelID"] = function(act, voxelID)
		act["voxelID"] = voxelID
	end,

	["SetVoxelState"] = function(act, voxelState)
		act["voxelState"] = voxelState
	end,

	-- execute
	["execute_sv"] = function(act, ply)
		local univName = act:GetUniverseName()
		if univName ~= ZVox.SV_GetPlayerZVoxUniverse(ply) then
			return
		end


		local univ = ZVox.GetUniverseByName(univName)
		if not univ then
			return
		end

		local x, y, z = act["x"], act["y"], act["z"]
		local newID = act["voxelID"]
		local prevID = ZVox.GetBlockAtPos(univ, x, y, z)


		-- TODO: proper CanPlace checks
		-- they shall go here
		ZVox.SetBlockAtPos(univ, x, y, z, newID, act["voxelState"])
		ZVox.SV_BroadcastAction(act, ply)
	end,

	["execute_cl"] = function(act)
		local univName = act:GetUniverseName()

		local univ = ZVox.GetUniverseByName(univName)
		if not univ then
			univ = ZVox.GetActiveUniverse()
		end

		local voxelID = act["voxelID"]

		local x, y, z = act["x"], act["y"], act["z"]

		ZVox.SetBlockAtPos(univ, x, y, z, voxelID, act["voxelState"])
	end
})


ZVox.DeclareNewActionType("break", {
	["structure"] = {
		{"x", ZVOX_ACTION_FIELD_ULONG}, -- pos X
		{"y", ZVOX_ACTION_FIELD_ULONG}, -- pos Y
		{"z", ZVOX_ACTION_FIELD_ULONG}, -- pos Z
	},

	["SetPosition"] = function(act, x, y, z)
		act["x"] = x
		act["y"] = y
		act["z"] = z
	end,

	-- Called when received from a client
	["execute_sv"] = function(act, ply)
		local univName = act:GetUniverseName()
		if univName ~= ZVox.SV_GetPlayerZVoxUniverse(ply) then
			return
		end


		local univ = ZVox.GetUniverseByName(univName)
		if not univ then
			return
		end


		local x, y, z = act["x"], act["y"], act["z"]
		local prevID, prevState = ZVox.GetBlockAtPos(univ, x, y, z)

		-- TODO: proper CanBreak checks
		-- they shall go here
		ZVox.SetBlockAtPos(univ, x, y, z, 0)
		ZVox.SV_BroadcastAction(act, ply)
	end,

	-- Called when received from the server
	["execute_cl"] = function(act)
		ZVox.PushMessageToLogFile("break, execute_cl, l106")
		local univName = act:GetUniverseName()

		ZVox.PushMessageToLogFile("break, execute_cl, l109")
		local univ = ZVox.GetUniverseByName(univName)
		if not univ then
			univ = ZVox.GetActiveUniverse()
		end

		ZVox.PushMessageToLogFile("break, execute_cl, l115")
		local x, y, z = act["x"], act["y"], act["z"]
		local voxelID = ZVox.GetBlockAtPos(univ, x, y, z)

		ZVox.PushMessageToLogFile("break, execute_cl, l119")
		ZVox.EmitVoxelBreakParticles(voxelID, x, y, z)
		ZVox.PushMessageToLogFile("break, execute_cl, l121")
		ZVox.SetBlockAtPos(univ, x, y, z, 0)
		ZVox.PushMessageToLogFile("break, execute_cl, l124")
	end
})


ZVox.DeclareNewActionType("update", {
	["structure"] = {
		{"x", ZVOX_ACTION_FIELD_ULONG}, -- pos X
		{"y", ZVOX_ACTION_FIELD_ULONG}, -- pos Y
		{"z", ZVOX_ACTION_FIELD_ULONG}, -- pos Z

		{"voxelID", ZVOX_ACTION_FIELD_ULONG}, -- voxelID
		{"voxelState", ZVOX_ACTION_FIELD_ULONG}, -- voxelState
	},

	["SetPosition"] = function(act, x, y, z)
		act["x"] = x
		act["y"] = y
		act["z"] = z
	end,

	["SetVoxelID"] = function(act, voxelID)
		act["voxelID"] = voxelID
	end,

	["SetVoxelState"] = function(act, voxelState)
		act["voxelState"] = voxelState
	end,


	-- Called when received from a client
	["execute_sv"] = function(act, ply)
		return -- this is a sv -> cl only action, clients shouldn't send it
	end,

	-- Called when received from the server
	["execute_cl"] = function(act)
		local univName = act:GetUniverseName()
		local univ = ZVox.GetUniverseByName(univName)
		if not univ then
			return
		end

		local x, y, z = act["x"], act["y"], act["z"]
		local voxelID = act["voxelID"]
		local voxState = act["voxelState"]

		ZVox.SetBlockAtPos(univ, x, y, z, voxelID, voxState)
	end
})