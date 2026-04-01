ZVox = ZVox or {}
file.CreateDir("zvox/saves")


-- header shouldn't change as it only specifies it is a zvox file and which version
local function writeHeader(fPtr, univObj)
	-- zvox file format header "ZVOX"

	fPtr:Write("ZVOX")
	-- now write byte for ver.

	local encodeVerTarget = ZVOX_ENCODER_VER_OVERRIDE or ZVOX_ENCODER_MAXVERSION
	fPtr:WriteByte(encodeVerTarget)
end


-- TODO: fix 
-- Unable to rename d:\steamlibrary\steamapps\common\garrysmod\garrysmod\data\zvox\saves\playtest.dat to d:\steamlibrary\steamapps\common\garrysmod\garrysmod\data\zvox\saves\playtest.backup.dat!
-- Unable to rename d:\steamlibrary\steamapps\common\garrysmod\garrysmod\data\zvox\saves\playtest_temp.dat to d:\steamlibrary\steamapps\common\garrysmod\garrysmod\data\zvox\saves\playtest.dat!

local progressiveQueue = {}
local function finishedSave(name, progressiveSaveStruct)
	if CurTime() < progressiveSaveStruct["saveTime"] then
		return
	end


	-- we finished! perform renaming and backups
	local fileName = progressiveSaveStruct.fileName


	local targetFinalNameNoExt = "zvox/saves/" .. name
	local targetFinalName = targetFinalNameNoExt .. ".dat"
	local targetFinalNameBackup = targetFinalNameNoExt .. ".backup.dat"

	-- File exists, we back up
	if file.Exists(targetFinalName, "DATA") then
		if file.Exists(targetFinalNameBackup, "DATA") then
			file.Delete(targetFinalNameBackup)
		end

		file.Rename(targetFinalName, targetFinalNameBackup)
	end

	-- copy it!
	file.Rename(fileName, targetFinalName)

	progressiveQueue[name] = nil
	progressiveSaveStruct = nil -- cleanup

	ZVox.PrintInfo("Done saving universe \"" .. name .. "\"!")
end


local _SAVE_WAIT = 2
local function performProgressiveSave(name, progressiveSaveStruct)
	if progressiveSaveStruct["finished"] then
		finishedSave(name, progressiveSaveStruct)
		return
	end

	local encoder = progressiveSaveStruct.encoder
	local univObj = progressiveSaveStruct.univObj
	local fPtr = progressiveSaveStruct.fPtr

	local persistData = progressiveSaveStruct.persistData


	local code = encoder.encodeFunc(fPtr, univObj, persistData)

	if code ~= ZVOX_PROGRESSIVE_ENCODE_FINISHED then
		return
	end
	progressiveSaveStruct["finished"] = true
	progressiveSaveStruct["saveTime"] = CurTime() + _SAVE_WAIT
end



function ZVox.ProgressiveSaveThink()
	for k, v in pairs(progressiveQueue) do
		performProgressiveSave(k, v)
	end
end

function ZVox.EmergencyProgressiveSaveNOW()
	while true do -- TODO: bad practice
		local did = false
		for k, v in pairs(progressiveQueue) do
			did = true

			v["saveTime"] = -100
			performProgressiveSave(k, v)
		end

		if not did then
			break
		end
	end
end


function ZVox.ForceProgressiveSaveUniverse(name)
	local entry = progressiveQueue[name]

	if not entry then
		return
	end

	for i = 1, 512000 do
		if not progressiveQueue[name] then
			break
		end

		entry["saveTime"] = -100
		performProgressiveSave(name, entry)
	end

	ZVox.PrintInfo("Done with ZVox.ForceProgressiveSaveUniverse for \"" .. name .. "\"!")
end


-- TODO: progressive save with queue
function ZVox.SaveUniverse(univObj, nameOverride)
	if not univObj then
		return
	end
	if univObj["noSave"] then
		return
	end


	ZVox.PrintInfo("Saving universe \"" .. univObj["name"] .. "\"!")

	local name = nameOverride or univObj["name"]
	if progressiveQueue[name] then
		return
	end


	local fileName = "zvox/saves/" .. name .. "_temp.dat"
	local fPtr = file.Open(fileName, "wb", "DATA")
	if not fPtr then
		ZVox.PrintFatal("Fatal error saving universe \"" .. univObj["name"] .. "\": invalid file pointer")
		return
	end

	writeHeader(fPtr, univObj)

	-- now encode!
	local encodeVerTarget = ZVOX_ENCODER_VER_OVERRIDE or ZVOX_ENCODER_MAXVERSION

	local encoder = ZVOX_ENCODER_LIST[encodeVerTarget]
	if not encoder then
		fPtr:Close()
		ZVox.PrintFatal("Fatal error saving universe \"" .. univObj["name"] .. "\": no encoder for version #" .. tostring(encodeVerTarget))
		return
	end

	local progressive = encoder.progressive
	if progressive then
		progressiveQueue[name] = {
			["fileName"] = fileName,
			["encoder"] = encoder,
			["fPtr"] = fPtr,
			["univObj"] = univObj,
			["persistData"] = {},
		}
		return
	end



	local ret = encoder.encodeFunc(fPtr, univObj, fileName)
	if ret ~= ZVOX_ENCODE_OK then
		fPtr:Close()
		ZVox.PrintFatal("Fatal error saving universe \"" .. univObj["name"] .. "\": encoder failure!")
		return
	end
	fPtr:Close()


	-- now once done, we copy the current temp one to the final one
	local targetFinalNameNoExt = "zvox/saves/" .. name
	local targetFinalName = targetFinalNameNoExt .. ".dat"
	local targetFinalNameBackup = targetFinalNameNoExt .. ".backup.dat"

	-- File exists, we back up
	if file.Exists(targetFinalName, "DATA") then
		if file.Exists(targetFinalNameBackup, "DATA") then
			file.Delete(targetFinalNameBackup)
		end

		file.Rename(targetFinalName, targetFinalNameBackup)
	end

	-- copy it!
	file.Rename(fileName, targetFinalName)
end



local univRegistry = ZVox.GetUniverseRegistry()
local _nextAutoSaveLUT = {}

local function autoSaveUnivThink(univObj)
	if not univObj then
		return
	end

	local name = univObj["name"]

	if not _nextAutoSaveLUT[name] then
		_nextAutoSaveLUT[name] = (CurTime() + ZVOX_AUTOSAVE_INTERVAL)
		return
	end

	if CurTime() < _nextAutoSaveLUT[name] then
		return
	end

	_nextAutoSaveLUT[name] = (CurTime() + ZVOX_AUTOSAVE_INTERVAL)

	ZVox.SaveUniverse(univObj, name)
end

function ZVox.UniverseAutoSaveThink()
	for k, v in pairs(univRegistry) do
		if v["noSave"] then
			continue
		end

		---autoSaveUnivThink(v)
	end
end

function ZVox.SaveAllUniverses()
	for k, v in pairs(univRegistry) do
		if k == "mothervox" then
			ZVox.SaveUniverse(v, ZVOX_AUTOSAVE_WORLDNAME)
		else
			ZVox.SaveUniverse(v)
		end
	end
end



-- TODO: ZVox.SaveUniverseAsync(univObj)
--[[
concommand.Add("zvox_save_universe" .. (CLIENT and "_cl" or "_sv"), function(ply, cmd, args)
	if not args[1] then
		ZVox.CommandErrorNotify(ply, "zvox_save_universe <univName> ?<univNameOverride>?")
		return
	end

	local univName = args[1]
	local nameOverride = args[2]

	local univObj = ZVox.GetUniverseByName(univName)
	if not univObj then
		ZVox.CommandErrorNotify(ply, "No universe named \"" .. univName .. "\"!")
		return
	end

	ZVox.SaveUniverse(univObj, nameOverride)
end)
]]--