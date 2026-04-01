ZVox = ZVox or {}

ZVox.CamPos = Vector(0, 0, 0)
ZVox.CamAng = Angle(0, 0, 0)
ZVox.CamFOV = 90
ZVox.ViewmodelFOV = 90

ZVox.CamNearZ = 0.01
ZVox.CamFarZ = 1000

function ZVox.SetCamPos(pos)
	ZVox.CamPos = pos
end

function ZVox.GetCamPos()
	return ZVox.CamPos
end

function ZVox.SetCamAng(ang)
	ZVox.CamAng = ang
end

function ZVox.GetCamAng()
	return ZVox.CamAng
end

function ZVox.GetCamForward()
	return ZVox.CamAng:Forward()
end

function ZVox.GetCamFOV()
	return ZVox.CamFOV
end

function ZVox.GetCamZDistances()
	return ZVox.CamNearZ, ZVox.CamFarZ
end

function ZVox.GetCamChunkIndex()
	local camPos = ZVox.GetCamPos()
	local chunkIdx = ZVox.WorldToChunkIndex(ZVox.GetActiveUniverse(), camPos[1], camPos[2], camPos[3])

	return chunkIdx
end