ZVox = ZVox or {}

---@alias universe table Universe object

local _univRegistry = {}
if ZVox.UnivPersistRegistry then
	_univRegistry = ZVox.UnivPersistRegistry
end
ZVox.UnivPersistRegistry = _univRegistry -- refresh persistence

function ZVox.GetUniverseRegistry()
	return _univRegistry
end

function ZVox.GetUniverseByName(name)
	return _univRegistry[name]
end

function ZVox.NewUniverse(name, params)
	if not name then
		return
	end

	local cSizeX = params and (params.chunkSizeX or 8) or 8
	local cSizeY = params and (params.chunkSizeY or 8) or 8
	local cSizeZ = params and (params.chunkSizeZ or 8) or cSizeY
	local clientOnly = params and params.clientOnly

	if clientOnly then
		clientOnly = true
	else
		clientOnly = false
	end

	_univRegistry[name] = {
		["name"] = name,
		["chunks"] = {},
		["chunkSizeX"] = cSizeX,
		["chunkSizeY"] = cSizeY,
		["chunkSizeZ"] = cSizeZ,

		["chunkSizeConst1"] = cSizeX * cSizeY,

		["worldgen"] = function() return "zvox:air" end,

		["clientOnly"] = clientOnly,
		["noSave"] = false,

		["plusdata"] = ZVox.GetDefaultPlusDataTable(), -- this returns a copy with default plusdata values
	}

	return _univRegistry[name]
end

function ZVox.DeleteUniverseFromRegistry(name)
	if not _univRegistry[name] then
		return
	end

	_univRegistry[name] = nil
end

function ZVox.SetUniverseChunkSize(univ, cSizeX, cSizeY, cSizeZ)
	if not univ then
		return
	end

	univ["chunkSizeX"] = cSizeX
	univ["chunkSizeY"] = cSizeY
	univ["chunkSizeZ"] = cSizeZ

	univ["chunkSizeConst1"] = cSizeX * cSizeY
end

---Gets the chunkSize of a universe
---@shared
---@internal
---@group internal
---@category universes
---@param univ universe The universe
---@return integer chunkSizeX
---@return integer chunkSizeY
---@return integer chunkSizeZ
function ZVox.GetUniverseChunkSize(univ)
	return univ["chunkSizeX"], univ["chunkSizeY"], univ["chunkSizeZ"]
end

---Gets the block size of a universe
---@shared
---@internal
---@group internal
---@category universes
---@param univ universe The universe
---@return integer blockSizeX
---@return integer blockSizeY
---@return integer blockSizeZ
function ZVox.GetUniverseBlockSize(univ)
	return univ["chunkSizeX"] * ZVOX_CHUNKSIZE_X, univ["chunkSizeY"] * ZVOX_CHUNKSIZE_Y, univ["chunkSizeZ"] * ZVOX_CHUNKSIZE_Z
end

function ZVox.SetUniverseWorldGenFunc(univ, func)
	if not univ then
		return
	end

	univ["worldgen"] = func
end

function ZVox.SetUniverseWorldGen(univ, worldGenName)
	if not univ then
		return
	end

	if not ZVox.GetWorldGeneratorByName(worldGenName) then
		return
	end

	univ["worldgen"] = worldGenName
end


function ZVox.SetUniverseClientOnly(univ, bool)
	if not univ then
		return
	end

	univ["clientOnly"] = bool
end

function ZVox.RawSetUniversePlusDataTable(univ, pData)
	if not univ then
		return
	end

	if not pData then
		ZVox.PrintFatal("raw setting plusdata to a nil value, something went wrong, and stuff will break </3")
	end

	univ["plusdata"] = pData
end

function ZVox.OLD_UniverseGenerateChunks(univ)
	if not univ then
		return
	end

	local cSizeX = univ.chunkSizeX
	local cSizeY = univ.chunkSizeY
	local cSizeZ = univ.chunkSizeZ


	local startTime = SysTime()

	for i = 0, (cSizeX * cSizeY * cSizeZ) - 1 do
		local chunk = ZVox.NewChunk(i)
		univ["chunks"][i] = chunk

		-- perform the world gen
		ZVox.ChunkPerformWorldGen(univ, chunk)
	end

	local endTime = SysTime()
	ZVox.PrintInfo("Done generating chunks!")
	ZVox.PrintInfo("| took " .. tostring((endTime - startTime) * 1000) .. "ms")

	if not CLIENT then
		return
	end

	for i = 0, (cSizeX * cSizeY * cSizeZ) - 1 do
		ZVox.EmitChunkToRemesh(univ["chunks"][i])
	end
end


function ZVox.IsUniverseLoaded(name)
	return _univRegistry[name] and true or false
end

if SERVER then
	return
end


local _activeUniv = nil
if ZVox.ActiveUniverse then
	_activeUniv = ZVox.ActiveUniverse
end
ZVox.ActiveUniverse = _activeUniv

---Returns the active clientside universe
---@client
---@internal
---@group internal
---@category universes
---@return universe univ The active universe
function ZVox.GetActiveUniverse()
	return _activeUniv
end

function ZVox.SetActiveUniverse(name)
	_activeUniv = name
	ZVox.ActiveUniverse = _activeUniv
end


local function _sortFunc(a, b)
	return a[2] < b[2]
end

function ZVox.RemeshUniv(univ, sort)
	if not univ then
		return
	end

	--print("REMESHING UNIV")
	--ZVox.Lighting_SetActiveUniverse()
	--ZVox.Culling_SetActiveUniverse()

	local cSizeX = univ.chunkSizeX
	local cSizeY = univ.chunkSizeY
	local cSizeZ = univ.chunkSizeZ

	-- sort by closest dist to ply

	if sort then
		local meshSorted = {}
		local plyPos = ZVox.GetPlayerPos()
		for i = 0, (cSizeX * cSizeY * cSizeZ) - 1 do
			local chunkPos = Vector(cSizeX, cSizeY, cSizeZ)

			local dist = chunkPos:DistToSqr(plyPos)

			meshSorted[#meshSorted + 1] = {i, dist}
		end

		table.sort(meshSorted, _sortFunc)

		for i = 1, #meshSorted do
			local chunk = univ["chunks"][meshSorted[i][1]]
			ZVox.Culling_FullRecullChunk(chunk)
			ZVox.Lighting_FullRelightChunk(chunk)
			ZVox.EmitChunkToRemesh(chunk)
		end

	else
		for i = 0, (cSizeX * cSizeY * cSizeZ) - 1 do
			local chunk = univ["chunks"][i]

			ZVox.Culling_FullRecullChunk(chunk)
			ZVox.Lighting_FullRelightChunk(chunk)
			ZVox.EmitChunkToRemesh(chunk)
		end
	end
end

function ZVox.SetUniverseNoSave(univ, noSave)
	if not univ then
		return
	end

	univ["noSave"] = noSave or false
end