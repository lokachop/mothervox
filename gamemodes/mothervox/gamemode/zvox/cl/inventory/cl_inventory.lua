ZVox = ZVox or {}



function ZVox.OpenInventory()
	if ZVox.GetPlayerMovementType() ~= ZVOX_MOVEMENT_NOCLIP then
		ZVox.MV_OpenInventory()
		-- open mothervox inventory
		return
	end

	if ZVOX_DO_UI_NEW_GEN_INVENTORY then
		ZVox.NEW_OpenInventory()
		return
	end

	ZVox.OLD_OpenInventory()
end

function ZVox.CloseInventory()
	if ZVox.GetPlayerMovementType() ~= ZVOX_MOVEMENT_NOCLIP then
		ZVox.MV_CloseInventory()
		-- close mothervox inventory
		return
	end


	if ZVOX_DO_UI_NEW_GEN_INVENTORY then
		ZVox.NEW_CloseInventory()
		return
	end

	ZVox.OLD_CloseInventory()
end

ZVox.NewControlListener("inv_show", "open_inv", function()
	if ZVox.IsEscapeMenuOpen() then
		return
	end

	local eyeTrace = ZVox.GetEyeTrace()
	if eyeTrace["Hit"] then
		local dist = eyeTrace["Dist"]
		if dist <= 1 then
			local voxID = eyeTrace["VoxelID"]
			local voxName = ZVox.GetVoxelName(voxID)
			if ZVox.IsVoxelInteractable(voxName) then
				ZVox.CallVoxelOnInteract(voxName)
				return
			end
		end
	end


	ZVox.OpenInventory()
end)