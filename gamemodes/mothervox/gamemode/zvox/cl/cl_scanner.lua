ZVox = ZVox or {}
local cSizeX = ZVOX_CHUNKSIZE_X
local cSizeY = ZVOX_CHUNKSIZE_Y
local cSizeZ = ZVOX_CHUNKSIZE_Z
local cSizeConst1 = ZVOX_CHUNKSIZE_X * ZVOX_CHUNKSIZE_Y
local cSizeConst2 = ZVOX_CHUNKSIZE_X * ZVOX_CHUNKSIZE_Y * ZVOX_CHUNKSIZE_Z

local nextScan = 0
local foundOnScan = {}
function ZVox.Scanner_ScannerThink(univObj)
	if nextScan > CurTime() then
		return
	end

	nextScan = CurTime() + (1 / ZVox.Upgrades_GetScannerInterval())

	foundOnScan = {}

	local plyPos = ZVox.GetPlayerInterpolatedPos()
	local pX, pY, pZ = math.floor(plyPos[1]), math.floor(plyPos[2]), math.floor(plyPos[3])

	local range = ZVox.Upgrades_GetScannerRange()


	local wX, wY, wZ
	for z = -range, range do
		for y = -range, range do
			for x = -range, range do
				if (x == 0) and (y == 0) and (z == 0) then
					continue
				end

				wX = pX + x
				wY = pY + y
				wZ = pZ + z

				if (wX < 0) or (wY < 0) or (wZ < 0) then
					continue
				end

				if (wX >= (univObj.chunkSizeX * cSizeX)) or (wY >= (univObj.chunkSizeY * cSizeY)) or (wZ >= (univObj.chunkSizeZ * cSizeZ)) then
					continue
				end

				local voxID = ZVox.GetBlockAtPos(univObj, wX, wY, wZ)
				local voxName = ZVox.GetVoxelName(voxID)

				local scannable = MOTHERVOX_SCANNABLE_BLOCKS[voxName]
				if not scannable then
					continue
				end

				foundOnScan[#foundOnScan + 1] = {
					voxName, wX, wY, wZ,
					0, 0, -- scrx, scry
					0 -- dist
				}
			end
		end
	end
end

local tmp = Vector()
function ZVox.Scanner_ComputeScannerVisibility()
	if #foundOnScan <= 0 then
		return
	end

	local plyPos = ZVox.GetPlayerInterpolatedPos()
	for i = 1, #foundOnScan do
		local scanEntry = foundOnScan[i]

		local name = scanEntry[1]
		local x, y, z = scanEntry[2], scanEntry[3], scanEntry[4]

		tmp:SetUnpacked(x + .5, y + .5, z + .5)

		local scrPos = tmp:ToScreen()

		scanEntry[5] = scrPos.x
		scanEntry[6] = scrPos.y

		-- calc dist
		scanEntry[7] = plyPos:Distance(tmp) -- actual distance yes this is slow, i don't gaf
	end
end


function ZVox.Scanner_RenderScanned()
	if #foundOnScan <= 0 then
		return
	end

	local range = ZVox.Upgrades_GetScannerRange()

	local nextScanDelta = (nextScan - CurTime()) * ZVox.Upgrades_GetScannerInterval()
	nextScanDelta = math.min(nextScanDelta, 1)
	nextScanDelta = math.max(nextScanDelta, .25)

	local shakeX, shakeY = ZVox.GetScreenShake()


	for i = 1, #foundOnScan do
		local scanEntry = foundOnScan[i]
		local dist = scanEntry[7]
		local distDelta = dist / (range)
		distDelta = math.min(distDelta, 1)
		distDelta = 1 - distDelta

		local name = scanEntry[1]
		local col = MOTHERVOX_SCANNABLE_COLOURS[name]


		local scrX, scrY = scanEntry[5] + shakeX, scanEntry[6] + shakeY
		surface.SetDrawColor(col.r, col.g, col.b, (1 - distDelta) * 128 * nextScanDelta)

		local sz = 128
		sz = sz * math.max(distDelta, .25)

		local h_sz = sz * .5

		for j = 1, 8 do
			local oX = (.5 - math.random()) * 64
			local oY = (.5 - math.random()) * 64

			surface.DrawRect(scrX - h_sz + oX, scrY - h_sz + oY, sz, sz)
		end
	end
end