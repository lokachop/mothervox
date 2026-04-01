ZVox = ZVox or {}
local voxRegistry = ZVox.GetVoxelRegistry()

-- This for lua refresh compliance, check if we have added/removed any blocks since last luaRefresh, if so, go through each universe and shift their IDs up/down
-- so it still retains the same voxels

-- consts
local DO_EXCHANGE_TABLE_PRINT = false

ZVox._IDShift_VoxelList = ZVox._IDShift_VoxelList
ZVox._IDShift_VoxelList_ByName = ZVox._IDShift_VoxelList_ByName
ZVox._IDShift_VoxelCount = ZVox._IDShift_VoxelCount
local function recomputeVoxelList()
	ZVox._IDShift_VoxelList = {}
	ZVox._IDShift_VoxelList_ByName = {}

	local voxCount = ZVox.GetVoxelCount()
	ZVox._IDShift_VoxelCount = voxCount

	for i = 0, voxCount do
		local voxNfo = voxRegistry[i]

		local voxelName = voxNfo.name

		ZVox._IDShift_VoxelList[i] = voxelName
		ZVox._IDShift_VoxelList_ByName[voxelName] = i
	end
end

if not ZVox._IDShift_VoxelList then
	recomputeVoxelList()
	return
end


-- now we check if we have added / lost voxels
local haveShifted = false
for i = 0, ZVox.GetVoxelCount() do
	local voxNfo = voxRegistry[i]


	local voxName = voxNfo.name
	local listName = ZVox._IDShift_VoxelList[i]

	if voxName ~= listName then
		haveShifted = true
		break
	end
end

if not haveShifted then -- no changes in structure, we haven't shifted
	return
end
ZVox.PrintError("IDs have shifted! Attempting to fix...")
ZVox.PrintError("If you keep seeing this and you're not a developer, it is very likely a mod author sucks at programming!")
ZVox.PrintError("If you're a developer, make sure to not add voxels mid-game in your final release!")

-- we have shifted, build an exchange table
if DO_EXCHANGE_TABLE_PRINT then
	ZVox.PrintInfo("--== REPAIR EXCHANGE TABLE ==--")
end

local exchTable = {}
for i = 0, ZVox._IDShift_VoxelCount do
	local oldID = i
	local oldName = ZVox._IDShift_VoxelList[oldID]

	local newID = ZVox.GetVoxelID(oldName)

	exchTable[oldID] = newID


	if DO_EXCHANGE_TABLE_PRINT then
		ZVox.PrintInfo(oldName .. "[#" .. tostring(oldID) .. "] -> " .. ZVox.GetVoxelName(newID) .. "[#" .. tostring(newID) .. "]")
	end
end



--start repairing the universes
local cSizeX = ZVOX_CHUNKSIZE_X
local cSizeY = ZVOX_CHUNKSIZE_Y
local cSizeZ = ZVOX_CHUNKSIZE_Z
local function repairChunk(chunk)
	for i = 0, (cSizeX * cSizeY * cSizeZ) do
		local oldData = chunk["voxelData"][i]


		local newID = exchTable[oldData]
		if not newID then
			ZVox.PrintError("No NewID for oldID [#" .. tostring(oldData) .. "], if you deleted a voxel, this is normal!")
			newID = 1
		end

		chunk["voxelData"][i] = newID
	end
end


local function repairUniverse(univObj)
	local chunkSizeX = univObj.chunkSizeX
	local chunkSizeY = univObj.chunkSizeY
	local chunkSizeZ = univObj.chunkSizeZ

	for i = 0, (chunkSizeX * chunkSizeY * chunkSizeZ) - 1 do
		repairChunk(univObj["chunks"][i])
	end
end

for k, v in pairs(ZVox.GetUniverseRegistry()) do
	repairUniverse(v)
end

-- recompute the list so we don't fuck it up after patching it
recomputeVoxelList()

-- and remesh to fix vis issues
if CLIENT then
	ZVox.RemeshUniv(ZVox.GetActiveUniverse(), true)
end