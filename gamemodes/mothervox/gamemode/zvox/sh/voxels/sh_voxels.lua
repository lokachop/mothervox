ZVox = ZVox or {}

local _voxels = {}
function ZVox.GetVoxelByID(voxID)
	return _voxels[voxID]
end

function ZVox.GetVoxelRegistry()
	return _voxels
end

local _voxNameToID = {}
function ZVox.GetVoxelID(name)
	return _voxNameToID[name] or 1
end

function ZVox.GetVoxelName(voxID)
	if not _voxels[voxID] then
		return "zvox:error"
	end

	return _voxels[voxID].name
end

function ZVox.GetVoxelStateType(id)
	return _voxels[id].voxelstatetype
end

function ZVox.GetVoxelStateParam(id, param)
	if not _voxels[id].voxelstateparams then
		return
	end


	return _voxels[id].voxelstateparams[param]
end


local _lastIdx = 0
function ZVox.GetVoxelCount()
	return _lastIdx - 1
end

function ZVox.GetVoxelByName(name)
	local id = _voxNameToID[name]
	if not id then
		return
	end

	return _voxels[id]
end

function ZVox.PokeVoxelEntry(name, var, val)
	local id = _voxNameToID[name]
	if not id then
		return
	end

	_voxels[id][var] = val
end

local fillerAverageAABB = {{0, 0, 0, 1, 1, 1}}

function ZVox.GetVoxelAABBList(voxID, voxState)
	if not _voxels[voxID] then
		return fillerAverageAABB
	end

	local aabbList = _voxels[voxID].aabb
	if not aabbList then
		return fillerAverageAABB
	end

	local stateEntry = aabbList[voxState]
	if not stateEntry then
		stateEntry = aabbList[0]
	end

	return stateEntry
end

local currVoxelCategory = ZVOX_VOXELCATEGORY_UNKNOWN
function ZVox.PushVoxelCategory(category)
	currVoxelCategory = category
end

function ZVox.GetVoxelCategory(voxID)
	return _voxels[voxID].category
end

function ZVox.GetVoxelCollisionGroup(voxID)
	return _voxels[voxID].collisiongroup
end

function ZVox.NewVoxel(params)
	local name = params.name
	if not name then
		ZVox.PrintError("Attempt to declare a voxel with no name!")
		return
	end

	name = ZVox.NAMESPACES_NamespaceConvert(name)

	if _lastIdx > 268435456 then
		ZVox.PrintFatal("[ZVox] too many voxels (" .. tostring(_lastIdx) .. "> 268435456)")
		return
	end

	if _voxNameToID[name] ~= nil then
		ZVox.PrintError("Attempting to re-declare existing voxel \"" .. name .. "\", this could be a mod conflict!")
		return
	end


	local aabbGet = params.aabb
	if aabbGet then -- divide by 16
		for k, v in pairs(aabbGet) do -- we could do this cleaner since it will always start at zero but i be lazy
			for i = 1, #v do
				local aabb = v[i]

				-- div by 16
				aabb[1] = aabb[1] / 16
				aabb[2] = aabb[2] / 16
				aabb[3] = aabb[3] / 16
				aabb[4] = aabb[4] / 16
				aabb[5] = aabb[5] / 16
				aabb[6] = aabb[6] / 16
			end
		end
	end


	local opaque = true
	if params.opaque ~= nil then
		opaque = params.opaque
	end
	_voxels[_lastIdx] = {
		["name"] = name,
		["category"] = currVoxelCategory,
		["visible"] = params.visible,
		["solid"] = params.solid,
		["multitex"] = params.multitex,
		["tex"] = params.tex or "zvox:white", -- ??? wtf was i coding here, white is not a texture, defaults to error thankfully
		["sound"] = params.sound,

		["voxelgroup"] = params.voxelgroup or ZVOX_VOXELGROUP_SOLID,
		["voxelstatetype"] = params.voxelstatetype or VOXELSTATE_TYPE_NONE,
		["voxelstateparams"] = params.voxelstateparams,

		["aabb"] = aabbGet,
		["emissive"] = params.emissive,
		["opaque"] = opaque,

		["voxelmodel"] = params.voxelmodel or "zvox:cube_all",
		["voxelmodeltable"] = params.voxelmodeltable,

		["collisiongroup"] = params.collisiongroup or ZVOX_COLLISION_GROUP_SOLID,
	}

	_voxNameToID[name] = _lastIdx
	_lastIdx = _lastIdx + 1
	-- MULTITEX
	-- idx 1 -> +x
	-- idx 2 -> -x
	-- idx 3 -> +y
	-- idx 4 -> -y
	-- idx 5 -> +z
	-- idx 6 -> -z

	ZVox.RecomputeExpressVoxelInfoRegistry()
end

function ZVox.SimpleVoxel(name, mat, group, voxelmodel)
	ZVox.NewVoxel({
		["name"] = name,
		["visible"] = true,
		["solid"] = true,
		["multitex"] = false,
		["tex"] = ZVox.NAMESPACES_NamespaceConvert(name),
		["opaque"] = true,

		["voxelgroup"] = group or ZVOX_VOXELGROUP_SOLID,


		["voxelstatetype"] = VOXELSTATE_TYPE_NONE,
		["voxelstateparams"] = nil,

		["aabb"] = nil,
		["sound"] = mat or ZVOX_MAT_STONE,
		["voxelmodel"] = voxelmodel,
	})
end

function ZVox.SimpleVoxelSlab(params)
	ZVox.NewVoxel({
		["name"] = params.name,
		["visible"] = true,
		["solid"] = true,
		["multitex"] = params.multitex,
		["tex"] = params.tex,
		["opaque"] = false,


		["voxelgroup"] = params.group or ZVOX_VOXELGROUP_SOLID,
		["sound"] = params.sound or ZVOX_MAT_STONE,

		["voxelstatetype"] = VOXELSTATE_TYPE_SLAB,
		["voxelstateparams"] = params.voxelstateparams,

		["voxelmodel"] = "zvox:slab_lower",
		["voxelmodeltable"] = {
			[0] = "zvox:slab_lower",
			[1] = "zvox:slab_upper",
		},
		["aabb"] = {
			[0] = {
				{
					0, 0, 0,
					16, 16, 8
				},
			},
			[1] = {
				{
					0, 0, 8,
					16, 16, 16
				},
			},
		}
	})
end

function ZVox.SimpleVoxelStairs(params)
	ZVox.NewVoxel({
		["name"] = params.name,
		["visible"] = true,
		["solid"] = true,
		["multitex"] = params.multitex,
		["tex"] = params.tex,
		["opaque"] = false,


		["voxelgroup"] = params.group or ZVOX_VOXELGROUP_SOLID,
		["sound"] = params.sound or ZVOX_MAT_STONE,

		["voxelstatetype"] = VOXELSTATE_TYPE_ZROT,
		["voxelstateparams"] = params.voxelstateparams,

		["voxelmodel"] = "zvox:stair_x_plus",
		["voxelmodeltable"] = {
			[0] = "zvox:stair_x_plus",
			[1] = "zvox:stair_x_minus",
			[2] = "zvox:stair_y_plus",
			[3] = "zvox:stair_y_minus",
		},
		["aabb"] = {
			[0] = {
				{
					0, 0, 0,
					16, 16, 8
				},
				{
					0, 0, 8,
					8, 16, 16
				},
			},
			[1] = {
				{
					0, 0, 0,
					16, 16, 8
				},
				{
					8, 0, 8,
					16, 16, 16
				},
			},
			[2] = {
				{
					0, 0, 0,
					16, 16, 8
				},
				{
					0, 0, 8,
					16, 8, 16
				},
			},
			[3] = {
				{
					0, 0, 0,
					16, 16, 8
				},
				{
					0, 8, 8,
					16, 16, 16
				},
			},
		}
	})
end

function ZVox.SimpleVoxelZRot(params)
	ZVox.NewVoxel({
		["name"] = params.name,
		["visible"] = true,
		["solid"] = true,
		["multitex"] = params.multitex,
		["tex"] = params.tex,
		["opaque"] = true,


		["voxelgroup"] = params.group or ZVOX_VOXELGROUP_SOLID,
		["sound"] = params.sound or ZVOX_MAT_STONE,

		["voxelstatetype"] = VOXELSTATE_TYPE_ZROT,
		["voxelstateparams"] = params.voxelstateparams,

		["voxelmodel"] = "zvox:zrot_x_plus",
		["voxelmodeltable"] = {
			[0] = "zvox:zrot_x_plus",
			[1] = "zvox:zrot_x_minus",
			[2] = "zvox:zrot_y_plus",
			[3] = "zvox:zrot_y_minus",
		},
	})
end

function ZVox.SimpleVoxelLogRot(params)
	ZVox.NewVoxel({
		["name"] = params.name,
		["visible"] = true,
		["solid"] = true,
		["multitex"] = params.multitex,
		["tex"] = params.tex,
		["opaque"] = true,


		["voxelgroup"] = params.group or ZVOX_VOXELGROUP_SOLID,
		["sound"] = params.sound or ZVOX_MAT_STONE,

		["voxelstatetype"] = VOXELSTATE_TYPE_LOGROT,
		["voxelstateparams"] = params.voxelstateparams,

		["voxelmodel"] = "zvox:logrot_z",
		["voxelmodeltable"] = {
			[0] = "zvox:logrot_z",
			[1] = "zvox:logrot_y",
			[2] = "zvox:logrot_x",
		},
	})
end

function ZVox.VoxelDonePrint()
	ZVox.PrintInfo("Done declaring voxels!")
	ZVox.PrintInfo("| " .. tostring(_lastIdx - 1) .. "/268435456 voxels declared...")
end


----------------------------------------------------------------------
--  /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ --
----------------------------------------------------------------------
--                     WHEN ADDING NEW VOXELS                       --
-- MAKE SURE YOU ADD THEM UNDER ALL OF THE PREVIOUSLY DECLARED ONES --
--            OTHERWISE OLD WORLDS WILL SHIFT BLOCKS                --
----------------------------------------------------------------------
--     NO LONGER AN ISSUE SINCE SAVES, DECLARE THEM ANYWHERE :)     --
----------------------------------------------------------------------
-- /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\  --
----------------------------------------------------------------------

ZVox.NAMESPACES_SetActiveNamespace("zvox")


ZVox.NewVoxel({
	["name"] = "air",
	["visible"] = false,
	["solid"] = false,
	["multitex"] = false,
	["tex"] = "zvox:air",
	["opaque"] = false,
})

ZVox.SimpleVoxel("error")