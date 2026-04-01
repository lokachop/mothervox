ZVox = ZVox or {}


local cBorder = 32
local bSize = 1
local rtTexHighlight, matTexHighlightOk = ZVox.NewRTMatPairAlpha("zvox_voxel_highlight", 64, 64, function()
	render.Clear(0, 0, 0, 0, true, true)

	surface.SetDrawColor(cBorder, 255, cBorder, 220)
	surface.DrawRect(0, 0         , 64, bSize)
	surface.DrawRect(0, 64 - bSize, 64, bSize)

	surface.DrawRect(0         , 0, bSize, 64)
	surface.DrawRect(64 - bSize, 0, bSize, 64)
end)

local rtTexHighlight, matTexHighlightNo = ZVox.NewRTMatPairAlpha("zvox_voxel_highlight_no", 64, 64, function()
	render.Clear(0, 0, 0, 0, true, true)

	surface.SetDrawColor(255, cBorder, cBorder, 220)
	surface.DrawRect(0, 0         , 64, bSize)
	surface.DrawRect(0, 64 - bSize, 64, bSize)

	surface.DrawRect(0         , 0, bSize, 64)
	surface.DrawRect(64 - bSize, 0, bSize, 64)
end)

local rtTexHighlight, matTexHighlightInteract = ZVox.NewRTMatPairAlpha("zvox_voxel_highlight_interact", 64, 64, function()
	render.Clear(0, 0, 0, 0, true, true)

	surface.SetDrawColor(255, 255, cBorder, 220)
	surface.DrawRect(0, 0         , 64, bSize)
	surface.DrawRect(0, 64 - bSize, 64, bSize)

	surface.DrawRect(0         , 0, bSize, 64)
	surface.DrawRect(64 - bSize, 0, bSize, 64)
end)



local meshHighFront, meshHighBack = ZVox.GetCubeMeshFlippedPairs(Vector(.5, .5, .5), Vector(.51, .51, .51))

local wfAdd = .0125
local h_wfAdd = wfAdd * .5
local cubeMeshWF = ZVox.GetCubeLineMesh(Vector(-h_wfAdd, -h_wfAdd, -h_wfAdd), Vector(1 + wfAdd, 1 + wfAdd, 1 + wfAdd), 0, 0, 0)

local highlightCanDig = false
function ZVox.SetVoxelHighlightCanDig(canDig)
	highlightCanDig = canDig
end

local highlightCanInteract = false
function ZVox.SetVoxelHighlightCanInteract(canInteract)
	highlightCanInteract = canInteract
end

local highlightPos = Vector(0, 0, 0)
local matrixHighlight = Matrix()
function ZVox.SetVoxelHighlightPos(posWorld)
	highlightPos = posWorld
end

local shouldDraw = false
function ZVox.SetVoxelHighlightShouldRender(bool)
	shouldDraw = bool
end

local aabbs = {}
function ZVox.SetVoxelHighlightIDState(voxID, voxState)
	aabbs = ZVox.GetVoxelAABBList(voxID, voxState)
end

local _whiteRT, _whiteMat = ZVox.NewRTMatPair("white_rt_notex", 4, 4, function()
	render.Clear(255, 255, 255, 255)
end)


local sclAccum = Vector(1, 1, 1)
local trsAccum = Vector(0, 0, 0)
function ZVox.RenderVoxelHighlight()
	if not shouldDraw then
		return
	end

	if ZVox.GetCameraModeState() then
		return
	end

	render.SetMaterial(highlightCanDig and matTexHighlightOk or matTexHighlightNo)
	--render.SetMaterial(_whiteMat)

	if highlightCanInteract then
		render.SetMaterial(matTexHighlightInteract)
	end

	for i = 1, #aabbs do
		local aabb = aabbs[i]
		local minX = aabb[1]
		local minY = aabb[2]
		local minZ = aabb[3]

		local maxX = aabb[4]
		local maxY = aabb[5]
		local maxZ = aabb[6]

		local aabbScale

		matrixHighlight:Identity()

		sclAccum:SetUnpacked(maxX - minX, maxY - minY, maxZ - minZ)
		matrixHighlight:SetScale(sclAccum)

		trsAccum:SetUnpacked(highlightPos[1] + minX, highlightPos[2] + minY, highlightPos[3] + minZ)
		matrixHighlight:SetTranslation(trsAccum)

		cam.PushModelMatrix(matrixHighlight, true)
			--cubeMeshWF:Draw()
			meshHighBack:Draw()
			meshHighFront:Draw()
		cam.PopModelMatrix()
	end
end