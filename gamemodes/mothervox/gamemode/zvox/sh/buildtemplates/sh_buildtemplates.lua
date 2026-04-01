ZVox = ZVox or {}

file.CreateDir("zvox/mv_build_templates")

function ZVox.SaveBuildTemplate(univ, name, mX, mY, mZ, eX, eY, eZ)
	ZVox.PrintInfo("Saving buildtemplate \"" .. name .. "\"!")


	local startX = math.min(mX, eX)
	local startY = math.min(mY, eY)
	local startZ = math.min(mZ, eZ)

	local endX = math.max(mX, eX)
	local endY = math.max(mY, eY)
	local endZ = math.max(mZ, eZ)

	local sX = endX - startX
	local sY = endY - startY
	local sZ = endZ - startZ


	local fBuffOut = ZVox.FB_NewFileBuffer()
	ZVox.FB_Write(fBuffOut, "BTMP")
	ZVox.FB_WriteUShort(fBuffOut, sX)
	ZVox.FB_WriteUShort(fBuffOut, sY)
	ZVox.FB_WriteUShort(fBuffOut, sZ)

	-- write an equivalence table
	local voxelsWeUse = {}
	local voxelsWeUseLUT = {}
	local weUseIdx = 1

	for x = startX, endX do
		for y = startY, endY do
			for z = startZ, endZ do
				local voxID, voxState = ZVox.GetBlockAtPos(univ, x, y, z)
				local voxName = ZVox.GetVoxelName(voxID)

				if not voxelsWeUseLUT[voxName] then
					voxelsWeUseLUT[voxName] = weUseIdx
					weUseIdx = weUseIdx + 1

					voxelsWeUse[#voxelsWeUse + 1] = voxName
				end
			end
		end
	end

	ZVox.FB_WriteULong(fBuffOut, #voxelsWeUse)
	for i = 1, #voxelsWeUse do
		local name = voxelsWeUse[i]
		ZVox.FB_WriteString(fBuffOut, name)
		ZVox.FB_WriteULong(fBuffOut, voxelsWeUseLUT[name])
	end

	-- now dump the voxels
	for x = startX, endX do
		for y = startY, endY do
			for z = startZ, endZ do
				local voxID, voxState = ZVox.GetBlockAtPos(univ, x, y, z)
				local voxName = ZVox.GetVoxelName(voxID)

				local truVoxID = voxelsWeUseLUT[voxName]

				ZVox.FB_WriteUShort(fBuffOut, truVoxID)
				ZVox.FB_WriteUShort(fBuffOut, voxState)
			end
		end
	end


	local luaStr = util.Base64Encode(util.Compress(ZVox.FB_GetContents(fBuffOut)), true)

	ZVox.FB_Close(fBuffOut)

	file.Write("zvox/mv_build_templates/" .. name .. ".txt", luaStr)

	ZVox.PrintInfo("...done.")
end

-- x, y, z need to be the min x, y, z loka
function ZVox.LoadBuildTemplate(univ, params, templateStr)
	local fBuff = ZVox.FB_NewFileBufferFromData(util.Decompress(util.Base64Decode(templateStr)))

	local magic = ZVox.FB_Read(fBuff, 4)
	if magic ~= "BTMP" then
		ZVox.FB_Close(fBuff)
		ZVox.PrintError("Magic doesn't match for a buildtemplate.")
		return
	end

	local sX = ZVox.FB_ReadUShort(fBuff)
	local sY = ZVox.FB_ReadUShort(fBuff)
	local sZ = ZVox.FB_ReadUShort(fBuff)

	local startX = params.x
	local startY = params.y
	local startZ = params.z

	local endX = startX + sX
	local endY = startY + sY
	local endZ = startZ + sZ

	local convTable = {}
	for i = 1, ZVox.FB_ReadULong(fBuff) do
		local name = ZVox.FB_ReadString(fBuff)
		local localID = ZVox.FB_ReadULong(fBuff)

		convTable[localID] = ZVox.GetVoxelID(name)
	end


	local airIgnore = params.airIgnore
	for x = startX, endX do
		for y = startY, endY do
			for z = startZ, endZ do
				local voxID = ZVox.FB_ReadUShort(fBuff)
				local voxState = ZVox.FB_ReadUShort(fBuff)

				local truID = convTable[voxID]

				if airIgnore and truID == 0 then
					continue
				end

				ZVox.SetBlockAtPos(univ, x, y, z, truID, voxState)
			end
		end
	end

	ZVox.FB_Close(fBuff)
end


if CLIENT then
	concommand.Add("mothervox_save_build_template", function (ply, cmd, args, argStr)
		if SERVER then
			return
		end

		if not args then
			return
		end

		local name = args[1]
		if not name then
			ZVox.CommandErrorNotify("mothervox_save_build_template <name> <mX> <mY> <mZ> <eX> <eY> <eZ>")
			return
		end

		local mX = tonumber(args[2])
		if not mX then
			ZVox.CommandErrorNotify("mothervox_save_build_template <name> <mX> <mY> <mZ> <eX> <eY> <eZ>")
			return
		end

		local mY = tonumber(args[3])
		if not mY then
			ZVox.CommandErrorNotify("mothervox_save_build_template <name> <mX> <mY> <mZ> <eX> <eY> <eZ>")
			return
		end

		local mZ = tonumber(args[4])
		if not mZ then
			ZVox.CommandErrorNotify("mothervox_save_build_template <name> <mX> <mY> <mZ> <eX> <eY> <eZ>")
			return
		end

		local eX = tonumber(args[5])
		if not eX then
			ZVox.CommandErrorNotify("mothervox_save_build_template <name> <mX> <mY> <mZ> <eX> <eY> <eZ>")
			return
		end

		local eY = tonumber(args[6])
		if not eY then
			ZVox.CommandErrorNotify("mothervox_save_build_template <name> <mX> <mY> <mZ> <eX> <eY> <eZ>")
			return
		end


		local eZ = tonumber(args[7])
		if not eZ then
			ZVox.CommandErrorNotify("mothervox_save_build_template <name> <mX> <mY> <mZ> <eX> <eY> <eZ>")
			return
		end

		ZVox.SaveBuildTemplate(ZVox.GetActiveUniverse(), name, mX, mY, mZ, eX, eY, eZ)
	end)

end