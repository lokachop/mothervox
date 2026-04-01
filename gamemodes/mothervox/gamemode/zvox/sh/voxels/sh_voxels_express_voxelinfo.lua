ZVox = ZVox or {}

-- EXPRESS VOXELINFO
-- a faster way to get voxel info, although more mem hungry
-- this file is loaded before sh_voxels, as sh_voxels calls into it!

-- make these global
ZVOX_EXPRESS_IDX_NAME             = 1
ZVOX_EXPRESS_IDX_VISIBLE          = 2
ZVOX_EXPRESS_IDX_SOLID            = 3
ZVOX_EXPRESS_IDX_MULTITEX         = 4
ZVOX_EXPRESS_IDX_TEX              = 5
ZVOX_EXPRESS_IDX_VOXELGROUP       = 6
ZVOX_EXPRESS_IDX_VOXELMODEL       = 7
ZVOX_EXPRESS_IDX_VOXELMODEL_TABLE = 8
ZVOX_EXPRESS_IDX_EMISSIVE         = 9
ZVOX_EXPRESS_IDX_OPAQUE           = 10

local expressVoxelRegistry = {}
function ZVox.GetExpressVoxelInfoRegistry()
	return expressVoxelRegistry
end

-- This is what you should copy into your file that uses express
-- also express is internal only, addons shouldn't have to tamper with it!

-- EXPRESSINCLUDE
local voxInfoExpressRegistry        = ZVox.GetExpressVoxelInfoRegistry()
local _EXPRESS_IDX_NAME 	        = ZVOX_EXPRESS_IDX_NAME
local _EXPRESS_IDX_VISIBLE          = ZVOX_EXPRESS_IDX_VISIBLE
local _EXPRESS_IDX_SOLID            = ZVOX_EXPRESS_IDX_SOLID
local _EXPRESS_IDX_MULTITEX         = ZVOX_EXPRESS_IDX_MULTITEX
local _EXPRESS_IDX_TEX              = ZVOX_EXPRESS_IDX_TEX
local _EXPRESS_IDX_VOXELGROUP       = ZVOX_EXPRESS_IDX_VOXELGROUP
local _EXPRESS_IDX_VOXELMODEL       = ZVOX_EXPRESS_IDX_VOXELMODEL
local _EXPRESS_IDX_VOXELMODEL_TABLE = ZVOX_EXPRESS_IDX_VOXELMODEL_TABLE
local _EXPRESS_IDX_EMISSIVE         = ZVOX_EXPRESS_IDX_EMISSIVE
local _EXPRESS_IDX_OPAQUE           = ZVOX_EXPRESS_IDX_OPAQUE
-- EXPRESSINCLUDE


function ZVox.RecomputeExpressVoxelInfoRegistry()
	for i = 0, ZVox.GetVoxelCount() do
		local voxNfo = ZVox.GetVoxelByID(i)
		if not voxNfo then
			continue
		end


		local tblGet = expressVoxelRegistry[i]
		if not tblGet then
			expressVoxelRegistry[i] = {}
			tblGet = expressVoxelRegistry[i]
		end

		tblGet[_EXPRESS_IDX_NAME]             = voxNfo["name"]
		tblGet[_EXPRESS_IDX_VISIBLE]          = voxNfo["visible"]
		tblGet[_EXPRESS_IDX_SOLID]            = voxNfo["solid"]
		tblGet[_EXPRESS_IDX_MULTITEX]         = voxNfo["multitex"]
		tblGet[_EXPRESS_IDX_TEX]              = voxNfo["tex"]
		tblGet[_EXPRESS_IDX_VOXELGROUP]       = voxNfo["voxelgroup"]
		tblGet[_EXPRESS_IDX_VOXELMODEL]       = voxNfo["voxelmodel"]
		tblGet[_EXPRESS_IDX_VOXELMODEL_TABLE] = voxNfo["voxelmodeltable"]
		tblGet[_EXPRESS_IDX_EMISSIVE]         = voxNfo["emissive"]
		tblGet[_EXPRESS_IDX_OPAQUE]           = voxNfo["opaque"]

		--[[
		tblGet[_EXPRESS_IDX_VOXELSTATETYPE]   = voxNfo["voxelstatetype"]
		tblGet[_EXPRESS_IDX_VOXELSTATEPARAMS] = voxNfo["voxelstateparams"]
		tblGet[_EXPRESS_IDX_AABB]             = voxNfo["aabb"]
		tblGet[_EXPRESS_IDX_SOUND]            = voxNfo["sound"]
		tblGet[_EXPRESS_IDX_UNSHADED]         = voxNfo["unshaded"]
		]]--
	end
end