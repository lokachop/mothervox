ZVox = ZVox or {}

function ZVox.TransmitChunks(chunks, ply, baseIdx)
	if not chunks then
		return
	end
	if #chunks < 1 then
		return
	end

	net.Start("zvox_sendchunks")
		-- first write base idx
		net.WriteUInt(baseIdx, 32)

		-- then write count
		local chunkCount = #chunks
		net.WriteUInt(chunkCount, 32)

		for i = 1, chunkCount do
			local chunkData = chunks[i]

			-- now we serialize and compress the voxeldata
			local compData = chunkData[1]

			-- then we send it, with its size
			net.WriteUInt(#compData, 32)
			net.WriteData(compData)

			-- voxelstate now
			local compState = chunkData[2]

			-- then we send it, with its size
			net.WriteUInt(#compState, 32)
			net.WriteData(compState)
		end
	net.Send(ply)
end