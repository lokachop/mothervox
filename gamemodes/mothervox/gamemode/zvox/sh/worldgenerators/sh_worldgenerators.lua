ZVox = ZVox or {}

---@alias worldgenerator table

ZVOX_WORLDGEN_STAGE_TYPE_SETTER = 1
ZVOX_WORLDGEN_STAGE_TYPE_EXCHANGER = 2
ZVOX_WORLDGEN_STAGE_TYPE_COMPUTE = 3
ZVOX_WORLDGEN_STAGE_TYPE_SOLO_COMPUTE = 4

-- how stages work
-- ZVOX_WORLDGEN_STAGE_TYPE_SETTER -> Sets blocks, classic function(x, y, z) return "namespace:blockName" end
-- ZVOX_WORLDGEN_STAGE_TYPE_EXCHANGER -> exchanges blocks, function(x, y, z, blockName) return nil for no exchange, return new block name to set it, useful for oregen
-- ^- also useful for carve stages
-- ZVOX_WORLDGEN_STAGE_TYPE_COMPUTE -> loops thru each block but you don't set anything, useful for heightmap computes?
-- ZVOX_WORLDGEN_STAGE_TYPE_SOLO_COMPUTE -> single func call with the univ object to precompute certain stuff

local genStartTime = 0
local function getMsSinceStart()
	return math.floor((SysTime() - genStartTime) * 100000) / 100
end

local _worldGenners = {}
function ZVox.DeclareNewWorldGenerator(name, data)
	if not name then
		ZVox.PrintError("Attempt to create a world generator with no name!")
		return
	end

	name = ZVox.NAMESPACES_NamespaceConvert(name)


	local worldGenerator = {}
	worldGenerator["data"] = {
		["author"] = data.author or "No Author?",
		["fancyname"] = data.fancyName or name,
		["description"] = data.description or "No description, please write one...",
	}

	worldGenerator["last_stage_id"] = 0
	worldGenerator["stage_to_id"] = {}
	worldGenerator["stages"] = {}
	function worldGenerator:AddStage(stageName, stageData)
		if not stageName then
			ZVox.PrintFatal("Attempt to add a world generator stage with no name!")
			return
		end

		self.last_stage_id = self.last_stage_id + 1
		local stageID = self.last_stage_id

		local finalStageData = {
			["name"] = stageName,
			["stagetype"] = stageData.stagetype or ZVOX_WORLDGEN_STAGE_TYPE_SETTER,
			["callback"] = stageData.callback or function() return "zvox:error" end
		}

		self.stages[stageID] = finalStageData
	end


	_worldGenners[name] = worldGenerator
	return worldGenerator
end

function ZVox.GetWorldGeneratorByName(name)
	return _worldGenners[name]
end

local function performWorldGenStage(univ, stage)
	local cSizeX = univ.chunkSizeX
	local cSizeY = univ.chunkSizeY
	local cSizeZ = univ.chunkSizeZ

	local stageName = stage.name
	local stageType = stage.stagetype
	ZVox.PrintInfo("| executing stage \"" .. stageName .. "\" (" .. tostring(getMsSinceStart()) .. "ms)")


	if stageType == ZVOX_WORLDGEN_STAGE_TYPE_SOLO_COMPUTE then
		stage.callback(univ)
	end

	local coX, coY, coZ
	for i = 0, (cSizeX * cSizeY * cSizeZ) - 1 do
		local chunk = univ["chunks"][i]
		coX, coY, coZ = ZVox.ChunkIndexToWorld(univ, chunk["index"])

		local vData = chunk["voxelData"]
		local vState = chunk["voxelState"]

		local voxName, voxState
		local x, y, z
		for j = 0, ZVOX_CHUNKSIZE_XYZ do
			x = (j % ZVOX_CHUNKSIZE_X) + coX
			y = (math.floor(j / ZVOX_CHUNKSIZE_X) % ZVOX_CHUNKSIZE_Y) + coY
			z = (math.floor(j / ZVOX_CHUNKSIZE_XY) % ZVOX_CHUNKSIZE_Z) + coZ

			if stageType == ZVOX_WORLDGEN_STAGE_TYPE_SETTER then
				voxName, voxState = stage.callback(x, y, z)

				vData[j] = ZVox.GetVoxelID(voxName)
				if voxState then
					vState[j] = voxState
				end
			elseif stageType == ZVOX_WORLDGEN_STAGE_TYPE_EXCHANGER then
				voxName, voxState = stage.callback(x, y, z, ZVox.GetVoxelName(vData[j]), vState[j])

				if voxName then
					vData[j] = ZVox.GetVoxelID(voxName)
				end
				if voxState then
					vState[j] = voxState
				end
			elseif stageType == ZVOX_WORLDGEN_STAGE_TYPE_COMPUTE then
				stage.callback(x, y, z)
			end
		end
	end
end


function ZVox.UniverseGenerateChunks(univ)
	if not univ then
		return
	end

	local wGen = univ["worldgen"]
	if not wGen then
		wGen = "zvox:legacy"
	end


	if type(wGen) == "function" then
		ZVox.OLD_UniverseGenerateChunks(univ)
		return
	end

	ZVox.PrintInfo("Performing worldgen \"" .. wGen .. "\" for universe \"" .. univ.name .. "\"!")
	genStartTime = SysTime()

	local wGenEntry = ZVox.GetWorldGeneratorByName(wGen)
	if not wGenEntry then
		wGenEntry = ZVox.GetWorldGeneratorByName("zvox:legacy")
	end

	-- init the chunks first
	local cSizeX = univ.chunkSizeX
	local cSizeY = univ.chunkSizeY
	local cSizeZ = univ.chunkSizeZ

	for i = 0, (cSizeX * cSizeY * cSizeZ) - 1 do
		local chunk = ZVox.NewChunk(i)
		ZVox.SetChunkUniv(chunk, univ)
		univ["chunks"][i] = chunk


		for j = 0, ZVOX_CHUNKSIZE_XYZ do
			chunk["voxelData"][j] = 0 -- id 0 hardcoded air
			chunk["voxelState"][j] = 0
		end
	end
	ZVox.PrintInfo("| generated empty chunks (" .. tostring(getMsSinceStart()) .. "ms)")

	local stages = wGenEntry.stages
	for i = 1, #stages do
		local stage = stages[i]

		performWorldGenStage(univ, stage)
	end

	ZVox.PrintInfo("Done performing worldgen! (took " .. tostring(getMsSinceStart()) .. "ms)")

	if not CLIENT then
		return
	end


	--for i = 0, (cSizeX * cSizeY * cSizeZ) - 1 do
		--ZVox.EmitChunkToRemesh(univ["chunks"][i])
	--end
end