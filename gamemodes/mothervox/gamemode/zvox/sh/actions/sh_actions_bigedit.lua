ZVox = ZVox or {}

local vecReuse = Vector()


ZVox.DeclareNewActionType("bigedit_fill_cube", {
	["structure"] = {
		{"x", ZVOX_ACTION_FIELD_ULONG}, -- pos X
		{"y", ZVOX_ACTION_FIELD_ULONG}, -- pos Y
		{"z", ZVOX_ACTION_FIELD_ULONG}, -- pos Z

		{"sX", ZVOX_ACTION_FIELD_ULONG}, -- size X
		{"sY", ZVOX_ACTION_FIELD_ULONG}, -- size Y
		{"sZ", ZVOX_ACTION_FIELD_ULONG}, -- size Z

		{"voxelID", ZVOX_ACTION_FIELD_ULONG}, -- voxelID
		{"voxelState", ZVOX_ACTION_FIELD_ULONG}, -- voxelState
	},

	["SetPosition"] = function(act, x, y, z)
		act["x"] = x
		act["y"] = y
		act["z"] = z
	end,

	["SetSize"] = function(act, sX, sY, sZ)
		act["sX"] = sX
		act["sY"] = sY
		act["sZ"] = sZ
	end,

	["SetVoxelID"] = function(act, voxelID)
		act["voxelID"] = voxelID
	end,

	["SetVoxelState"] = function(act, voxelState)
		act["voxelState"] = voxelState
	end,

	-- Called when received from a client
	["execute_sv"] = function(act, ply)
		if not ply:IsSuperAdmin() then
			return
		end

		local univName = act:GetUniverseName()
		if univName ~= ZVox.SV_GetPlayerZVoxUniverse(ply) then
			return
		end


		local univ = ZVox.GetUniverseByName(univName)
		if not univ then
			return
		end

		local x, y, z = act["x"], act["y"], act["z"]
		local voxelID = act["voxelID"]
		local voxelState = act["voxelState"]
		local sX, sY, sZ = act["sX"], act["sY"], act["sZ"]

		ZVox.FillCube(univ, x, y, z, sX, sY, sZ, voxelID, voxelState)
		ZVox.SV_BroadcastAction(act, ply)
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
		local voxelState = act["voxelState"]
		local sX, sY, sZ = act["sX"], act["sY"], act["sZ"]

		ZVox.FillCube(univ, x, y, z, sX, sY, sZ, voxelID, voxelState)
	end
})


ZVox.DeclareNewActionType("bigedit_fill_sphere", {
	["structure"] = {
		{"x", ZVOX_ACTION_FIELD_ULONG}, -- pos X
		{"y", ZVOX_ACTION_FIELD_ULONG}, -- pos Y
		{"z", ZVOX_ACTION_FIELD_ULONG}, -- pos Z

		{"sX", ZVOX_ACTION_FIELD_ULONG}, -- size X
		{"sY", ZVOX_ACTION_FIELD_ULONG}, -- size Y
		{"sZ", ZVOX_ACTION_FIELD_ULONG}, -- size Z

		{"voxelID", ZVOX_ACTION_FIELD_ULONG}, -- voxelID
		{"voxelState", ZVOX_ACTION_FIELD_ULONG}, -- voxelState
	},

	["SetPosition"] = function(act, x, y, z)
		act["x"] = x
		act["y"] = y
		act["z"] = z
	end,

	["SetSize"] = function(act, sX, sY, sZ)
		act["sX"] = sX
		act["sY"] = sY
		act["sZ"] = sZ
	end,

	["SetVoxelID"] = function(act, voxelID)
		act["voxelID"] = voxelID
	end,

	["SetVoxelState"] = function(act, voxelState)
		act["voxelState"] = voxelState
	end,

	-- Called when received from a client
	["execute_sv"] = function(act, ply)
		if not ply:IsSuperAdmin() then
			return
		end

		local univName = act:GetUniverseName()
		if univName ~= ZVox.SV_GetPlayerZVoxUniverse(ply) then
			return
		end


		local univ = ZVox.GetUniverseByName(univName)
		if not univ then
			return
		end

		local x, y, z = act["x"], act["y"], act["z"]
		local voxelID = act["voxelID"]
		local voxelState = act["voxelState"]
		local sX, sY, sZ = act["sX"], act["sY"], act["sZ"]

		ZVox.FillSphere(univ, x, y, z, sX, sY, sZ, voxelID, voxelState)
		ZVox.SV_BroadcastAction(act, ply)
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
		local voxelState = act["voxelState"]
		local sX, sY, sZ = act["sX"], act["sY"], act["sZ"]

		ZVox.FillSphere(univ, x, y, z, sX, sY, sZ, voxelID, voxelState)
	end
})


ZVox.DeclareNewActionType("bigedit_replace_cube", {
	["structure"] = {
		{"x", ZVOX_ACTION_FIELD_ULONG}, -- pos X
		{"y", ZVOX_ACTION_FIELD_ULONG}, -- pos Y
		{"z", ZVOX_ACTION_FIELD_ULONG}, -- pos Z

		{"sX", ZVOX_ACTION_FIELD_ULONG}, -- size X
		{"sY", ZVOX_ACTION_FIELD_ULONG}, -- size Y
		{"sZ", ZVOX_ACTION_FIELD_ULONG}, -- size Z

		{"voxelIDTarget", ZVOX_ACTION_FIELD_ULONG}, -- voxelID to replace

		{"voxelID", ZVOX_ACTION_FIELD_ULONG}, -- voxelID
		{"voxelState", ZVOX_ACTION_FIELD_ULONG}, -- voxelState
	},

	["SetPosition"] = function(act, x, y, z)
		act["x"] = x
		act["y"] = y
		act["z"] = z
	end,

	["SetSize"] = function(act, sX, sY, sZ)
		act["sX"] = sX
		act["sY"] = sY
		act["sZ"] = sZ
	end,

	["SetVoxelIDTarget"] = function(act, voxelID)
		act["voxelIDTarget"] = voxelID
	end,

	["SetVoxelID"] = function(act, voxelID)
		act["voxelID"] = voxelID
	end,

	["SetVoxelState"] = function(act, voxelState)
		act["voxelState"] = voxelState
	end,

	-- Called when received from a client
	["execute_sv"] = function(act, ply)
		if not ply:IsSuperAdmin() then
			return
		end

		local univName = act:GetUniverseName()
		if univName ~= ZVox.SV_GetPlayerZVoxUniverse(ply) then
			return
		end


		local univ = ZVox.GetUniverseByName(univName)
		if not univ then
			return
		end

		local x, y, z = act["x"], act["y"], act["z"]
		local voxelID = act["voxelID"]
		local voxelIDTarget = act["voxelIDTarget"]
		local voxelState = act["voxelState"]
		local sX, sY, sZ = act["sX"], act["sY"], act["sZ"]

		ZVox.ReplaceCube(univ, x, y, z, sX, sY, sZ, voxelIDTarget, voxelID, voxelState)
		ZVox.SV_BroadcastAction(act, ply)
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
		local voxelIDTarget = act["voxelIDTarget"]
		local voxelState = act["voxelState"]
		local sX, sY, sZ = act["sX"], act["sY"], act["sZ"]

		ZVox.ReplaceCube(univ, x, y, z, sX, sY, sZ, voxelIDTarget, voxelID, voxelState)
	end
})


ZVox.DeclareNewActionType("bigedit_replace_sphere", {
	["structure"] = {
		{"x", ZVOX_ACTION_FIELD_ULONG}, -- pos X
		{"y", ZVOX_ACTION_FIELD_ULONG}, -- pos Y
		{"z", ZVOX_ACTION_FIELD_ULONG}, -- pos Z

		{"sX", ZVOX_ACTION_FIELD_ULONG}, -- size X
		{"sY", ZVOX_ACTION_FIELD_ULONG}, -- size Y
		{"sZ", ZVOX_ACTION_FIELD_ULONG}, -- size Z

		{"voxelIDTarget", ZVOX_ACTION_FIELD_ULONG}, -- voxelID to replace

		{"voxelID", ZVOX_ACTION_FIELD_ULONG}, -- voxelID
		{"voxelState", ZVOX_ACTION_FIELD_ULONG}, -- voxelState
	},

	["SetPosition"] = function(act, x, y, z)
		act["x"] = x
		act["y"] = y
		act["z"] = z
	end,

	["SetSize"] = function(act, sX, sY, sZ)
		act["sX"] = sX
		act["sY"] = sY
		act["sZ"] = sZ
	end,

	["SetVoxelIDTarget"] = function(act, voxelID)
		act["voxelIDTarget"] = voxelID
	end,

	["SetVoxelID"] = function(act, voxelID)
		act["voxelID"] = voxelID
	end,

	["SetVoxelState"] = function(act, voxelState)
		act["voxelState"] = voxelState
	end,

	-- Called when received from a client
	["execute_sv"] = function(act, ply)
		if not ply:IsSuperAdmin() then
			return
		end

		local univName = act:GetUniverseName()
		if univName ~= ZVox.SV_GetPlayerZVoxUniverse(ply) then
			return
		end


		local univ = ZVox.GetUniverseByName(univName)
		if not univ then
			return
		end

		local x, y, z = act["x"], act["y"], act["z"]
		local voxelID = act["voxelID"]
		local voxelIDTarget = act["voxelIDTarget"]
		local voxelState = act["voxelState"]
		local sX, sY, sZ = act["sX"], act["sY"], act["sZ"]

		ZVox.ReplaceSphere(univ, x, y, z, sX, sY, sZ, voxelIDTarget, voxelID, voxelState)
		ZVox.SV_BroadcastAction(act, ply)
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
		local voxelIDTarget = act["voxelIDTarget"]
		local voxelState = act["voxelState"]
		local sX, sY, sZ = act["sX"], act["sY"], act["sZ"]

		ZVox.ReplaceSphere(univ, x, y, z, sX, sY, sZ, voxelIDTarget, voxelID, voxelState)
	end
})