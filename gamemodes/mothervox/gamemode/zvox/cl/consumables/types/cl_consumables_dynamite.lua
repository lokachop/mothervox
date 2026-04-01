ZVox = ZVox or {}
local cSizeX = ZVOX_CHUNKSIZE_X
local cSizeY = ZVOX_CHUNKSIZE_Y
local cSizeZ = ZVOX_CHUNKSIZE_Z
local colBlue = Color(64, 196, 255)
local nextCanDynamite = 0
ZVox.NewControlListener("item_dynamite", "dynamite_use", function()
	if ZVox.GetState() ~= ZVOX_STATE_INGAME then
		return
	end

	if ZVox.GetGamePaused() then
		return
	end

	local currDynamite = ZVox.Consumable_GetCurrentCount(MV_CONSUMABLE_DYNAMITE)
	if currDynamite <= 0 then
		return
	end

	if not ZVox.GetPlayerGrounded() then
		return
	end

	if nextCanDynamite > CurTime() then
		return
	end
	nextCanDynamite = CurTime() + 1.25

	surface.PlaySound("mothervox/sfx/consumables/dynamite.wav")
	ZVox.DoScreenShake(48, 0.65)
	ZVox.AddMinedPopup("Used Dynamite", colBlue)



	local plyPos = ZVox.GetPlayerInterpolatedPos()
	local plyX, plyY, plyZ = math.floor(plyPos[1]), math.floor(plyPos[2]), math.floor(plyPos[3])


	local univObj = ZVox.GetActiveUniverse()

	local size = 1
	for x = -size, size do
		for y = -size, size do
			for z = -size, size do
				local wX = x + plyX
				local wY = y + plyY
				local wZ = z + plyZ

				if (wX < 0) or (wY < 0) or (wZ < 0) then
					continue
				end

				if (wX >= (univObj.chunkSizeX * cSizeX)) or (wY >= (univObj.chunkSizeY * cSizeY)) or (wZ >= (univObj.chunkSizeZ * cSizeZ)) then
					continue
				end

				local voxID = ZVox.GetBlockAtPos(univObj, wX, wY, wZ)
				local voxName = ZVox.GetVoxelName(voxID)

				local canBoom = MOTHERVOX_ALLOWED_CAN_EXPLODE_BLOCKS[voxName]
				if not canBoom then
					continue
				end

				ZVox.ExplodedBlocksTotal = ZVox.ExplodedBlocksTotal + 1

				if MOTHERVOX_SCANNABLE_BLOCKS[voxName] then
					ZVox.ExplodedMineralsTotal = ZVox.ExplodedMineralsTotal + 1
				end

				local act = ZVox.NewAction("zvox:break")
				act:SetUniverseName(ZVox.GetActiveUniverse()["name"])

				act:SetPosition(wX, wY, wZ)

				ZVox.CL_ExecuteAction(act)
				ZVox.CL_SendAction(act)
			end
		end
	end

	ZVox.Consumable_SpendConsumable(MV_CONSUMABLE_DYNAMITE)
	ZVox.PushExplosionFX(0.5)
end)