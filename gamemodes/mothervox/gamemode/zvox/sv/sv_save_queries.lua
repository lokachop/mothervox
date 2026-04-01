ZVox = ZVox or {}

-- returns a sequential table of what saves are available on the server
-- this effectively returns all of the data/zvox/saves that don't end in .backup.dat
-- TODO: backups shouldn't be going to the same save directory!
function ZVox.SV_GetSaveListing()
	local saveFiles = file.Find("zvox/saves/*.dat", "DATA")

	local retList = {}
	for i = 1, #saveFiles do
		local fileName = saveFiles[i]
		-- hax check if its a backup
		-- .backup.dat
		local backupLast = string.sub(fileName, -11)

		if backupLast == ".backup.dat" then
			continue
		end

		retList[#retList + 1] = fileName
	end

	return retList
end


-- same as above, but without the ones that are actually loaded
function ZVox.SV_GetUnloadedSaveListing()
	local saveFiles = file.Find("zvox/saves/*.dat", "DATA")

	local retList = {}
	for i = 1, #saveFiles do
		local fileName = saveFiles[i]
		-- hax check if its a backup
		-- .backup.dat
		local backupLast = string.sub(fileName, -11)

		if backupLast == ".backup.dat" then
			continue
		end

		local truName = string.sub(fileName, 1, #fileName - 4)
		local loaded = ZVox.IsUniverseLoaded(truName)
		if loaded then
			continue
		end

		retList[#retList + 1] = fileName
	end

	return retList
end