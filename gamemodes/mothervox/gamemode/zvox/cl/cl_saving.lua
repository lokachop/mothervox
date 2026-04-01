ZVox = ZVox or {}


local hasSave = file.Exists("zvox/mv_savefile.dat", "DATA")
function ZVox.MV_HasSaveFile()
	return hasSave
end

function ZVox.MV_SaveProgress()
	local fBuffSave = ZVox.FB_NewFileBuffer()
	ZVox.FB_Write(fBuffSave, "MVSV")

	ZVox.FB_WriteUShort(fBuffSave, MV_PART_MAX)
	-- save our upgrades
	for i = 1, MV_PART_MAX do
		local partLv = ZVox.Upgrades_GetPartLevel(i)
		ZVox.FB_WriteByte(fBuffSave, partLv)
	end

	-- save our consumables
	ZVox.FB_WriteUShort(fBuffSave, MV_CONSUMABLE_MAX)
	for i = 1, MV_CONSUMABLE_MAX do
		local count = ZVox.Consumable_GetCurrentCount(i)
		ZVox.FB_WriteULong(fBuffSave, count)
	end

	-- money
	ZVox.FB_WriteULong(fBuffSave, ZVox.Money_GetCurrentMoney())

	-- how many blocks we dug
	ZVox.FB_WriteULong(fBuffSave, ZVox.DugBlocksTotal)

	-- how many we exploded
	ZVox.FB_WriteULong(fBuffSave, ZVox.ExplodedBlocksTotal)

	-- how many ores we exploded
	ZVox.FB_WriteULong(fBuffSave, ZVox.ExplodedMineralsTotal)

	-- and how much magma we dug
	ZVox.FB_WriteULong(fBuffSave, ZVox.DugMagmaTotal)

	-- and the comm. flags
	ZVox.FB_WriteULong(fBuffSave, ZVox.CommunicationFlags)

	ZVox.FB_DumpToDisk(fBuffSave, "zvox/mv_savefile.dat")
	if not hasSave then
		hasSave = true
	end

	ZVox.FB_Close(fBuffSave)
end


function ZVox.MV_LoadProgress()
	if not ZVox.MV_HasSaveFile() then
		return
	end

	local fBuffGet = ZVox.FB_NewFileBufferFromFile("zvox/mv_savefile.dat")
	if not fBuffGet then
		ZVox.PrintError("Failed to load the savedata file, probably doesn't exist?")
		return
	end

	local magic = ZVox.FB_Read(fBuffGet, 4)
	if magic ~= "MVSV" then
		ZVox.PrintError("Failed to load the savedata file, magic doesn't match")
		return
	end

	local partCount = ZVox.FB_ReadUShort(fBuffGet)
	for i = 1, partCount do
		local lvRead = ZVox.FB_ReadByte(fBuffGet)
		ZVox.Upgrades_SetPartLevel(i, lvRead)
	end

	local consumableCount = ZVox.FB_ReadUShort(fBuffGet)
	for i = 1, consumableCount do
		local count = ZVox.FB_ReadULong(fBuffGet)
		ZVox.Consumable_SetConsumableCount(i, count)
	end

	-- money
	local moneyCount = ZVox.FB_ReadULong(fBuffGet)
	ZVox.Money_SetMoney(moneyCount)

	local blocksDug = ZVox.FB_ReadULong(fBuffGet)
	ZVox.DugBlocksTotal = blocksDug or 0

	local blocksExploded = ZVox.FB_ReadULong(fBuffGet)
	ZVox.ExplodedBlocksTotal = blocksExploded or 0

	local mineralsExploded = ZVox.FB_ReadULong(fBuffGet)
	ZVox.ExplodedMineralsTotal = mineralsExploded or 0

	local magmaDug = ZVox.FB_ReadULong(fBuffGet)
	ZVox.DugMagmaTotal = magmaDug or 0

	local commFlags = ZVox.FB_ReadULong(fBuffGet)
	ZVox.CommunicationFlags = commFlags or 0x0

	ZVox.FB_Close(fBuffGet)

	ZVox.Fuel_GainFuel(5120000)
	ZVox.Health_GainHealth(5120000)
end

function ZVox.MV_ResetProgress()
	for i = 1, MV_PART_MAX do
		ZVox.Upgrades_SetPartLevel(i, 0)
	end

	for i = 1, MV_CONSUMABLE_MAX do
		ZVox.Consumable_SetConsumableCount(i, 0)
	end

	-- money
	ZVox.Money_SetMoney(20)

	ZVox.DugBlocksTotal = 0
	ZVox.ExplodedBlocksTotal = 0
	ZVox.ExplodedMineralsTotal = 0
	ZVox.DugMagmaTotal = 0
	ZVox.CommunicationFlags = 0x0

	ZVox.Health_SetHealth(512000)
	ZVox.Fuel_SetFuel(ZVox.Upgrades_GetMaxFuelLevel())
end